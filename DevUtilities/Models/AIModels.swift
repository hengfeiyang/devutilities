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

// MARK: - Core AI Models

struct ChatSession: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    let createdAt: Date
    var updatedAt: Date
    var messages: [ChatMessage]
    var selectedProviderModelId: UUID?  // Reference to selected provider/model
    var selectedModelId: UUID?  // Reference to selected model within provider
    var selectedTool: ChatToolMode = .chat

    init(title: String = "New Chat") {
        self.id = UUID()
        self.title = title
        self.createdAt = Date()
        self.updatedAt = Date()
        self.messages = []
        self.selectedTool = .chat  // Explicitly reset tool selection for new sessions
    }
    
    mutating func addMessage(_ message: ChatMessage) {
        messages.append(message)
        updatedAt = Date()
        
        // Auto-generate title from first user message
        if title == "New Chat" && message.role == .user {
            title = String(message.content.prefix(50))
            if message.content.count > 50 {
                title += "..."
            }
        }
    }
    
    mutating func updateTitle(_ newTitle: String) {
        title = newTitle
        updatedAt = Date()
    }

    // Helper to get the current model ID for API calls
    @MainActor func getCurrentModelId() -> String? {
        // If we have a selected model, get its modelId from the provider system
        if let providerId = selectedProviderModelId,
           let modelId = selectedModelId,
           let provider = ProviderManager.shared.getProviderById(providerId),
           let model = provider.models.first(where: { $0.id == modelId }) {
            return model.modelId
        }

        // Fall back to default model from UI settings
        if let defaultModelKey = AIUISettings.shared.selectedDefaultModelKey {
            let components = defaultModelKey.split(separator: "|")
            if components.count == 2,
               let providerIdStr = components.first,
               let modelIdStr = components.last,
               let providerId = UUID(uuidString: String(providerIdStr)),
               let modelId = UUID(uuidString: String(modelIdStr)),
               let provider = ProviderManager.shared.getProviderById(providerId),
               let model = provider.models.first(where: { $0.id == modelId }) {
                return model.modelId
            }
        }

        // Ultimate fallback to first available active model
        let activeModels = ProviderManager.shared.getAllActiveModels()
        return activeModels.first?.model.modelId
    }

    // Helper to get current provider details for API calls
    @MainActor func getCurrentProviderInfo() -> (baseURL: String, apiKey: String)? {
        // If we have a selected model, get provider info
        if let providerId = selectedProviderModelId,
           let modelId = selectedModelId,
           let provider = ProviderManager.shared.getProviderById(providerId),
           provider.models.contains(where: { $0.id == modelId }),
           let apiKey = ProviderManager.shared.getAPIKey(for: providerId), !apiKey.isEmpty {
            return (baseURL: provider.baseURL, apiKey: apiKey)
        }

        // Fall back to default model from UI settings
        if let defaultModelKey = AIUISettings.shared.selectedDefaultModelKey {
            let components = defaultModelKey.split(separator: "|")
            if components.count == 2,
               let providerIdStr = components.first,
               let modelIdStr = components.last,
               let providerId = UUID(uuidString: String(providerIdStr)),
               let modelId = UUID(uuidString: String(modelIdStr)),
               let provider = ProviderManager.shared.getProviderById(providerId),
               provider.models.contains(where: { $0.id == modelId }),
               let apiKey = ProviderManager.shared.getAPIKey(for: providerId), !apiKey.isEmpty {
                return (baseURL: provider.baseURL, apiKey: apiKey)
            }
        }

        // Ultimate fallback to first available active model
        let activeModels = ProviderManager.shared.getAllActiveModels()
        if let firstModel = activeModels.first,
           let apiKey = ProviderManager.shared.getAPIKey(for: firstModel.provider.id), !apiKey.isEmpty {
            return (baseURL: firstModel.provider.baseURL, apiKey: apiKey)
        }

        return nil
    }
}

enum MessageContentType: String, Codable, CaseIterable {
    case text = "text"
    case image = "image"
}

enum AttachmentType: String, Codable, CaseIterable {
    case image
    
    var displayName: String {
        switch self {
        case .image: return "Image"
        }
    }
}

struct ChatMessageImage: Identifiable, Codable, Hashable {
    let id: UUID
    var imageURL: String? = nil
    var localImagePath: String? = nil
    var caption: String? = nil // Optional caption for the image
    var attachmentType: AttachmentType = .image // Always image type
    
    init(imageURL: String? = nil, localImagePath: String? = nil, caption: String? = nil) {
        self.id = UUID()
        self.imageURL = imageURL
        self.localImagePath = localImagePath
        self.caption = caption
    }
    
    var effectiveImageURL: String? {
        if let localPath = localImagePath,
           FileManager.default.fileExists(atPath: localPath) {
            return "file://\(localPath)"
        }
        return imageURL
    }
    
    // Get base64 encoded image URL for API compatibility
    var base64ImageURL: String? {
        if let localPath = localImagePath,
           FileManager.default.fileExists(atPath: localPath) {
            // Convert local image to base64 data URL
            do {
                let imageData = try Data(contentsOf: URL(fileURLWithPath: localPath))
                let base64String = imageData.base64EncodedString()
                
                // Determine MIME type based on file extension
                let mimeType: String
                if localPath.lowercased().hasSuffix(".png") {
                    mimeType = "image/png"
                } else if localPath.lowercased().hasSuffix(".jpg") || localPath.lowercased().hasSuffix(".jpeg") {
                    mimeType = "image/jpeg"
                } else if localPath.lowercased().hasSuffix(".webp") {
                    mimeType = "image/webp"
                } else {
                    mimeType = "image/png" // Default to PNG
                }
                
                return "data:\(mimeType);base64,\(base64String)"
            } catch {
                print("❌ Failed to convert local image to base64: \(error)")
                return nil
            }
        }
        return imageURL
    }
}

struct ChatMessage: Identifiable, Codable, Hashable {
    let id: UUID
    let role: MessageRole
    var content: String
    let timestamp: Date
    var isStreaming: Bool
    var contentType: MessageContentType = .text
    // Legacy single image support (for backward compatibility)
    var imageURL: String? = nil
    var localImagePath: String? = nil
    var imagePrompt: String? = nil
    // New multiple images support
    var images: [ChatMessageImage] = []
    // Response ID for multi-turn image generation
    var responseId: String? = nil
    // DeepSeek reasoning content (deepthink)
    var reasoningContent: String? = nil
    
    init(role: MessageRole, content: String, isStreaming: Bool = false, contentType: MessageContentType = .text, imageURL: String? = nil, localImagePath: String? = nil, imagePrompt: String? = nil, images: [ChatMessageImage] = [], responseId: String? = nil, reasoningContent: String? = nil) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
        self.isStreaming = isStreaming
        self.contentType = contentType
        self.imageURL = imageURL
        self.localImagePath = localImagePath
        self.imagePrompt = imagePrompt
        self.images = images
        self.responseId = responseId
        self.reasoningContent = reasoningContent
    }
    
    // Legacy compatibility - returns first image if available
    var effectiveImageURL: String? {
        // Check new images array first
        if let firstImage = images.first {
            return firstImage.effectiveImageURL
        }
        // Fall back to legacy single image
        if let localPath = localImagePath,
           FileManager.default.fileExists(atPath: localPath) {
            return "file://\(localPath)"
        }
        return imageURL
    }
    
    // Get base64 encoded image URL for API compatibility (legacy support)
    var base64ImageURL: String? {
        // Check new images array first
        if let firstImage = images.first {
            return firstImage.base64ImageURL
        }
        // Fall back to legacy single image
        if let localPath = localImagePath,
           FileManager.default.fileExists(atPath: localPath) {
            do {
                let imageData = try Data(contentsOf: URL(fileURLWithPath: localPath))
                let base64String = imageData.base64EncodedString()
                // Determine MIME type based on file extension
                let mimeType: String
                if localPath.lowercased().hasSuffix(".png") {
                    mimeType = "image/png"
                } else if localPath.lowercased().hasSuffix(".jpg") || localPath.lowercased().hasSuffix(".jpeg") {
                    mimeType = "image/jpeg"
                } else if localPath.lowercased().hasSuffix(".webp") {
                    mimeType = "image/webp"
                } else {
                    mimeType = "image/png" // Default to PNG
                }
                return "data:\(mimeType);base64,\(base64String)"
            } catch {
                print("❌ Failed to convert legacy local image to base64: \(error)")
                return nil
            }
        }
        return imageURL
    }
    
    // Helper to get all effective image URLs
    var allImageURLs: [String] {
        var urls: [String] = []
        // Add new images
        for image in images {
            if let url = image.effectiveImageURL {
                urls.append(url)
            }
        }
        // Add legacy image if not already covered
        if images.isEmpty, let legacyURL = effectiveImageURL {
            urls.append(legacyURL)
        }
        return urls
    }
    
    // Check if message has any images
    var hasImages: Bool {
        return !images.isEmpty || effectiveImageURL != nil
    }
}

enum MessageRole: String, Codable, CaseIterable {
    case user = "user"
    case assistant = "assistant"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .user: return "You"
        case .assistant: return "Assistant"
        case .system: return "System"
        }
    }
}

enum ModelType: String, Codable, CaseIterable {
    case chat = "chat"
    case image = "image"
}

enum ChatToolMode: String, Codable, CaseIterable {
    case chat = "chat"
    case webSearch = "web_search"
    case imageGeneration = "image_generation"
    
    var displayName: String {
        switch self {
        case .chat: return "Chat"
        case .webSearch: return "Search"
        case .imageGeneration: return "Image"
        }
    }
    
    var iconName: String {
        switch self {
        case .chat: return "message"
        case .webSearch: return "globe"
        case .imageGeneration: return "photo.on.rectangle.angled"
        }
    }
}


// OpenAI API configuration
enum OpenAIConfig {
    static let baseURL = "https://api.openai.com/v1"
    static let providerName = "OpenAI"
}



// MARK: - Keychain Service

final class KeychainService: @unchecked Sendable {
    static let shared = KeychainService()
    private init() {}
    
    private let service = "com.hengfeiyang.devutilities.api-keys"
    private let openaiAccount = "api-key-openai"
    
    func saveOpenAIAPIKey(_ key: String) {
        let data = key.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: openaiAccount,
            kSecValueData as String: data
        ]
        
        // Delete existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func getOpenAIAPIKey() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: openaiAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess,
           let data = dataTypeRef as? Data,
           let key = String(data: data, encoding: .utf8) {
            return key
        }
        
        return nil
    }
    
    func clearOpenAIAPIKey() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: openaiAccount
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - AI UI Settings Manager

@MainActor
@Observable
class AIUISettings {
    static let shared = AIUISettings()

    private let userDefaults = UserDefaults.standard

    // General Settings
    var selectedDefaultModelKey: String? {
        get { userDefaults.string(forKey: "ai_ui_default_model_key") }
        set {
            if let key = newValue {
                userDefaults.set(key, forKey: "ai_ui_default_model_key")
            } else {
                userDefaults.removeObject(forKey: "ai_ui_default_model_key")
            }
        }
    }

    var streamResponses: Bool {
        get { userDefaults.object(forKey: "ai_ui_stream_responses") as? Bool ?? true }
        set { userDefaults.set(newValue, forKey: "ai_ui_stream_responses") }
    }

    var showReasoning: Bool {
        get { userDefaults.object(forKey: "ai_ui_show_reasoning") as? Bool ?? true }
        set { userDefaults.set(newValue, forKey: "ai_ui_show_reasoning") }
    }

    var autoScroll: Bool {
        get { userDefaults.object(forKey: "ai_ui_auto_scroll") as? Bool ?? true }
        set { userDefaults.set(newValue, forKey: "ai_ui_auto_scroll") }
    }

    var saveHistory: Bool {
        get { userDefaults.object(forKey: "ai_ui_save_history") as? Bool ?? true }
        set { userDefaults.set(newValue, forKey: "ai_ui_save_history") }
    }

    // Appearance Settings
    var theme: String {
        get { userDefaults.string(forKey: "ai_ui_theme") ?? "Auto" }
        set { userDefaults.set(newValue, forKey: "ai_ui_theme") }
    }

    var fontSize: Int {
        get { userDefaults.object(forKey: "ai_ui_font_size") as? Int ?? 14 }
        set { userDefaults.set(newValue, forKey: "ai_ui_font_size") }
    }

    var messageDensity: String {
        get { userDefaults.string(forKey: "ai_ui_message_density") ?? "Comfortable" }
        set { userDefaults.set(newValue, forKey: "ai_ui_message_density") }
    }

    // Advanced Settings
    var maxHistoryChats: Int {
        get { userDefaults.object(forKey: "ai_ui_max_history_chats") as? Int ?? 100 }
        set { userDefaults.set(newValue, forKey: "ai_ui_max_history_chats") }
    }

    var requestTimeout: Int {
        get { userDefaults.object(forKey: "ai_ui_request_timeout") as? Int ?? 30 }
        set { userDefaults.set(newValue, forKey: "ai_ui_request_timeout") }
    }

    var maxRetries: Int {
        get { userDefaults.object(forKey: "ai_ui_max_retries") as? Int ?? 3 }
        set { userDefaults.set(newValue, forKey: "ai_ui_max_retries") }
    }

    private init() {}
}