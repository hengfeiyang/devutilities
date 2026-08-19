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
import SwiftUI

@MainActor
@Observable
class ProviderManager {
    static let shared = ProviderManager()

    private(set) var providers: [AIProvider] = []
    private let keychain = ProviderKeychainService.shared
    private let storage = ProviderStorage()

    init() {
        loadProviders()
        setupBuiltInProvidersIfNeeded()
    }

    // MARK: - Provider Management

    func addProvider(_ provider: AIProvider) {
        var newProvider = provider
        // Save API key to keychain if provided
        if !provider.apiKey.isEmpty {
            keychain.saveAPIKey(provider.apiKey, for: provider.id)
            // Clear API key from the provider object for storage
            newProvider.apiKey = ""
        }

        if newProvider.preset == nil {
            newProvider.preset = AIProviderPreset.infer(fromProviderName: newProvider.name)
        }
        if newProvider.preset != nil {
            newProvider = AIProviderCatalog.synchronized(newProvider)
        }

        providers.append(newProvider)
        saveProviders()
    }

    func updateProvider(_ updatedProvider: AIProvider) {
        guard let index = providers.firstIndex(where: { $0.id == updatedProvider.id }) else { return }

        var providerToSave = updatedProvider

        // Handle API key update
        if !updatedProvider.apiKey.isEmpty {
            keychain.saveAPIKey(updatedProvider.apiKey, for: updatedProvider.id)
            providerToSave.apiKey = ""
        }

        providers[index] = providerToSave
        saveProviders()
    }

    func deleteProvider(id: UUID) {
        // Don't allow deletion of built-in providers
        guard let provider = providers.first(where: { $0.id == id }), !provider.isBuiltIn else { return }

        // Clear API key from keychain
        keychain.clearAPIKey(for: id)

        // Remove provider
        providers.removeAll { $0.id == id }
        saveProviders()
    }

    func toggleProviderStatus(id: UUID) {
        guard let index = providers.firstIndex(where: { $0.id == id }) else { return }
        providers[index].isActive.toggle()
        saveProviders()
    }

    // MARK: - Model Management

    func addModelToProvider(providerId: UUID, model: AIModelV2) {
        guard let index = providers.firstIndex(where: { $0.id == providerId }) else { return }
        providers[index].models.append(model)
        saveProviders()
    }

    func updateModel(_ updatedModel: AIModelV2) {
        guard let providerIndex = providers.firstIndex(where: { $0.id == updatedModel.providerId }),
              let modelIndex = providers[providerIndex].models.firstIndex(where: { $0.id == updatedModel.id }) else { return }

        providers[providerIndex].models[modelIndex] = updatedModel
        saveProviders()
    }

    func deleteModel(id: UUID, from providerId: UUID) {
        guard let providerIndex = providers.firstIndex(where: { $0.id == providerId }) else { return }
        providers[providerIndex].models.removeAll { $0.id == id }
        saveProviders()
    }

    func toggleModelStatus(id: UUID, in providerId: UUID) {
        guard let providerIndex = providers.firstIndex(where: { $0.id == providerId }),
              let modelIndex = providers[providerIndex].models.firstIndex(where: { $0.id == id }) else { return }

        providers[providerIndex].models[modelIndex].isActive.toggle()
        saveProviders()
    }

    // MARK: - Utility Methods

    func getAllActiveModels() -> [ProviderModelItem] {
        var items: [ProviderModelItem] = []

        for provider in providers where provider.isActive && !provider.isBuiltIn {
            for model in provider.models where model.isActive {
                items.append(ProviderModelItem(provider: provider, model: model))
            }
        }

        return items.sorted { $0.sortKey < $1.sortKey }
    }

    static func preferredDefaultModel(in items: [ProviderModelItem]) -> ProviderModelItem? {
        items.first { item in
            let preset = item.provider.preset
                ?? AIProviderPreset.infer(fromProviderName: item.provider.name)
            return preset == AIProviderCatalog.preferredDefaultPreset
                && item.model.modelId == AIProviderCatalog.preferredDefaultModelId
        } ?? items.first
    }

    func getProviderById(_ id: UUID) -> AIProvider? {
        return providers.first { $0.id == id }
    }

    func getModelById(_ id: UUID) -> (provider: AIProvider, model: AIModelV2)? {
        for provider in providers {
            if let model = provider.models.first(where: { $0.id == id }) {
                return (provider, model)
            }
        }
        return nil
    }

    func getAPIKey(for providerId: UUID) -> String? {
        return keychain.getAPIKey(for: providerId)
    }

    /// Returns credentials for the active OpenAI provider used by OpenAI TTS.
    func getActiveOpenAIForTTS() -> (baseURL: String, apiKey: String)? {
        for provider in providers where provider.isActive && !provider.isBuiltIn {
            let preset = provider.preset ?? AIProviderPreset.infer(fromProviderName: provider.name)
            guard preset == .openAI,
                  provider.apiProtocol == .openAICompatible,
                  let apiKey = keychain.getAPIKey(for: provider.id),
                  !apiKey.isEmpty else { continue }
            return (provider.baseURL, apiKey)
        }
        return nil
    }

    // MARK: - Connection Testing

    func testProviderConnection(_ provider: AIProvider) async -> (success: Bool, message: String?) {
        // Use the API key from the provider parameter if available, otherwise get from keychain
        let apiKey = !provider.apiKey.isEmpty ? provider.apiKey : (getAPIKey(for: provider.id) ?? "")

        guard !apiKey.isEmpty else {
            return (false, "API key is empty")
        }

        do {
            let result = try await AIChatRouter.testConnection(provider: provider, apiKey: apiKey)

            // Update last tested time if successful
            if result.success, let index = providers.firstIndex(where: { $0.id == provider.id }) {
                providers[index].lastTested = Date()
                saveProviders()
            }

            return result
        } catch {
            return (false, "Network error: \(error.localizedDescription)")
        }
    }

    // MARK: - Data Persistence

    private func loadProviders() {
        providers = storage.loadProviders()
    }

    private func saveProviders() {
        storage.saveProviders(providers)
    }

    private func setupBuiltInProvidersIfNeeded() {
        let existingPresets = Set(providers.filter(\.isBuiltIn).compactMap { provider in
            provider.preset ?? AIProviderPreset.infer(fromProviderName: provider.name)
        })
        let missingProviderTemplates = AIProvider.builtInProviders.filter { template in
            guard let preset = template.preset else { return false }
            return !existingPresets.contains(preset)
        }

        if !missingProviderTemplates.isEmpty {
            providers.append(contentsOf: missingProviderTemplates)
            saveProviders()
        }

        // Sync both internal templates and user-configured preset providers.
        syncBuiltInModels()
    }

    private func syncBuiltInModels() {
        var changed = false

        for index in providers.indices {
            guard providers[index].preset != nil
                    || AIProviderPreset.infer(fromProviderName: providers[index].name) != nil else {
                continue
            }

            let synchronized = AIProviderCatalog.synchronized(providers[index])
            guard synchronized != providers[index] else { continue }
            providers[index] = synchronized
            changed = true
        }

        if changed {
            saveProviders()
        }
    }

}

// MARK: - Provider Storage

private class ProviderStorage {
    private let userDefaults = UserDefaults.standard
    private let providersKey = "ai_providers"

    func loadProviders() -> [AIProvider] {
        guard let data = userDefaults.data(forKey: providersKey),
              let providers = try? JSONDecoder().decode([AIProvider].self, from: data) else {
            return []
        }
        return providers
    }

    func saveProviders(_ providers: [AIProvider]) {
        if let data = try? JSONEncoder().encode(providers) {
            userDefaults.set(data, forKey: providersKey)
        }
    }
}

// MARK: - Provider Keychain Service

class ProviderKeychainService: @unchecked Sendable {
    static let shared = ProviderKeychainService()
    private init() {}

    private let service = "com.hengfeiyang.devutilities.provider-api-keys"

    func saveAPIKey(_ key: String, for providerId: UUID) {
        let data = key.data(using: .utf8)!
        let account = providerId.uuidString

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        // Delete existing item
        SecItemDelete(query as CFDictionary)

        // Add new item
        SecItemAdd(query as CFDictionary, nil)
    }

    func getAPIKey(for providerId: UUID) -> String? {
        let account = providerId.uuidString

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
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

    func clearAPIKey(for providerId: UUID) {
        let account = providerId.uuidString

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        SecItemDelete(query as CFDictionary)
    }
}
