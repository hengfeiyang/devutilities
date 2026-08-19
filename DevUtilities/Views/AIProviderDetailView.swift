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

struct AIProviderDetailView: View {
    let providerId: UUID
    @State private var providerManager = ProviderManager.shared

    @State private var name: String = ""
    @State private var baseURL: String = ""
    @State private var apiKey: String = ""
    @State private var apiProtocol: AIAPIProtocol = .openAICompatible
    @State private var showingKeySecurely = false
    @State private var isTestingConnection = false
    @State private var testResult: Bool?
    @State private var testErrorMessage: String?
    @State private var showingAddModel = false
    @State private var editingModel: AIModelV2?

    // Save state management
    @State private var isSaving = false
    @State private var saveSuccess = false

    // Get the current provider state from the manager
    private var currentProvider: AIProvider? {
        providerManager.getProviderById(providerId)
    }

    init(provider: AIProvider, providerManager: ProviderManager) {
        self.providerId = provider.id
    }

    var body: some View {
        Group {
            if let provider = currentProvider {
                providerDetailContent(for: provider)
            } else {
                Text("Provider not found")
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            loadProviderData()
        }
        .onChange(of: currentProvider) { _, newProvider in
            if let provider = newProvider {
                loadProviderData(from: provider)
                testResult = nil
                testErrorMessage = nil
            }
        }
    }

    @ViewBuilder
    private func providerDetailContent(for provider: AIProvider) -> some View {
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
                                }

                                HStack {
                                    Text("API Protocol")
                                    Spacer()
                                    Picker("API Protocol", selection: $apiProtocol) {
                                        ForEach(AIAPIProtocol.allCases) { apiProtocol in
                                            Text(apiProtocol.displayName).tag(apiProtocol)
                                        }
                                    }
                                    .labelsHidden()
                                    .frame(minWidth: 220)
                                    .disabled(provider.preset != nil)
                                }

                                Text(provider.preset == nil
                                     ? apiProtocol.detail
                                     : "The selected provider preset fixes this protocol family.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("API Key")

                                HStack(spacing: 4) {
                                    Image(systemName: "info.circle")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("Authentication is selected automatically by API protocol")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

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
                                HStack(alignment: .top) {
                                    Image(systemName: testResult ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(testResult ? .green : .red)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(testResult ? "Connection successful" : "Connection failed")
                                            .font(.caption)
                                            .foregroundColor(testResult ? .green : .red)
                                        if !testResult, let errorMessage = testErrorMessage {
                                            Text(errorMessage)
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
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
                            LazyVStack(alignment: .leading, spacing: 4) {
                                ForEach(provider.models) { model in
                                    ModelRowView(
                                        model: model,
                                        onEdit: { editingModel = model },
                                        onDelete: { providerManager.deleteModel(id: model.id, from: provider.id) },
                                        onToggle: nil,
                                        isBuiltIn: model.isBuiltIn
                                    )
                                    .padding(.horizontal, 4)

                                    if model.id != provider.models.last?.id {
                                        Divider()
                                            .padding(.horizontal, 4)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .frame(maxHeight: 300) // Limit height to prevent page jumping
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(6)

                        Button(action: { showingAddModel = true }) {
                            Label("Add Custom Model", systemImage: "plus")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.accentColor)
                        .padding(.top, 8)
                    }
                    .padding()
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
                Button(action: {
                    saveProvider()
                }) {
                    HStack(spacing: 4) {
                        if isSaving {
                            ProgressView()
                                .scaleEffect(0.7)
                                .frame(width: 12, height: 12)
                        } else if saveSuccess {
                            Image(systemName: "checkmark")
                        }
                        Text(isSaving ? "Saving..." : (saveSuccess ? "Saved" : "Save"))
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty || baseURL.isEmpty || isSaving)

                if !provider.isBuiltIn {
                    Button("Delete", role: .destructive) {
                        providerManager.deleteProvider(id: provider.id)
                    }
                }
            }
        }
    }

    private var statusColor: Color {
        guard let provider = currentProvider else { return .gray }
        switch provider.statusColor {
        case "green": return .green
        case "yellow": return .yellow
        case "red": return .red
        default: return .gray
        }
    }

    private func loadProviderData() {
        guard let provider = currentProvider else { return }
        loadProviderData(from: provider)
    }

    private func loadProviderData(from provider: AIProvider) {
        name = provider.name
        baseURL = provider.baseURL
        apiProtocol = provider.apiProtocol
        loadAPIKey()
    }

    private func loadAPIKey() {
        guard let provider = currentProvider else { return }
        if let existingKey = providerManager.getAPIKey(for: provider.id) {
            apiKey = existingKey
        } else {
            apiKey = ""
        }
    }

    private func saveProvider() {
        guard var provider = currentProvider else { return }

        // Set saving state
        isSaving = true
        saveSuccess = false

        // Async save operation with UI feedback
        Task {
            // Trim and prepare data
            provider.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            provider.baseURL = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
            provider.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
            provider.apiProtocol = apiProtocol

            // Small delay for better UX (shows the "Saving..." state)
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

            // Save to provider manager
            providerManager.updateProvider(provider)

            // Update UI on main thread
            await MainActor.run {
                isSaving = false
                saveSuccess = true

                // Reset success state after 2 seconds
                Task {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    await MainActor.run {
                        saveSuccess = false
                    }
                }
            }
        }
    }

    private func testConnection() {
        guard var provider = currentProvider else { return }

        // Update provider with current form values (without the delay from saveProvider)
        provider.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        provider.baseURL = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        provider.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        provider.apiProtocol = apiProtocol

        // Save immediately before testing
        providerManager.updateProvider(provider)

        isTestingConnection = true
        testResult = nil
        testErrorMessage = nil

        Task {
            let (success, message) = await providerManager.testProviderConnection(provider)

            await MainActor.run {
                testResult = success
                testErrorMessage = message
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
    let onToggle: (() -> Void)?
    let isBuiltIn: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // First line: Model name and function icons
            HStack {
                Text(model.name)
                    .font(.body)

                Spacer()

                HStack(spacing: 4) {
                    ForEach(model.capabilityIcons, id: \.self) { iconName in
                        Image(systemName: iconName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Second line: Model ID and operation icons
            HStack {
                Text(model.modelId)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                HStack(spacing: 8) {
                    if !isBuiltIn {
                        Button(action: onEdit) {
                            Image(systemName: "pencil")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.accentColor)
                        .help("Edit model")

                        Button(action: onDelete) {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.red)
                        .help("Remove model")
                    }
                }
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    AIProviderDetailView(
        provider: .createBuiltInDeepSeek(),
        providerManager: ProviderManager.shared
    )
}
