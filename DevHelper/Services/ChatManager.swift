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
    private let openAIClient = OpenAIClient()
    
    // MARK: - Session Management
    
    func loadChatSessions() {
        chatSessions = storage.loadChatSessions()
    }
    
    func createNewChat() -> ChatSession {
        let session = ChatSession()
        chatSessions.insert(session, at: 0) // Add to beginning for recent-first order
        storage.saveChatSession(session)
        return session
    }
    
    func deleteChat(_ session: ChatSession) {
        chatSessions.removeAll { $0.id == session.id }
        storage.deleteChatSession(session.id)
    }
    
    func duplicateChat(_ session: ChatSession) -> ChatSession {
        var duplicated = session
        duplicated = ChatSession(
            title: "\(session.title) (Copy)",
            selectedModel: session.selectedModel
        )
        // Copy all messages except system messages
        let userAndAssistantMessages = session.messages.filter { $0.role != .system }
        for message in userAndAssistantMessages {
            let copiedMessage = ChatMessage(
                role: message.role,
                content: message.content,
                isStreaming: false
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
    
    // MARK: - Message Handling
    
    func sendMessage(
        _ content: String,
        in sessionId: UUID,
        with settings: AISettings,
        isLoading: Binding<Bool>,
        errorMessage: Binding<String?>
    ) async {
        print("📱 ChatManager: Starting sendMessage for session: \(sessionId)")
        
        await MainActor.run {
            isLoading.wrappedValue = true
            errorMessage.wrappedValue = nil
        }
        
        // Find the session and add user message
        let userMessage = ChatMessage(role: .user, content: content)
        guard let sessionIndex = await MainActor.run(body: {
            chatSessions.firstIndex(where: { $0.id == sessionId })
        }) else {
            await MainActor.run {
                errorMessage.wrappedValue = "Chat session not found."
                isLoading.wrappedValue = false
            }
            return
        }
        
        await MainActor.run {
            chatSessions[sessionIndex].addMessage(userMessage)
            storage.saveChatSession(chatSessions[sessionIndex])
        }
        
        do {
            let model = await MainActor.run {
                chatSessions[sessionIndex].selectedModel ?? settings.defaultModel
            }
            
            // Validate API key
            print("📱 ChatManager: Using model: \(model.displayName)")
            guard let apiKey = settings.getOpenAIAPIKey(), !apiKey.isEmpty else {
                print("❌ ChatManager: No OpenAI API key found")
                await MainActor.run {
                    errorMessage.wrappedValue = "No OpenAI API key configured. Please add your API key in settings."
                    isLoading.wrappedValue = false
                }
                return
            }
            print("✅ ChatManager: OpenAI API key found")
            
            // Get current session messages
            let currentMessages = await MainActor.run {
                chatSessions[sessionIndex].messages
            }
            
            // Handle image generation when DALL-E 3 is selected
            if model.type == .image {
                print("🎨 ChatManager: Using DALL-E 3 for image generation")
                await generateImage(content, sessionIndex: sessionIndex, apiKey: apiKey, settings: settings, isLoading: isLoading, errorMessage: errorMessage)
                return
            }
            
            // Always use streaming for better UX
            print("📱 ChatManager: Sending \(currentMessages.count) messages to OpenAI API (streaming: enabled)")
            
            // Create placeholder streaming message (in memory only, not saved)
            let streamingMessage = ChatMessage(role: .assistant, content: "", isStreaming: true)
            await MainActor.run {
                chatSessions[sessionIndex].messages.append(streamingMessage)
                // Note: Don't save to storage yet - only save when complete
            }
            
            let streamingMessageIndex = await MainActor.run { 
                chatSessions[sessionIndex].messages.count - 1 
            }
            
            // Start streaming
            openAIClient.sendMessageStreaming(
                currentMessages,
                model: model,
                apiKey: apiKey,
                baseURL: settings.apiGatewayURL,
                onToken: { [weak self] token in
                    guard let self = self else { return }
                    
                    // Update streaming message content (in memory only)
                    if let sessionIdx = self.chatSessions.firstIndex(where: { $0.id == sessionId }),
                       streamingMessageIndex < self.chatSessions[sessionIdx].messages.count {
                        self.chatSessions[sessionIdx].messages[streamingMessageIndex].content += token
                        // Note: Don't save to storage during streaming - only save when complete
                    }
                },
                onComplete: { [weak self] in
                    guard let self = self else { return }
                    
                    // Mark streaming as complete and save to storage
                    if let sessionIdx = self.chatSessions.firstIndex(where: { $0.id == sessionId }),
                       streamingMessageIndex < self.chatSessions[sessionIdx].messages.count {
                        self.chatSessions[sessionIdx].messages[streamingMessageIndex].isStreaming = false
                        self.chatSessions[sessionIdx].updatedAt = Date()
                        // Now save to storage - only successful messages are persisted
                        self.storage.saveChatSession(self.chatSessions[sessionIdx])
                    }
                    
                    isLoading.wrappedValue = false
                    print("✅ ChatManager: Streaming completed")
                },
                onError: { error in
                    print("❌ ChatManager: Streaming error: \(error)")
                    
                    // Just remove from memory - nothing to clean up from storage
                    Task { @MainActor in
                        if let sessionIdx = self.chatSessions.firstIndex(where: { $0.id == sessionId }),
                           streamingMessageIndex < self.chatSessions[sessionIdx].messages.count {
                            self.chatSessions[sessionIdx].messages.remove(at: streamingMessageIndex)
                            // No need to save since it was never persisted
                        }
                    }
                    
                    errorMessage.wrappedValue = "Failed to send message: \(error.localizedDescription)"
                    isLoading.wrappedValue = false
                }
            )
            
        } catch {
            print("❌ ChatManager: Error sending message: \(error)")
            await MainActor.run {
                // Remove any streaming message that was created but failed (from memory only)
                if let sessionIdx = chatSessions.firstIndex(where: { $0.id == sessionId }) {
                    // Remove the last message if it's still streaming (failed)
                    if let lastMessage = chatSessions[sessionIdx].messages.last,
                       lastMessage.isStreaming {
                        chatSessions[sessionIdx].messages.removeLast()
                        // No need to save since it was never persisted
                    }
                }
                
                errorMessage.wrappedValue = "Failed to send message: \(error.localizedDescription)"
                isLoading.wrappedValue = false
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
            
            // Sort by last updated (most recent first)
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

// MARK: - OpenAI API Client

class OpenAIClient {
    private let session = URLSession.shared
    
    func sendMessage(
        _ messages: [ChatMessage],
        model: AIModel,
        apiKey: String,
        baseURL: String = OpenAIConfig.baseURL
    ) async throws -> String {
        
        let url = URL(string: "\(baseURL)/chat/completions")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Convert ChatMessage to OpenAI format
        let openAIMessages = messages.map { message in
            return [
                "role": message.role.rawValue,
                "content": message.content
            ]
        }
        
        let requestBody: [String: Any] = [
            "model": model.name,
            "messages": openAIMessages,
            "stream": false // Phase 1: non-streaming only
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.httpError(httpResponse.statusCode, errorMessage)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw APIError.invalidJSON
        }
        
        // Parse OpenAI response
        guard let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw APIError.invalidResponse
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Streaming Support
    
    func sendMessageStreaming(
        _ messages: [ChatMessage],
        model: AIModel,
        apiKey: String,
        baseURL: String = OpenAIConfig.baseURL,
        onToken: @escaping (String) -> Void,
        onComplete: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) {
        Task {
            do {
                let url = URL(string: "\(baseURL)/chat/completions")!
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                // Convert ChatMessage to OpenAI format
                let openAIMessages = messages.map { message in
                    return [
                        "role": message.role.rawValue,
                        "content": message.content
                    ]
                }
                
                let requestBody: [String: Any] = [
                    "model": model.name,
                    "messages": openAIMessages,
                    "stream": true // Enable streaming
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
                
                // Process streaming response
                for try await line in data.lines {
                    // Skip empty lines and metadata
                    guard !line.isEmpty, line.hasPrefix("data: ") else { continue }
                    
                    let jsonString = String(line.dropFirst(6)) // Remove "data: " prefix
                    
                    // Check for completion signal
                    if jsonString == "[DONE]" {
                        await MainActor.run { onComplete() }
                        break
                    }
                    
                    // Parse JSON chunk
                    guard let jsonData = jsonString.data(using: .utf8),
                          let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                          let choices = json["choices"] as? [[String: Any]],
                          let firstChoice = choices.first,
                          let delta = firstChoice["delta"] as? [String: Any],
                          let content = delta["content"] as? String else {
                        continue
                    }
                    
                    // Send token to UI
                    await MainActor.run { onToken(content) }
                }
                
            } catch {
                await MainActor.run { onError(error) }
            }
        }
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

// MARK: - Image Generation Extension

extension ChatManager {
    private func generateImage(
        _ prompt: String, 
        sessionIndex: Int, 
        apiKey: String, 
        settings: AISettings,
        isLoading: Binding<Bool>, 
        errorMessage: Binding<String?>
    ) async {
        do {
            print("🎨 Generating image with DALL-E 3...")
            
            // Create placeholder image message
            let imageMessage = ChatMessage(
                role: .assistant, 
                content: "Generating image...", 
                isStreaming: true,
                contentType: .image,
                imagePrompt: prompt
            )
            
            await MainActor.run {
                chatSessions[sessionIndex].messages.append(imageMessage)
                // Note: Don't save to storage yet - only save when complete
            }
            
            // Call DALL-E 3 API
            let imageURL = try await generateImageWithDallE3(prompt: prompt, apiKey: apiKey, baseURL: settings.apiGatewayURL)
            
            // Update the message with the generated image and save to storage
            await MainActor.run {
                if let lastIndex = chatSessions[sessionIndex].messages.lastIndex(where: { $0.contentType == .image && $0.isStreaming }) {
                    chatSessions[sessionIndex].messages[lastIndex].content = "Generated image for: \"\(prompt)\""
                    chatSessions[sessionIndex].messages[lastIndex].imageURL = imageURL
                    chatSessions[sessionIndex].messages[lastIndex].isStreaming = false
                    chatSessions[sessionIndex].updatedAt = Date()
                    
                    // Now save to storage - only successful messages are persisted
                    storage.saveChatSession(chatSessions[sessionIndex])
                    print("✅ Image generated successfully: \(imageURL)")
                }
                
                isLoading.wrappedValue = false
            }
            
        } catch {
            print("❌ Failed to generate image: \(error)")
            await MainActor.run {
                errorMessage.wrappedValue = "Failed to generate image: \(error.localizedDescription)"
                isLoading.wrappedValue = false
                
                // Remove the failed message (from memory only)
                if let lastIndex = chatSessions[sessionIndex].messages.lastIndex(where: { $0.contentType == .image && $0.isStreaming }) {
                    chatSessions[sessionIndex].messages.remove(at: lastIndex)
                    // No need to save since it was never persisted
                }
            }
        }
    }
    
    private func generateImageWithDallE3(prompt: String, apiKey: String, baseURL: String = OpenAIConfig.baseURL) async throws -> String {
        let url = URL(string: "\(baseURL)/images/generations")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "dall-e-3",
            "prompt": prompt,
            "n": 1,
            "size": "1024x1024",
            "quality": "standard"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("🎨 DALL-E 3 API Response Status: \(httpResponse.statusCode)")
        
        if httpResponse.statusCode != 200 {
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorData["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw NSError(domain: "OpenAIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error \(httpResponse.statusCode): \(message)"])
            } else {
                throw NSError(domain: "OpenAIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error \(httpResponse.statusCode)"])
            }
        }
        
        guard let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let dataArray = jsonResponse["data"] as? [[String: Any]],
              let firstImage = dataArray.first,
              let imageURL = firstImage["url"] as? String else {
            throw NSError(domain: "OpenAIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
        }
        
        return imageURL
    }
}