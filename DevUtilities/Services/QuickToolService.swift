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

import Foundation
import CryptoKit
import Security

enum QuickToolError: LocalizedError {
    case invalidInput(String)

    var errorDescription: String? {
        switch self {
        case .invalidInput(let message):
            return message
        }
    }
}

/// UI-independent conversion logic shared by tool views and App Intents (Spotlight actions).
enum QuickToolService {

    // MARK: - Base64

    static func base64Encode(_ text: String, urlSafe: Bool = false) -> String {
        let base64 = Data(text.utf8).base64EncodedString()
        guard urlSafe else { return base64 }
        return base64
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    /// Accepts both standard and URL-safe Base64; padding is restored automatically.
    static func base64Decode(_ text: String) throws -> String {
        var base64String = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64String.count % 4 != 0 {
            base64String += "="
        }
        guard let data = Data(base64Encoded: base64String) else {
            throw QuickToolError.invalidInput("Invalid Base64 input")
        }
        guard let decoded = String(data: data, encoding: .utf8) else {
            throw QuickToolError.invalidInput("Unable to decode as UTF-8 text")
        }
        return decoded
    }

    // MARK: - URL

    static func urlEncode(_ text: String, alphanumericOnly: Bool = false) throws -> String {
        let allowedCharacters: CharacterSet = alphanumericOnly ? .alphanumerics : .urlQueryAllowed
        guard let encoded = text.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else {
            throw QuickToolError.invalidInput("Unable to encode text")
        }
        return encoded
    }

    static func urlDecode(_ text: String) throws -> String {
        guard let decoded = text.removingPercentEncoding else {
            throw QuickToolError.invalidInput("Invalid percent-encoded input")
        }
        return decoded
    }

    // MARK: - Timestamp

    /// Smart conversion: numeric input is treated as a Unix timestamp,
    /// "now" returns the current time, anything else is parsed as a date string.
    static func convertTimestamp(_ input: String, isLocalTime: Bool = true) throws -> String {
        let cleaned = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else {
            throw QuickToolError.invalidInput("Input is empty")
        }
        if cleaned.lowercased() == "now" {
            return timestampResult(Int64(Date().timeIntervalSince1970))
        }
        if Int64(cleaned) != nil {
            return try timestampToDate(cleaned)
        }
        return try dateToTimestamp(cleaned, isLocalTime: isLocalTime)
    }

    /// Auto-detects precision from digit count: 10 = s, 13 = ms, 16 = µs, 19 = ns.
    static func timestampToDate(_ timestamp: String) throws -> String {
        guard let timestampInt = Int64(timestamp) else {
            throw QuickToolError.invalidInput("Invalid timestamp")
        }

        let timeInterval: TimeInterval
        let detectedPrecision: String
        switch timestamp.count {
        case 10:
            timeInterval = TimeInterval(timestampInt)
            detectedPrecision = "seconds"
        case 13:
            timeInterval = TimeInterval(timestampInt) / 1000
            detectedPrecision = "milliseconds"
        case 16:
            timeInterval = TimeInterval(timestampInt) / 1_000_000
            detectedPrecision = "microseconds"
        case 19:
            timeInterval = TimeInterval(timestampInt) / 1_000_000_000
            detectedPrecision = "nanoseconds"
        default:
            throw QuickToolError.invalidInput("Invalid timestamp length. Expected 10 (s), 13 (ms), 16 (µs) or 19 (ns) digits.")
        }

        let date = Date(timeIntervalSince1970: timeInterval)

        let localFormatter = DateFormatter()
        localFormatter.timeZone = TimeZone.current
        localFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"

        let utcFormatter = DateFormatter()
        utcFormatter.timeZone = TimeZone(abbreviation: "UTC")
        utcFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss 'UTC'"

        return """
        UTC Time: \(utcFormatter.string(from: date))
        Local Time: \(localFormatter.string(from: date))
        Detected Format: \(detectedPrecision)
        """
    }

    /// Parses "yyyy-MM-dd HH:mm:ss" and returns the timestamp in s/ms/µs/ns.
    static func dateToTimestamp(_ dateString: String, isLocalTime: Bool = true) throws -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.isLenient = false
        formatter.timeZone = isLocalTime ? TimeZone.current : TimeZone(abbreviation: "UTC")

        guard let date = formatter.date(from: dateString) else {
            throw QuickToolError.invalidInput("Invalid date format. Use: YYYY-MM-DD HH:MM:SS (example: 2025-02-01 21:44:45)")
        }

        let timestamp = Int64(date.timeIntervalSince1970)
        let maxSafeTimestamp: Int64 = Int64.max / 1_000_000_000
        let minSafeTimestamp: Int64 = Int64.min / 1_000_000_000
        guard timestamp <= maxSafeTimestamp && timestamp >= minSafeTimestamp else {
            throw QuickToolError.invalidInput("Date is out of supported range")
        }

        return timestampResult(timestamp)
    }

    private static func timestampResult(_ timestamp: Int64) -> String {
        func multiplied(_ factor: Int64) -> String {
            let result = timestamp.multipliedReportingOverflow(by: factor)
            return result.overflow ? "Overflow" : "\(result.partialValue)"
        }
        return """
        Seconds: \(timestamp)
        Milliseconds: \(multiplied(1000))
        Microseconds: \(multiplied(1_000_000))
        Nanoseconds: \(multiplied(1_000_000_000))
        """
    }

    // MARK: - UUID

    enum UUIDStyle {
        case v4
        case v7
    }

    static func generateUUID(style: UUIDStyle = .v4, uppercase: Bool = false) -> String {
        let uuid: UUID
        switch style {
        case .v4:
            uuid = UUID()
        case .v7:
            uuid = generateUUIDv7()
        }
        return uppercase ? uuid.uuidString.uppercased() : uuid.uuidString.lowercased()
    }

    static func generateUUIDv7() -> UUID {
        // 48-bit unix ms timestamp + version 7 nibble + variant 10 bits, rest random
        let timestamp = UInt64(Date().timeIntervalSince1970 * 1000)

        var randomBytes = [UInt8](repeating: 0, count: 16)
        _ = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)

        randomBytes[0] = UInt8((timestamp >> 40) & 0xFF)
        randomBytes[1] = UInt8((timestamp >> 32) & 0xFF)
        randomBytes[2] = UInt8((timestamp >> 24) & 0xFF)
        randomBytes[3] = UInt8((timestamp >> 16) & 0xFF)
        randomBytes[4] = UInt8((timestamp >> 8) & 0xFF)
        randomBytes[5] = UInt8(timestamp & 0xFF)
        randomBytes[6] = (randomBytes[6] & 0x0F) | 0x70
        randomBytes[8] = (randomBytes[8] & 0x3F) | 0x80

        let uuidBytes = (randomBytes[0], randomBytes[1], randomBytes[2], randomBytes[3],
                         randomBytes[4], randomBytes[5], randomBytes[6], randomBytes[7],
                         randomBytes[8], randomBytes[9], randomBytes[10], randomBytes[11],
                         randomBytes[12], randomBytes[13], randomBytes[14], randomBytes[15])
        return UUID(uuid: uuidBytes)
    }

    // MARK: - JWT

    /// Decodes a JWT without verifying the signature. Returns pretty-printed header and payload.
    static func decodeJWT(_ token: String) throws -> String {
        let parts = token.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: ".")
        guard parts.count >= 2 else {
            throw QuickToolError.invalidInput("Invalid JWT format. Expected header.payload.signature")
        }

        func decodeSegment(_ segment: String) throws -> String {
            guard let data = base64URLDecode(segment),
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let formatted = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys]),
                  let string = String(data: formatted, encoding: .utf8) else {
                throw QuickToolError.invalidInput("Unable to decode JWT segment")
            }
            return string
        }

        let header = try decodeSegment(String(parts[0]))
        let payload = try decodeSegment(String(parts[1]))
        var result = "Header:\n\(header)\n\nPayload:\n\(payload)"
        if parts.count < 3 {
            result += "\n\n(Unsigned token — no signature)"
        }
        return result
    }

    static func base64URLDecode(_ string: String) -> Data? {
        var base64 = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 {
            base64 += "="
        }
        return Data(base64Encoded: base64)
    }

    // MARK: - Hash

    enum HashKind: String, CaseIterable {
        case md5
        case crc32
        case sha1
        case sha256
        case sha384
        case sha512
    }

    static func hash(_ text: String, kind: HashKind) -> String {
        let data = Data(text.utf8)
        switch kind {
        case .md5:
            return Insecure.MD5.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
        case .crc32:
            return String(crc32(data))
        case .sha1:
            return Insecure.SHA1.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
        case .sha256:
            return SHA256.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
        case .sha384:
            return SHA384.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
        case .sha512:
            return SHA512.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
        }
    }

    // MARK: - Number Base

    private static let base62Chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

    enum NumberBaseKind: Int, CaseIterable {
        case binary = 2
        case octal = 8
        case decimal = 10
        case hexadecimal = 16
        case base62 = 62

        var title: String {
            switch self {
            case .binary: return "Binary"
            case .octal: return "Octal"
            case .decimal: return "Decimal"
            case .hexadecimal: return "Hexadecimal"
            case .base62: return "Base62"
            }
        }
    }

    /// Converts a value from the given base and returns it in all five bases.
    static func convertNumberBase(_ value: String, from base: NumberBaseKind) throws -> String {
        let cleaned: String
        if base == .hexadecimal {
            cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "0x", with: "")
                .replacingOccurrences(of: "0X", with: "")
        } else {
            cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        guard !cleaned.isEmpty else {
            throw QuickToolError.invalidInput("Input is empty")
        }

        let decimalInt: Int
        if base == .base62 {
            guard let parsed = fromBase62(cleaned) else {
                throw QuickToolError.invalidInput("Invalid Base62 input. Only 0-9, A-Z, and a-z are allowed.")
            }
            decimalInt = parsed
        } else {
            guard let parsed = Int(cleaned, radix: base.rawValue), parsed >= 0 else {
                throw QuickToolError.invalidInput("Invalid \(base.title.lowercased()) input")
            }
            decimalInt = parsed
        }

        return """
        Binary: \(String(decimalInt, radix: 2))
        Octal: \(String(decimalInt, radix: 8))
        Decimal: \(decimalInt)
        Hexadecimal: \(String(decimalInt, radix: 16, uppercase: true))
        Base62: \(toBase62(decimalInt))
        """
    }

    // MARK: - Random String

    static func generateRandomString(length: Int, includeSymbols: Bool) throws -> String {
        guard (1...100).contains(length) else {
            throw QuickToolError.invalidInput("Length must be between 1 and 100")
        }
        var config = RandomStringConfig()
        config.length = length
        config.includeUppercase = true
        config.includeLowercase = true
        config.includeNumbers = true
        config.includeSymbols = includeSymbols
        return try RandomStringGenerator.generate(config: config)
    }

    // MARK: - Unit Conversion

    /// Converts within one category, mirroring UnitConverterView's logic.
    static func convertUnit(_ value: Double, category: UnitCategory, from fromName: String, to toName: String) throws -> String {
        guard let fromUnit = category.units.first(where: { $0.name == fromName }),
              let toUnit = category.units.first(where: { $0.name == toName }) else {
            throw QuickToolError.invalidInput("Unknown unit")
        }

        let result: Double
        if category == .temperature {
            let celsius: Double
            switch fromName {
            case "fahrenheit": celsius = (value - 32) * 5 / 9
            case "kelvin": celsius = value - 273.15
            default: celsius = value
            }
            switch toName {
            case "fahrenheit": result = celsius * 9 / 5 + 32
            case "kelvin": result = celsius + 273.15
            default: result = celsius
            }
        } else {
            result = value * fromUnit.toBaseMultiplier / toUnit.toBaseMultiplier
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 10
        formatter.minimumFractionDigits = 0
        let formatted = formatter.string(from: NSNumber(value: result)) ?? "\(result)"
        return "\(formatted) \(toUnit.symbol)"
    }

    static func toBase62(_ decimal: Int) -> String {
        guard decimal >= 0 else { return "" }
        guard decimal > 0 else { return "0" }

        var number = decimal
        var result = ""
        while number > 0 {
            let remainder = number % 62
            let char = base62Chars[base62Chars.index(base62Chars.startIndex, offsetBy: remainder)]
            result = String(char) + result
            number /= 62
        }
        return result
    }

    static func fromBase62(_ input: String) -> Int? {
        var result = 0
        for char in input {
            guard let index = base62Chars.firstIndex(of: char) else {
                return nil
            }
            let value = base62Chars.distance(from: base62Chars.startIndex, to: index)
            let multiplied = result.multipliedReportingOverflow(by: 62)
            guard !multiplied.overflow else { return nil }
            let added = multiplied.partialValue.addingReportingOverflow(value)
            guard !added.overflow else { return nil }
            result = added.partialValue
        }
        return result
    }
}
