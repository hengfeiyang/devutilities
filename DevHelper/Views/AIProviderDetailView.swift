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

import SwiftUI

struct AIProviderDetailView: View {
    let provider: AIProvider
    let providerManager: ProviderManager

    @State private var name: String
    @State private var baseURL: String
    @State private var apiKey: String
    @State private var showingKeySecurely = false
    @State private var isTestingConnection = false
    @State private var testResult: Bool?
    @State private var showingAddModel = false
    @State private var editingModel: AIModelV2?

    init(provider: AIProvider, providerManager: ProviderManager) {
        self.provider = provider
        self.providerManager = providerManager
        self._name = State(initialValue: provider.name)
        self._baseURL = State(initialValue: provider.baseURL)
        self._apiKey = State(initialValue: "")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Non-scrollable content
            VStack(alignment: .leading, spacing: 16) {
                // Provider Settings Section
                GroupBox("Provider Settings") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Provider Name")
                            Spacer()
                            TextField("Provider Name", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(minWidth: 200)
                                .disabled(provider.isBuiltIn)
                        }

                        HStack {
                            Text("Base URL")
                            Spacer()
                            TextField("https://api.example.com/v1", text: $baseURL)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(minWidth: 300)
                                .disabled(provider.isBuiltIn)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("API Key")
                                Spacer()
                                if !apiKey.isEmpty || providerManager.getAPIKey(for: provider.id) != nil {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }

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

                                Button("Test") {
                                    testConnection()
                                }
                                .disabled(isTestingConnection || (apiKey.isEmpty && providerManager.getAPIKey(for: provider.id) == nil))
                            }

                            if let testResult = testResult {
                                HStack {
                                    Image(systemName: testResult ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(testResult ? .green : .red)
                                    Text(testResult ? "Connection successful" : "Connection failed")
                                        .font(.caption)
                                        .foregroundColor(testResult ? .green : .red)
                                }
                            }
                        }
                    }
                    .padding()
                }

                // Models Section - Scrollable
                GroupBox("Models (\(provider.models.count) available)") {
                    VStack(alignment: .leading, spacing: 0) {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 8) {
                                ForEach(provider.models) { model in
                                    ModelRowView(
                                        model: model,
                                        onEdit: { editingModel = model },
                                        onDelete: { providerManager.deleteModel(id: model.id, from: provider.id) },
                                        onToggle: { providerManager.toggleModelStatus(id: model.id, in: provider.id) },
                                        isBuiltIn: provider.isBuiltIn
                                    )
                                    .padding(.horizontal, 4)

                                    if model.id != provider.models.last?.id {
                                        Divider()
                                            .padding(.horizontal, 4)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .frame(maxHeight: 300) // Limit height to prevent page jumping
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(6)

                        if !provider.isBuiltIn {
                            Button(action: { showingAddModel = true }) {
                                Label("Add Custom Model", systemImage: "plus")
                            }
                            .buttonStyle(PlainButtonStyle())
                            .foregroundColor(.accentColor)
                            .padding(.top, 8)
                        }
                    }
                    .padding()
                }

                // Usage Statistics Section (if available)
                if let lastTested = provider.lastTested {
                    GroupBox("Usage Statistics") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Last tested")
                                Spacer()
                                Text(lastTested, style: .relative)
                                    .foregroundColor(.secondary)
                            }

                            HStack {
                                Text("Status")
                                Spacer()
                                HStack {
                                    Circle()
                                        .fill(statusColor)
                                        .frame(width: 8, height: 8)
                                    Text(provider.statusText)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .padding()
        }
        .navigationTitle(provider.name)
        .onAppear {
            loadAPIKey()
        }
        .sheet(isPresented: $showingAddModel) {
            AddModelView(
                providerId: provider.id,
                providerManager: providerManager
            )
        }
        .sheet(item: $editingModel) { model in
            EditModelView(
                model: model,
                providerManager: providerManager
            )
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                if !provider.isBuiltIn {
                    Button("Save") {
                        saveProvider()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.isEmpty || baseURL.isEmpty)

                    Button("Delete", role: .destructive) {
                        providerManager.deleteProvider(id: provider.id)
                    }
                }
            }
        }
    }

    private var statusColor: Color {
        switch provider.statusColor {
        case "green": return .green
        case "yellow": return .yellow
        case "red": return .red
        default: return .gray
        }
    }

    private func loadAPIKey() {
        if let existingKey = providerManager.getAPIKey(for: provider.id) {
            apiKey = existingKey
        }
    }

    private func saveProvider() {
        var updatedProvider = provider
        updatedProvider.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedProvider.baseURL = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedProvider.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)

        providerManager.updateProvider(updatedProvider)
    }

    private func testConnection() {
        isTestingConnection = true
        testResult = nil

        Task {
            let result = await providerManager.testProviderConnection(provider)

            await MainActor.run {
                testResult = result
                isTestingConnection = false
            }
        }
    }
}

// MARK: - Model Row View

struct ModelRowView: View {
    let model: AIModelV2
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onToggle: () -> Void
    let isBuiltIn: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(model.name)
                        .font(.body)
                        .foregroundColor(model.isActive ? .primary : .secondary)

                    Spacer()

                    HStack(spacing: 4) {
                        ForEach(model.capabilityIcons, id: \.self) { iconName in
                            Image(systemName: iconName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Text(model.modelId)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if !model.isActive {
                    Text("Disabled")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }

            Spacer()

            HStack(spacing: 8) {
                if !isBuiltIn {
                    Button("Edit") {
                        onEdit()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.accentColor)

                    Button("Remove") {
                        onDelete()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.red)
                }

                Button(model.isActive ? "Disable" : "Enable") {
                    onToggle()
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.accentColor)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AIProviderDetailView(
        provider: .createBuiltInDeepSeek(),
        providerManager: ProviderManager.shared
    )
}