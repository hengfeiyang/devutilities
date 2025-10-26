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

struct AITranslateView: View {
    // MARK: - State Variables
    @State private var selectedMode: TranslationMode = .translate
    @AppStorage("AITranslate.sourceLanguage") private var sourceLanguageRawValue: String = TranslationLanguage.auto.rawValue
    @AppStorage("AITranslate.targetLanguage") private var targetLanguageRawValue: String = TranslationLanguage.detectSystemLanguage().rawValue
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var isTranslating: Bool = false
    @State private var showingSettings = false
    @State private var errorMessage: String?
    @State private var writingOffset: CGFloat = 0

    @State private var providerManager = ProviderManager.shared
    @State private var chatAPI = ChatCompletionsAPI()

    // Computed properties for language access
    private var sourceLanguage: TranslationLanguage {
        get { TranslationLanguage(rawValue: sourceLanguageRawValue) ?? .auto }
        nonmutating set { sourceLanguageRawValue = newValue.rawValue }
    }

    private var targetLanguage: TranslationLanguage {
        get { TranslationLanguage(rawValue: targetLanguageRawValue) ?? .english }
        nonmutating set { targetLanguageRawValue = newValue.rawValue }
    }

    // Character count
    private var characterCount: Int {
        inputText.count
    }

    // Selected model (using AI Chat's model system)
    private var currentModel: ProviderModelItem? {
        let availableModels = providerManager.getAllActiveModels()

        // Try to get default from settings
        if let defaultModelKey = AIUISettings.shared.selectedDefaultModelKey {
            let components = defaultModelKey.split(separator: "|")
            if components.count == 2,
               let providerIdStr = components.first,
               let modelIdStr = components.last,
               let providerId = UUID(uuidString: String(providerIdStr)),
               let modelId = UUID(uuidString: String(modelIdStr)),
               let match = availableModels.first(where: { $0.provider.id == providerId && $0.model.id == modelId }) {
                return match
            }
        }

        // Fallback to first available
        return availableModels.first
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            toolbarView
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Main Content (Input and Output areas)
            VSplitView {
                // Input Area (Top)
                inputAreaView

                // Output Area (Bottom)
                outputAreaView
            }
        }
        .navigationTitle("AI Translate")
        .sheet(isPresented: $showingSettings) {
            AIProviderSettingsView()
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let error = errorMessage {
                Text(error)
            }
        }
    }

    // MARK: - Toolbar View
    private var toolbarView: some View {
        HStack(spacing: 12) {
            // Model Selector
            modelSelectorView

            // Source Language
            languagePickerView(isSource: true)

            // Swap Button
            Button(action: swapLanguages) {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
            .help("Swap languages")
            .disabled(sourceLanguage == .auto)

            // Target Language
            languagePickerView(isSource: false)

            // Mode Buttons
            modeButtonsView

            Spacer()

            // Settings Button (moved to the end)
            Button(action: {
                showingSettings = true
            }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
            .help("AI Settings")
        }
    }

    // MARK: - Model Selector
    private var modelSelectorView: some View {
        let availableModels = providerManager.getAllActiveModels()

        return Menu {
            ForEach(availableModels, id: \.id) { item in
                Button(action: {
                    // Update default model selection
                    let modelKey = "\(item.provider.id.uuidString)|\(item.model.id.uuidString)"
                    AIUISettings.shared.selectedDefaultModelKey = modelKey
                }) {
                    HStack {
                        Text(item.displayName)
                        if item.model.id == currentModel?.model.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }

            if availableModels.isEmpty {
                Text("No models available")
                    .foregroundColor(.secondary)
            }
        } label: {
            HStack(spacing: 4) {
                Text(currentModel?.displayName ?? "No Model")
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(PlainButtonStyle())
        .help("Select AI model")
    }

    // MARK: - Language Picker
    private func languagePickerView(isSource: Bool) -> some View {
        let languages = isSource ? TranslationLanguage.allCases : TranslationLanguage.targetLanguages
        let currentLanguage = isSource ? sourceLanguage : targetLanguage

        return Menu {
            ForEach(languages) { lang in
                Button(action: {
                    if isSource {
                        sourceLanguageRawValue = lang.rawValue
                    } else {
                        targetLanguageRawValue = lang.rawValue
                    }
                }) {
                    HStack {
                        Text(lang.displayName)
                        if lang == currentLanguage {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(currentLanguage.displayName)
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(PlainButtonStyle())
        .help(isSource ? "Select source language" : "Select target language")
    }

    // MARK: - Mode Buttons
    private var modeButtonsView: some View {
        HStack(spacing: 4) {
            ForEach(TranslationMode.allCases) { mode in
                Button(action: {
                    selectedMode = mode
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: mode.iconName)
                            .font(.system(size: 12, weight: .medium))
                        if selectedMode == mode {
                            Text(mode.displayName)
                                .font(.system(size: 12, weight: .medium))
                        }
                    }
                    .foregroundColor(selectedMode == mode ? .white : .secondary)
                    .padding(.horizontal, selectedMode == mode ? 10 : 7)
                    .padding(.vertical, 6)
                    .background(selectedMode == mode ? Color.accentColor : Color.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(PlainButtonStyle())
                .help(mode.displayName)
            }
        }
    }

    // MARK: - Input Area
    private var inputAreaView: some View {
        VStack(spacing: 0) {
            // Text Editor
            TextEditor(text: $inputText, onEnterKey: {
                handleSubmit()
            })
            .font(.body)
            .scrollContentBackground(.hidden)
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 100, maxHeight: 300)

            Divider()

            // Bottom Bar (Character count + Submit button)
            HStack {
                Text("\(characterCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 12)

                // Speaker button for input text
                if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    SpeakerButton(
                        text: inputText,
                        language: sourceLanguage == .auto ? targetLanguage.ttsLanguageCode : sourceLanguage.ttsLanguageCode
                    )
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .help("Speak input text")
                }

                Spacer()

                Text("Press <Enter> to submit, <Shift+Enter> for new line")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Button(action: handleSubmit) {
                        HStack(spacing: 4) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 12))
                            Text("Submit")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isTranslating)
                    .padding(.trailing, 12)
                }
            }
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
        }
    }

    // MARK: - Output Area
    private var outputAreaView: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if !outputText.isEmpty || isTranslating {
                        // Divider with Status Badge overlay
                        ZStack {
                            Divider()
                                .padding(.vertical, 16)

                            // Status Badge centered on divider
                            statusBadgeView
                                .padding(.horizontal, 12)
                                .background(Color(NSColor.textBackgroundColor))
                        }
                        .padding(.top, 16)

                        // Output Text
                        Text(outputText)
                            .font(.body)
                            .lineSpacing(6)
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 12)

                        // Action buttons (Retry & Copy) - only show when translation is complete
                        if !isTranslating && !outputText.isEmpty {
                            HStack(spacing: 8) {
                                Spacer()

                                // Retry button
                                Button(action: handleSubmit) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .help("Retry translation")

                                // Speaker button (TTS)
                                SpeakerButton(
                                    text: outputText,
                                    language: targetLanguage.ttsLanguageCode
                                )
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .help("Speak translation")

                                // Copy button
                                Button(action: {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(outputText, forType: .string)
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .help("Copy translation")
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                        }

                        // Bottom padding
                        Spacer()
                            .frame(height: 16)
                    } else {
                        // Empty state
                        VStack(spacing: 12) {
                            Image(systemName: "translate")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)

                            Text("Enter text above to translate")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(16)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(NSColor.textBackgroundColor))
        }
    }

    // MARK: - Status Badge
    private var statusBadgeView: some View {
        HStack(spacing: 4) {
            if isTranslating {
                // Static text part
                let statusText = selectedMode.processingStatus
                let textWithoutEmoji = statusText.replacingOccurrences(of: "✍️", with: "").trimmingCharacters(in: .whitespaces)

                Text(textWithoutEmoji)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)

                // Animated emoji only
                Text("✍️")
                    .font(.system(size: 14))
                    .offset(x: writingOffset)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true)
                        ) {
                            writingOffset = 10
                        }
                    }
                    .onDisappear {
                        writingOffset = 0
                    }
            } else {
                Text(selectedMode.completedStatus)
                    .font(.system(size: 14))
                    .foregroundColor(.green)
            }
        }
    }

    // MARK: - Helper Functions
    private func swapLanguages() {
        guard sourceLanguage != .auto else { return }
        let temp = sourceLanguageRawValue
        sourceLanguageRawValue = targetLanguageRawValue
        targetLanguageRawValue = temp
    }

    private func handleSubmit() {
        let textToTranslate = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !textToTranslate.isEmpty, !isTranslating else { return }

        // Generate prompts
        let (systemPrompt, userPrompt) = TranslationPrompts.generatePrompts(
            mode: selectedMode,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            text: textToTranslate
        )

        // Get model and provider info
        guard let model = currentModel else {
            errorMessage = "No AI model selected. Please configure your AI settings."
            return
        }

        guard let apiKey = ProviderManager.shared.getAPIKey(for: model.provider.id), !apiKey.isEmpty else {
            errorMessage = "No API key configured for \(model.provider.name). Please configure your settings."
            return
        }

        // Prepare messages
        let messages: [ChatMessage] = [
            ChatMessage(role: .system, content: systemPrompt),
            ChatMessage(role: .user, content: userPrompt)
        ]

        // Start translation
        isTranslating = true
        outputText = ""
        errorMessage = nil

        Task { @MainActor in
            await chatAPI.sendMessage(
                messages: messages,
                modelId: model.model.modelId,
                apiKey: apiKey,
                baseURL: model.provider.baseURL,
                onToken: { token in
                    Task { @MainActor in
                        outputText += token
                    }
                },
                onComplete: {
                    Task { @MainActor in
                        isTranslating = false
                    }
                },
                onError: { error in
                    Task { @MainActor in
                        isTranslating = false
                        errorMessage = "Translation failed: \(error.localizedDescription)"
                        outputText = ""
                    }
                },
                onReasoning: { _ in
                    // Ignore reasoning for translation
                }
            )
        }
    }
}

#Preview {
    AITranslateView()
}
