// Copyright 2026 Hengfei Yang.
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

enum AIAPIProtocol: String, Codable, CaseIterable, Identifiable {
    case openAICompatible = "openai_compatible"
    case anthropicMessages = "anthropic_messages"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .openAICompatible:
            return "OpenAI Compatible"
        case .anthropicMessages:
            return "Anthropic Messages"
        }
    }

    var detail: String {
        switch self {
        case .openAICompatible:
            return "For OpenAI, DeepSeek, Qwen, Kimi, GLM, Gemini, and compatible gateways"
        case .anthropicMessages:
            return "For Claude and Anthropic Messages-compatible gateways"
        }
    }
}

enum AIChatEndpoint: String, Codable, CaseIterable, Identifiable {
    case chatCompletions = "chat_completions"
    case responses = "responses"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .chatCompletions:
            return "Chat Completions"
        case .responses:
            return "Responses"
        }
    }
}

enum AIProviderPreset: String, Codable, CaseIterable, Identifiable {
    case openAI
    case deepSeek
    case qwen
    case kimi
    case glm
    case gemini
    case anthropic

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .openAI: return "OpenAI"
        case .deepSeek: return "DeepSeek"
        case .qwen: return "Qwen"
        case .kimi: return "Kimi"
        case .glm: return "GLM"
        case .gemini: return "Gemini"
        case .anthropic: return "Anthropic / Claude"
        }
    }

    var providerName: String {
        self == .anthropic ? "Anthropic" : displayName
    }

    var baseURL: String {
        switch self {
        case .openAI: return "https://api.openai.com/v1"
        case .deepSeek: return "https://api.deepseek.com/v1"
        case .qwen: return "https://dashscope.aliyuncs.com/compatible-mode/v1"
        case .kimi: return "https://api.moonshot.cn/v1"
        case .glm: return "https://open.bigmodel.cn/api/paas/v4"
        case .gemini: return "https://generativelanguage.googleapis.com/v1beta/openai"
        case .anthropic: return "https://api.anthropic.com/v1"
        }
    }

    var apiProtocol: AIAPIProtocol {
        self == .anthropic ? .anthropicMessages : .openAICompatible
    }

    static func infer(fromProviderName name: String) -> AIProviderPreset? {
        switch name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "openai": return .openAI
        case "deepseek": return .deepSeek
        case "qwen": return .qwen
        case "kimi": return .kimi
        case "glm": return .glm
        case "gemini": return .gemini
        case "anthropic", "claude", "anthropic / claude": return .anthropic
        default: return nil
        }
    }

    /// Maps catalog models removed during an upgrade to their replacement tier.
    var modelIdMigrations: [String: String] {
        switch self {
        case .openAI:
            return [
                "gpt-5.4": "gpt-5.6-sol",
                "gpt-5.4-mini": "gpt-5.6-terra",
                "gpt-5.4-nano": "gpt-5.6-luna"
            ]
        case .qwen:
            return [
                "qwen3.7-max": "qwen3.8-max",
                "qwen-plus": "qwen3.7-plus"
            ]
        default:
            return [:]
        }
    }

    var retiredCatalogModelIds: Set<String> {
        switch self {
        case .openAI:
            return Set(modelIdMigrations.keys).union(["gpt-5.4-pro"])
        case .qwen:
            return Set(modelIdMigrations.keys)
        default:
            return []
        }
    }
}

struct AIProvider: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var baseURL: String
    var apiKey: String
    var apiProtocol: AIAPIProtocol
    var preset: AIProviderPreset?
    var isBuiltIn: Bool
    var isActive: Bool
    var models: [AIModelV2]
    let createdAt: Date
    var lastTested: Date?

    init(
        name: String,
        baseURL: String,
        apiKey: String = "",
        apiProtocol: AIAPIProtocol = .openAICompatible,
        preset: AIProviderPreset? = nil,
        isBuiltIn: Bool = false,
        isActive: Bool = true,
        models: [AIModelV2] = []
    ) {
        self.id = UUID()
        self.name = name
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.apiProtocol = apiProtocol
        self.preset = preset
        self.isBuiltIn = isBuiltIn
        self.isActive = isActive
        self.models = models
        self.createdAt = Date()
        self.lastTested = nil
    }

    // Custom Codable implementation to handle missing lastTested field
    enum CodingKeys: String, CodingKey {
        case id, name, baseURL, apiKey, apiProtocol, preset, isBuiltIn, isActive, models, createdAt, lastTested
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        baseURL = try container.decode(String.self, forKey: .baseURL)
        apiKey = try container.decode(String.self, forKey: .apiKey)
        apiProtocol = try container.decodeIfPresent(AIAPIProtocol.self, forKey: .apiProtocol) ?? .openAICompatible
        preset = try container.decodeIfPresent(AIProviderPreset.self, forKey: .preset)
            ?? AIProviderPreset.infer(fromProviderName: name)
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
        try container.encode(apiProtocol, forKey: .apiProtocol)
        try container.encodeIfPresent(preset, forKey: .preset)
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
    var chatEndpoint: AIChatEndpoint
    var capabilities: ModelCapabilities
    var isActive: Bool
    var isBuiltIn: Bool
    let providerId: UUID

    init(
        id: UUID = UUID(),
        name: String,
        modelId: String,
        chatEndpoint: AIChatEndpoint = .chatCompletions,
        capabilities: ModelCapabilities = ModelCapabilities(),
        isActive: Bool = true,
        isBuiltIn: Bool = false,
        providerId: UUID
    ) {
        self.id = id
        self.name = name
        self.modelId = modelId
        self.chatEndpoint = chatEndpoint
        self.capabilities = capabilities
        self.isActive = isActive
        self.isBuiltIn = isBuiltIn
        self.providerId = providerId
    }

    enum CodingKeys: String, CodingKey {
        case id, name, modelId, chatEndpoint, capabilities, isActive, isBuiltIn, providerId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        modelId = try container.decode(String.self, forKey: .modelId)
        capabilities = try container.decode(ModelCapabilities.self, forKey: .capabilities)
        chatEndpoint = try container.decodeIfPresent(AIChatEndpoint.self, forKey: .chatEndpoint)
            ?? (capabilities.legacyUseResponsesAPI ? .responses : .chatCompletions)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        isBuiltIn = try container.decode(Bool.self, forKey: .isBuiltIn)
        providerId = try container.decode(UUID.self, forKey: .providerId)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(modelId, forKey: .modelId)
        try container.encode(chatEndpoint, forKey: .chatEndpoint)
        try container.encode(capabilities, forKey: .capabilities)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(isBuiltIn, forKey: .isBuiltIn)
        try container.encode(providerId, forKey: .providerId)
    }

    var displayName: String {
        return name
    }

    var capabilityIcons: [String] {
        var icons: [String] = []
        if capabilities.supportsReasoning { icons.append("brain") }
        if capabilities.supportsFunctionCalls { icons.append("function") }
        if capabilities.supportsImages { icons.append("photo") }
        if capabilities.supportsImageGeneration { icons.append("photo.badge.plus") }
        if capabilities.supportsWeb { icons.append("globe") }
        return icons
    }
}

struct ModelCapabilities: Codable, Hashable {
    var supportsStreaming: Bool
    var supportsReasoning: Bool
    var supportsFunctionCalls: Bool
    var supportsImages: Bool
    var supportsImageGeneration: Bool
    var supportsWeb: Bool
    var maxTokens: Int
    var contextWindow: Int
    // Read-only migration bridge for v2.12-v2.15 stored models.
    var legacyUseResponsesAPI: Bool

    init(
        supportsStreaming: Bool = true,
        supportsReasoning: Bool = false,
        supportsFunctionCalls: Bool = false,
        supportsImages: Bool = false,
        supportsImageGeneration: Bool = false,
        supportsWeb: Bool = false,
        maxTokens: Int = 4096,
        contextWindow: Int = 4096
    ) {
        self.supportsStreaming = supportsStreaming
        self.supportsReasoning = supportsReasoning
        self.supportsFunctionCalls = supportsFunctionCalls
        self.supportsImages = supportsImages
        self.supportsImageGeneration = supportsImageGeneration
        self.supportsWeb = supportsWeb
        self.maxTokens = maxTokens
        self.contextWindow = contextWindow
        self.legacyUseResponsesAPI = false
    }

    enum CodingKeys: String, CodingKey {
        case supportsStreaming, supportsReasoning, supportsFunctionCalls
        case supportsImages, supportsImageGeneration, supportsWeb, maxTokens, contextWindow
        case legacyUseResponsesAPI = "useResponsesAPI"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        supportsStreaming = try c.decodeIfPresent(Bool.self, forKey: .supportsStreaming) ?? true
        supportsReasoning = try c.decodeIfPresent(Bool.self, forKey: .supportsReasoning) ?? false
        supportsFunctionCalls = try c.decodeIfPresent(Bool.self, forKey: .supportsFunctionCalls) ?? false
        supportsImages = try c.decodeIfPresent(Bool.self, forKey: .supportsImages) ?? false
        supportsImageGeneration = try c.decodeIfPresent(Bool.self, forKey: .supportsImageGeneration) ?? false
        supportsWeb = try c.decodeIfPresent(Bool.self, forKey: .supportsWeb) ?? false
        maxTokens = try c.decodeIfPresent(Int.self, forKey: .maxTokens) ?? 4096
        contextWindow = try c.decodeIfPresent(Int.self, forKey: .contextWindow) ?? 4096
        legacyUseResponsesAPI = try c.decodeIfPresent(Bool.self, forKey: .legacyUseResponsesAPI) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(supportsStreaming, forKey: .supportsStreaming)
        try c.encode(supportsReasoning, forKey: .supportsReasoning)
        try c.encode(supportsFunctionCalls, forKey: .supportsFunctionCalls)
        try c.encode(supportsImages, forKey: .supportsImages)
        try c.encode(supportsImageGeneration, forKey: .supportsImageGeneration)
        try c.encode(supportsWeb, forKey: .supportsWeb)
        try c.encode(maxTokens, forKey: .maxTokens)
        try c.encode(contextWindow, forKey: .contextWindow)
        // The legacy useResponsesAPI flag is decoded for migration only.
    }

    var capabilityIcons: [String] {
        var icons: [String] = []
        if supportsReasoning { icons.append("brain") }
        if supportsFunctionCalls { icons.append("gearshape") }
        if supportsImages { icons.append("photo") }
        if supportsImageGeneration { icons.append("photo.badge.plus") }
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
            name: AIProviderPreset.openAI.providerName,
            baseURL: AIProviderPreset.openAI.baseURL,
            apiProtocol: AIProviderPreset.openAI.apiProtocol,
            preset: .openAI,
            isBuiltIn: true,
            isActive: true
        )

        let sol = AIModelV2(
            name: "GPT-5.6 Sol",
            modelId: "gpt-5.6-sol",
            chatEndpoint: .responses,
            capabilities: ModelCapabilities(
                supportsStreaming: true,
                supportsReasoning: true,
                supportsFunctionCalls: true,
                supportsImages: true,
                supportsImageGeneration: true,
                supportsWeb: true,
                maxTokens: 128_000,
                contextWindow: 1_050_000
            ),
            isBuiltIn: true,
            providerId: provider.id
        )

        let terra = AIModelV2(
            name: "GPT-5.6 Terra",
            modelId: "gpt-5.6-terra",
            chatEndpoint: .responses,
            capabilities: ModelCapabilities(
                supportsStreaming: true,
                supportsReasoning: true,
                supportsFunctionCalls: true,
                supportsImages: true,
                supportsImageGeneration: true,
                supportsWeb: true,
                maxTokens: 128_000,
                contextWindow: 1_050_000
            ),
            isBuiltIn: true,
            providerId: provider.id
        )

        let luna = AIModelV2(
            name: "GPT-5.6 Luna",
            modelId: "gpt-5.6-luna",
            chatEndpoint: .responses,
            capabilities: ModelCapabilities(
                supportsStreaming: true,
                supportsReasoning: true,
                supportsFunctionCalls: true,
                supportsImages: true,
                supportsImageGeneration: true,
                supportsWeb: true,
                maxTokens: 128_000,
                contextWindow: 1_050_000
            ),
            isBuiltIn: true,
            providerId: provider.id
        )

        var providerWithModels = provider
        providerWithModels.models = [sol, terra, luna]
        return providerWithModels
    }

    static func createBuiltInDeepSeek() -> AIProvider {
        let provider = AIProvider(
            name: AIProviderPreset.deepSeek.providerName,
            baseURL: AIProviderPreset.deepSeek.baseURL,
            apiProtocol: AIProviderPreset.deepSeek.apiProtocol,
            preset: .deepSeek,
            isBuiltIn: true,
            isActive: true
        )

        let deepSeekV4Flash = AIModelV2(
            name: "V4-Flash",
            modelId: "deepseek-v4-flash",
            capabilities: ModelCapabilities(
                supportsStreaming: true,
                supportsReasoning: true,
                supportsFunctionCalls: true,
                maxTokens: 384_000,
                contextWindow: 1_000_000
            ),
            isBuiltIn: true,
            providerId: provider.id
        )

        let deepSeekV4Pro = AIModelV2(
            name: "V4-Pro",
            modelId: "deepseek-v4-pro",
            capabilities: ModelCapabilities(
                supportsStreaming: true,
                supportsReasoning: true,
                supportsFunctionCalls: true,
                maxTokens: 384_000,
                contextWindow: 1_000_000
            ),
            isBuiltIn: true,
            providerId: provider.id
        )

        var providerWithModels = provider
        providerWithModels.models = [deepSeekV4Flash, deepSeekV4Pro]
        return providerWithModels
    }

    static func createBuiltInAnthropic() -> AIProvider {
        let provider = AIProvider(
            name: AIProviderPreset.anthropic.providerName,
            baseURL: AIProviderPreset.anthropic.baseURL,
            apiProtocol: AIProviderPreset.anthropic.apiProtocol,
            preset: .anthropic,
            isBuiltIn: true,
            isActive: true
        )

        let fable = AIModelV2(
            name: "Claude Fable 5",
            modelId: "claude-fable-5",
            capabilities: ModelCapabilities(
                supportsStreaming: true,
                supportsReasoning: true,
                supportsFunctionCalls: true,
                supportsImages: true,
                maxTokens: 128_000,
                contextWindow: 1_000_000
            ),
            isBuiltIn: true,
            providerId: provider.id
        )

        let opus = AIModelV2(
            name: "Claude Opus 5",
            modelId: "claude-opus-5",
            capabilities: ModelCapabilities(
                supportsStreaming: true,
                supportsReasoning: true,
                supportsFunctionCalls: true,
                supportsImages: true,
                maxTokens: 128_000,
                contextWindow: 1_000_000
            ),
            isBuiltIn: true,
            providerId: provider.id
        )

        let sonnet = AIModelV2(
            name: "Claude Sonnet 5",
            modelId: "claude-sonnet-5",
            capabilities: ModelCapabilities(
                supportsStreaming: true,
                supportsReasoning: true,
                supportsFunctionCalls: true,
                supportsImages: true,
                maxTokens: 128_000,
                contextWindow: 1_000_000
            ),
            isBuiltIn: true,
            providerId: provider.id
        )

        var providerWithModels = provider
        providerWithModels.models = [fable, opus, sonnet]
        return providerWithModels
    }

    static func createBuiltInQwen() -> AIProvider {
        let provider = AIProvider(
            name: AIProviderPreset.qwen.providerName,
            baseURL: AIProviderPreset.qwen.baseURL,
            apiProtocol: AIProviderPreset.qwen.apiProtocol,
            preset: .qwen,
            isBuiltIn: true
        )
        let max = AIModelV2(
            name: "Qwen 3.8 Max",
            modelId: "qwen3.8-max",
            chatEndpoint: .responses,
            capabilities: ModelCapabilities(
                supportsReasoning: true,
                supportsFunctionCalls: true,
                supportsImages: true,
                supportsWeb: true,
                maxTokens: 65_536,
                contextWindow: 1_000_000
            ),
            isBuiltIn: true,
            providerId: provider.id
        )
        let plus = AIModelV2(
            name: "Qwen 3.7 Plus",
            modelId: "qwen3.7-plus",
            chatEndpoint: .responses,
            capabilities: ModelCapabilities(
                supportsReasoning: true,
                supportsFunctionCalls: true,
                supportsImages: true,
                supportsWeb: true,
                maxTokens: 65_536,
                contextWindow: 1_000_000
            ),
            isBuiltIn: true,
            providerId: provider.id
        )
        let flash = AIModelV2(
            name: "Qwen 3.7 Flash",
            modelId: "qwen3.7-flash",
            chatEndpoint: .responses,
            capabilities: ModelCapabilities(
                supportsReasoning: true,
                supportsFunctionCalls: true,
                supportsImages: true,
                supportsWeb: true,
                maxTokens: 65_536,
                contextWindow: 1_000_000
            ),
            isBuiltIn: true,
            providerId: provider.id
        )
        var providerWithModels = provider
        providerWithModels.models = [max, plus, flash]
        return providerWithModels
    }

    static func createBuiltInKimi() -> AIProvider {
        let provider = AIProvider(
            name: AIProviderPreset.kimi.providerName,
            baseURL: AIProviderPreset.kimi.baseURL,
            apiProtocol: AIProviderPreset.kimi.apiProtocol,
            preset: .kimi,
            isBuiltIn: true
        )
        let kimi = AIModelV2(
            name: "Kimi K3",
            modelId: "kimi-k3",
            capabilities: ModelCapabilities(
                supportsReasoning: true,
                supportsFunctionCalls: true,
                supportsImages: true,
                maxTokens: 131_072,
                contextWindow: 1_048_576
            ),
            isBuiltIn: true,
            providerId: provider.id
        )
        var providerWithModels = provider
        providerWithModels.models = [kimi]
        return providerWithModels
    }

    static func createBuiltInGLM() -> AIProvider {
        let provider = AIProvider(
            name: AIProviderPreset.glm.providerName,
            baseURL: AIProviderPreset.glm.baseURL,
            apiProtocol: AIProviderPreset.glm.apiProtocol,
            preset: .glm,
            isBuiltIn: true
        )
        let glm = AIModelV2(
            name: "GLM 5.2",
            modelId: "glm-5.2",
            capabilities: ModelCapabilities(
                supportsReasoning: true,
                supportsFunctionCalls: true,
                maxTokens: 128_000,
                contextWindow: 1_000_000
            ),
            isBuiltIn: true,
            providerId: provider.id
        )
        var providerWithModels = provider
        providerWithModels.models = [glm]
        return providerWithModels
    }

    static func createBuiltInGemini() -> AIProvider {
        let provider = AIProvider(
            name: AIProviderPreset.gemini.providerName,
            baseURL: AIProviderPreset.gemini.baseURL,
            apiProtocol: AIProviderPreset.gemini.apiProtocol,
            preset: .gemini,
            isBuiltIn: true
        )
        let flash = AIModelV2(
            name: "Gemini 3.6 Flash",
            modelId: "gemini-3.6-flash",
            capabilities: ModelCapabilities(
                supportsReasoning: true,
                supportsFunctionCalls: true,
                supportsImages: true,
                maxTokens: 65536,
                contextWindow: 1048576
            ),
            isBuiltIn: true,
            providerId: provider.id
        )
        var providerWithModels = provider
        providerWithModels.models = [flash]
        return providerWithModels
    }

    static let builtInProviders: [AIProvider] = [
        .createBuiltInOpenAI(),
        .createBuiltInDeepSeek(),
        .createBuiltInQwen(),
        .createBuiltInKimi(),
        .createBuiltInGLM(),
        .createBuiltInGemini(),
        .createBuiltInAnthropic()
    ]
}

extension AIProviderPreset {
    func makeTemplate() -> AIProvider {
        switch self {
        case .openAI: return .createBuiltInOpenAI()
        case .deepSeek: return .createBuiltInDeepSeek()
        case .qwen: return .createBuiltInQwen()
        case .kimi: return .createBuiltInKimi()
        case .glm: return .createBuiltInGLM()
        case .gemini: return .createBuiltInGemini()
        case .anthropic: return .createBuiltInAnthropic()
        }
    }
}

enum AIProviderCatalog {
    static let preferredDefaultPreset = AIProviderPreset.openAI
    static let preferredDefaultModelId = "gpt-5.6-sol"

    /// Refreshes catalog-managed models while retaining provider credentials,
    /// custom models, enablement choices, and model UUIDs used by saved chats.
    static func synchronized(_ provider: AIProvider) -> AIProvider {
        guard let preset = provider.preset ?? AIProviderPreset.infer(fromProviderName: provider.name) else {
            return provider
        }

        let template = preset.makeTemplate()
        let currentCatalogIds = Set(template.models.map(\.modelId))
        let managedIds = currentCatalogIds.union(preset.retiredCatalogModelIds)

        var updated = provider
        updated.preset = preset
        updated.apiProtocol = template.apiProtocol

        var reusedModelIds = Set<UUID>()
        let catalogModels = template.models.map { templateModel -> AIModelV2 in
            let existing = provider.models.first(where: { $0.modelId == templateModel.modelId })
                ?? provider.models.first(where: {
                    preset.modelIdMigrations[$0.modelId] == templateModel.modelId
                })
            if let existing {
                reusedModelIds.insert(existing.id)
            }

            return AIModelV2(
                id: existing?.id ?? UUID(),
                name: templateModel.name,
                modelId: templateModel.modelId,
                chatEndpoint: templateModel.chatEndpoint,
                capabilities: templateModel.capabilities,
                isActive: existing?.isActive ?? templateModel.isActive,
                isBuiltIn: true,
                providerId: provider.id
            )
        }

        let customModels = provider.models.filter { model in
            !model.isBuiltIn
                && !managedIds.contains(model.modelId)
                && !reusedModelIds.contains(model.id)
        }
        updated.models = catalogModels + customModels
        return updated
    }
}
