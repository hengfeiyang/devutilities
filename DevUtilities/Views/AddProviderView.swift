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

struct AddProviderView: View {
    let providerManager: ProviderManager
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var baseURL = ""
    @State private var apiKey = ""
    @State private var apiProtocol: AIAPIProtocol = .openAICompatible
    @State private var selectedPreset: AIProviderPreset?
    @State private var showingKeySecurely = false
    var body: some View {
        Form {
            Section("Provider Details") {
                Menu("Use Provider Preset") {
                    ForEach(AIProviderPreset.allCases) { preset in
                        Button(preset.displayName) {
                            selectedPreset = preset
                            name = preset.providerName
                            baseURL = preset.baseURL
                            apiProtocol = preset.apiProtocol
                        }
                    }
                }

                TextField("Provider Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Base URL", text: $baseURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Picker("API Protocol", selection: $apiProtocol) {
                    ForEach(AIAPIProtocol.allCases) { apiProtocol in
                        Text(apiProtocol.displayName).tag(apiProtocol)
                    }
                }

                Text(apiProtocol.detail)
                    .font(.caption)
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("API Key")
                        .font(.headline)

                    HStack {
                        if showingKeySecurely {
                            TextField("API Key", text: $apiKey)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            SecureField("API Key", text: $apiKey)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }

                        Button(action: { showingKeySecurely.toggle() }) {
                            Image(systemName: showingKeySecurely ? "eye.slash" : "eye")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help(showingKeySecurely ? "Hide" : "Show")
                    }

                    Text("Leave empty to configure later")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .formStyle(GroupedFormStyle())
        .navigationTitle("Add Provider")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    addProvider()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty || baseURL.isEmpty)
            }
        }
        .frame(width: 540, height: 390)
    }

    private func addProvider() {
        let provider = AIProvider(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            baseURL: baseURL.trimmingCharacters(in: .whitespacesAndNewlines),
            apiKey: apiKey.trimmingCharacters(in: .whitespacesAndNewlines),
            apiProtocol: apiProtocol,
            preset: selectedPreset ?? AIProviderPreset.infer(fromProviderName: name),
            isBuiltIn: false,
            isActive: true
        )

        providerManager.addProvider(provider)
        dismiss()
    }
}

#Preview {
    AddProviderView(providerManager: ProviderManager.shared)
}
