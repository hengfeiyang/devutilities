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

struct BaseConverterView: View {
    let screenName = "Base Converter"
    let module = "base_converter"

    @State private var binaryValue: String = ""
    @State private var octalValue: String = ""
    @State private var decimalValue: String = ""
    @State private var hexValue: String = ""
    @State private var base62Value: String = ""

    @State private var activeField: NumberBase? = nil
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    // Base62 character set for number conversion (0-9, A-Z, a-z)
    private let base62Chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

    var body: some View {
        VStack(spacing: 20) {
            // Binary Input
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Binary (Base 2)")
                        .font(.headline)
                    Spacer()
                    if !binaryValue.isEmpty {
                        Button(action: {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(binaryValue, forType: .string)
                        }) {
                            Image(systemName: "doc.on.doc")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Copy to clipboard")
                    }
                }

                TextEditor(text: $binaryValue)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 60, maxHeight: 100)
                    .border(Color.gray.opacity(0.3), width: 1)
                    .cornerRadius(4)
                    .onChange(of: binaryValue) { _, newValue in
                        if activeField != .binary {
                            activeField = .binary
                            convertFromBinary(newValue)
                        }
                    }
            }

            // Octal Input
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Octal (Base 8)")
                        .font(.headline)
                    Spacer()
                    if !octalValue.isEmpty {
                        Button(action: {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(octalValue, forType: .string)
                        }) {
                            Image(systemName: "doc.on.doc")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Copy to clipboard")
                    }
                }

                TextEditor(text: $octalValue)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 60, maxHeight: 100)
                    .border(Color.gray.opacity(0.3), width: 1)
                    .cornerRadius(4)
                    .onChange(of: octalValue) { _, newValue in
                        if activeField != .octal {
                            activeField = .octal
                            convertFromOctal(newValue)
                        }
                    }
            }

            // Decimal Input
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Decimal (Base 10)")
                        .font(.headline)
                    Spacer()
                    if !decimalValue.isEmpty {
                        Button(action: {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(decimalValue, forType: .string)
                        }) {
                            Image(systemName: "doc.on.doc")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Copy to clipboard")
                    }
                }

                TextEditor(text: $decimalValue)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 60, maxHeight: 100)
                    .border(Color.gray.opacity(0.3), width: 1)
                    .cornerRadius(4)
                    .onChange(of: decimalValue) { _, newValue in
                        if activeField != .decimal {
                            activeField = .decimal
                            convertFromDecimal(newValue)
                        }
                    }
            }

            // Hexadecimal Input
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Hexadecimal (Base 16)")
                        .font(.headline)
                    Spacer()
                    if !hexValue.isEmpty {
                        Button(action: {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(hexValue, forType: .string)
                        }) {
                            Image(systemName: "doc.on.doc")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Copy to clipboard")
                    }
                }

                TextEditor(text: $hexValue)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 60, maxHeight: 100)
                    .border(Color.gray.opacity(0.3), width: 1)
                    .cornerRadius(4)
                    .onChange(of: hexValue) { _, newValue in
                        if activeField != .hexadecimal {
                            activeField = .hexadecimal
                            convertFromHexadecimal(newValue)
                        }
                    }
            }

            // Base62 Input
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Base62 (Base 62)")
                        .font(.headline)
                    Spacer()
                    if !base62Value.isEmpty {
                        Button(action: {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(base62Value, forType: .string)
                        }) {
                            Image(systemName: "doc.on.doc")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Copy to clipboard")
                    }
                }

                TextEditor(text: $base62Value)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 60, maxHeight: 100)
                    .border(Color.gray.opacity(0.3), width: 1)
                    .cornerRadius(4)
                    .onChange(of: base62Value) { _, newValue in
                        if activeField != .base62 {
                            activeField = .base62
                            convertFromBase62(newValue)
                        }
                    }
            }

            // Error Message
            if showError {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(errorMessage)
                        .foregroundColor(.orange)
                        .font(.caption)
                }
                .padding(.horizontal)
            }

            // Clear Button
            HStack {
                Spacer()
                Button("Clear All") {
                    clearAll()
                }
                .buttonStyle(.bordered)
            }

            Spacer()
        }
        .padding()
        .navigationTitle(screenName)
        .onAppear {
            loadState()
        }
        .onDisappear {
            saveState()
        }
    }

    // MARK: - Conversion Functions

    private func convertFromBinary(_ input: String) {
        let cleaned = input.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleaned.isEmpty else {
            clearOthers(except: .binary)
            showError = false
            return
        }

        // Validate binary input
        let validChars = CharacterSet(charactersIn: "01")
        guard cleaned.rangeOfCharacter(from: validChars.inverted) == nil else {
            showError = true
            errorMessage = "Invalid binary input. Only 0 and 1 are allowed."
            clearOthers(except: .binary)
            return
        }

        guard let decimalInt = Int(cleaned, radix: 2) else {
            showError = true
            errorMessage = "Invalid binary input."
            clearOthers(except: .binary)
            return
        }

        showError = false
        octalValue = String(decimalInt, radix: 8, uppercase: false)
        decimalValue = String(decimalInt)
        hexValue = String(decimalInt, radix: 16, uppercase: true)
        base62Value = toBase62(decimalInt)

        activeField = nil
    }

    private func convertFromOctal(_ input: String) {
        let cleaned = input.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleaned.isEmpty else {
            clearOthers(except: .octal)
            showError = false
            return
        }

        // Validate octal input
        let validChars = CharacterSet(charactersIn: "01234567")
        guard cleaned.rangeOfCharacter(from: validChars.inverted) == nil else {
            showError = true
            errorMessage = "Invalid octal input. Only digits 0-7 are allowed."
            clearOthers(except: .octal)
            return
        }

        guard let decimalInt = Int(cleaned, radix: 8) else {
            showError = true
            errorMessage = "Invalid octal input."
            clearOthers(except: .octal)
            return
        }

        showError = false
        binaryValue = String(decimalInt, radix: 2)
        decimalValue = String(decimalInt)
        hexValue = String(decimalInt, radix: 16, uppercase: true)
        base62Value = toBase62(decimalInt)

        activeField = nil
    }

    private func convertFromDecimal(_ input: String) {
        let cleaned = input.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleaned.isEmpty else {
            clearOthers(except: .decimal)
            showError = false
            return
        }

        guard let decimalInt = Int(cleaned) else {
            showError = true
            errorMessage = "Invalid decimal input. Only digits 0-9 are allowed."
            clearOthers(except: .decimal)
            return
        }

        guard decimalInt >= 0 else {
            showError = true
            errorMessage = "Negative numbers are not supported."
            clearOthers(except: .decimal)
            return
        }

        showError = false
        binaryValue = String(decimalInt, radix: 2)
        octalValue = String(decimalInt, radix: 8, uppercase: false)
        hexValue = String(decimalInt, radix: 16, uppercase: true)
        base62Value = toBase62(decimalInt)

        activeField = nil
    }

    private func convertFromHexadecimal(_ input: String) {
        let cleaned = input.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "0x", with: "")
            .replacingOccurrences(of: "0X", with: "")

        guard !cleaned.isEmpty else {
            clearOthers(except: .hexadecimal)
            showError = false
            return
        }

        // Validate hexadecimal input
        let validChars = CharacterSet(charactersIn: "0123456789ABCDEFabcdef")
        guard cleaned.rangeOfCharacter(from: validChars.inverted) == nil else {
            showError = true
            errorMessage = "Invalid hexadecimal input. Only digits 0-9 and letters A-F are allowed."
            clearOthers(except: .hexadecimal)
            return
        }

        guard let decimalInt = Int(cleaned, radix: 16) else {
            showError = true
            errorMessage = "Invalid hexadecimal input."
            clearOthers(except: .hexadecimal)
            return
        }

        showError = false
        binaryValue = String(decimalInt, radix: 2)
        octalValue = String(decimalInt, radix: 8, uppercase: false)
        decimalValue = String(decimalInt)
        base62Value = toBase62(decimalInt)

        activeField = nil
    }

    private func convertFromBase62(_ input: String) {
        let cleaned = input.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleaned.isEmpty else {
            clearOthers(except: .base62)
            showError = false
            return
        }

        // Validate Base62 input
        let validChars = CharacterSet(charactersIn: base62Chars)
        guard cleaned.rangeOfCharacter(from: validChars.inverted) == nil else {
            showError = true
            errorMessage = "Invalid Base62 input. Only 0-9, A-Z, and a-z are allowed."
            clearOthers(except: .base62)
            return
        }

        guard let decimalInt = fromBase62(cleaned) else {
            showError = true
            errorMessage = "Invalid Base62 input."
            clearOthers(except: .base62)
            return
        }

        showError = false
        binaryValue = String(decimalInt, radix: 2)
        octalValue = String(decimalInt, radix: 8, uppercase: false)
        decimalValue = String(decimalInt)
        hexValue = String(decimalInt, radix: 16, uppercase: true)

        activeField = nil
    }

    // MARK: - Base62 Conversion Helpers

    private func toBase62(_ decimal: Int) -> String {
        guard decimal >= 0 else { return "" }
        guard decimal > 0 else { return "0" }

        var number = decimal
        var result = ""

        while number > 0 {
            let remainder = number % 62
            let char = base62Chars[base62Chars.index(base62Chars.startIndex, offsetBy: remainder)]
            result = String(char) + result
            number = number / 62
        }

        return result
    }

    private func fromBase62(_ input: String) -> Int? {
        var result = 0

        for char in input {
            guard let index = base62Chars.firstIndex(of: char) else {
                return nil
            }
            let value = base62Chars.distance(from: base62Chars.startIndex, to: index)
            result = result * 62 + value
        }

        return result
    }

    // MARK: - Helper Functions

    private func clearOthers(except base: NumberBase) {
        switch base {
        case .binary:
            octalValue = ""
            decimalValue = ""
            hexValue = ""
            base62Value = ""
        case .octal:
            binaryValue = ""
            decimalValue = ""
            hexValue = ""
            base62Value = ""
        case .decimal:
            binaryValue = ""
            octalValue = ""
            hexValue = ""
            base62Value = ""
        case .hexadecimal:
            binaryValue = ""
            octalValue = ""
            decimalValue = ""
            base62Value = ""
        case .base62:
            binaryValue = ""
            octalValue = ""
            decimalValue = ""
            hexValue = ""
        }
    }

    private func clearAll() {
        binaryValue = ""
        octalValue = ""
        decimalValue = ""
        hexValue = ""
        base62Value = ""
        showError = false
        errorMessage = ""
        activeField = nil
    }

    // MARK: - State Persistence

    private func saveState() {
        let defaults = UserDefaults.standard
        defaults.set(binaryValue, forKey: "BaseConverter.binaryValue")
        defaults.set(octalValue, forKey: "BaseConverter.octalValue")
        defaults.set(decimalValue, forKey: "BaseConverter.decimalValue")
        defaults.set(hexValue, forKey: "BaseConverter.hexValue")
        defaults.set(base62Value, forKey: "BaseConverter.base62Value")
    }

    private func loadState() {
        let defaults = UserDefaults.standard

        binaryValue = defaults.string(forKey: "BaseConverter.binaryValue") ?? ""
        octalValue = defaults.string(forKey: "BaseConverter.octalValue") ?? ""
        decimalValue = defaults.string(forKey: "BaseConverter.decimalValue") ?? ""
        hexValue = defaults.string(forKey: "BaseConverter.hexValue") ?? ""
        base62Value = defaults.string(forKey: "BaseConverter.base62Value") ?? ""
    }
}

enum NumberBase {
    case binary
    case octal
    case decimal
    case hexadecimal
    case base62
}

#Preview {
    BaseConverterView()
}
