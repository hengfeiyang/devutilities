//
//  RandomStringConfig.swift
//  DevUtilities
//
//  Configuration model for Random String
//

import Foundation

// MARK: - Character Sets
struct CharacterSets {
    static let uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    static let lowercase = "abcdefghijklmnopqrstuvwxyz"
    static let numbers = "0123456789"
    static let symbols = "!@#$%^&*()_+-=[]{}|;:,.<>?"
    static let ambiguous = "0O1lI"
    static let hex = "0123456789ABCDEF"
}

// MARK: - String Preset
enum StringPreset: String, CaseIterable, Identifiable {
    case strongPassword = "Strong Password"
    case apiKey = "API Key"
    case hexString = "Hex String"
    case pinCode = "PIN Code"
    case readableCode = "Readable Code"
    case custom = "Custom"

    var id: String { rawValue }

    var config: RandomStringConfig {
        switch self {
        case .strongPassword:
            return RandomStringConfig(
                length: 16,
                includeUppercase: true,
                includeLowercase: true,
                includeNumbers: true,
                includeSymbols: true,
                requireUppercase: true,
                requireNumber: true,
                requireSymbol: true
            )
        case .apiKey:
            return RandomStringConfig(
                length: 32,
                includeUppercase: true,
                includeLowercase: true,
                includeNumbers: true,
                includeSymbols: false
            )
        case .hexString:
            return RandomStringConfig(
                length: 64,
                includeUppercase: true,
                includeLowercase: false,
                includeNumbers: true,
                includeSymbols: false
            )
        case .pinCode:
            return RandomStringConfig(
                length: 6,
                includeUppercase: false,
                includeLowercase: false,
                includeNumbers: true,
                includeSymbols: false
            )
        case .readableCode:
            return RandomStringConfig(
                length: 12,
                includeUppercase: true,
                includeLowercase: true,
                includeNumbers: true,
                includeSymbols: false
            )
        case .custom:
            return RandomStringConfig()
        }
    }

    var description: String {
        switch self {
        case .strongPassword:
            return "Mixed case + numbers + symbols, 16 chars"
        case .apiKey:
            return "Alphanumeric, 32 chars"
        case .hexString:
            return "Uppercase + numbers, 64 chars"
        case .pinCode:
            return "Numbers only, 6 chars"
        case .readableCode:
            return "Alphanumeric, 12 chars"
        case .custom:
            return "User-defined settings"
        }
    }
}

// MARK: - Random String Configuration
struct RandomStringConfig: Codable {
    var length: Int = 16
    var quantity: Int = 1

    var includeUppercase: Bool = true
    var includeLowercase: Bool = true
    var includeNumbers: Bool = true
    var includeSymbols: Bool = false

    var excludeAmbiguous: Bool = false
    var customCharacterSet: String = ""

    var requireUppercase: Bool = false
    var requireNumber: Bool = false
    var requireSymbol: Bool = false

    var preset: String = StringPreset.custom.rawValue

    // Validation
    var isValid: Bool {
        guard length >= 1 && length <= 1000 else { return false }
        guard quantity >= 1 && quantity <= 100 else { return false }

        // At least one character set must be selected
        if !includeUppercase && !includeLowercase && !includeNumbers && !includeSymbols {
            return false
        }

        return true
    }

    // Build character pool
    func buildCharacterPool() -> String {
        var pool = ""

        // Build from selected character sets
        if includeUppercase {
            pool += CharacterSets.uppercase
        }
        if includeLowercase {
            pool += CharacterSets.lowercase
        }
        if includeNumbers {
            pool += CharacterSets.numbers
        }
        if includeSymbols {
            pool += CharacterSets.symbols
        }

        return pool
    }

    // Validate generated string meets requirements
    func meetsRequirements(_ string: String) -> Bool {
        if requireUppercase && !string.contains(where: { CharacterSets.uppercase.contains($0) }) {
            return false
        }
        if requireNumber && !string.contains(where: { CharacterSets.numbers.contains($0) }) {
            return false
        }
        if requireSymbol && !string.contains(where: { CharacterSets.symbols.contains($0) }) {
            return false
        }
        return true
    }
}

// MARK: - User Defaults Extension
extension RandomStringConfig {
    private static let configKey = "randomStringConfig"

    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: Self.configKey)
        }
    }

    static func load() -> RandomStringConfig {
        guard let data = UserDefaults.standard.data(forKey: configKey),
              let config = try? JSONDecoder().decode(RandomStringConfig.self, from: data) else {
            return RandomStringConfig()
        }
        return config
    }
}
