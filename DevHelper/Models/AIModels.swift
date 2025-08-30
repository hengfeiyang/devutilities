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
    var selectedModel: AIModel?
    
    init(title: String = "New Chat", selectedModel: AIModel? = nil) {
        self.id = UUID()
        self.title = title
        self.createdAt = Date()
        self.updatedAt = Date()
        self.messages = []
        self.selectedModel = selectedModel
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
}

enum MessageContentType: String, Codable, CaseIterable {
    case text = "text"
    case image = "image"
}

struct ChatMessage: Identifiable, Codable, Hashable {
    let id: UUID
    let role: MessageRole
    var content: String
    let timestamp: Date
    var isStreaming: Bool
    var contentType: MessageContentType = .text
    var imageURL: String? = nil
    var imagePrompt: String? = nil
    
    init(role: MessageRole, content: String, isStreaming: Bool = false, contentType: MessageContentType = .text, imageURL: String? = nil, imagePrompt: String? = nil) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
        self.isStreaming = isStreaming
        self.contentType = contentType
        self.imageURL = imageURL
        self.imagePrompt = imagePrompt
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

struct AIModel: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let displayName: String
    let maxTokens: Int
    let contextWindow: Int
    let type: ModelType
    
    init(id: String, name: String, displayName: String, maxTokens: Int, contextWindow: Int = 8192, type: ModelType = .chat) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.maxTokens = maxTokens
        self.contextWindow = contextWindow
        self.type = type
    }
}

// OpenAI API configuration
enum OpenAIConfig {
    static let baseURL = "https://api.openai.com/v1"
    static let providerName = "OpenAI"
}

// MARK: - Available Models

extension AIModel {
    // OpenAI Models
    static let gpt5 = AIModel(
        id: "gpt-5",
        name: "gpt-5",
        displayName: "GPT-5",
        maxTokens: 8192,
        contextWindow: 200000
    )
    
    static let gpt5Mini = AIModel(
        id: "gpt-5-mini",
        name: "gpt-5-mini", 
        displayName: "GPT-5 Mini",
        maxTokens: 16384,
        contextWindow: 128000
    )
    
    static let gpt5Nano = AIModel(
        id: "gpt-5-nano",
        name: "gpt-5-nano",
        displayName: "GPT-5 Nano", 
        maxTokens: 8192,
        contextWindow: 64000
    )
    
    static let gpt41 = AIModel(
        id: "gpt-4.1",
        name: "gpt-4.1",
        displayName: "GPT-4.1",
        maxTokens: 4096,
        contextWindow: 128000
    )
    
    static let gpt41Mini = AIModel(
        id: "gpt-4.1-mini",
        name: "gpt-4.1-mini",
        displayName: "GPT-4.1 Mini",
        maxTokens: 16384,
        contextWindow: 128000
    )
    
    static let gpt41Nano = AIModel(
        id: "gpt-4.1-nano",
        name: "gpt-4.1-nano",
        displayName: "GPT-4.1 Nano",
        maxTokens: 8192,
        contextWindow: 64000
    )
    
    static let o3DeepResearch = AIModel(
        id: "o3-deep-research",
        name: "o3-deep-research",
        displayName: "O3 Deep Research",
        maxTokens: 32768,
        contextWindow: 500000
    )
    
    static let o4MiniDeepResearch = AIModel(
        id: "o4-mini-deep-research",
        name: "o4-mini-deep-research",
        displayName: "O4 Mini Deep Research",
        maxTokens: 16384,
        contextWindow: 300000
    )
    
    static let dalle3 = AIModel(
        id: "dall-e-3",
        name: "dall-e-3",
        displayName: "DALL-E 3",
        maxTokens: 4096,
        contextWindow: 8192,
        type: .image
    )
    
    // Chat models only (for regular conversation)
    static let chatModels: [AIModel] = [.gpt5, .gpt5Mini, .gpt5Nano, .gpt41, .gpt41Mini, .gpt41Nano, .o3DeepResearch, .o4MiniDeepResearch]
    
    // Image models (for image generation)
    static let imageModels: [AIModel] = [.dalle3]
    
    // All available models
    static let allModels: [AIModel] = chatModels + imageModels
    
    // Default model (must be a chat model)
    static let defaultModel: AIModel = .gpt41
}

// MARK: - AI Settings

@Observable
class AISettings {
    private let userDefaults = UserDefaults.standard
    private let keychain = KeychainService.shared
    
    // OpenAI API Key (stored in Keychain)
    var openAIAPIKey: String {
        get { keychain.getOpenAIAPIKey() ?? "" }
        set { 
            if newValue.isEmpty {
                keychain.clearOpenAIAPIKey()
            } else {
                keychain.saveOpenAIAPIKey(newValue)
            }
        }
    }
    
    // Settings (stored in UserDefaults)
    var defaultModel: AIModel {
        get {
            if let data = userDefaults.data(forKey: "ai_default_model"),
               let model = try? JSONDecoder().decode(AIModel.self, from: data) {
                return model
            }
            return .defaultModel
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                userDefaults.set(data, forKey: "ai_default_model")
            }
        }
    }
    
    
    var maxHistoryChats: Int {
        get { userDefaults.object(forKey: "ai_max_history_chats") as? Int ?? 100 }
        set { userDefaults.set(newValue, forKey: "ai_max_history_chats") }
    }
    
    var apiGatewayURL: String {
        get { 
            let storedURL = userDefaults.string(forKey: "ai_api_gateway_url") ?? ""
            return storedURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? OpenAIConfig.baseURL : storedURL
        }
        set { userDefaults.set(newValue, forKey: "ai_api_gateway_url") }
    }
    
    // Helper Methods
    func hasOpenAIAPIKey() -> Bool {
        return !openAIAPIKey.isEmpty
    }
    
    func getOpenAIAPIKey() -> String? {
        let key = keychain.getOpenAIAPIKey()
        return key?.isEmpty == false ? key : nil
    }
    
    func availableModels() -> [AIModel] {
        return hasOpenAIAPIKey() ? AIModel.allModels : []
    }
}

// MARK: - Keychain Service

class KeychainService {
    static let shared = KeychainService()
    private init() {}
    
    private let service = "com.devhelper.api-keys"
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