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

import AppIntents
import AppKit

// MARK: - Shared helpers

private func copyToPasteboard(_ text: String) async {
    await MainActor.run {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}

// MARK: - Timestamp

struct ConvertTimestampIntent: AppIntent {
    static let title: LocalizedStringResource = "Convert Timestamp"
    static let description = IntentDescription(
        "Convert a Unix timestamp to a readable date, or a date string to a timestamp. Type \"now\" for the current time.",
        categoryName: "Converters"
    )

    @Parameter(title: "Timestamp or Date", inputOptions: String.IntentInputOptions(keyboardType: .default))
    var input: String

    @Parameter(title: "Copy Result to Clipboard", default: true)
    var copyToClipboard: Bool

    static var parameterSummary: some ParameterSummary {
        Summary("Convert \(\.$input)")
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let output = try QuickToolService.convertTimestamp(input)
        if copyToClipboard { await copyToPasteboard(output) }
        return .result(value: output, dialog: IntentDialog(stringLiteral: output))
    }
}

// MARK: - Base64

struct EncodeBase64Intent: AppIntent {
    static let title: LocalizedStringResource = "Encode Base64"
    static let description = IntentDescription("Encode text to Base64.", categoryName: "Encoders")

    @Parameter(title: "Text")
    var input: String

    @Parameter(title: "URL-Safe", default: false)
    var urlSafe: Bool

    @Parameter(title: "Copy Result to Clipboard", default: true)
    var copyToClipboard: Bool

    static var parameterSummary: some ParameterSummary {
        Summary("Encode \(\.$input) to Base64")
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let output = QuickToolService.base64Encode(input, urlSafe: urlSafe)
        if copyToClipboard { await copyToPasteboard(output) }
        return .result(value: output, dialog: IntentDialog(stringLiteral: output))
    }
}

struct DecodeBase64Intent: AppIntent {
    static let title: LocalizedStringResource = "Decode Base64"
    static let description = IntentDescription("Decode a Base64 string (standard or URL-safe).", categoryName: "Encoders")

    @Parameter(title: "Base64 Text")
    var input: String

    @Parameter(title: "Copy Result to Clipboard", default: true)
    var copyToClipboard: Bool

    static var parameterSummary: some ParameterSummary {
        Summary("Decode Base64 \(\.$input)")
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let output = try QuickToolService.base64Decode(input)
        if copyToClipboard { await copyToPasteboard(output) }
        return .result(value: output, dialog: IntentDialog(stringLiteral: output))
    }
}

// MARK: - URL

struct EncodeURLIntent: AppIntent {
    static let title: LocalizedStringResource = "URL Encode"
    static let description = IntentDescription("Percent-encode text for use in URLs.", categoryName: "Encoders")

    @Parameter(title: "Text")
    var input: String

    @Parameter(title: "Copy Result to Clipboard", default: true)
    var copyToClipboard: Bool

    static var parameterSummary: some ParameterSummary {
        Summary("URL encode \(\.$input)")
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let output = try QuickToolService.urlEncode(input)
        if copyToClipboard { await copyToPasteboard(output) }
        return .result(value: output, dialog: IntentDialog(stringLiteral: output))
    }
}

struct DecodeURLIntent: AppIntent {
    static let title: LocalizedStringResource = "URL Decode"
    static let description = IntentDescription("Decode a percent-encoded URL string.", categoryName: "Encoders")

    @Parameter(title: "Encoded Text")
    var input: String

    @Parameter(title: "Copy Result to Clipboard", default: true)
    var copyToClipboard: Bool

    static var parameterSummary: some ParameterSummary {
        Summary("URL decode \(\.$input)")
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let output = try QuickToolService.urlDecode(input)
        if copyToClipboard { await copyToPasteboard(output) }
        return .result(value: output, dialog: IntentDialog(stringLiteral: output))
    }
}

// MARK: - UUID

enum UUIDVersionAppEnum: String, AppEnum {
    case v4
    case v7

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "UUID Version"
    static let caseDisplayRepresentations: [UUIDVersionAppEnum: DisplayRepresentation] = [
        .v4: "v4 (random)",
        .v7: "v7 (time-ordered)",
    ]
}

struct GenerateUUIDIntent: AppIntent {
    static let title: LocalizedStringResource = "Generate UUID"
    static let description = IntentDescription("Generate a random UUID (v4 or v7).", categoryName: "Generators")

    @Parameter(title: "Version", default: .v4)
    var version: UUIDVersionAppEnum

    @Parameter(title: "Uppercase", default: false)
    var uppercase: Bool

    @Parameter(title: "Copy Result to Clipboard", default: true)
    var copyToClipboard: Bool

    static var parameterSummary: some ParameterSummary {
        Summary("Generate a \(\.$version) UUID")
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let style: QuickToolService.UUIDStyle = version == .v7 ? .v7 : .v4
        let output = QuickToolService.generateUUID(style: style, uppercase: uppercase)
        if copyToClipboard { await copyToPasteboard(output) }
        return .result(value: output, dialog: IntentDialog(stringLiteral: output))
    }
}

// MARK: - JWT

struct DecodeJWTIntent: AppIntent {
    static let title: LocalizedStringResource = "Decode JWT"
    static let description = IntentDescription("Decode a JWT's header and payload (signature is not verified).", categoryName: "Decoders")

    @Parameter(title: "JWT Token")
    var input: String

    @Parameter(title: "Copy Result to Clipboard", default: false)
    var copyToClipboard: Bool

    static var parameterSummary: some ParameterSummary {
        Summary("Decode JWT \(\.$input)")
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let output = try QuickToolService.decodeJWT(input)
        if copyToClipboard { await copyToPasteboard(output) }
        return .result(value: output, dialog: IntentDialog(stringLiteral: output))
    }
}

// MARK: - Hash

enum HashKindAppEnum: String, AppEnum {
    case md5
    case crc32
    case sha1
    case sha256
    case sha384
    case sha512

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Hash Algorithm"
    static let caseDisplayRepresentations: [HashKindAppEnum: DisplayRepresentation] = [
        .md5: "MD5",
        .crc32: "CRC32",
        .sha1: "SHA-1",
        .sha256: "SHA-256",
        .sha384: "SHA-384",
        .sha512: "SHA-512",
    ]

    var serviceKind: QuickToolService.HashKind {
        QuickToolService.HashKind(rawValue: rawValue) ?? .sha256
    }
}

struct HashTextIntent: AppIntent {
    static let title: LocalizedStringResource = "Hash Text"
    static let description = IntentDescription("Compute the hash of a text (MD5, CRC32, SHA-1/256/384/512).", categoryName: "Generators")

    @Parameter(title: "Text")
    var input: String

    @Parameter(title: "Algorithm", default: .sha256)
    var algorithm: HashKindAppEnum

    @Parameter(title: "Copy Result to Clipboard", default: true)
    var copyToClipboard: Bool

    static var parameterSummary: some ParameterSummary {
        Summary("Generate \(\.$algorithm) hash of \(\.$input)")
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let output = QuickToolService.hash(input, kind: algorithm.serviceKind)
        if copyToClipboard { await copyToPasteboard(output) }
        return .result(value: output, dialog: IntentDialog(stringLiteral: output))
    }
}

// MARK: - Number Base

enum NumberBaseAppEnum: String, AppEnum {
    case binary
    case octal
    case decimal
    case hexadecimal
    case base62

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Number Base"
    static let caseDisplayRepresentations: [NumberBaseAppEnum: DisplayRepresentation] = [
        .binary: "Binary (2)",
        .octal: "Octal (8)",
        .decimal: "Decimal (10)",
        .hexadecimal: "Hexadecimal (16)",
        .base62: "Base62 (62)",
    ]

    var serviceKind: QuickToolService.NumberBaseKind {
        switch self {
        case .binary: return .binary
        case .octal: return .octal
        case .decimal: return .decimal
        case .hexadecimal: return .hexadecimal
        case .base62: return .base62
        }
    }
}

struct ConvertNumberBaseIntent: AppIntent {
    static let title: LocalizedStringResource = "Convert Number Base"
    static let description = IntentDescription("Convert a number between binary, octal, decimal, hexadecimal and Base62.", categoryName: "Converters")

    @Parameter(title: "Value")
    var input: String

    @Parameter(title: "From Base", default: .decimal)
    var fromBase: NumberBaseAppEnum

    @Parameter(title: "Copy Result to Clipboard", default: false)
    var copyToClipboard: Bool

    static var parameterSummary: some ParameterSummary {
        Summary("Convert \(\.$fromBase) value \(\.$input)")
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let output = try QuickToolService.convertNumberBase(input, from: fromBase.serviceKind)
        if copyToClipboard { await copyToPasteboard(output) }
        return .result(value: output, dialog: IntentDialog(stringLiteral: output))
    }
}

// MARK: - Random String

struct GenerateRandomStringIntent: AppIntent {
    static let title: LocalizedStringResource = "Generate Random String"
    static let description = IntentDescription(
        "Generate a cryptographically secure random string (letters and numbers, symbols optional).",
        categoryName: "Generators"
    )

    @Parameter(title: "Length", default: 16, inclusiveRange: (1, 100))
    var length: Int

    @Parameter(title: "Include Symbols", default: false)
    var includeSymbols: Bool

    @Parameter(title: "Copy Result to Clipboard", default: true)
    var copyToClipboard: Bool

    static var parameterSummary: some ParameterSummary {
        Summary("Generate a random string of \(\.$length) characters") {
            \.$includeSymbols
            \.$copyToClipboard
        }
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let output = try QuickToolService.generateRandomString(length: length, includeSymbols: includeSymbols)
        if copyToClipboard { await copyToPasteboard(output) }
        return .result(value: output, dialog: IntentDialog(stringLiteral: output))
    }
}

// MARK: - Unit Conversion

enum UnitAppEnum: String, AppEnum {
    // Data
    case bit, byte, kilobyte, megabyte, gigabyte, terabyte, petabyte
    // Time
    case nanosecond, microsecond, millisecond, second, minute, hour, day, week, month, year
    // Length
    case millimeter, centimeter, meter, kilometer, inch, foot, yard, mile
    // Weight
    case milligram, gram, kilogram, ounce, pound, ton
    // Temperature
    case celsius, fahrenheit, kelvin
    // Area
    case squareMeter = "square_meter"
    case squareFoot = "square_foot"
    case acre, hectare
    // Volume
    case milliliter, liter, gallon, quart, pint, cup

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Unit"
    static let caseDisplayRepresentations: [UnitAppEnum: DisplayRepresentation] = [
        .bit: "bit", .byte: "Byte", .kilobyte: "KB", .megabyte: "MB", .gigabyte: "GB", .terabyte: "TB", .petabyte: "PB",
        .nanosecond: "ns", .microsecond: "µs", .millisecond: "ms", .second: "second", .minute: "minute",
        .hour: "hour", .day: "day", .week: "week", .month: "month", .year: "year",
        .millimeter: "mm", .centimeter: "cm", .meter: "m", .kilometer: "km",
        .inch: "inch", .foot: "foot", .yard: "yard", .mile: "mile",
        .milligram: "mg", .gram: "g", .kilogram: "kg", .ounce: "oz", .pound: "lb", .ton: "ton",
        .celsius: "°C", .fahrenheit: "°F", .kelvin: "K",
        .squareMeter: "m²", .squareFoot: "ft²", .acre: "acre", .hectare: "hectare",
        .milliliter: "mL", .liter: "L", .gallon: "gallon", .quart: "quart", .pint: "pint", .cup: "cup",
    ]

    var category: UnitCategory {
        switch self {
        case .bit, .byte, .kilobyte, .megabyte, .gigabyte, .terabyte, .petabyte:
            return .data
        case .nanosecond, .microsecond, .millisecond, .second, .minute, .hour, .day, .week, .month, .year:
            return .time
        case .millimeter, .centimeter, .meter, .kilometer, .inch, .foot, .yard, .mile:
            return .length
        case .milligram, .gram, .kilogram, .ounce, .pound, .ton:
            return .weight
        case .celsius, .fahrenheit, .kelvin:
            return .temperature
        case .squareMeter, .squareFoot, .acre, .hectare:
            return .area
        case .milliliter, .liter, .gallon, .quart, .pint, .cup:
            return .volume
        }
    }
}

struct ConvertUnitIntent: AppIntent {
    static let title: LocalizedStringResource = "Convert Unit"
    static let description = IntentDescription(
        "Convert a value between units of data, time, length, weight, temperature, area or volume.",
        categoryName: "Converters"
    )

    @Parameter(title: "Value")
    var value: Double

    @Parameter(title: "From", default: .megabyte)
    var fromUnit: UnitAppEnum

    @Parameter(title: "To", default: .gigabyte)
    var toUnit: UnitAppEnum

    @Parameter(title: "Copy Result to Clipboard", default: true)
    var copyToClipboard: Bool

    static var parameterSummary: some ParameterSummary {
        Summary("Convert \(\.$value) \(\.$fromUnit) to \(\.$toUnit)")
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        guard fromUnit.category == toUnit.category else {
            throw QuickToolError.invalidInput("Units must belong to the same category (e.g. MB → GB, not MB → km)")
        }
        let output = try QuickToolService.convertUnit(
            value,
            category: fromUnit.category,
            from: fromUnit.rawValue,
            to: toUnit.rawValue
        )
        if copyToClipboard { await copyToPasteboard(output) }
        return .result(value: output, dialog: IntentDialog(stringLiteral: output))
    }
}

// MARK: - App Shortcuts (Spotlight / Siri discovery)

struct DevUtilitiesShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ConvertTimestampIntent(),
            phrases: ["Convert timestamp with \(.applicationName)"],
            shortTitle: "Convert Timestamp",
            systemImageName: "clock"
        )
        AppShortcut(
            intent: GenerateUUIDIntent(),
            phrases: ["Generate UUID with \(.applicationName)"],
            shortTitle: "Generate UUID",
            systemImageName: "number.square"
        )
        AppShortcut(
            intent: EncodeBase64Intent(),
            phrases: ["Encode Base64 with \(.applicationName)"],
            shortTitle: "Encode Base64",
            systemImageName: "arrow.right.square"
        )
        AppShortcut(
            intent: DecodeBase64Intent(),
            phrases: ["Decode Base64 with \(.applicationName)"],
            shortTitle: "Decode Base64",
            systemImageName: "arrow.left.square"
        )
        AppShortcut(
            intent: ConvertNumberBaseIntent(),
            phrases: ["Convert number base with \(.applicationName)"],
            shortTitle: "Number Base",
            systemImageName: "textformat.123"
        )
        AppShortcut(
            intent: HashTextIntent(),
            phrases: ["Hash text with \(.applicationName)"],
            shortTitle: "Hash Text",
            systemImageName: "number"
        )
        AppShortcut(
            intent: EncodeURLIntent(),
            phrases: ["URL encode with \(.applicationName)"],
            shortTitle: "URL Encode",
            systemImageName: "link"
        )
        AppShortcut(
            intent: DecodeURLIntent(),
            phrases: ["URL decode with \(.applicationName)"],
            shortTitle: "URL Decode",
            systemImageName: "link.badge.plus"
        )
        AppShortcut(
            intent: GenerateRandomStringIntent(),
            phrases: ["Generate random string with \(.applicationName)"],
            shortTitle: "Random String",
            systemImageName: "dice"
        )
        AppShortcut(
            intent: ConvertUnitIntent(),
            phrases: ["Convert unit with \(.applicationName)"],
            shortTitle: "Convert Unit",
            systemImageName: "scalemass"
        )
    }
}
