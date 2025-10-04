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
import AppKit

struct HexStringConverterView: View {
    let screenName = "Hex String Converter"
    let module = "hex_string_converter"
    @State private var stringInput: String = ""
    @State private var hexOutput: String = ""
    @State private var hexInput: String = ""
    @State private var decodedOutput: String = ""
    @State private var selectedTab: HexStringTab = .stringToHex
    @State private var encoding: String.Encoding = .utf8

    var body: some View {
        VStack(spacing: 20) {
            // Tab Selection
            Picker("Mode", selection: $selectedTab) {
                ForEach(HexStringTab.allCases, id: \.self) { tab in
                    Text(tab.title)
                        .tag(tab)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            HStack(alignment: .top, spacing: 20) {
                if selectedTab == .stringToHex {
                    // String to Hex Section
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("String Input")
                                .font(.headline)
                            Spacer()
                            Button("Clear") {
                                stringInput = ""
                                hexOutput = ""
                            }
                            .buttonStyle(.borderless)
                        }

                        TextEditor(text: $stringInput)
                            .padding(5)
                            .frame(maxHeight: .infinity)
                            .onChange(of: stringInput) { _, _ in
                                convertStringToHex()
                            }

                        Text("\(stringInput.count) characters, \(stringInput.components(separatedBy: .newlines).count) lines")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Image(systemName: "arrow.right")
                        .font(.title)
                        .foregroundColor(.blue)
                        .frame(maxHeight: .infinity, alignment: .center)

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Hex Output")
                                .font(.headline)
                            Spacer()
                            Button("Copy") {
                                copyToClipboard(hexOutput)
                            }
                            .buttonStyle(.borderless)
                            .disabled(hexOutput.isEmpty)
                        }

                        ScrollView {
                            Text(hexOutput.isEmpty ? "Hex encoded string will appear here" : hexOutput)
                                .font(.system(.body, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textSelection(.enabled)
                        }
                        .padding(5)
                        .frame(maxHeight: .infinity)
                        .background(AppConstants.lightGrayBackground)
                        .cornerRadius(8)

                        Text("\(hexOutput.count) characters, \(hexOutput.components(separatedBy: .newlines).count) lines")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    // Hex to String Section
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Hex Input")
                                .font(.headline)
                            Spacer()
                            Button("Clear") {
                                hexInput = ""
                                decodedOutput = ""
                            }
                            .buttonStyle(.borderless)
                        }

                        TextEditor(text: $hexInput)
                            .padding(5)
                            .frame(maxHeight: .infinity)
                            .onChange(of: hexInput) { _, _ in
                                convertHexToString()
                            }

                        Text("\(hexInput.count) characters, \(hexInput.components(separatedBy: .newlines).count) lines")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Image(systemName: "arrow.right")
                        .font(.title)
                        .foregroundColor(.blue)
                        .frame(maxHeight: .infinity, alignment: .center)

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("String Output")
                                .font(.headline)
                            Spacer()
                            Button("Copy") {
                                copyToClipboard(decodedOutput)
                            }
                            .buttonStyle(.borderless)
                            .disabled(decodedOutput.isEmpty)
                        }

                        ScrollView {
                            Text(decodedOutput.isEmpty ? "Decoded string will appear here" : decodedOutput)
                                .font(.system(.body, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textSelection(.enabled)
                        }
                        .padding(5)
                        .frame(maxHeight: .infinity)
                        .background(AppConstants.lightGrayBackground)
                        .cornerRadius(8)

                        Text("\(decodedOutput.count) characters, \(decodedOutput.components(separatedBy: .newlines).count) lines")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 0)

            // Additional Tools
            HStack(spacing: 20) {
                Button("Sample") {
                    if selectedTab == .stringToHex {
                        stringInput = "Welcome to dev helper"
                    } else {
                        hexInput = "57656c636f6d65746f64657668656c706572"
                    }
                }
                .buttonStyle(.bordered)

                Button("Swap") {
                    if selectedTab == .stringToHex && !hexOutput.isEmpty {
                        hexInput = hexOutput
                        selectedTab = .hexToString
                    } else if selectedTab == .hexToString && !decodedOutput.isEmpty {
                        stringInput = decodedOutput
                        selectedTab = .stringToHex
                    }
                }
                .buttonStyle(.bordered)
                .disabled((selectedTab == .stringToHex && hexOutput.isEmpty) ||
                         (selectedTab == .hexToString && decodedOutput.isEmpty))

                Spacer()

                Picker("Encoding", selection: $encoding) {
                    Text("UTF-8").tag(String.Encoding.utf8)
                    Text("UTF-16").tag(String.Encoding.utf16)
                    Text("ASCII").tag(String.Encoding.ascii)
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: encoding) { _, _ in
                    if selectedTab == .stringToHex {
                        convertStringToHex()
                    } else {
                        convertHexToString()
                    }
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("\(screenName)")
        .onChange(of: selectedTab) { _, _ in
            if selectedTab == .stringToHex {
                convertStringToHex()
            } else {
                convertHexToString()
            }
        }
        .onAppear {
            loadState()
        }
        .onDisappear {
            saveState()
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            Task.detached {
                await EventManager.shared.reportSubmoduleSwitch(
                    module: module,
                    from: "\(oldValue)".lowercased(),
                    to: "\(newValue)".lowercased()
                )
            }
        }
    }

    private func convertStringToHex() {
        guard !stringInput.isEmpty else {
            hexOutput = ""
            return
        }

        guard let data = stringInput.data(using: encoding) else {
            hexOutput = "Error: Unable to encode string with selected encoding"
            return
        }

        hexOutput = data.map { String(format: "%02x", $0) }.joined()
    }

    private func convertHexToString() {
        guard !hexInput.isEmpty else {
            decodedOutput = ""
            return
        }

        // Clean the hex input (remove spaces, newlines, etc.)
        let cleanHex = hexInput.replacingOccurrences(of: " ", with: "")
                               .replacingOccurrences(of: "\n", with: "")
                               .replacingOccurrences(of: "\r", with: "")
                               .lowercased()

        // Check if hex string has even length
        guard cleanHex.count % 2 == 0 else {
            decodedOutput = "Error: Hex string must have even number of characters"
            return
        }

        // Check if all characters are valid hex
        let hexCharacterSet = CharacterSet(charactersIn: "0123456789abcdef")
        guard cleanHex.unicodeScalars.allSatisfy({ hexCharacterSet.contains($0) }) else {
            decodedOutput = "Error: Invalid hex characters found"
            return
        }

        var data = Data()
        var index = cleanHex.startIndex

        while index < cleanHex.endIndex {
            let nextIndex = cleanHex.index(index, offsetBy: 2)
            let byteString = String(cleanHex[index..<nextIndex])

            if let byte = UInt8(byteString, radix: 16) {
                data.append(byte)
            } else {
                decodedOutput = "Error: Failed to parse hex byte: \(byteString)"
                return
            }

            index = nextIndex
        }

        if let decodedString = String(data: data, encoding: encoding) {
            decodedOutput = decodedString
        } else {
            decodedOutput = "Error: Unable to decode as \(encodingName(encoding)) text"
        }
    }

    private func encodingName(_ encoding: String.Encoding) -> String {
        switch encoding {
        case .utf8: return "UTF-8"
        case .utf16: return "UTF-16"
        case .ascii: return "ASCII"
        default: return "Unknown"
        }
    }

    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(text, forType: .string)
    }

    private func saveState() {
        let defaults = UserDefaults.standard
        defaults.set(stringInput, forKey: "HexString.stringInput")
        defaults.set(hexInput, forKey: "HexString.hexInput")
        defaults.set(hexOutput, forKey: "HexString.hexOutput")
        defaults.set(decodedOutput, forKey: "HexString.decodedOutput")
        defaults.set(selectedTab.title, forKey: "HexString.selectedTab")
        defaults.set(encoding.rawValue, forKey: "HexString.encoding")
    }

    private func loadState() {
        let defaults = UserDefaults.standard
        stringInput = defaults.string(forKey: "HexString.stringInput") ?? ""
        hexInput = defaults.string(forKey: "HexString.hexInput") ?? ""
        hexOutput = defaults.string(forKey: "HexString.hexOutput") ?? ""
        decodedOutput = defaults.string(forKey: "HexString.decodedOutput") ?? ""

        if let encodingRawValue = defaults.object(forKey: "HexString.encoding") as? UInt {
            encoding = String.Encoding(rawValue: encodingRawValue)
        }

        if let tabTitle = defaults.string(forKey: "HexString.selectedTab") {
            selectedTab = HexStringTab.allCases.first { $0.title == tabTitle } ?? .stringToHex
        }

        // If we have input, trigger processing
        if selectedTab == .stringToHex && !stringInput.isEmpty {
            convertStringToHex()
        } else if selectedTab == .hexToString && !hexInput.isEmpty {
            convertHexToString()
        }
    }
}

enum HexStringTab: CaseIterable {
    case stringToHex, hexToString

    var title: String {
        switch self {
        case .stringToHex: return "String to Hex"
        case .hexToString: return "Hex to String"
        }
    }
}

#Preview {
    HexStringConverterView()
}