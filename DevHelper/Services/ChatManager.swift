// Copyright 2025 Hengfei Yang.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import Foundation
import SwiftUI

@Observable
class ChatManager {
    var chatSessions: [ChatSession] = []
    private let storage = ChatStorage()
    private let chatAPI = ChatCompletionsAPI()
    private let responsesAPI = ResponsesAPI()
    
    // MARK: - Session Management
    
    func loadChatSessions() {
        chatSessions = storage.loadChatSessions()
    }
    
    func createNewChat() -> ChatSession {
        let session = ChatSession()
        chatSessions.insert(session, at: 0)
        storage.saveChatSession(session)
        return session
    }
    
    func deleteChat(_ session: ChatSession) {
        for message in session.messages where message.contentType == .image {
            if let localPath = message.localImagePath {
                ImageStorageService.shared.deleteImage(at: localPath)
            }
        }
        
        chatSessions.removeAll { $0.id == session.id }
        storage.deleteChatSession(session.id)
    }
    
    func duplicateChat(_ session: ChatSession) -> ChatSession {
        var duplicated = session
        duplicated = ChatSession(
            title: "\(session.title) (Copy)",
            selectedModel: session.selectedModel
        )
        let userAndAssistantMessages = session.messages.filter { $0.role != .system }
        for message in userAndAssistantMessages {
            let copiedMessage = ChatMessage(
                role: message.role,
                content: message.content,
                contentType: message.contentType,
                imageURL: message.imageURL,
                localImagePath: message.localImagePath,
                imagePrompt: message.imagePrompt
            )
            duplicated.addMessage(copiedMessage)
        }
        
        chatSessions.insert(duplicated, at: 0)
        storage.saveChatSession(duplicated)
        return duplicated
    }
    
    func renameChat(_ session: ChatSession, to title: String) {
        if let index = chatSessions.firstIndex(where: { $0.id == session.id }) {
            chatSessions[index].updateTitle(title)
            storage.saveChatSession(chatSessions[index])
        }
    }
    
    func updateSessionTool(at index: Int, tool: ChatToolMode) {
        guard index < chatSessions.count else { return }
        
        var updatedSession = chatSessions[index]
        updatedSession.selectedTool = tool
        updatedSession.updatedAt = Date()
        
        chatSessions[index] = updatedSession
        storage.saveChatSession(updatedSession)
    }
    
    // MARK: - Message Handling
    
    func sendMessage(
        _ content: String,
        in sessionId: UUID,
        with settings: AISettings,
        isLoading: Binding<Bool>,
        errorMessage: Binding<String?>
    ) async {
        guard let sessionIndex = await MainActor.run(body: {
            chatSessions.firstIndex(where: { $0.id == sessionId })
        }) else {
            await MainActor.run {
                errorMessage.wrappedValue = "Chat session not found."
                isLoading.wrappedValue = false
            }
            return
        }
        
        let userMessage = ChatMessage(role: .user, content: content)
        await MainActor.run {
            chatSessions[sessionIndex].addMessage(userMessage)
            storage.saveChatSession(chatSessions[sessionIndex])
            isLoading.wrappedValue = true
            errorMessage.wrappedValue = nil
        }
        
        let model = await MainActor.run { chatSessions[sessionIndex].selectedModel ?? settings.defaultModel }
        
        guard let apiKey = settings.getOpenAIAPIKey(), !apiKey.isEmpty else {
            await MainActor.run {
                errorMessage.wrappedValue = "No OpenAI API key configured. Please add your API key in settings."
                isLoading.wrappedValue = false
            }
            return
        }
        
        let currentMessages = await MainActor.run { chatSessions[sessionIndex].messages }
        
        let streamingMessage = ChatMessage(role: .assistant, content: "", isStreaming: true)
        await MainActor.run {
            chatSessions[sessionIndex].messages.append(streamingMessage)
        }
        
        let streamingMessageIndex = await MainActor.run { 
            chatSessions[sessionIndex].messages.count - 1 
        }
        
        await chatAPI.sendMessage(
            messages: currentMessages,
            model: model,
            apiKey: apiKey,
            baseURL: settings.apiGatewayURL,
            onToken: { [weak self] token in
                guard let self = self else { return }
                
                if let sessionIdx = self.chatSessions.firstIndex(where: { $0.id == sessionId }),
                   streamingMessageIndex < self.chatSessions[sessionIdx].messages.count {
                    self.chatSessions[sessionIdx].messages[streamingMessageIndex].content += token
                }
            },
            onComplete: { [weak self] in
                guard let self = self else { return }
                
                if let sessionIdx = self.chatSessions.firstIndex(where: { $0.id == sessionId }),
                   streamingMessageIndex < self.chatSessions[sessionIdx].messages.count {
                    self.chatSessions[sessionIdx].messages[streamingMessageIndex].isStreaming = false
                    self.chatSessions[sessionIdx].updatedAt = Date()
                    self.storage.saveChatSession(self.chatSessions[sessionIdx])
                }
                
                isLoading.wrappedValue = false
            },
            onError: { error in
                Task { @MainActor in
                    if let sessionIdx = self.chatSessions.firstIndex(where: { $0.id == sessionId }),
                       streamingMessageIndex < self.chatSessions[sessionIdx].messages.count {
                        self.chatSessions[sessionIdx].messages.remove(at: streamingMessageIndex)
                    }
                }
                
                errorMessage.wrappedValue = "Failed to send message: \(error.localizedDescription)"
                isLoading.wrappedValue = false
            }
        )
    }
    
    func sendMessageWithImages(
        _ content: String,
        images: [ChatMessageImage],
        in sessionId: UUID,
        with settings: AISettings,
        isLoading: Binding<Bool>,
        errorMessage: Binding<String?>
    ) async {
        guard let sessionIndex = await MainActor.run(body: {
            chatSessions.firstIndex(where: { $0.id == sessionId })
        }) else {
            await MainActor.run {
                errorMessage.wrappedValue = "Chat session not found."
                isLoading.wrappedValue = false
            }
            return
        }
        
        let userMessage = ChatMessage(role: .user, content: content, images: images)
        await MainActor.run {
            chatSessions[sessionIndex].addMessage(userMessage)
            storage.saveChatSession(chatSessions[sessionIndex])
            isLoading.wrappedValue = true
            errorMessage.wrappedValue = nil
        }
        
        let model = await MainActor.run { chatSessions[sessionIndex].selectedModel ?? settings.defaultModel }
        
        guard let apiKey = settings.getOpenAIAPIKey(), !apiKey.isEmpty else {
            await MainActor.run {
                errorMessage.wrappedValue = "No OpenAI API key configured. Please add your API key in settings."
                isLoading.wrappedValue = false
            }
            return
        }
        
        let currentMessages = await MainActor.run { chatSessions[sessionIndex].messages }
        
        let streamingMessage = ChatMessage(role: .assistant, content: "", isStreaming: true)
        await MainActor.run {
            chatSessions[sessionIndex].messages.append(streamingMessage)
        }
        
        let streamingMessageIndex = await MainActor.run {
            chatSessions[sessionIndex].messages.count - 1
        }
        
        await chatAPI.sendMessage(
            messages: currentMessages,
            model: model,
            apiKey: apiKey,
            baseURL: settings.apiGatewayURL,
            onToken: { [weak self] token in
                guard let self = self else { return }
                
                if streamingMessageIndex < self.chatSessions[sessionIndex].messages.count {
                    self.chatSessions[sessionIndex].messages[streamingMessageIndex].content += token
                }
            },
            onComplete: { [weak self] in
                guard let self = self else { return }
                
                if streamingMessageIndex < self.chatSessions[sessionIndex].messages.count {
                    self.chatSessions[sessionIndex].messages[streamingMessageIndex].isStreaming = false
                    self.chatSessions[sessionIndex].updatedAt = Date()
                    self.storage.saveChatSession(self.chatSessions[sessionIndex])
                }
                
                isLoading.wrappedValue = false
            },
            onError: { error in
                Task { @MainActor in
                    if streamingMessageIndex < self.chatSessions[sessionIndex].messages.count {
                        self.chatSessions[sessionIndex].messages.remove(at: streamingMessageIndex)
                    }
                }
                
                errorMessage.wrappedValue = "Failed to send vision message: \(error.localizedDescription)"
                isLoading.wrappedValue = false
            }
        )
    }
    
    func sendMessageWithTool(
        _ content: String,
        tool: ChatToolMode,
        in sessionId: UUID,
        with settings: AISettings,
        isLoading: Binding<Bool>,
        errorMessage: Binding<String?>
    ) async {
        switch tool {
        case .chat:
            await sendMessage(content, in: sessionId, with: settings, isLoading: isLoading, errorMessage: errorMessage)
            
        case .webSearch:
            await performWebSearch(content, in: sessionId, with: settings, isLoading: isLoading, errorMessage: errorMessage)
            
        case .imageGeneration:
            await generateImage(content, in: sessionId, with: settings, isLoading: isLoading, errorMessage: errorMessage)
        }
    }
    
    func sendMessageWithImagesAndTool(
        _ content: String,
        images: [ChatMessageImage],
        tool: ChatToolMode,
        in sessionId: UUID,
        with settings: AISettings,
        isLoading: Binding<Bool>,
        errorMessage: Binding<String?>
    ) async {
        switch tool {
        case .chat:
            await sendMessageWithImages(content, images: images, in: sessionId, with: settings, isLoading: isLoading, errorMessage: errorMessage)
            
        case .webSearch:
            await performWebSearch(content, in: sessionId, with: settings, isLoading: isLoading, errorMessage: errorMessage)
            
        case .imageGeneration:
            await generateImageWithReferenceImages(content, referenceImages: images, in: sessionId, with: settings, isLoading: isLoading, errorMessage: errorMessage)
        }
    }
    
    // MARK: - Web Search
    
    private func performWebSearch(
        _ query: String,
        in sessionId: UUID,
        with settings: AISettings,
        isLoading: Binding<Bool>,
        errorMessage: Binding<String?>
    ) async {
        guard let sessionIndex = await MainActor.run(body: {
            chatSessions.firstIndex(where: { $0.id == sessionId })
        }) else {
            await MainActor.run {
                errorMessage.wrappedValue = "Chat session not found."
                isLoading.wrappedValue = false
            }
            return
        }
        
        let userMessage = ChatMessage(role: .user, content: query)
        await MainActor.run {
            chatSessions[sessionIndex].addMessage(userMessage)
            storage.saveChatSession(chatSessions[sessionIndex])
            isLoading.wrappedValue = true
            errorMessage.wrappedValue = nil
        }
        
        let model = await MainActor.run { chatSessions[sessionIndex].selectedModel ?? settings.defaultModel }
        
        guard let apiKey = settings.getOpenAIAPIKey(), !apiKey.isEmpty else {
            await MainActor.run {
                errorMessage.wrappedValue = "No OpenAI API key configured. Please add your API key in settings."
                isLoading.wrappedValue = false
            }
            return
        }
        
        let streamingMessage = ChatMessage(role: .assistant, content: "", isStreaming: true)
        await MainActor.run {
            chatSessions[sessionIndex].messages.append(streamingMessage)
        }
        
        let streamingMessageIndex = await MainActor.run {
            chatSessions[sessionIndex].messages.count - 1
        }
        
        do {
            let result = try await responsesAPI.performWebSearch(
                query: query,
                model: model,
                apiKey: apiKey,
                baseURL: settings.apiGatewayURL
            )
            
            await MainActor.run {
                if streamingMessageIndex < chatSessions[sessionIndex].messages.count {
                    chatSessions[sessionIndex].messages[streamingMessageIndex].content = result
                    chatSessions[sessionIndex].messages[streamingMessageIndex].isStreaming = false
                    chatSessions[sessionIndex].updatedAt = Date()
                    storage.saveChatSession(chatSessions[sessionIndex])
                }
                
                isLoading.wrappedValue = false
            }
            
        } catch {
            await MainActor.run {
                errorMessage.wrappedValue = "Failed to perform web search: \(error.localizedDescription)"
                isLoading.wrappedValue = false
                
                if streamingMessageIndex < chatSessions[sessionIndex].messages.count {
                    chatSessions[sessionIndex].messages.remove(at: streamingMessageIndex)
                }
            }
        }
    }
    
    // MARK: - Image Generation
    
    private func generateImage(
        _ prompt: String,
        in sessionId: UUID,
        with settings: AISettings,
        isLoading: Binding<Bool>,
        errorMessage: Binding<String?>
    ) async {
        guard let sessionIndex = await MainActor.run(body: {
            chatSessions.firstIndex(where: { $0.id == sessionId })
        }) else {
            await MainActor.run {
                errorMessage.wrappedValue = "Chat session not found."
                isLoading.wrappedValue = false
            }
            return
        }
        
        let userMessage = ChatMessage(role: .user, content: prompt)
        await MainActor.run {
            chatSessions[sessionIndex].addMessage(userMessage)
            storage.saveChatSession(chatSessions[sessionIndex])
            isLoading.wrappedValue = true
            errorMessage.wrappedValue = nil
        }
        
        let model = await MainActor.run { chatSessions[sessionIndex].selectedModel ?? settings.defaultModel }
        
        guard let apiKey = settings.getOpenAIAPIKey(), !apiKey.isEmpty else {
            await MainActor.run {
                errorMessage.wrappedValue = "No OpenAI API key configured. Please add your API key in settings."
                isLoading.wrappedValue = false
            }
            return
        }
        
        let imageMessage = ChatMessage(
            role: .assistant,
            content: "Generating image...",
            isStreaming: true,
            contentType: .image,
            imagePrompt: prompt
        )
        
        await MainActor.run {
            chatSessions[sessionIndex].messages.append(imageMessage)
        }
        
        do {
            let (imageURL, responseId) = try await responsesAPI.generateImage(
                prompt: prompt,
                model: model,
                apiKey: apiKey,
                baseURL: settings.apiGatewayURL
            )
            
            guard let messageId = await MainActor.run(body: {
                if let lastIndex = chatSessions[sessionIndex].messages.lastIndex(where: { $0.contentType == .image && $0.isStreaming }) {
                    return chatSessions[sessionIndex].messages[lastIndex].id
                }
                return nil
            }) else {
                await MainActor.run {
                    errorMessage.wrappedValue = "Failed to find image message"
                    isLoading.wrappedValue = false
                }
                return
            }
            
            let localImagePath: String?
            do {
                localImagePath = try await ImageStorageService.shared.saveBase64Image(imageURL, messageId: messageId)
            } catch {
                localImagePath = nil
            }
            
            await MainActor.run {
                if let lastIndex = chatSessions[sessionIndex].messages.lastIndex(where: { $0.contentType == .image && $0.isStreaming }) {
                    chatSessions[sessionIndex].messages[lastIndex].content = "Generated image for: \"\(prompt)\""
                    chatSessions[sessionIndex].messages[lastIndex].imageURL = imageURL
                    chatSessions[sessionIndex].messages[lastIndex].localImagePath = localImagePath
                    chatSessions[sessionIndex].messages[lastIndex].responseId = responseId
                    chatSessions[sessionIndex].messages[lastIndex].isStreaming = false
                    chatSessions[sessionIndex].updatedAt = Date()
                    
                    storage.saveChatSession(chatSessions[sessionIndex])
                }
                
                isLoading.wrappedValue = false
            }
            
        } catch {
            await MainActor.run {
                errorMessage.wrappedValue = "Failed to generate image: \(error.localizedDescription)"
                isLoading.wrappedValue = false
                
                if let lastIndex = chatSessions[sessionIndex].messages.lastIndex(where: { $0.contentType == .image && $0.isStreaming }) {
                    chatSessions[sessionIndex].messages.remove(at: lastIndex)
                }
            }
        }
    }
    
    private func generateImageWithReferenceImages(
        _ prompt: String,
        referenceImages: [ChatMessageImage],
        in sessionId: UUID,
        with settings: AISettings,
        isLoading: Binding<Bool>,
        errorMessage: Binding<String?>
    ) async {
        guard let sessionIndex = await MainActor.run(body: {
            chatSessions.firstIndex(where: { $0.id == sessionId })
        }) else {
            await MainActor.run {
                errorMessage.wrappedValue = "Chat session not found."
                isLoading.wrappedValue = false
            }
            return
        }
        
        let userMessage = ChatMessage(role: .user, content: prompt, images: referenceImages)
        await MainActor.run {
            chatSessions[sessionIndex].addMessage(userMessage)
            storage.saveChatSession(chatSessions[sessionIndex])
            isLoading.wrappedValue = true
            errorMessage.wrappedValue = nil
        }
        
        let model = await MainActor.run { chatSessions[sessionIndex].selectedModel ?? settings.defaultModel }
        
        guard let apiKey = settings.getOpenAIAPIKey(), !apiKey.isEmpty else {
            await MainActor.run {
                errorMessage.wrappedValue = "No OpenAI API key configured. Please add your API key in settings."
                isLoading.wrappedValue = false
            }
            return
        }
        
        let imageMessage = ChatMessage(
            role: .assistant,
            content: "Generating image with reference images...",
            isStreaming: true,
            contentType: .image,
            imagePrompt: prompt
        )
        
        await MainActor.run {
            chatSessions[sessionIndex].messages.append(imageMessage)
        }
        
        do {
            let (imageURL, responseId) = try await responsesAPI.generateImageWithReferenceImages(
                prompt: prompt,
                referenceImages: referenceImages,
                model: model,
                apiKey: apiKey,
                baseURL: settings.apiGatewayURL
            )
            
            guard let messageId = await MainActor.run(body: {
                if let lastIndex = chatSessions[sessionIndex].messages.lastIndex(where: { $0.contentType == .image && $0.isStreaming }) {
                    return chatSessions[sessionIndex].messages[lastIndex].id
                }
                return nil
            }) else {
                await MainActor.run {
                    errorMessage.wrappedValue = "Failed to find image message"
                    isLoading.wrappedValue = false
                }
                return
            }
            
            let localImagePath: String?
            do {
                localImagePath = try await ImageStorageService.shared.saveBase64Image(imageURL, messageId: messageId)
            } catch {
                localImagePath = nil
            }
            
            await MainActor.run {
                if let lastIndex = chatSessions[sessionIndex].messages.lastIndex(where: { $0.contentType == .image && $0.isStreaming }) {
                    let referenceCount = referenceImages.count
                    chatSessions[sessionIndex].messages[lastIndex].content = "Generated image for: \"\(prompt)\" using \(referenceCount) reference image\(referenceCount == 1 ? "" : "s")"
                    chatSessions[sessionIndex].messages[lastIndex].imageURL = imageURL
                    chatSessions[sessionIndex].messages[lastIndex].localImagePath = localImagePath
                    chatSessions[sessionIndex].messages[lastIndex].responseId = responseId
                    chatSessions[sessionIndex].messages[lastIndex].isStreaming = false
                    chatSessions[sessionIndex].updatedAt = Date()
                    
                    storage.saveChatSession(chatSessions[sessionIndex])
                }
                
                isLoading.wrappedValue = false
            }
            
        } catch {
            await MainActor.run {
                errorMessage.wrappedValue = "Failed to generate image: \(error.localizedDescription)"
                isLoading.wrappedValue = false
                
                if let lastIndex = chatSessions[sessionIndex].messages.lastIndex(where: { $0.contentType == .image && $0.isStreaming }) {
                    chatSessions[sessionIndex].messages.remove(at: lastIndex)
                }
            }
        }
    }
}

// MARK: - Chat Storage

class ChatStorage {
    private let fileManager = FileManager.default
    private let documentsDirectory: URL
    
    init() {
        documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        createDirectoryIfNeeded()
    }
    
    private func createDirectoryIfNeeded() {
        let chatDirectory = documentsDirectory.appendingPathComponent("DevHelper/AIChats")
        try? fileManager.createDirectory(at: chatDirectory, withIntermediateDirectories: true)
    }
    
    private var chatDirectory: URL {
        documentsDirectory.appendingPathComponent("DevHelper/AIChats")
    }
    
    func loadChatSessions() -> [ChatSession] {
        do {
            let fileURLs = try fileManager.contentsOfDirectory(
                at: chatDirectory,
                includingPropertiesForKeys: [.contentModificationDateKey],
                options: [.skipsHiddenFiles]
            )
            
            let chatFiles = fileURLs.filter { $0.pathExtension == "json" }
            
            var sessions: [ChatSession] = []
            
            for fileURL in chatFiles {
                if let data = try? Data(contentsOf: fileURL),
                   let session = try? JSONDecoder().decode(ChatSession.self, from: data) {
                    sessions.append(session)
                }
            }
            
            sessions.sort { $0.updatedAt > $1.updatedAt }
            
            return sessions
        } catch {
            print("Failed to load chat sessions: \(error)")
            return []
        }
    }
    
    func saveChatSession(_ session: ChatSession) {
        do {
            let data = try JSONEncoder().encode(session)
            let fileURL = chatDirectory.appendingPathComponent("\(session.id.uuidString).json")
            try data.write(to: fileURL)
        } catch {
            print("Failed to save chat session: \(error)")
        }
    }
    
    func deleteChatSession(_ sessionId: UUID) {
        let fileURL = chatDirectory.appendingPathComponent("\(sessionId.uuidString).json")
        try? fileManager.removeItem(at: fileURL)
    }
}

// MARK: - API Error Types

enum APIError: LocalizedError {
    case invalidResponse
    case invalidJSON
    case httpError(Int, String)
    case missingAPIKey
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from AI service"
        case .invalidJSON:
            return "Invalid JSON response"
        case .httpError(let code, let message):
            return "HTTP Error \(code): \(message)"
        case .missingAPIKey:
            return "Missing OpenAI API key"
        }
    }
}

// MARK: - Chat Completions API

class ChatCompletionsAPI {
    private let session = URLSession.shared
    
    func sendMessage(
        messages: [ChatMessage],
        model: AIModel,
        apiKey: String,
        baseURL: String = OpenAIConfig.baseURL,
        onToken: @escaping (String) -> Void,
        onComplete: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) async {
        do {
            let url = URL(string: "\(baseURL)/chat/completions")!
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let openAIMessages = messages.map { message -> [String: Any] in
                if message.hasImages {
                    var content: [[String: Any]] = []
                    
                    if !message.content.isEmpty {
                        content.append([
                            "type": "text",
                            "text": message.content
                        ])
                    }
                    
                    for image in message.images {
                        if let imageURL = image.base64ImageURL {
                            content.append([
                                "type": "image_url",
                                "image_url": [
                                    "url": imageURL
                                ]
                            ])
                        }
                    }
                    
                    if message.images.isEmpty, let legacyImageURL = message.base64ImageURL {
                        content.append([
                            "type": "image_url",
                            "image_url": [
                                "url": legacyImageURL
                            ]
                        ])
                    }
                    
                    return [
                        "role": message.role.rawValue,
                        "content": content
                    ]
                } else {
                    return [
                        "role": message.role.rawValue,
                        "content": message.content
                    ]
                }
            }
            
            let requestBody: [String: Any] = [
                "model": model.name,
                "messages": openAIMessages,
                "stream": true,
                "max_tokens": model.maxTokens
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await session.bytes(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run { onError(APIError.invalidResponse) }
                return
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                let errorData = try await data.reduce(into: Data()) { $0.append($1) }
                let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                await MainActor.run { onError(APIError.httpError(httpResponse.statusCode, errorMessage)) }
                return
            }
            
            for try await line in data.lines {
                guard !line.isEmpty, line.hasPrefix("data: ") else { continue }
                
                let jsonString = String(line.dropFirst(6))
                
                if jsonString == "[DONE]" {
                    await MainActor.run { onComplete() }
                    break
                }
                
                guard let jsonData = jsonString.data(using: .utf8),
                      let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                      let choices = json["choices"] as? [[String: Any]],
                      let firstChoice = choices.first,
                      let delta = firstChoice["delta"] as? [String: Any],
                      let content = delta["content"] as? String else {
                    continue
                }
                
                await MainActor.run { onToken(content) }
            }
            
        } catch {
            await MainActor.run { onError(error) }
        }
    }
}

// MARK: - Responses API

class ResponsesAPI {
    private let session = URLSession.shared
    
    func generateImage(
        prompt: String,
        model: AIModel,
        apiKey: String,
        baseURL: String = OpenAIConfig.baseURL,
        previousResponseId: String? = nil
    ) async throws -> (imageURL: String, responseId: String) {
        let url = URL(string: "\(baseURL)/responses")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var requestBody: [String: Any] = [
            "model": model.name,
            "input": prompt,
            "tools": [[
                "type": "image_generation"
            ]]
        ]
        
        if let previousId = previousResponseId {
            requestBody["previous_response_id"] = previousId
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 600.0
        config.timeoutIntervalForResource = 600.0
        let customSession = URLSession(configuration: config)
        
        let (data, response) = try await customSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode != 200 {
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorData["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw NSError(domain: "OpenAIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error \(httpResponse.statusCode): \(message)"])
            } else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw NSError(domain: "OpenAIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error \(httpResponse.statusCode): \(errorMessage)"])
            }
        }
        
        guard let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let output = jsonResponse["output"] as? [[String: Any]],
              let responseId = jsonResponse["id"] as? String else {
            throw NSError(domain: "OpenAIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
        }
        
        for outputItem in output {
            if let type = outputItem["type"] as? String,
               type == "image_generation_call",
               let result = outputItem["result"] as? String {
                let imageURL = "data:image/png;base64,\(result)"
                return (imageURL: imageURL, responseId: responseId)
            }
        }
        
        throw NSError(domain: "OpenAIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No image generation result found in response"])
    }
    
    func generateImageWithReferenceImages(
        prompt: String,
        referenceImages: [ChatMessageImage],
        model: AIModel,
        apiKey: String,
        baseURL: String = OpenAIConfig.baseURL,
        previousResponseId: String? = nil
    ) async throws -> (imageURL: String, responseId: String) {
        let url = URL(string: "\(baseURL)/responses")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var inputContent: [[String: Any]] = []
        
        inputContent.append([
            "type": "input_text",
            "text": prompt
        ])
        
        var hasImage = false
        for attachment in referenceImages {
            if let base64URL = attachment.base64ImageURL {
                inputContent.append([
                    "type": "input_image",
                    "image_url": base64URL
                ])
                hasImage = true
            }
        }
        
        var requestBody: [String: Any] = [
            "model": model.name,
            "input": [
                [
                    "role": "user",
                    "content": inputContent
                ]
            ],
            "tools": [hasImage ? [
                "type": "image_generation"
            ] : []]
        ]
        
        if let previousId = previousResponseId {
            requestBody["previous_response_id"] = previousId
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 600.0
        config.timeoutIntervalForResource = 600.0
        let customSession = URLSession(configuration: config)
        
        let (data, response) = try await customSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode != 200 {
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorData["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw NSError(domain: "OpenAIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error \(httpResponse.statusCode): \(message)"])
            } else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw NSError(domain: "OpenAIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error \(httpResponse.statusCode): \(errorMessage)"])
            }
        }
        
        guard let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let output = jsonResponse["output"] as? [[String: Any]],
              let responseId = jsonResponse["id"] as? String else {
            throw NSError(domain: "OpenAIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
        }
        
        for outputItem in output {
            if let type = outputItem["type"] as? String,
               type == "image_generation_call",
               let result = outputItem["result"] as? String {
                let imageURL = "data:image/png;base64,\(result)"
                return (imageURL: imageURL, responseId: responseId)
            }
        }
        
        throw NSError(domain: "OpenAIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No image generation result found in response"])
    }
    
    func performWebSearch(
        query: String,
        model: AIModel,
        apiKey: String,
        baseURL: String = OpenAIConfig.baseURL
    ) async throws -> String {
        let url = URL(string: "\(baseURL)/responses")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": model.name,
            "input": query,
            "tools": [[
                "type": "web_search"
            ]]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60.0
        config.timeoutIntervalForResource = 60.0
        let customSession = URLSession(configuration: config)
        
        let (data, response) = try await customSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode != 200 {
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorData["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw NSError(domain: "OpenAIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error \(httpResponse.statusCode): \(message)"])
            } else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw NSError(domain: "OpenAIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error \(httpResponse.statusCode): \(errorMessage)"])
            }
        }
        
        guard let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let output = jsonResponse["output"] as? [[String: Any]] else {
            throw NSError(domain: "OpenAIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
        }

        print("🔍 Web Search Output: \(output)")
        
        // Look for message type with assistant role containing the search results
        for outputItem in output {
            if let type = outputItem["type"] as? String,
               type == "message",
               let role = outputItem["role"] as? String,
               role == "assistant",
               let content = outputItem["content"] as? [[String: Any]] {
                
                var combinedText = ""
                for contentItem in content {
                    if let contentType = contentItem["type"] as? String,
                       contentType == "output_text",
                       let text = contentItem["text"] as? String {
                        combinedText += text + "\n"
                    }
                }
                
                if !combinedText.isEmpty {
                    return combinedText.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        
        throw NSError(domain: "OpenAIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No web search result found in response"])
    }
}