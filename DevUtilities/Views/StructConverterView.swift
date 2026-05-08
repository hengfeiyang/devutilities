// Copyright 2026 Hengfei Yang.
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
import AppKit

struct StructConverterView: View {
    let screenName = "Struct Converter"
    let module = "struct_converter"

    @State private var inputFormat: StructInputFormat = .json
    @State private var outputLanguage: StructOutputLanguage = .typescript
    @State private var rootName: String = "Root"
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var statusMessage: String = ""
    @State private var isValid: Bool = true

    var body: some View {
        VStack(spacing: 16) {
            // Format selectors
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Input Format")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Picker("Input", selection: $inputFormat) {
                        ForEach(StructInputFormat.allCases) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: inputFormat) { _, _ in convert() }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 4) {
                    Text("")
                        .font(.caption)
                        .foregroundColor(.secondary)
                     Image(systemName: "arrow.right")
                    .foregroundColor(.blue)
                }
                .frame(maxWidth: 20, alignment: .leading)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Output Language")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Picker("Output", selection: $outputLanguage) {
                        ForEach(StructOutputLanguage.allCases) { lang in
                            Text(lang.rawValue).tag(lang)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: outputLanguage) { _, _ in convert() }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(alignment: .top, spacing: 20) {
                // Input
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Text("\(inputFormat.rawValue) Input")
                            .font(.headline)
                        Text("Root Name")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Root", text: $rootName)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                            .onSubmit { convert() }
                        Spacer()
                        Button("Sample") {
                            inputText = inputFormat.sample
                            convert()
                        }
                        .buttonStyle(.borderless)
                        Button("Clear") {
                            inputText = ""
                            outputText = ""
                            statusMessage = ""
                        }
                        .buttonStyle(.borderless)
                    }
                    inputEditor
                        .padding(5)
                        .frame(maxHeight: .infinity)
                        .onChange(of: inputText) { _, _ in convert() }
                    Text("\(inputText.count) characters, \(inputText.components(separatedBy: .newlines).count) lines")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Output
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("\(outputLanguage.rawValue) Output")
                            .font(.headline)
                        Spacer()
                        Button("Copy") {
                            copyToClipboard(outputText)
                        }
                        .buttonStyle(.borderless)
                        .disabled(outputText.isEmpty)
                    }
                    outputEditor
                        .padding(5)
                        .frame(maxHeight: .infinity)
                    Text("\(outputText.count) characters, \(outputText.components(separatedBy: .newlines).count) lines")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .font(.caption)
                    .foregroundColor(isValid ? .green : .red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .navigationTitle(screenName)
        .onAppear {
            loadState()
            if outputText.isEmpty && !inputText.isEmpty { convert() }
        }
        .onDisappear { saveState() }
        .onChange(of: inputFormat) { oldValue, newValue in
            Task.detached {
                await EventManager.shared.reportSubmoduleSwitch(
                    module: module,
                    from: "input_\(oldValue.rawValue.lowercased())",
                    to: "input_\(newValue.rawValue.lowercased())"
                )
            }
        }
        .onChange(of: outputLanguage) { oldValue, newValue in
            Task.detached {
                await EventManager.shared.reportSubmoduleSwitch(
                    module: module,
                    from: "output_\(oldValue.rawValue.lowercased())",
                    to: "output_\(newValue.rawValue.lowercased())"
                )
            }
        }
    }

    @ViewBuilder
    private var inputEditor: some View {
        switch inputFormat {
        case .json: CodeEditor.json(text: $inputText)
        case .toml: CodeEditor.toml(text: $inputText)
        case .yaml: CodeEditor.yaml(text: $inputText)
        case .sqlDDL: CodeEditor.sql(text: $inputText)
        }
    }

    @ViewBuilder
    private var outputEditor: some View {
        let placeholder = outputText.isEmpty ? "Generated code will appear here" : outputText
        let binding = Binding<String>(get: { placeholder }, set: { _ in })
        switch outputLanguage {
        case .swift: CodeEditor.swift(text: binding, readOnly: true)
        case .go: CodeEditor.go(text: binding, readOnly: true)
        case .typescript: CodeEditor.typescript(text: binding, readOnly: true)
        case .rust: CodeEditor.rust(text: binding, readOnly: true)
        case .python: CodeEditor.python(text: binding, readOnly: true)
        case .java: CodeEditor.java(text: binding, readOnly: true)
        case .php: CodeEditor.php(text: binding, readOnly: true)
        }
    }

    private func convert() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            outputText = ""
            statusMessage = ""
            return
        }
        do {
            let schema = try StructParserFactory.parse(inputText, format: inputFormat, rootName: rootName)
            let generator = StructGeneratorFactory.generator(for: outputLanguage)
            outputText = generator.generate(schema)
            isValid = true
            let count = schema.structs.count
            statusMessage = "✅ Generated \(count) \(count == 1 ? "type" : "types")"
        } catch let err as StructConverterError {
            outputText = ""
            isValid = false
            statusMessage = "❌ \(err.message)"
        } catch {
            outputText = ""
            isValid = false
            statusMessage = "❌ \(error.localizedDescription)"
        }
    }

    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(text, forType: .string)
    }

    private func saveState() {
        let defaults = UserDefaults.standard
        defaults.set(inputText, forKey: "StructConverter.inputText")
        defaults.set(rootName, forKey: "StructConverter.rootName")
        defaults.set(inputFormat.rawValue, forKey: "StructConverter.inputFormat")
        defaults.set(outputLanguage.rawValue, forKey: "StructConverter.outputLanguage")
    }

    private func loadState() {
        let defaults = UserDefaults.standard
        inputText = defaults.string(forKey: "StructConverter.inputText") ?? ""
        rootName = defaults.string(forKey: "StructConverter.rootName") ?? "Root"
        if let raw = defaults.string(forKey: "StructConverter.inputFormat"),
           let format = StructInputFormat(rawValue: raw) {
            inputFormat = format
        }
        if let raw = defaults.string(forKey: "StructConverter.outputLanguage"),
           let lang = StructOutputLanguage(rawValue: raw) {
            outputLanguage = lang
        }
    }
}

#Preview {
    StructConverterView()
}
