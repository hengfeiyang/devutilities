import Foundation

@main
enum AIProviderProtocolTests {
    static func main() throws {
        try testLegacyResponsesMigration()
        try testLegacyProviderProtocolMigration()
        testBuiltInProtocolFamilies()
        testCurrentBuiltInCatalog()
        testLegacyCatalogMigration()
        testLatestCatalogMigration()
        testAnthropicStreamEvents()
        print("AI provider protocol tests passed")
    }

    private static func testLegacyResponsesMigration() throws {
        let modelJSON = #"""
        {
          "id": "00000000-0000-0000-0000-000000000001",
          "name": "Legacy Responses Model",
          "modelId": "legacy-pro",
          "capabilities": {
            "supportsStreaming": true,
            "supportsReasoning": true,
            "supportsFunctionCalls": false,
            "supportsImages": false,
            "supportsWeb": false,
            "maxTokens": 4096,
            "contextWindow": 8192,
            "useResponsesAPI": true
          },
          "isActive": true,
          "isBuiltIn": false,
          "providerId": "00000000-0000-0000-0000-000000000002"
        }
        """#.data(using: .utf8)!

        let model = try JSONDecoder().decode(AIModelV2.self, from: modelJSON)
        precondition(model.chatEndpoint == .responses)

        let encoded = try JSONEncoder().encode(model)
        let object = try JSONSerialization.jsonObject(with: encoded) as! [String: Any]
        precondition(object["chatEndpoint"] as? String == AIChatEndpoint.responses.rawValue)
        let capabilities = object["capabilities"] as! [String: Any]
        precondition(capabilities["useResponsesAPI"] == nil)
    }

    private static func testLegacyProviderProtocolMigration() throws {
        let providerJSON = #"""
        {
          "id": "00000000-0000-0000-0000-000000000003",
          "name": "Legacy Provider",
          "baseURL": "https://example.com/v1",
          "apiKey": "",
          "isBuiltIn": false,
          "isActive": true,
          "models": [],
          "createdAt": 0
        }
        """#.data(using: .utf8)!

        let provider = try JSONDecoder().decode(AIProvider.self, from: providerJSON)
        precondition(provider.apiProtocol == .openAICompatible)
        precondition(provider.preset == nil)

        let openAIJSON = String(data: providerJSON, encoding: .utf8)!
            .replacingOccurrences(of: "Legacy Provider", with: "OpenAI")
            .data(using: .utf8)!
        let openAI = try JSONDecoder().decode(AIProvider.self, from: openAIJSON)
        precondition(openAI.preset == .openAI)
    }

    private static func testBuiltInProtocolFamilies() {
        let protocols = Set(AIProvider.builtInProviders.map(\.apiProtocol))
        precondition(protocols == Set(AIAPIProtocol.allCases))
        precondition(AIProvider.createBuiltInOpenAI().models.contains { $0.chatEndpoint == .responses })
        precondition(AIProvider.createBuiltInAnthropic().models.allSatisfy { $0.chatEndpoint == .chatCompletions })
    }

    private static func testCurrentBuiltInCatalog() {
        let expectedModels: [AIProviderPreset: [String]] = [
            .openAI: ["gpt-6.1-sol", "gpt-6-sol", "gpt-6-luna", "gpt-6-astra"],
            .deepSeek: ["deepseek-flash", "deepseek-v4-pro"],
            .qwen: ["qwen3.8-max", "qwen3.7-plus", "qwen3.7-flash"],
            .kimi: ["kimi-k3"],
            .glm: ["glm-5.2"],
            .gemini: ["gemini-3.6-flash"],
            .anthropic: ["claude-fable-5-1", "claude-opus-5-5", "claude-sonnet-5-5"]
        ]

        precondition(AIProvider.builtInProviders.count == AIProviderPreset.allCases.count)
        for provider in AIProvider.builtInProviders {
            guard let preset = provider.preset else { preconditionFailure("Missing provider preset") }
            precondition(provider.apiProtocol == preset.apiProtocol)
            precondition(provider.baseURL == preset.baseURL)
            precondition(provider.models.map(\.modelId) == expectedModels[preset])
            precondition(provider.models.allSatisfy(\.isBuiltIn))
        }

        let openAI = AIProvider.createBuiltInOpenAI()
        precondition(openAI.models.allSatisfy { $0.chatEndpoint == .responses })
        precondition(openAI.models.allSatisfy { $0.capabilities.contextWindow == 1_050_000 })
        precondition(openAI.models.allSatisfy { $0.capabilities.maxTokens == 128_000 })
        precondition(openAI.models.allSatisfy { $0.capabilities.supportsImages && $0.capabilities.supportsWeb && $0.capabilities.supportsImageGeneration })
        precondition(AIProviderCatalog.preferredDefaultModelId == "gpt-6.1-sol")

        let deepSeek = AIProvider.createBuiltInDeepSeek()
        precondition(deepSeek.models.allSatisfy { $0.chatEndpoint == .chatCompletions })
        precondition(deepSeek.models.allSatisfy { $0.capabilities.contextWindow == 1_048_576 && $0.capabilities.maxTokens == 393_216 })
        precondition(deepSeek.models[0].capabilities.supportsImages)
        precondition(!deepSeek.models[1].capabilities.supportsImages)
    }

    private static func testLegacyCatalogMigration() {
        var provider = AIProvider(
            name: "OpenAI",
            baseURL: "https://proxy.example.com/v1",
            apiProtocol: .openAICompatible,
            isBuiltIn: false
        )
        let legacySolId = UUID()
        let legacyTerraId = UUID()
        let legacyLunaId = UUID()
        let customId = UUID()
        provider.models = [
            AIModelV2(id: legacySolId, name: "GPT-5.4", modelId: "gpt-5.4", isActive: false, providerId: provider.id),
            AIModelV2(id: legacyTerraId, name: "GPT-5.4 Mini", modelId: "gpt-5.4-mini", providerId: provider.id),
            AIModelV2(id: legacyLunaId, name: "GPT-5.4 Nano", modelId: "gpt-5.4-nano", providerId: provider.id),
            AIModelV2(name: "GPT-5.4 Pro", modelId: "gpt-5.4-pro", providerId: provider.id),
            AIModelV2(id: customId, name: "Proxy Custom", modelId: "proxy-custom", providerId: provider.id)
        ]

        let migrated = AIProviderCatalog.synchronized(provider)
        precondition(migrated.preset == .openAI)
        precondition(migrated.baseURL == "https://proxy.example.com/v1")
        precondition(migrated.models.map(\.modelId) == [
            "gpt-6.1-sol", "gpt-6-sol", "gpt-6-luna", "gpt-6-astra", "proxy-custom"
        ])
        precondition(migrated.models.first { $0.modelId == "gpt-6.1-sol" }?.id == legacySolId)
        precondition(migrated.models.first { $0.modelId == "gpt-6.1-sol" }?.isActive == false)
        precondition(migrated.models.first { $0.modelId == "gpt-6-sol" }?.id == legacyTerraId)
        precondition(migrated.models.first { $0.modelId == "gpt-6-luna" }?.id == legacyLunaId)
        precondition(migrated.models.first { $0.modelId == "proxy-custom" }?.id == customId)
        precondition(migrated.models.filter { $0.modelId.hasPrefix("gpt-") }.allSatisfy(\.isBuiltIn))
    }

    private static func testLatestCatalogMigration() {
        let previousCatalogs: [(AIProviderPreset, [String])] = [
            (.openAI, ["gpt-5.6-sol", "gpt-5.6-terra", "gpt-5.6-luna"]),
            (.deepSeek, ["deepseek-v4-flash", "deepseek-v4-pro"]),
            (.deepSeek, ["deepseek-v4-flash-vision-exp", "deepseek-v4-pro"]),
            (.anthropic, ["claude-fable-5", "claude-opus-5", "claude-sonnet-5"])
        ]
        for (preset, modelIds) in previousCatalogs {
            var provider = AIProvider(
                name: preset.providerName,
                baseURL: "https://proxy.example.com/v1",
                apiKey: "test-placeholder",
                apiProtocol: preset.apiProtocol,
                preset: preset,
                isActive: false
            )
            provider.lastTested = Date(timeIntervalSince1970: 100)
            provider.models = modelIds.enumerated().map { index, modelId in
                AIModelV2(name: modelId, modelId: modelId, isActive: index != 0, isBuiltIn: true, providerId: provider.id)
            }
            let custom = AIModelV2(name: "Custom", modelId: "custom-model", chatEndpoint: .responses, providerId: provider.id)
            provider.models.append(custom)

            let migrated = AIProviderCatalog.synchronized(provider)
            precondition(migrated.id == provider.id)
            precondition(migrated.baseURL == provider.baseURL && migrated.apiKey == provider.apiKey)
            precondition(migrated.isActive == provider.isActive && migrated.isBuiltIn == provider.isBuiltIn)
            precondition(migrated.createdAt == provider.createdAt && migrated.lastTested == provider.lastTested)
            for previous in provider.models where previous.isBuiltIn {
                let target = preset.modelIdMigrations[previous.modelId] ?? previous.modelId
                let replacement = migrated.models.first { $0.modelId == target }
                precondition(replacement?.id == previous.id, "Saved chat model identity must survive migration")
                precondition(replacement?.isActive == previous.isActive)
                precondition(replacement?.providerId == provider.id)
            }
            precondition(migrated.models.last == custom)
            precondition(Set(migrated.models.map(\.modelId)).count == migrated.models.count)
            precondition(AIProviderCatalog.synchronized(migrated) == migrated, "Catalog refresh must be idempotent")
            precondition(migrated.models.filter(\.isBuiltIn).allSatisfy { !preset.retiredCatalogModelIds.contains($0.modelId) })
        }
    }

    private static func testAnthropicStreamEvents() {
        let start = #"{"type":"message_start","message":{"usage":{"input_tokens":12}}}"#
        let thinking = #"{"type":"content_block_delta","delta":{"type":"thinking_delta","thinking":"plan"}}"#
        let text = #"{"type":"content_block_delta","delta":{"type":"text_delta","text":"hello"}}"#
        let usage = #"{"type":"message_delta","usage":{"output_tokens":7}}"#
        let stop = #"{"type":"message_stop"}"#
        let error = #"{"type":"error","error":{"message":"bad request"}}"#

        precondition(AnthropicStreamCodec.decode(dataPayload: start) == [.inputTokens(12)])
        precondition(AnthropicStreamCodec.decode(dataPayload: thinking) == [.reasoning("plan")])
        precondition(AnthropicStreamCodec.decode(dataPayload: text) == [.text("hello")])
        precondition(AnthropicStreamCodec.decode(dataPayload: usage) == [.outputTokens(7)])
        precondition(AnthropicStreamCodec.decode(dataPayload: stop) == [.completed])
        precondition(AnthropicStreamCodec.decode(dataPayload: error) == [.failure("bad request")])
    }
}
