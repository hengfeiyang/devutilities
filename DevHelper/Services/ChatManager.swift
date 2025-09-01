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
    
    func sendMessageWithImagesAndTool(
        _ content: String,
        images: [ChatMessageImage],
        tool: ChatToolMode,
        in sessionId: UUID,
        with settings: AISettings,
        isLoading: Binding<Bool>,
        errorMessage: Binding<String?>
    ) async {
        print("📱 ChatManager: Starting sendMessageWithImagesAndTool (\(tool.displayName)) for session: \(sessionId)")
        
        switch tool {
        case .chat:
            // Regular vision message
            await sendMessageWithImages(content, images: images, in: sessionId, with: settings, isLoading: isLoading, errorMessage: errorMessage)
            
        case .webSearch:
            // TODO: Implement web search functionality
            await MainActor.run {
                errorMessage.wrappedValue = "Web search functionality not yet implemented"
                isLoading.wrappedValue = false
            }
            
        case .imageGeneration:
            // Image generation with reference images
            await forceImageGenerationWithReferenceImages(content, referenceImages: images, in: sessionId, with: settings, isLoading: isLoading, errorMessage: errorMessage)
        }
    }
    
    private func forceImageGenerationWithReferenceImages(
        _ content: String,
        referenceImages: [ChatMessageImage],
        in sessionId: UUID,
        with settings: AISettings,
        isLoading: Binding<Bool>,
        errorMessage: Binding<String?>
    ) async {
        await MainActor.run {
            isLoading.wrappedValue = true
            errorMessage.wrappedValue = nil
        }
        
        // Find the session and add user message with images
        let userMessage = ChatMessage(role: .user, content: content, images: referenceImages)
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
            print("📱 ChatManager: Force generating image with reference images using model: \(model.displayName)")
            guard let apiKey = settings.getOpenAIAPIKey(), !apiKey.isEmpty else {
                print("❌ ChatManager: No OpenAI API key found")
                await MainActor.run {
                    errorMessage.wrappedValue = "No OpenAI API key configured. Please add your API key in settings."
                    isLoading.wrappedValue = false
                }
                return
            }
            
            // Use responses API for image generation with reference images
            print("🎨 ChatManager: Using responses API for image generation with reference images using model: \(model.displayName)")
            await generateImageWithResponsesAPIAndReferenceImages(content, referenceImages: referenceImages, model: model, sessionIndex: sessionIndex, apiKey: apiKey, settings: settings, isLoading: isLoading, errorMessage: errorMessage)
            
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
            
            // Use responses API for image generation
            print("🎨 ChatManager: Using responses API for image generation with model: \(model.displayName)")
            await generateImageWithResponsesAPI(content, model: model, sessionIndex: sessionIndex, apiKey: apiKey, settings: settings, isLoading: isLoading, errorMessage: errorMessage)
            
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
            
            // Use vision-capable chat model for images
            print("💬 ChatManager: Using vision-capable chat model")
            await sendVisionMessage(currentMessages, sessionIndex: sessionIndex, apiKey: apiKey, settings: settings, isLoading: isLoading, errorMessage: errorMessage)
            
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
            
            // Use streaming chat for text messages
            
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
            
        }
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
    
    private func generateImageWithResponsesAPIAndReferenceImages(
        _ content: String,
        referenceImages: [ChatMessageImage],
        model: AIModel,
        sessionIndex: Int,
        apiKey: String,
        settings: AISettings,
        isLoading: Binding<Bool>,
        errorMessage: Binding<String?>
    ) async {
        do {
            print("🎨 Generating image with \(model.displayName) using responses API with \(referenceImages.count) reference images...")
            
            // Create placeholder image message
            let imageMessage = ChatMessage(
                role: .assistant, 
                content: "Generating image with reference images...", 
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
            
            // Call responses API with image_generation tool and reference images
            let (imageURL, responseId) = try await generateImageWithResponsesAPICallWithReferenceFiles(
                prompt: content,
                referenceImages: referenceImages,
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
                print("✅ \(model.displayName) image with reference images saved to local storage: \(localImagePath ?? "unknown")")
            } catch {
                print("⚠️ Failed to save \(model.displayName) image locally: \(error)")
                localImagePath = nil
            }
            
            // Update the message with the generated image and save to storage
            await MainActor.run {
                if let lastIndex = chatSessions[sessionIndex].messages.lastIndex(where: { $0.contentType == .image && $0.isStreaming }) {
                    let referenceCount = referenceImages.count
                    chatSessions[sessionIndex].messages[lastIndex].content = "Generated image for: \"\(content)\" using \(referenceCount) reference image\(referenceCount == 1 ? "" : "s")"
                    chatSessions[sessionIndex].messages[lastIndex].imageURL = imageURL
                    chatSessions[sessionIndex].messages[lastIndex].localImagePath = localImagePath
                    chatSessions[sessionIndex].messages[lastIndex].responseId = responseId
                    chatSessions[sessionIndex].messages[lastIndex].isStreaming = false
                    chatSessions[sessionIndex].updatedAt = Date()
                    
                    // Save to storage
                    storage.saveChatSession(chatSessions[sessionIndex])
                    print("✅ \(model.displayName) image generated successfully with reference images and responseId: \(responseId)")
                }
                
                isLoading.wrappedValue = false
            }
            
        } catch {
            print("❌ Failed to generate image with \(model.displayName) and reference images: \(error)")
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
    
    private func generateImageWithResponsesAPICallWithReferenceFiles(
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
        
        // Build the input content with text and reference images
        var inputContent: [[String: Any]] = []
        
        // Add text input
        inputContent.append([
            "type": "input_text",
            "text": prompt
        ])
        
        // Add reference images
        var hasImage = false
        for attachment in referenceImages {
            print("🎨 \(model.displayName) Reference Image: \(attachment.attachmentType.displayName)")
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
        
        // Add previous_response_id for multi-turn image generation if available
        if let previousId = previousResponseId {
            requestBody["previous_response_id"] = previousId
            print("🔄 Using previous_response_id for multi-turn generation with reference images: \(previousId)")
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
        
        print("🎨 \(model.displayName) Responses API with Reference Images Response Status: \(httpResponse.statusCode)")
        
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
                            if let imageURL = image.base64ImageURL {
                                content.append([
                                    "type": "image_url",
                                    "image_url": [
                                        "url": imageURL
                                    ]
                                ])
                            }
                        }
                        
                        // Handle legacy single image
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

