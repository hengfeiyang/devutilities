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
    @State private var providerManager = ProviderManager.shared
    @State private var selectedItem: AISettingsItem? = .general
    @State private var showingAddProvider = false

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
                        if !provider.isBuiltIn {
                            Button("Delete Provider", role: .destructive) {
                                providerManager.deleteProvider(id: provider.id)
                            }
                        }

                        Button(provider.isActive ? "Disable" : "Enable") {
                            providerManager.toggleProviderStatus(id: provider.id)
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
    @State private var selectedDefaultModel: ProviderModelItem?
    @State private var streamResponses = true
    @State private var showReasoning = true
    @State private var autoScroll = true
    @State private var saveHistory = true

    var body: some View {
        Form {
            Section("Default Model") {
                Picker("Model", selection: $selectedDefaultModel) {
                    ForEach(providerManager.getAllActiveModels(), id: \.id) { item in
                        Text(item.displayName)
                            .tag(item as ProviderModelItem?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }

            Section("Chat Behavior") {
                Toggle("Stream responses", isOn: $streamResponses)
                Toggle("Show reasoning process", isOn: $showReasoning)
                Toggle("Auto-scroll messages", isOn: $autoScroll)
                Toggle("Save conversation history", isOn: $saveHistory)
            }

            Section("Privacy") {
                Toggle("Clear history on quit", isOn: .constant(false))
                Toggle("Encrypt local storage", isOn: .constant(true))
            }
        }
        .formStyle(GroupedFormStyle())
        .navigationTitle("General Settings")
        .onAppear {
            loadSettings()
        }
    }

    private func loadSettings() {
        let activeModels = providerManager.getAllActiveModels()
        if selectedDefaultModel == nil && !activeModels.isEmpty {
            // Try to find OpenAI GPT-4.1 as the preferred default
            if let gpt41Model = activeModels.first(where: { $0.provider.name == "OpenAI" && $0.model.modelId == "gpt-4.1" }) {
                selectedDefaultModel = gpt41Model
            } else {
                // Fallback to first available model
                selectedDefaultModel = activeModels.first
            }
        }
    }
}

// MARK: - Appearance Settings

struct AIAppearanceSettingsView: View {
    @State private var theme = "Auto"
    @State private var fontSize = 14
    @State private var messageDensity = "Comfortable"

    var body: some View {
        Form {
            Section("Interface") {
                Picker("Theme", selection: $theme) {
                    Text("Auto").tag("Auto")
                    Text("Light").tag("Light")
                    Text("Dark").tag("Dark")
                }

                Picker("Font size", selection: $fontSize) {
                    Text("12px").tag(12)
                    Text("14px").tag(14)
                    Text("16px").tag(16)
                    Text("18px").tag(18)
                }

                Picker("Message density", selection: $messageDensity) {
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
    @State private var maxHistoryChats = 100
    @State private var requestTimeout = 30
    @State private var maxRetries = 3

    var body: some View {
        Form {
            Section("Performance") {
                HStack {
                    Text("Max chat history")
                    Spacer()
                    TextField("100", value: $maxHistoryChats, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                    Text("chats")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Request timeout")
                    Spacer()
                    TextField("30", value: $requestTimeout, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                    Text("seconds")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Max retries")
                    Spacer()
                    TextField("3", value: $maxRetries, format: .number)
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