// Copyright 2025 Hengfei Yang.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import SwiftUI

struct AISettingsView: View {
    let settings: AISettings
    @Environment(\.dismiss) private var dismiss
    
    @State private var openAIKey = ""
    @State private var selectedDefaultModel: AIModel = .defaultModel
    @State private var streamingEnabled = true
    @State private var maxHistoryChats = 100
    @State private var showingKeySecurely = false
    
    var body: some View {
        Form {
                Section("API Key") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("OpenAI")
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            if !openAIKey.isEmpty {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        
                        HStack {
                            if showingKeySecurely {
                                TextField("sk-...", text: $openAIKey)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            } else {
                                SecureField("sk-...", text: $openAIKey)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            Button(action: { showingKeySecurely.toggle() }) {
                                Image(systemName: showingKeySecurely ? "eye.slash" : "eye")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .help(showingKeySecurely ? "Hide" : "Show")
                        }
                        
                        Text("Get your API key from [platform.openai.com](https://platform.openai.com/api-keys)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Default Settings") {
                    HStack {
                        Text("Default Model")
                        Spacer()
                        Picker("", selection: $selectedDefaultModel) {
                            ForEach(AIModel.chatModels, id: \.id) { model in
                                Text(model.displayName)
                                    .tag(model)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(minWidth: 200)
                    }
                    
                    HStack {
                        Text("Max Chat History")
                        Spacer()
                        TextField("100", value: $maxHistoryChats, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 100)
                        Text("chats")
                            .foregroundColor(.secondary)
                    }
                    
                    Toggle("Enable Streaming", isOn: $streamingEnabled)
                }
        }
        .formStyle(GroupedFormStyle())
        .navigationTitle("AI Settings")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveSettings()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return, modifiers: .command)
            }
        }
        .frame(width: 550, height: 350)
        .onAppear {
            loadCurrentSettings()
        }
    }
    
    private func loadCurrentSettings() {
        openAIKey = settings.openAIAPIKey
        selectedDefaultModel = settings.defaultModel
        streamingEnabled = settings.streamingEnabled
        maxHistoryChats = settings.maxHistoryChats
        showingKeySecurely = false
    }
    
    private func saveSettings() {
        settings.openAIAPIKey = openAIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        settings.defaultModel = selectedDefaultModel
        settings.streamingEnabled = streamingEnabled
        settings.maxHistoryChats = maxHistoryChats
    }
}

#Preview {
    AISettingsView(settings: AISettings())
}