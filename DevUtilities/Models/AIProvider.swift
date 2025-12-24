// Copyright 2025 Hengfei Yang.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import Foundation

// MARK: - AI Provider Models

struct AIProvider: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var baseURL: String
    var apiKey: String
    var isBuiltIn: Bool
    var isActive: Bool
    var models: [AIModelV2]
    let createdAt: Date
    var lastTested: Date?

    init(
        name: String,
        baseURL: String,
        apiKey: String = "",
        isBuiltIn: Bool = false,
        isActive: Bool = true,
        models: [AIModelV2] = []
    ) {
        self.id = UUID()
        self.name = name
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.isBuiltIn = isBuiltIn
        self.isActive = isActive
        self.models = models
        self.createdAt = Date()
        self.lastTested = nil
    }

    // Custom Codable implementation to handle missing lastTested field
    enum CodingKeys: String, CodingKey {
        case id, name, baseURL, apiKey, isBuiltIn, isActive, models, createdAt, lastTested
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        baseURL = try container.decode(String.self, forKey: .baseURL)
        apiKey = try container.decode(String.self, forKey: .apiKey)
        isBuiltIn = try container.decode(Bool.self, forKey: .isBuiltIn)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        models = try container.decode([AIModelV2].self, forKey: .models)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        lastTested = try container.decodeIfPresent(Date.self, forKey: .lastTested)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(baseURL, forKey: .baseURL)
        try container.encode(apiKey, forKey: .apiKey)
        try container.encode(isBuiltIn, forKey: .isBuiltIn)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(models, forKey: .models)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(lastTested, forKey: .lastTested)
    }

    var statusColor: String {
        if !isActive { return "red" }
        if lastTested == nil { return "yellow" }
        return "green"
    }

    var statusText: String {
        if !isActive { return "Inactive" }
        if lastTested == nil { return "Untested" }
        return "Active"
    }
}

struct AIModelV2: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var modelId: String
    var capabilities: ModelCapabilities
    var isActive: Bool
    var isBuiltIn: Bool
    let providerId: UUID

    init(
        name: String,
        modelId: String,
        capabilities: ModelCapabilities = ModelCapabilities(),
        isActive: Bool = true,
        isBuiltIn: Bool = false,
        providerId: UUID
    ) {
        self.id = UUID()
        self.name = name
        self.modelId = modelId
        self.capabilities = capabilities
        self.isActive = isActive
        self.isBuiltIn = isBuiltIn
        self.providerId = providerId
    }

    var displayName: String {
        return name
    }

    var capabilityIcons: [String] {
        var icons: [String] = []
        if capabilities.supportsReasoning { icons.append("brain") }
        if capabilities.supportsFunctionCalls { icons.append("function") }
        if capabilities.supportsImages { icons.append("photo") }
        if capabilities.supportsWeb { icons.append("globe") }
        return icons
    }
}

struct ModelCapabilities: Codable, Hashable {
    var supportsStreaming: Bool
    var supportsReasoning: Bool
    var supportsFunctionCalls: Bool
    var supportsImages: Bool
    var supportsWeb: Bool
    var maxTokens: Int
    var contextWindow: Int

    init(
        supportsStreaming: Bool = true,
        supportsReasoning: Bool = false,
        supportsFunctionCalls: Bool = false,
        supportsImages: Bool = false,
        supportsWeb: Bool = false,
        maxTokens: Int = 4096,
        contextWindow: Int = 4096
    ) {
        self.supportsStreaming = supportsStreaming
        self.supportsReasoning = supportsReasoning
        self.supportsFunctionCalls = supportsFunctionCalls
        self.supportsImages = supportsImages
        self.supportsWeb = supportsWeb
        self.maxTokens = maxTokens
        self.contextWindow = contextWindow
    }

    var capabilityIcons: [String] {
        var icons: [String] = []
        if supportsReasoning { icons.append("brain") }
        if supportsFunctionCalls { icons.append("gearshape") }
        if supportsImages { icons.append("photo") }
        if supportsWeb { icons.append("globe") }
        return icons
    }
}

// MARK: - Provider+Model Display Item

struct ProviderModelItem: Identifiable, Hashable, Codable {
    var id = UUID()
    let provider: AIProvider
    let model: AIModelV2

    var displayName: String {
        return "\(provider.name)/\(model.name)"
    }

    var sortKey: String {
        return "\(provider.name.lowercased())/\(model.name.lowercased())"
    }

    var isAvailable: Bool {
        return provider.isActive && model.isActive
    }
}

// MARK: - Built-in Providers

extension AIProvider {
    static func createBuiltInOpenAI() -> AIProvider {
        let provider = AIProvider(
            name: "OpenAI",
            baseURL: "https://api.openai.com/v1",
            isBuiltIn: true,
            isActive: true
        )

        // GPT-5 Series
        let gpt5 = AIModelV2(
            name: "GPT-5.2",
            modelId: "gpt-5.2",
            capabilities: ModelCapabilities(
                supportsStreaming: true,
                supportsFunctionCalls: true,
                supportsImages: true,
                maxTokens: 8192,
                contextWindow: 200000
            ),
            isBuiltIn: true,
            providerId: provider.id
        )

        let gpt5Mini = AIModelV2(
            name: "GPT-5 Mini",
            modelId: "gpt-5-mini",
            capabilities: ModelCapabilities(
                supportsStreaming: true,
                supportsFunctionCalls: true,
                supportsImages: true,
                maxTokens: 16384,
                contextWindow: 128000
            ),
            isBuiltIn: true,
            providerId: provider.id
        )

        let gpt5Nano = AIModelV2(
            name: "GPT-5 Nano",
            modelId: "gpt-5-nano",
            capabilities: ModelCapabilities(
                supportsStreaming: true,
                supportsFunctionCalls: true,
                maxTokens: 8192,
                contextWindow: 64000
            ),
            isBuiltIn: true,
            providerId: provider.id
        )

        // GPT-4.1 Series
        let gpt41 = AIModelV2(
            name: "GPT-4.1",
            modelId: "gpt-4.1",
            capabilities: ModelCapabilities(
                supportsStreaming: true,
                supportsFunctionCalls: true,
                supportsImages: true,
                maxTokens: 4096,
                contextWindow: 128000
            ),
            isBuiltIn: true,
            providerId: provider.id
        )

        let gpt41Mini = AIModelV2(
            name: "GPT-4.1 Mini",
            modelId: "gpt-4.1-mini",
            capabilities: ModelCapabilities(
                supportsStreaming: true,
                supportsFunctionCalls: true,
                maxTokens: 16384,
                contextWindow: 128000
            ),
            isBuiltIn: true,
            providerId: provider.id
        )

        let gpt41Nano = AIModelV2(
            name: "GPT-4.1 Nano",
            modelId: "gpt-4.1-nano",
            capabilities: ModelCapabilities(
                supportsStreaming: true,
                supportsFunctionCalls: true,
                maxTokens: 8192,
                contextWindow: 64000
            ),
            isBuiltIn: true,
            providerId: provider.id
        )

        var providerWithModels = provider
        providerWithModels.models = [
            gpt5, gpt5Mini, gpt5Nano,
            gpt41, gpt41Mini, gpt41Nano
        ]
        return providerWithModels
    }

    static func createBuiltInDeepSeek() -> AIProvider {
        let provider = AIProvider(
            name: "DeepSeek",
            baseURL: "https://api.deepseek.com/v1",
            isBuiltIn: true,
            isActive: true
        )

        let deepSeekChat = AIModelV2(
            name: "Chat",
            modelId: "deepseek-chat",
            capabilities: ModelCapabilities(
                supportsStreaming: true,
                supportsReasoning: false,
                maxTokens: 8192,
                contextWindow: 64000
            ),
            isBuiltIn: true,
            providerId: provider.id
        )

        let deepSeekReasoner = AIModelV2(
            name: "Reasoner",
            modelId: "deepseek-reasoner",
            capabilities: ModelCapabilities(
                supportsStreaming: true,
                supportsReasoning: true,
                maxTokens: 8192,
                contextWindow: 64000
            ),
            isBuiltIn: true,
            providerId: provider.id
        )

        var providerWithModels = provider
        providerWithModels.models = [deepSeekChat, deepSeekReasoner]
        return providerWithModels
    }

    static let builtInProviders: [AIProvider] = [
        .createBuiltInOpenAI(),
        .createBuiltInDeepSeek()
    ]
}
