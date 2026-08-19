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

import SwiftUI

struct AddModelView: View {
    let providerId: UUID
    let providerManager: ProviderManager
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var modelId = ""
    @State private var chatEndpoint: AIChatEndpoint = .chatCompletions
    @State private var capabilities = ModelCapabilities()

    private var apiProtocol: AIAPIProtocol {
        providerManager.getProviderById(providerId)?.apiProtocol ?? .openAICompatible
    }

    var body: some View {
        Form {
            Section("Model Details") {
                TextField("Model Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Model ID", text: $modelId)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Text("Model ID is the identifier used in API requests")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if apiProtocol == .openAICompatible {
                    Picker("Chat Endpoint", selection: $chatEndpoint) {
                        ForEach(AIChatEndpoint.allCases) { endpoint in
                            Text(endpoint.displayName).tag(endpoint)
                        }
                    }
                    Text("Use Responses only for models or OpenAI-native tools that require /responses.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Section("Capabilities") {
                Toggle("Supports Streaming", isOn: $capabilities.supportsStreaming)
                Toggle("Supports Reasoning", isOn: $capabilities.supportsReasoning)
                Toggle("Supports Function Calls", isOn: $capabilities.supportsFunctionCalls)
                Toggle("Supports Image Input", isOn: $capabilities.supportsImages)
                Toggle("Supports Image Generation", isOn: $capabilities.supportsImageGeneration)
                Toggle("Supports Web Browsing", isOn: $capabilities.supportsWeb)
            }

            Section("Limits") {
                HStack {
                    Text("Max Tokens")
                    Spacer()
                    TextField("4096", value: $capabilities.maxTokens, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }

                HStack {
                    Text("Context Window")
                    Spacer()
                    TextField("4096", value: $capabilities.contextWindow, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }
            }
        }
        .formStyle(GroupedFormStyle())
        .navigationTitle("Add Model")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    addModel()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty || modelId.isEmpty)
            }
        }
        .frame(width: 520, height: 480)
    }

    private func addModel() {
        let model = AIModelV2(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            modelId: modelId.trimmingCharacters(in: .whitespacesAndNewlines),
            chatEndpoint: chatEndpoint,
            capabilities: capabilities,
            providerId: providerId
        )

        providerManager.addModelToProvider(providerId: providerId, model: model)
        dismiss()
    }
}

struct EditModelView: View {
    let model: AIModelV2
    let providerManager: ProviderManager
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var modelId: String
    @State private var chatEndpoint: AIChatEndpoint
    @State private var capabilities: ModelCapabilities

    private var apiProtocol: AIAPIProtocol {
        providerManager.getProviderById(model.providerId)?.apiProtocol ?? .openAICompatible
    }

    init(model: AIModelV2, providerManager: ProviderManager) {
        self.model = model
        self.providerManager = providerManager
        self._name = State(initialValue: model.name)
        self._modelId = State(initialValue: model.modelId)
        self._chatEndpoint = State(initialValue: model.chatEndpoint)
        self._capabilities = State(initialValue: model.capabilities)
    }

    var body: some View {
        Form {
            Section("Model Details") {
                TextField("Model Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Model ID", text: $modelId)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Text("Model ID is the identifier used in API requests")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if apiProtocol == .openAICompatible {
                    Picker("Chat Endpoint", selection: $chatEndpoint) {
                        ForEach(AIChatEndpoint.allCases) { endpoint in
                            Text(endpoint.displayName).tag(endpoint)
                        }
                    }
                    Text("Use Responses only for models or OpenAI-native tools that require /responses.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Section("Capabilities") {
                Toggle("Supports Streaming", isOn: $capabilities.supportsStreaming)
                Toggle("Supports Reasoning", isOn: $capabilities.supportsReasoning)
                Toggle("Supports Function Calls", isOn: $capabilities.supportsFunctionCalls)
                Toggle("Supports Image Input", isOn: $capabilities.supportsImages)
                Toggle("Supports Image Generation", isOn: $capabilities.supportsImageGeneration)
                Toggle("Supports Web Browsing", isOn: $capabilities.supportsWeb)
            }

            Section("Limits") {
                HStack {
                    Text("Max Tokens")
                    Spacer()
                    TextField("4096", value: $capabilities.maxTokens, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }

                HStack {
                    Text("Context Window")
                    Spacer()
                    TextField("4096", value: $capabilities.contextWindow, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }
            }
        }
        .formStyle(GroupedFormStyle())
        .navigationTitle("Edit Model")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveModel()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty || modelId.isEmpty)
            }
        }
        .frame(width: 520, height: 480)
    }

    private func saveModel() {
        var updatedModel = model
        updatedModel.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedModel.modelId = modelId.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedModel.chatEndpoint = chatEndpoint
        updatedModel.capabilities = capabilities

        providerManager.updateModel(updatedModel)
        dismiss()
    }
}

#Preview {
    AddModelView(
        providerId: UUID(),
        providerManager: ProviderManager.shared
    )
}
