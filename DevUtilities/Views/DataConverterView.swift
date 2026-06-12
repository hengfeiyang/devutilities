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

struct DataConverterView: View {
    let screenName = "Data Converter"
    let module = "data_converter"

    @State private var sourceFormat: DataFormat = .json
    @State private var targetFormat: DataFormat = .yaml
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var statusMessage: String = ""
    @State private var isValid: Bool = true
    @State private var coerceCSVTypes: Bool = true

    var body: some View {
        VStack(spacing: 16) {
            // Format selectors
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("From")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Picker("From", selection: $sourceFormat) {
                        ForEach(DataFormat.allCases) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: sourceFormat) { _, _ in convert() }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    swapFormats()
                } label: {
                    Image(systemName: "arrow.left.arrow.right")
                        .foregroundColor(.blue)
                }
                .buttonStyle(.borderless)
                .help("Swap source and target formats")
                .padding(.top, 16)

                VStack(alignment: .leading, spacing: 4) {
                    Text("To")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Picker("To", selection: $targetFormat) {
                        ForEach(DataFormat.allCases) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: targetFormat) { _, _ in convert() }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(alignment: .top, spacing: 20) {
                // Input
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Text("\(sourceFormat.rawValue) Input")
                            .font(.headline)
                        if sourceFormat == .csv {
                            Toggle("Infer types", isOn: $coerceCSVTypes)
                                .toggleStyle(.checkbox)
                                .font(.caption)
                                .onChange(of: coerceCSVTypes) { _, _ in convert() }
                                .help("Coerce CSV cells like 123 / true into numbers and booleans")
                        }
                        Spacer()
                        Button("Sample") {
                            inputText = sourceFormat.sample
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
                        Text("\(targetFormat.rawValue) Output")
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
        .onChange(of: sourceFormat) { oldValue, newValue in
            Task.detached {
                await EventManager.shared.reportSubmoduleSwitch(
                    module: module,
                    from: "from_\(oldValue.rawValue.lowercased())",
                    to: "from_\(newValue.rawValue.lowercased())"
                )
            }
        }
        .onChange(of: targetFormat) { oldValue, newValue in
            Task.detached {
                await EventManager.shared.reportSubmoduleSwitch(
                    module: module,
                    from: "to_\(oldValue.rawValue.lowercased())",
                    to: "to_\(newValue.rawValue.lowercased())"
                )
            }
        }
    }

    @ViewBuilder
    private func editor(for format: DataFormat, text: Binding<String>, readOnly: Bool) -> some View {
        switch format {
        case .json: CodeEditor.json(text: text, readOnly: readOnly)
        case .yaml: CodeEditor.yaml(text: text, readOnly: readOnly)
        case .toml: CodeEditor.toml(text: text, readOnly: readOnly)
        case .csv: CodeEditor.plain(text: text, readOnly: readOnly)
        }
    }

    @ViewBuilder
    private var inputEditor: some View {
        editor(for: sourceFormat, text: $inputText, readOnly: false)
    }

    @ViewBuilder
    private var outputEditor: some View {
        let placeholder = outputText.isEmpty ? "Converted output will appear here" : outputText
        let binding = Binding<String>(get: { placeholder }, set: { _ in })
        editor(for: targetFormat, text: binding, readOnly: true)
    }

    private func swapFormats() {
        let oldSource = sourceFormat
        sourceFormat = targetFormat
        targetFormat = oldSource
        // Move the converted output back into the input so the swap is useful.
        if !outputText.isEmpty {
            inputText = outputText
        }
        convert()
    }

    private func convert() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            outputText = ""
            statusMessage = ""
            return
        }
        guard sourceFormat != targetFormat else {
            outputText = inputText
            isValid = true
            statusMessage = "Source and target formats are the same"
            return
        }
        do {
            outputText = try DataConverter.convert(
                inputText,
                from: sourceFormat,
                to: targetFormat,
                coerceCSVTypes: coerceCSVTypes
            )
            isValid = true
            statusMessage = "✅ Converted \(sourceFormat.rawValue) → \(targetFormat.rawValue)"
        } catch let err as DataConvertError {
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
        defaults.set(inputText, forKey: "DataConverter.inputText")
        defaults.set(sourceFormat.rawValue, forKey: "DataConverter.sourceFormat")
        defaults.set(targetFormat.rawValue, forKey: "DataConverter.targetFormat")
        defaults.set(coerceCSVTypes, forKey: "DataConverter.coerceCSVTypes")
    }

    private func loadState() {
        let defaults = UserDefaults.standard
        inputText = defaults.string(forKey: "DataConverter.inputText") ?? ""
        if let raw = defaults.string(forKey: "DataConverter.sourceFormat"),
           let format = DataFormat(rawValue: raw) {
            sourceFormat = format
        }
        if let raw = defaults.string(forKey: "DataConverter.targetFormat"),
           let format = DataFormat(rawValue: raw) {
            targetFormat = format
        }
        if defaults.object(forKey: "DataConverter.coerceCSVTypes") != nil {
            coerceCSVTypes = defaults.bool(forKey: "DataConverter.coerceCSVTypes")
        }
    }
}

#Preview {
    DataConverterView()
}
