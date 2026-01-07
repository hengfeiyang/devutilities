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

        for provider in providers where provider.isActive {
            for model in provider.models where model.isActive {
                items.append(ProviderModelItem(provider: provider, model: model))
            }
        }

        return items.sorted { $0.sortKey < $1.sortKey }
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

    // MARK: - Connection Testing

    func testProviderConnection(_ provider: AIProvider) async -> (success: Bool, message: String?) {
        // Use the API key from the provider parameter if available, otherwise get from keychain
        let apiKey = !provider.apiKey.isEmpty ? provider.apiKey : (getAPIKey(for: provider.id) ?? "")

        guard !apiKey.isEmpty else {
            return (false, "API key is empty")
        }

        // Test connection by calling the /models endpoint (OpenAI-compatible)
        let baseURL = provider.baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: "\(baseURL)/models") else {
            return (false, "Invalid base URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return (false, "Invalid HTTP response")
            }

            // Consider 200-299 status codes as success
            let success = (200...299).contains(httpResponse.statusCode)

            // Update last tested time if successful
            if success, let index = providers.firstIndex(where: { $0.id == provider.id }) {
                providers[index].lastTested = Date()
                saveProviders()
            }

            if !success {
                // Try to extract error message from response
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorJson["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    return (false, "HTTP \(httpResponse.statusCode): \(message)")
                }
                return (false, "HTTP status code: \(httpResponse.statusCode)")
            }

            return (true, nil)
        } catch {
            // Network error or timeout
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
        // Check if built-in providers already exist
        let hasBuiltInOpenAI = providers.contains { $0.name == "OpenAI" && $0.isBuiltIn }
        let hasBuiltInDeepSeek = providers.contains { $0.name == "DeepSeek" && $0.isBuiltIn }

        if !hasBuiltInOpenAI || !hasBuiltInDeepSeek {
            // Add missing built-in providers
            if !hasBuiltInOpenAI {
                let openAIProvider = AIProvider.createBuiltInOpenAI()
                providers.append(openAIProvider)
            }

            if !hasBuiltInDeepSeek {
                let deepSeekProvider = AIProvider.createBuiltInDeepSeek()
                providers.append(deepSeekProvider)
            }

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
