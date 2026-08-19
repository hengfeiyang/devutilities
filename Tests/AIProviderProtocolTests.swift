import Foundation

@main
enum AIProviderProtocolTests {
    static func main() throws {
        try testLegacyResponsesMigration()
        try testLegacyProviderProtocolMigration()
        testBuiltInProtocolFamilies()
        testCurrentBuiltInCatalog()
        testLegacyCatalogMigration()
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
            .openAI: ["gpt-5.6-sol", "gpt-5.6-terra", "gpt-5.6-luna"],
            .deepSeek: ["deepseek-v4-flash", "deepseek-v4-pro"],
            .qwen: ["qwen3.8-max", "qwen3.7-plus", "qwen3.7-flash"],
            .kimi: ["kimi-k3"],
            .glm: ["glm-5.2"],
            .gemini: ["gemini-3.6-flash"],
            .anthropic: ["claude-fable-5", "claude-opus-5", "claude-sonnet-5"]
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
            "gpt-5.6-sol", "gpt-5.6-terra", "gpt-5.6-luna", "proxy-custom"
        ])
        precondition(migrated.models.first { $0.modelId == "gpt-5.6-sol" }?.id == legacySolId)
        precondition(migrated.models.first { $0.modelId == "gpt-5.6-sol" }?.isActive == false)
        precondition(migrated.models.first { $0.modelId == "gpt-5.6-terra" }?.id == legacyTerraId)
        precondition(migrated.models.first { $0.modelId == "gpt-5.6-luna" }?.id == legacyLunaId)
        precondition(migrated.models.first { $0.modelId == "proxy-custom" }?.id == customId)
        precondition(migrated.models.filter { $0.modelId.hasPrefix("gpt-") }.allSatisfy(\.isBuiltIn))
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
