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

struct RandomStringView: View {
    let screenName = "Random String Generator"

    @State private var config = RandomStringConfig.load()
    @State private var selectedPreset: StringPreset = .custom
    @State private var generatedStrings: [String] = []
    @State private var errorMessage: String = ""
    @State private var copiedButtonId: String? = nil
    @State private var showingCopyAllSuccess = false

    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top, spacing: 40) {
                // Configuration Section (Left)
                VStack(alignment: .leading, spacing: 15) {
                    Text("Configuration")
                        .font(.headline)

                    // Preset Picker
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Preset:")
                            .font(.subheadline)
                        Picker("Preset", selection: $selectedPreset) {
                            ForEach(StringPreset.allCases) { preset in
                                Text(preset.rawValue).tag(preset)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: selectedPreset) { _, newValue in
                            if newValue != .custom {
                                config = newValue.config
                                config.preset = newValue.rawValue
                            }
                        }

                        if selectedPreset != .custom {
                            Text(selectedPreset.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Divider()

                    // Length Control
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Length:")
                                .font(.subheadline)
                            Spacer()
                            Text("\(config.length)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Slider(value: Binding(
                            get: { Double(config.length) },
                            set: { config.length = Int($0) }
                        ), in: 1...100, step: 1)

                        HStack {
                            Text("1")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("100")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Quantity Control
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Quantity:")
                                .font(.subheadline)
                            Spacer()
                            Text("\(config.quantity)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Slider(value: Binding(
                            get: { Double(config.quantity) },
                            set: { config.quantity = Int($0) }
                        ), in: 1...20, step: 1)

                        HStack {
                            Text("1")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("20")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Divider()

                    // Character Sets
                    Text("Character Sets:")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Toggle("Uppercase (A-Z)", isOn: $config.includeUppercase)
                        .onChange(of: config.includeUppercase) { _, newValue in
                            if !newValue {
                                config.requireUppercase = false
                            }
                        }
                    Toggle("Lowercase (a-z)", isOn: $config.includeLowercase)
                    Toggle("Numbers (0-9)", isOn: $config.includeNumbers)
                        .onChange(of: config.includeNumbers) { _, newValue in
                            if !newValue {
                                config.requireNumber = false
                            }
                        }
                    Toggle("Symbols (!@#$...)", isOn: $config.includeSymbols)
                        .onChange(of: config.includeSymbols) { _, newValue in
                            if !newValue {
                                config.requireSymbol = false
                            }
                        }

                    Divider()

                    // Requirements
                    Text("Requirements:")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Toggle("At least 1 uppercase", isOn: $config.requireUppercase)
                        .disabled(!config.includeUppercase)
                    Toggle("At least 1 number", isOn: $config.requireNumber)
                        .disabled(!config.includeNumbers)
                    Toggle("At least 1 symbol", isOn: $config.requireSymbol)
                        .disabled(!config.includeSymbols)
                }
                .frame(width: 300)

                // Output Section (Right)
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Generated Strings")
                            .font(.headline)
                        Spacer()
                        if !generatedStrings.isEmpty {
                            Text("\(generatedStrings.count) string\(generatedStrings.count > 1 ? "s" : ""), \(totalCharacters) chars")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Generate Button
                    Button(action: generateStrings) {
                        HStack {
                            Image(systemName: "wand.and.stars")
                            Text("Generate")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!config.isValid)

                    // Error Message
                    if !errorMessage.isEmpty {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding(8)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(6)
                    }

                    // Generated Strings List
                    ScrollView {
                        VStack(alignment: .leading, spacing: 5) {
                            if generatedStrings.isEmpty {
                                Text("Click Generate to create random strings")
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 40)
                            } else {
                                ForEach(Array(generatedStrings.enumerated()), id: \.offset) { index, string in
                                    HStack {
                                        Text("\(index + 1).")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .frame(width: 30, alignment: .trailing)

                                        Text(string)
                                            .font(.system(.body, design: .monospaced))
                                            .textSelection(.enabled)
                                            .lineLimit(1)

                                        Spacer()

                                        Button(action: {
                                            copyToClipboard(string)
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                copiedButtonId = string
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    copiedButtonId = nil
                                                }
                                            }
                                        }) {
                                            Image(systemName: copiedButtonId == string ? "checkmark" : "doc.on.doc")
                                                .foregroundColor(copiedButtonId == string ? .green : .blue)
                                                .font(.caption)
                                        }
                                        .buttonStyle(.borderless)
                                        .help("Copy to clipboard")
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(AppConstants.lightGrayBackground)
                                    .cornerRadius(6)
                                }
                            }
                        }
                    }
                    .frame(minHeight: 200)

                    // Action Buttons
                    if !generatedStrings.isEmpty {
                        HStack {
                            Button(action: {
                                let allStrings = generatedStrings.joined(separator: "\n")
                                copyToClipboard(allStrings)
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showingCopyAllSuccess = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        showingCopyAllSuccess = false
                                    }
                                }
                            }) {
                                HStack {
                                    Image(systemName: showingCopyAllSuccess ? "checkmark" : "doc.on.doc.fill")
                                    Text(showingCopyAllSuccess ? "Copied!" : "Copy All")
                                }
                            }
                            .buttonStyle(.bordered)

                            Button(action: {
                                withAnimation {
                                    generatedStrings.removeAll()
                                    errorMessage = ""
                                }
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Clear")
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
            .padding(.horizontal, 0)

            Spacer()
        }
        .padding()
        .navigationTitle("\(screenName)")
        .onAppear {
            loadState()
        }
        .onDisappear {
            saveState()
        }
    }

    // MARK: - Computed Properties

    private var totalCharacters: Int {
        generatedStrings.reduce(0) { $0 + $1.count }
    }

    // MARK: - Actions

    private func generateStrings() {
        errorMessage = ""

        // Mark as custom if user modified settings
        if selectedPreset != .custom {
            selectedPreset = .custom
            config.preset = StringPreset.custom.rawValue
        }

        do {
            let strings = try RandomStringGenerator.generate(config: config, count: config.quantity)
            withAnimation {
                generatedStrings = strings
            }
        } catch let error as RandomStringError {
            errorMessage = error.errorDescription ?? "Unknown error occurred"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(text, forType: .string)
    }

    // MARK: - State Persistence

    private func saveState() {
        config.save()
        let defaults = UserDefaults.standard
        defaults.set(selectedPreset.rawValue, forKey: "RandomString.selectedPreset")
        defaults.set(generatedStrings, forKey: "RandomString.generatedStrings")
    }

    private func loadState() {
        config = RandomStringConfig.load()

        let defaults = UserDefaults.standard
        if let presetValue = defaults.string(forKey: "RandomString.selectedPreset"),
           let preset = StringPreset.allCases.first(where: { $0.rawValue == presetValue }) {
            selectedPreset = preset
        }

        if let savedStrings = defaults.array(forKey: "RandomString.generatedStrings") as? [String] {
            generatedStrings = savedStrings
        }

        // Generate initial strings if none exist
        if generatedStrings.isEmpty {
            generateStrings()
        }
    }
}

#Preview {
    RandomStringView()
}
