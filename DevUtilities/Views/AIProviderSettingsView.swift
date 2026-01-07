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
import Foundation

// MARK: - Settings Navigation Item

enum AISettingsItem: Identifiable, Hashable {
    case general
    case appearance
    case advanced
    case provider(AIProvider)

    var id: String {
        switch self {
        case .general: return "general"
        case .appearance: return "appearance"
        case .advanced: return "advanced"
        case .provider(let provider): return "provider-\(provider.id.uuidString)"
        }
    }

    var displayName: String {
        switch self {
        case .general: return "General"
        case .appearance: return "Appearance"
        case .advanced: return "Advanced"
        case .provider(let provider): return provider.name
        }
    }

    var iconName: String {
        switch self {
        case .general: return "gearshape"
        case .appearance: return "paintpalette"
        case .advanced: return "slider.horizontal.3"
        case .provider: return "externaldrive.connected.to.line.below"
        }
    }
}

// MARK: - Main Settings View

struct AIProviderSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: AISettingsItem? = .general
    @State private var showingAddProvider = false
    @State private var providerManager = ProviderManager.shared

    var body: some View {
        NavigationSplitView {
            // Left Sidebar
            AISettingsSidebar(
                providerManager: providerManager,
                selectedItem: $selectedItem,
                showingAddProvider: $showingAddProvider
            )
            .frame(minWidth: 200, maxWidth: 250)
        } detail: {
            // Right Detail Pane
            Group {
                if let item = selectedItem {
                    switch item {
                    case .general:
                        AIGeneralSettingsView(providerManager: providerManager)
                    case .appearance:
                        AIAppearanceSettingsView()
                    case .advanced:
                        AIAdvancedSettingsView()
                    case .provider(let provider):
                        AIProviderDetailView(
                            provider: provider,
                            providerManager: providerManager
                        )
                    }
                } else {
                    AISettingsEmptyStateView()
                }
            }
            .frame(minWidth: 400)
        }
        .navigationTitle("AI Settings")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
        }
        .sheet(isPresented: $showingAddProvider) {
            AddProviderView(providerManager: providerManager)
        }
        .frame(width: 700, height: 500) // Fixed size to prevent jumping
    }
}

// MARK: - Settings Sidebar

struct AISettingsSidebar: View {
    let providerManager: ProviderManager
    @Binding var selectedItem: AISettingsItem?
    @Binding var showingAddProvider: Bool

    var body: some View {
        List(selection: $selectedItem) {
            Section("Settings") {
                Label("General", systemImage: "gearshape")
                    .tag(AISettingsItem.general)

                Label("Appearance", systemImage: "paintpalette")
                    .tag(AISettingsItem.appearance)

                Label("Advanced", systemImage: "slider.horizontal.3")
                    .tag(AISettingsItem.advanced)
            }

            Section {
                ForEach(providerManager.providers) { provider in
                    HStack {
                        Label {
                            Text(provider.name)
                        } icon: {
                            Circle()
                                .fill(statusColor(for: provider))
                                .frame(width: 8, height: 8)
                        }

                        Spacer()

                        if provider.isBuiltIn {
                            Text("Built-in")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .tag(AISettingsItem.provider(provider))
                    .contextMenu {
                        Button(provider.isActive ? "Disable" : "Enable") {
                            providerManager.toggleProviderStatus(id: provider.id)
                        }

                        if !provider.isBuiltIn {
                            Button("Delete", role: .destructive) {
                                providerManager.deleteProvider(id: provider.id)
                            }
                        }
                    }
                }

                Button(action: { showingAddProvider = true }) {
                    Label("Add Provider", systemImage: "plus")
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.accentColor)
            } header: {
                Text("Providers")
            }
        }
        .listStyle(SidebarListStyle())
    }

    private func statusColor(for provider: AIProvider) -> Color {
        switch provider.statusColor {
        case "green": return .green
        case "yellow": return .yellow
        case "red": return .red
        default: return .gray
        }
    }
}

// MARK: - General Settings

struct AIGeneralSettingsView: View {
    let providerManager: ProviderManager
    @State private var uiSettings = AIUISettings.shared
    @State private var selectedModelKey: String?

    var body: some View {
        Form {
            Section("Default Model") {
                Picker("Model", selection: $selectedModelKey) {
                    Text("Select a model...")
                        .tag(String?.none)

                    ForEach(providerManager.getAllActiveModels(), id: \.id) { item in
                        Text(item.displayName)
                            .tag(modelKey(for: item) as String?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedModelKey) { _, newValue in
                    uiSettings.selectedDefaultModelKey = newValue
                }
            }

            Section("Chat Behavior") {
                Toggle("Stream responses", isOn: $uiSettings.streamResponses)
                Toggle("Show reasoning process", isOn: $uiSettings.showReasoning)
                Toggle("Auto-scroll messages", isOn: $uiSettings.autoScroll)
                Toggle("Save conversation history", isOn: $uiSettings.saveHistory)
            }
        }
        .formStyle(GroupedFormStyle())
        .navigationTitle("General Settings")
        .onAppear {
            loadSettings()
        }
    }

    private func modelKey(for item: ProviderModelItem) -> String {
        return "\(item.provider.id.uuidString)|\(item.model.id.uuidString)"
    }

    private func loadSettings() {
        let activeModels = providerManager.getAllActiveModels()

        // Load selected model from settings
        if let savedModelKey = uiSettings.selectedDefaultModelKey,
           activeModels.contains(where: { modelKey(for: $0) == savedModelKey }) {
            selectedModelKey = savedModelKey
        } else if !activeModels.isEmpty {
            // Try to find OpenAI GPT-4.1 as the preferred default
            if let gpt41Model = activeModels.first(where: { $0.provider.name == "OpenAI" && $0.model.modelId == "gpt-4.1" }) {
                let key = modelKey(for: gpt41Model)
                selectedModelKey = key
                uiSettings.selectedDefaultModelKey = key
            } else {
                // Fallback to first available model
                if let firstModel = activeModels.first {
                    let key = modelKey(for: firstModel)
                    selectedModelKey = key
                    uiSettings.selectedDefaultModelKey = key
                }
            }
        }
    }
}

// MARK: - Appearance Settings

struct AIAppearanceSettingsView: View {
    @State private var uiSettings = AIUISettings.shared

    var body: some View {
        Form {
            Section("Interface") {
                Picker("Theme", selection: $uiSettings.theme) {
                    Text("Auto").tag("Auto")
                    Text("Light").tag("Light")
                    Text("Dark").tag("Dark")
                }

                Picker("Font size", selection: $uiSettings.fontSize) {
                    Text("12px").tag(12)
                    Text("14px").tag(14)
                    Text("16px").tag(16)
                    Text("18px").tag(18)
                }

                Picker("Message density", selection: $uiSettings.messageDensity) {
                    Text("Compact").tag("Compact")
                    Text("Comfortable").tag("Comfortable")
                    Text("Spacious").tag("Spacious")
                }
            }
        }
        .formStyle(GroupedFormStyle())
        .navigationTitle("Appearance")
    }
}

// MARK: - Advanced Settings

struct AIAdvancedSettingsView: View {
    @State private var uiSettings = AIUISettings.shared

    var body: some View {
        Form {
            Section("Performance") {
                HStack {
                    Text("Max chat history")
                    Spacer()
                    TextField("100", value: $uiSettings.maxHistoryChats, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                    Text("chats")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Request timeout")
                    Spacer()
                    TextField("30", value: $uiSettings.requestTimeout, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                    Text("seconds")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Max retries")
                    Spacer()
                    TextField("3", value: $uiSettings.maxRetries, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }
            }
        }
        .formStyle(GroupedFormStyle())
        .navigationTitle("Advanced")
    }
}

// MARK: - Empty State

struct AISettingsEmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "gearshape")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("Select a setting to configure")
                .font(.title2)
                .foregroundColor(.secondary)

            Text("Choose an option from the sidebar to view and modify settings")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    AIProviderSettingsView()
}