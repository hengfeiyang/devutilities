// Copyright 2026 Hengfei Yang.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

import Foundation

/// The single runtime entry point for the two provider protocol families.
/// OpenAI's Responses endpoint remains an endpoint choice inside the
/// OpenAI-compatible family rather than becoming a third provider protocol.
final class AIChatRouter: @unchecked Sendable {
    private let chatCompletions = ChatCompletionsAPI()
    private let responses = ResponsesAPI()
    private let anthropic = AnthropicMessagesAPI()

    func cancelCurrentRequest() {
        chatCompletions.cancelCurrentRequest()
        responses.cancelCurrentRequest()
        anthropic.cancelCurrentRequest()
    }

    func sendMessage(
        messages: [ChatMessage],
        model: AIModelV2,
        apiProtocol: AIAPIProtocol,
        apiKey: String,
        baseURL: String,
        onToken: @escaping @Sendable (String) -> Void,
        onComplete: @escaping @Sendable () -> Void,
        onError: @escaping @Sendable (Error) -> Void,
        onReasoning: @escaping @Sendable (String) -> Void = { _ in },
        onUsage: @escaping @Sendable (TokenUsage) -> Void = { _ in }
    ) async {
        switch apiProtocol {
        case .openAICompatible:
            switch model.chatEndpoint {
            case .chatCompletions:
                await chatCompletions.sendMessage(
                    messages: messages,
                    modelId: model.modelId,
                    apiKey: apiKey,
                    baseURL: baseURL,
                    onToken: onToken,
                    onComplete: onComplete,
                    onError: onError,
                    onReasoning: onReasoning,
                    onUsage: onUsage
                )
            case .responses:
                await responses.sendChatMessage(
                    messages: messages,
                    modelId: model.modelId,
                    apiKey: apiKey,
                    baseURL: baseURL,
                    onToken: onToken,
                    onComplete: onComplete,
                    onError: onError,
                    onReasoning: onReasoning,
                    onUsage: onUsage
                )
            }
        case .anthropicMessages:
            await anthropic.sendMessage(
                messages: messages,
                modelId: model.modelId,
                maxTokens: model.capabilities.maxTokens,
                enableReasoning: model.capabilities.supportsReasoning,
                apiKey: apiKey,
                baseURL: baseURL,
                onToken: onToken,
                onComplete: onComplete,
                onError: onError,
                onReasoning: onReasoning,
                onUsage: onUsage
            )
        }
    }

    static func testConnection(
        provider: AIProvider,
        apiKey: String
    ) async throws -> (success: Bool, message: String?) {
        let url = try AIEndpointURL.make(baseURL: provider.baseURL, path: "models")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10

        switch provider.apiProtocol {
        case .openAICompatible:
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        case .anthropicMessages:
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
            request.setValue(AnthropicMessagesAPI.apiVersion, forHTTPHeaderField: "anthropic-version")
        }
        AICompatibilityHeaders.apply(to: &request)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            return (false, "Invalid HTTP response")
        }
        guard 200...299 ~= httpResponse.statusCode else {
            return (false, "HTTP \(httpResponse.statusCode): \(APIErrorParser.message(from: data))")
        }
        return (true, nil)
    }
}

enum AIEndpointURL {
    static func make(baseURL: String, path: String) throws -> URL {
        let trimmed = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let base = URL(string: trimmed),
              let scheme = base.scheme,
              ["http", "https"].contains(scheme.lowercased()),
              base.host != nil else {
            throw URLError(.badURL)
        }
        return base.appendingPathComponent(path)
    }
}

enum APIErrorParser {
    static func message(from data: Data) -> String {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return String(data: data, encoding: .utf8) ?? "Unknown error"
        }
        if let error = json["error"] as? [String: Any],
           let message = error["message"] as? String {
            return message
        }
        if let message = json["message"] as? String {
            return message
        }
        return "Unknown error"
    }
}

enum AICompatibilityHeaders {
    static func apply(to request: inout URLRequest) {
        if request.url?.host == "generativelanguage.googleapis.com" {
            request.setValue("devutilities/2.16.0", forHTTPHeaderField: "x-goog-api-client")
        }
    }
}

// MARK: - Anthropic Messages API

final class AnthropicMessagesAPI: @unchecked Sendable {
    static let apiVersion = "2023-06-01"

    private var currentTask: Task<Void, Never>?

    func cancelCurrentRequest() {
        currentTask?.cancel()
        currentTask = nil
    }

    func sendMessage(
        messages: [ChatMessage],
        modelId: String,
        maxTokens: Int,
        enableReasoning: Bool,
        apiKey: String,
        baseURL: String,
        onToken: @escaping @Sendable (String) -> Void,
        onComplete: @escaping @Sendable () -> Void,
        onError: @escaping @Sendable (Error) -> Void,
        onReasoning: @escaping @Sendable (String) -> Void = { _ in },
        onUsage: @escaping @Sendable (TokenUsage) -> Void = { _ in }
    ) async {
        do {
            let url = try AIEndpointURL.make(baseURL: baseURL, path: "messages")
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
            request.setValue(Self.apiVersion, forHTTPHeaderField: "anthropic-version")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            var body: [String: Any] = [
                "model": modelId,
                "max_tokens": max(1, maxTokens),
                "messages": Self.makeMessages(from: messages),
                "stream": true
            ]
            let systemPrompt = messages
                .filter { $0.role == .system }
                .map(\.content)
                .filter { !$0.isEmpty }
                .joined(separator: "\n\n")
            if !systemPrompt.isEmpty {
                body["system"] = systemPrompt
            }
            if enableReasoning {
                body["thinking"] = ["type": "adaptive", "display": "summarized"]
            }
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (bytes, response) = try await URLSession.shared.bytes(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run { onError(APIError.invalidResponse) }
                return
            }
            guard 200...299 ~= httpResponse.statusCode else {
                let data = try await bytes.reduce(into: Data()) { $0.append($1) }
                let message = APIErrorParser.message(from: data)
                await MainActor.run { onError(APIError.httpError(httpResponse.statusCode, message)) }
                return
            }

            var promptTokens = 0
            var completionTokens = 0
            var didComplete = false

            for try await line in bytes.lines {
                try Task.checkCancellation()
                guard line.hasPrefix("data: ") else { continue }
                let payload = String(line.dropFirst(6))
                guard payload != "[DONE]" else { continue }

                for event in AnthropicStreamCodec.decode(dataPayload: payload) {
                    switch event {
                    case .text(let text):
                        await MainActor.run { onToken(text) }
                    case .reasoning(let thinking):
                        await MainActor.run { onReasoning(thinking) }
                    case .inputTokens(let value):
                        promptTokens = value
                    case .outputTokens(let value):
                        completionTokens = value
                    case .completed:
                        let usage = TokenUsage(
                            promptTokens: promptTokens,
                            completionTokens: completionTokens,
                            totalTokens: promptTokens + completionTokens
                        )
                        await MainActor.run {
                            onUsage(usage)
                            onComplete()
                        }
                        didComplete = true
                    case .failure(let message):
                        await MainActor.run { onError(APIError.httpError(0, message)) }
                        return
                    }
                }

                if didComplete { break }
            }

            if !didComplete {
                await MainActor.run { onComplete() }
            }
        } catch {
            await MainActor.run { onError(error) }
        }
    }

    private static func makeMessages(from messages: [ChatMessage]) -> [[String: Any]] {
        messages.compactMap { message in
            guard message.role != .system else { return nil }

            if message.hasImages {
                var content: [[String: Any]] = []
                if !message.content.isEmpty {
                    content.append(["type": "text", "text": message.content])
                }

                let imageURLs = message.images.compactMap(\.base64ImageURL)
                    + (message.images.isEmpty ? [message.base64ImageURL].compactMap { $0 } : [])
                for imageURL in imageURLs {
                    if let source = imageSource(from: imageURL) {
                        content.append(["type": "image", "source": source])
                    }
                }
                return ["role": message.role.rawValue, "content": content]
            }

            return ["role": message.role.rawValue, "content": message.content]
        }
    }

    private static func imageSource(from value: String) -> [String: Any]? {
        if value.hasPrefix("data:"),
           let comma = value.firstIndex(of: ","),
           let semicolon = value.firstIndex(of: ";"),
           semicolon < comma {
            let mediaType = String(value[value.index(value.startIndex, offsetBy: 5)..<semicolon])
            let data = String(value[value.index(after: comma)...])
            return ["type": "base64", "media_type": mediaType, "data": data]
        }
        if value.hasPrefix("https://") || value.hasPrefix("http://") {
            return ["type": "url", "url": value]
        }
        return nil
    }
}
