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
        // Delete associated images
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
        // Copy all messages except system messages
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
        
        print("💾 ChatManager: Updating session \(chatSessions[index].title) tool from \(chatSessions[index].selectedTool.displayName) to: \(tool.displayName)")
        
        // Create a modified copy to trigger SwiftUI updates
        var updatedSession = chatSessions[index]
        updatedSession.selectedTool = tool
        updatedSession.updatedAt = Date()
        
        // Replace the session in the array
        chatSessions[index] = updatedSession
        
        // Save to storage
        storage.saveChatSession(updatedSession)
        
        print("✅ ChatManager: Session tool update complete")
    }
    
    // MARK: - Message Handling
    
    func sendMessageWithTool(
        _ content: String,
        tool: ChatToolMode,
        in sessionId: UUID,
        with settings: AISettings,
        isLoading: Binding<Bool>,
        errorMessage: Binding<String?>
    ) async {
        print("📱 ChatManager: Starting sendMessageWithTool (\(tool.displayName)) for session: \(sessionId)")
        
        switch tool {
        case .chat:
            // Regular text message
            await sendMessage(content, in: sessionId, with: settings, isLoading: isLoading, errorMessage: errorMessage)
            
        case .webSearch:
            // TODO: Implement web search functionality
            await MainActor.run {
                errorMessage.wrappedValue = "Web search functionality not yet implemented"
                isLoading.wrappedValue = false
            }
            
        case .imageGeneration:
            // Force image generation regardless of model type
            await forceImageGeneration(content, in: sessionId, with: settings, isLoading: isLoading, errorMessage: errorMessage)
        }
    }
    
    private func forceImageGeneration(
        _ content: String,
        in sessionId: UUID,
        with settings: AISettings,
        isLoading: Binding<Bool>,
        errorMessage: Binding<String?>
    ) async {
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
            print("📱 ChatManager: Force generating image with model: \(model.displayName)")
            guard let apiKey = settings.getOpenAIAPIKey(), !apiKey.isEmpty else {
                print("❌ ChatManager: No OpenAI API key found")
                await MainActor.run {
                    errorMessage.wrappedValue = "No OpenAI API key configured. Please add your API key in settings."
                    isLoading.wrappedValue = false
                }
                return
            }
            
            // For GPT-5 and GPT-4.1, use responses API
            if model.id == "gpt-5" || model.id == "gpt-4.1" {
                print("🎨 ChatManager: Using responses API for forced image generation")
                await generateImageWithResponsesAPI(content, model: model, sessionIndex: sessionIndex, apiKey: apiKey, settings: settings, isLoading: isLoading, errorMessage: errorMessage)
            }
            // For other models, fall back to DALL-E 3
            else {
                print("🎨 ChatManager: Falling back to DALL-E 3 for forced image generation")
                await generateImage(content, sessionIndex: sessionIndex, apiKey: apiKey, settings: settings, isLoading: isLoading, errorMessage: errorMessage)
            }
            
        } catch {
            print("❌ ChatManager: Error in force image generation: \(error)")
            await MainActor.run {
                errorMessage.wrappedValue = "Failed to generate image: \(error.localizedDescription)"
                isLoading.wrappedValue = false
            }
        }
    }
    
    func sendMessageWithImages(
        _ content: String,
        images: [ChatMessageImage],
        in sessionId: UUID,
        with settings: AISettings,
        isLoading: Binding<Bool>,
        errorMessage: Binding<String?>
    ) async {
        print("📱 ChatManager: Starting sendMessageWithImages for session: \(sessionId)")
        
        await MainActor.run {
            isLoading.wrappedValue = true
            errorMessage.wrappedValue = nil
        }
        
        // Create user message with images
        let userMessage = ChatMessage(role: .user, content: content, images: images)
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
            
            // Handle different models based on their capabilities
            if model.type == .image {
                if model.id == "dall-e-3" {
                    print("🎨 ChatManager: Using DALL-E 3 for image generation")
                    await generateImage(content, sessionIndex: sessionIndex, apiKey: apiKey, settings: settings, isLoading: isLoading, errorMessage: errorMessage)
                    return
                } else if model.id == "gpt-image-1" {
                    print("🎨 ChatManager: Using GPT-Image 1 for image generation")
                    await generateImageWithGPTImage1(content, sessionIndex: sessionIndex, apiKey: apiKey, settings: settings, isLoading: isLoading, errorMessage: errorMessage)
                    return
                }
            } 
            // Note: Keyword-based image generation removed - now using explicit tool selection
            else {
                // Regular chat model with vision support
                print("💬 ChatManager: Using vision-capable chat model")
                await sendVisionMessage(currentMessages, sessionIndex: sessionIndex, apiKey: apiKey, settings: settings, isLoading: isLoading, errorMessage: errorMessage)
            }
            
        } catch {
            print("❌ ChatManager: Error sending message with images: \(error)")
            await MainActor.run {
                errorMessage.wrappedValue = "Failed to send message: \(error.localizedDescription)"
                isLoading.wrappedValue = false
            }
        }
    }
    
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
            
            // Handle image generation models
            if model.type == .image {
                if model.id == "dall-e-3" {
                    print("🎨 ChatManager: Using DALL-E 3 for image generation")
                    await generateImage(content, sessionIndex: sessionIndex, apiKey: apiKey, settings: settings, isLoading: isLoading, errorMessage: errorMessage)
                    return
                } else if model.id == "gpt-image-1" {
                    print("🎨 ChatManager: Using GPT-Image 1 for image generation")
                    await generateImageWithGPTImage1(content, sessionIndex: sessionIndex, apiKey: apiKey, settings: settings, isLoading: isLoading, errorMessage: errorMessage)
                    return
                }
            }
            
            // Note: Keyword-based image generation removed - now using explicit tool selection
            
            // Always use streaming for better UX
            print("📱 ChatManager: Sending \(currentMessages.count) messages to OpenAI API")
            
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
    
    private func sendVisionMessage(
        _ messages: [ChatMessage],
        sessionIndex: Int,
        apiKey: String,
        settings: AISettings,
        isLoading: Binding<Bool>,
        errorMessage: Binding<String?>
    ) async {
        do {
            print("👁️ ChatManager: Sending vision message with images")
            
            // Create placeholder streaming message
            let streamingMessage = ChatMessage(role: .assistant, content: "", isStreaming: true)
            await MainActor.run {
                chatSessions[sessionIndex].messages.append(streamingMessage)
            }
            
            let streamingMessageIndex = await MainActor.run {
                chatSessions[sessionIndex].messages.count - 1
            }
            
            // Use the vision-capable chat API
            openAIClient.sendVisionMessageStreaming(
                messages,
                model: chatSessions[sessionIndex].selectedModel ?? settings.defaultModel,
                apiKey: apiKey,
                baseURL: settings.apiGatewayURL,
                onToken: { [weak self] token in
                    guard let self = self else { return }
                    
                    // Update streaming message content
                    if streamingMessageIndex < self.chatSessions[sessionIndex].messages.count {
                        self.chatSessions[sessionIndex].messages[streamingMessageIndex].content += token
                    }
                },
                onComplete: { [weak self] in
                    guard let self = self else { return }
                    
                    // Mark streaming as complete and save
                    if streamingMessageIndex < self.chatSessions[sessionIndex].messages.count {
                        self.chatSessions[sessionIndex].messages[streamingMessageIndex].isStreaming = false
                        self.chatSessions[sessionIndex].updatedAt = Date()
                        self.storage.saveChatSession(self.chatSessions[sessionIndex])
                    }
                    
                    isLoading.wrappedValue = false
                    print("✅ ChatManager: Vision message streaming completed")
                },
                onError: { error in
                    print("❌ ChatManager: Vision message streaming error: \(error)")
                    
                    Task { @MainActor in
                        if streamingMessageIndex < self.chatSessions[sessionIndex].messages.count {
                            self.chatSessions[sessionIndex].messages.remove(at: streamingMessageIndex)
                        }
                    }
                    
                    errorMessage.wrappedValue = "Failed to send vision message: \(error.localizedDescription)"
                    isLoading.wrappedValue = false
                }
            )
            
        } catch {
            print("❌ ChatManager: Error in sendVisionMessage: \(error)")
            await MainActor.run {
                errorMessage.wrappedValue = "Failed to send vision message: \(error.localizedDescription)"
                isLoading.wrappedValue = false
            }
        }
    }
    
    private func generateImageWithGPTImage1API(prompt: String, apiKey: String, baseURL: String = OpenAIConfig.baseURL) async throws -> String {
        // Validate prompt length for gpt-image-1 (max 1000 characters)
        guard prompt.count <= 1000 else {
            throw NSError(domain: "OpenAIError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Prompt too long. GPT-Image 1 supports maximum 1000 characters."])
        }
        
        let url = URL(string: "\(baseURL)/images/generations")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-image-1",
            "prompt": prompt,
            "n": 1,
            "size": "1024x1024",
            "stream": false, // For now, use non-streaming for simplicity
            "background": "auto", // Let the model automatically determine background
            "moderation": "auto" // Use default content moderation
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("🎨 GPT-Image 1 API Response Status: \(httpResponse.statusCode)")
        
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
              let dataArray = jsonResponse["data"] as? [[String: Any]],
              let firstImage = dataArray.first,
              let imageURL = firstImage["url"] as? String else {
            throw NSError(domain: "OpenAIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
        }
        
        return imageURL
    }
    
    private func generateImageWithGPTImage1Streaming(
        prompt: String, 
        sessionIndex: Int,
        apiKey: String, 
        baseURL: String = OpenAIConfig.baseURL,
        onProgress: @escaping (Double) -> Void
    ) async throws -> String {
        // Validate prompt length for gpt-image-1 (max 1000 characters)
        guard prompt.count <= 1000 else {
            throw NSError(domain: "OpenAIError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Prompt too long. GPT-Image 1 supports maximum 1000 characters."])
        }
        
        let url = URL(string: "\(baseURL)/images/generations")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-image-1",
            "prompt": prompt,
            "n": 1,
            "size": "1024x1024",
            "stream": true, // Enable streaming for better UX
            "background": "auto",
            "moderation": "auto"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.bytes(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            let errorData = try await data.reduce(into: Data()) { $0.append($1) }
            let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "OpenAIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error \(httpResponse.statusCode): \(errorMessage)"])
        }
        
        var finalImageURL: String?
        
        // Process streaming response
        for try await line in data.lines {
            // Skip empty lines and metadata
            guard !line.isEmpty, line.hasPrefix("data: ") else { continue }
            
            let jsonString = String(line.dropFirst(6)) // Remove "data: " prefix
            
            // Check for completion signal
            if jsonString == "[DONE]" {
                break
            }
            
            // Parse JSON chunk
            guard let jsonData = jsonString.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                continue
            }
            
            // Only print first 100 characters of the response to avoid flooding logs
            let shortJsonString = jsonString.count > 100 ? String(jsonString.prefix(100)) + "..." : jsonString
            print("🔍 GPT-Image 1 streaming event received: \(shortJsonString)")
            
            // Log only key fields for debugging, not the full structure
            if let eventType = json["type"] as? String {
                if let b64Data = json["b64_json"] as? String {
                    print("📋 Event: \(eventType), Base64 data length: \(b64Data.count) characters")
                } else {
                    print("📋 Event: \(eventType), No base64 data found")
                }
            } else {
                print("📋 No event type found in response")
            }
            
            // Handle different event types based on the actual API response format
            // The actual format uses "type" field, not "event" field
            if let eventType = json["type"] as? String {
                print("📡 Event type: \(eventType)")
                
                if eventType == "image_generation.partial_image" {
                    print("🎨 Received partial image event")
                    // Check for base64 data directly in the response
                    if let b64Json = json["b64_json"] as? String {
                        print("🎨 Received partial image data, length: \(b64Json.count)")
                        await MainActor.run {
                            onProgress(0.7) // Partial progress
                        }
                    } else {
                        // Assume some progress for partial events
                        await MainActor.run {
                            onProgress(0.5)
                        }
                    }
                } else if eventType == "image_generation.completed" {
                    print("🎯 Image generation completed event")
                    // Check for base64 data directly in the response
                    if let base64Data = json["b64_json"] as? String {
                        print("✅ Found base64 image data, length: \(base64Data.count) characters")
                        finalImageURL = "data:image/png;base64,\(base64Data)"
                        await MainActor.run {
                            onProgress(1.0)
                        }
                    }
                    // Also check for URL (in case API returns URL instead)
                    else if let imageURL = json["url"] as? String {
                        print("✅ Found image URL: \(imageURL)")
                        finalImageURL = imageURL
                        await MainActor.run {
                            onProgress(1.0)
                        }
                    }
                    else {
                        print("⚠️ Completed event but no URL or base64 data found")
                    }
                }
            }
            // Also check for legacy "event" field format (fallback)
            else if let event = json["event"] as? String {
                print("📡 Legacy event type: \(event)")
                
                if event == "image_generation.partial_image" {
                    // Partial image with base64 data
                    if let data = json["data"] as? [String: Any] {
                        // Check for base64 encoded partial image
                        if let b64Json = data["b64_json"] as? String {
                            print("🎨 Received partial image data, length: \(b64Json.count)")
                            await MainActor.run {
                                onProgress(0.7) // Partial progress
                            }
                        }
                        // Also check for progress info
                        else if let progressInfo = data["progress"] as? Double {
                            await MainActor.run {
                                onProgress(progressInfo)
                            }
                        } else {
                            // Assume some progress for partial events
                            await MainActor.run {
                                onProgress(0.5)
                            }
                        }
                    }
                } else if event == "image_generation.completed" {
                    print("🎯 Image generation completed event")
                    // Final image URL or base64 data
                    if let data = json["data"] as? [String: Any] {
                        // Check for URL first (preferred)
                        if let imageURL = data["url"] as? String {
                            print("✅ Found image URL: \(imageURL)")
                            finalImageURL = imageURL
                            await MainActor.run {
                                onProgress(1.0)
                            }
                        } 
                        // Check for base64 data
                        else if let base64Data = data["b64_json"] as? String {
                            print("✅ Found base64 image data, length: \(base64Data.count) characters")
                            finalImageURL = "data:image/png;base64,\(base64Data)"
                            await MainActor.run {
                                onProgress(1.0)
                            }
                        }
                        else {
                            print("⚠️ Completed event but no URL or base64 data found")
                        }
                    }
                }
            }
            // Check for non-event based streaming response format
            else {
                print("📡 Non-event response format")
                
                // Standard OpenAI response format with data array
                if let dataArray = json["data"] as? [[String: Any]], 
                   let firstImage = dataArray.first {
                    print("🔍 Found data array format")
                    if let imageURL = firstImage["url"] as? String {
                        print("✅ Found image URL in data array: \(imageURL)")
                        finalImageURL = imageURL
                        await MainActor.run {
                            onProgress(1.0)
                        }
                    } else if let base64Data = firstImage["b64_json"] as? String {
                        print("✅ Found base64 data in data array, length: \(base64Data.count) characters")
                        finalImageURL = "data:image/png;base64,\(base64Data)"
                        await MainActor.run {
                            onProgress(1.0)
                        }
                    }
                }
                // Direct data object format
                else if let dataDict = json["data"] as? [String: Any] {
                    print("🔍 Found direct data object format")
                    if let base64Data = dataDict["b64_json"] as? String {
                        print("✅ Found base64 data in direct format, length: \(base64Data.count) characters")
                        finalImageURL = "data:image/png;base64,\(base64Data)"
                        await MainActor.run {
                            onProgress(1.0)
                        }
                    }
                }
                // Check for any other base64 data formats
                else if let base64Data = json["b64_json"] as? String {
                    print("✅ Found root-level base64 data, length: \(base64Data.count) characters")
                    finalImageURL = "data:image/png;base64,\(base64Data)"
                    await MainActor.run {
                        onProgress(1.0)
                    }
                }
            }
        }
        
        guard let imageURL = finalImageURL else {
            throw NSError(domain: "OpenAIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No image URL received from streaming response"])
        }
        
        return imageURL
    }
    
    private func shouldTriggerImageGeneration(_ text: String, in messages: [ChatMessage]) -> Bool {
        let lowercaseText = text.lowercased()
        
        // Primary keywords for new image generation
        let hasGenerateImage = lowercaseText.contains("generate") && lowercaseText.contains("image")
        
        // Check if we have a recent image generation in the conversation (multi-turn context)
        let hasRecentImageGeneration = findLastImageGenerationResponse(in: messages) != nil
        
        if hasRecentImageGeneration {
            // In multi-turn context, we're more liberal with keywords
            let hasRefinementKeywords = lowercaseText.contains("make it") || 
                                       lowercaseText.contains("change it") || 
                                       lowercaseText.contains("modify") || 
                                       lowercaseText.contains("adjust") ||
                                       lowercaseText.contains("refine") || 
                                       lowercaseText.contains("improve") ||
                                       lowercaseText.contains("now") ||
                                       lowercaseText.contains("more") ||
                                       lowercaseText.contains("less") ||
                                       lowercaseText.contains("different") ||
                                       lowercaseText.contains("realistic") ||
                                       lowercaseText.contains("stylized") ||
                                       lowercaseText.contains("brighter") ||
                                       lowercaseText.contains("darker")
            
            // Also check for direct image references without specific keywords
            let hasImageReference = lowercaseText.contains("image") || 
                                   lowercaseText.contains("picture") || 
                                   lowercaseText.contains("photo") ||
                                   lowercaseText.contains("it") // referring to the previous image
            
            return hasRefinementKeywords || hasImageReference
        } else {
            // First image generation - require explicit keywords
            let hasImageRefinement = (lowercaseText.contains("make it") || lowercaseText.contains("change it") || 
                                      lowercaseText.contains("modify") || lowercaseText.contains("adjust") ||
                                      lowercaseText.contains("refine") || lowercaseText.contains("improve")) && 
                                      (lowercaseText.contains("image") || lowercaseText.contains("picture"))
            return hasGenerateImage || hasImageRefinement
        }
    }
    
    private func containsImageGenerationKeywords(_ text: String) -> Bool {
        // Legacy function - keeping for backward compatibility
        let lowercaseText = text.lowercased()
        return lowercaseText.contains("generate") && lowercaseText.contains("image")
    }
    
    private func findLastImageGenerationResponse(in messages: [ChatMessage]) -> String? {
        // Find the most recent assistant message with image generation and a response ID
        for message in messages.reversed() {
            if message.role == .assistant && 
               message.contentType == .image && 
               message.responseId != nil {
                return message.responseId
            }
        }
        return nil
    }
    
    private func generateImageWithResponsesAPI(
        _ content: String,
        model: AIModel,
        sessionIndex: Int,
        apiKey: String,
        settings: AISettings,
        isLoading: Binding<Bool>,
        errorMessage: Binding<String?>
    ) async {
        do {
            print("🎨 Generating image with \(model.displayName) using responses API...")
            
            // Create placeholder image message
            let imageMessage = ChatMessage(
                role: .assistant, 
                content: "Generating image...", 
                isStreaming: true,
                contentType: .image,
                imagePrompt: content
            )
            
            await MainActor.run {
                chatSessions[sessionIndex].messages.append(imageMessage)
            }
            
            // Check if this is a multi-turn refinement request
            let currentMessages = await MainActor.run {
                chatSessions[sessionIndex].messages
            }
            let previousResponseId = findLastImageGenerationResponse(in: currentMessages)
            
            // Call responses API with image_generation tool
            let (imageURL, responseId) = try await generateImageWithResponsesAPICall(
                prompt: content,
                model: model,
                apiKey: apiKey,
                baseURL: settings.apiGatewayURL,
                previousResponseId: previousResponseId
            )
            
            // Get the message ID for local storage before updating
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
            
            // Save image locally
            let localImagePath: String?
            do {
                localImagePath = try await ImageStorageService.shared.saveBase64Image(imageURL, messageId: messageId)
                print("✅ \(model.displayName) image saved to local storage: \(localImagePath ?? "unknown")")
            } catch {
                print("⚠️ Failed to save \(model.displayName) image locally: \(error)")
                localImagePath = nil
            }
            
            // Update the message with the generated image and save to storage
            await MainActor.run {
                if let lastIndex = chatSessions[sessionIndex].messages.lastIndex(where: { $0.contentType == .image && $0.isStreaming }) {
                    chatSessions[sessionIndex].messages[lastIndex].content = "Generated image for: \"\(content)\""
                    chatSessions[sessionIndex].messages[lastIndex].imageURL = imageURL
                    chatSessions[sessionIndex].messages[lastIndex].localImagePath = localImagePath
                    chatSessions[sessionIndex].messages[lastIndex].responseId = responseId
                    chatSessions[sessionIndex].messages[lastIndex].isStreaming = false
                    chatSessions[sessionIndex].updatedAt = Date()
                    
                    // Save to storage
                    storage.saveChatSession(chatSessions[sessionIndex])
                    print("✅ \(model.displayName) image generated successfully with responseId: \(responseId)")
                }
                
                isLoading.wrappedValue = false
            }
            
        } catch {
            print("❌ Failed to generate image with \(model.displayName): \(error)")
            await MainActor.run {
                errorMessage.wrappedValue = "Failed to generate image: \(error.localizedDescription)"
                isLoading.wrappedValue = false
                
                // Remove the failed message
                if let lastIndex = chatSessions[sessionIndex].messages.lastIndex(where: { $0.contentType == .image && $0.isStreaming }) {
                    chatSessions[sessionIndex].messages.remove(at: lastIndex)
                }
            }
        }
    }
    
    private func generateImageWithResponsesAPICall(prompt: String, model: AIModel, apiKey: String, baseURL: String = OpenAIConfig.baseURL, previousResponseId: String? = nil) async throws -> (imageURL: String, responseId: String) {
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
        
        // Add previous_response_id for multi-turn image generation if available
        if let previousId = previousResponseId {
            requestBody["previous_response_id"] = previousId
            print("🔄 Using previous_response_id for multi-turn generation: \(previousId)")
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        // Create a custom session with 60-second timeout for image generation
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 600.0
        config.timeoutIntervalForResource = 600.0
        let customSession = URLSession(configuration: config)
        
        let (data, response) = try await customSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("🎨 \(model.displayName) Responses API Response Status: \(httpResponse.statusCode)")
        
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
        
        // Find the image_generation_call in the output
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
    
    func sendVisionMessageStreaming(
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
                
                // Convert ChatMessage to OpenAI vision format
                let openAIMessages = messages.map { message -> [String: Any] in
                    if message.hasImages {
                        // Vision message format with images
                        var content: [[String: Any]] = []
                        
                        // Add text content if present
                        if !message.content.isEmpty {
                            content.append([
                                "type": "text",
                                "text": message.content
                            ])
                        }
                        
                        // Add images
                        for image in message.images {
                            if let imageURL = image.effectiveImageURL {
                                content.append([
                                    "type": "image_url",
                                    "image_url": [
                                        "url": imageURL
                                    ]
                                ])
                            }
                        }
                        
                        // Handle legacy single image
                        if message.images.isEmpty, let legacyImageURL = message.effectiveImageURL {
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
                        // Text-only message format
                        return [
                            "role": message.role.rawValue,
                            "content": message.content
                        ]
                    }
                }
                
                let requestBody: [String: Any] = [
                    "model": model.name,
                    "messages": openAIMessages,
                    "stream": true, // Enable streaming
                    "max_tokens": 1000 // Add reasonable limit for vision models
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
            
            // Get the message ID for local storage before updating
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
            
            // Download image to local storage
            let localImagePath: String?
            do {
                localImagePath = try await ImageStorageService.shared.downloadAndSaveImage(from: imageURL, messageId: messageId)
                print("✅ Image downloaded to local storage: \(localImagePath ?? "unknown")")
            } catch {
                print("⚠️ Failed to download image locally, will use remote URL: \(error)")
                localImagePath = nil
            }
            
            // Update the message with the generated image and save to storage
            await MainActor.run {
                if let lastIndex = chatSessions[sessionIndex].messages.lastIndex(where: { $0.contentType == .image && $0.isStreaming }) {
                    chatSessions[sessionIndex].messages[lastIndex].content = "Generated image for: \"\(prompt)\""
                    chatSessions[sessionIndex].messages[lastIndex].imageURL = imageURL
                    chatSessions[sessionIndex].messages[lastIndex].localImagePath = localImagePath
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
    
    private func generateImageWithGPTImage1(
        _ content: String,
        sessionIndex: Int,
        apiKey: String,
        settings: AISettings,
        isLoading: Binding<Bool>,
        errorMessage: Binding<String?>
    ) async {
        do {
            print("🎨 Generating image with GPT-Image 1...")
            
            // Create placeholder image message
            let imageMessage = ChatMessage(
                role: .assistant, 
                content: "Generating image...", 
                isStreaming: true,
                contentType: .image,
                imagePrompt: content
            )
            
            await MainActor.run {
                chatSessions[sessionIndex].messages.append(imageMessage)
                // Note: Don't save to storage yet - only save when complete
            }
            
            // Call GPT-Image 1 API using images/generations endpoint with streaming support
            let imageURL = try await generateImageWithGPTImage1Streaming(
                prompt: content, 
                sessionIndex: sessionIndex,
                apiKey: apiKey, 
                baseURL: settings.apiGatewayURL,
                onProgress: { progress in
                    // Update UI with generation progress if available
                    Task { @MainActor in
                        if let lastIndex = self.chatSessions[sessionIndex].messages.lastIndex(where: { $0.contentType == .image && $0.isStreaming }) {
                            self.chatSessions[sessionIndex].messages[lastIndex].content = "Generating image... \(Int(progress * 100))%"
                        }
                    }
                }
            )
            
            // Get the message ID for local storage before updating
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
            
            // Download image to local storage
            let localImagePath: String?
            do {
                localImagePath = try await ImageStorageService.shared.downloadAndSaveImage(from: imageURL, messageId: messageId)
                print("✅ GPT-Image 1 image downloaded to local storage: \(localImagePath ?? "unknown")")
                
                // Verify the file actually exists
                if let localPath = localImagePath, FileManager.default.fileExists(atPath: localPath) {
                    print("✅ Verified local file exists at: \(localPath)")
                } else {
                    print("❌ Local file does not exist at path: \(localImagePath ?? "nil")")
                }
            } catch {
                print("⚠️ Failed to download GPT-Image 1 image locally, will use remote URL: \(error)")
                localImagePath = nil
            }
            
            // Update the message with the generated image and save to storage
            await MainActor.run {
                if let lastIndex = chatSessions[sessionIndex].messages.lastIndex(where: { $0.contentType == .image && $0.isStreaming }) {
                    chatSessions[sessionIndex].messages[lastIndex].content = "Generated image for: \"\(content)\""
                    chatSessions[sessionIndex].messages[lastIndex].imageURL = imageURL
                    chatSessions[sessionIndex].messages[lastIndex].localImagePath = localImagePath
                    chatSessions[sessionIndex].messages[lastIndex].isStreaming = false
                    chatSessions[sessionIndex].updatedAt = Date()
                    
                    // Now save to storage - only successful messages are persisted
                    storage.saveChatSession(chatSessions[sessionIndex])
                    print("✅ GPT-Image 1 image generated successfully: \(imageURL)")
                }
                
                isLoading.wrappedValue = false
            }
            
        } catch {
            print("❌ Failed to generate image with GPT-Image 1: \(error)")
            await MainActor.run {
                errorMessage.wrappedValue = "Failed to generate image: \(error.localizedDescription)"
                isLoading.wrappedValue = false
                
                // Remove the failed streaming message
                if let sessionIndex = chatSessions.firstIndex(where: { $0.id == chatSessions[sessionIndex].id }),
                   let lastMessage = chatSessions[sessionIndex].messages.last,
                   lastMessage.isStreaming {
                    chatSessions[sessionIndex].messages.removeLast()
                }
            }
        }
    }
}