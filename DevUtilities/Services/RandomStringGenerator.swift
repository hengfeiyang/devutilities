//
//  RandomStringGenerator.swift
//  DevUtilities
//
//  Random string generation utility with cryptographically secure random
//

import Foundation
import Security

enum RandomStringError: Error, LocalizedError {
    case invalidConfiguration
    case emptyCharacterPool
    case failedToMeetRequirements
    case secureRandomFailed

    var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "Invalid configuration: check length and quantity values"
        case .emptyCharacterPool:
            return "No character sets selected. Please select at least one character set."
        case .failedToMeetRequirements:
            return "Unable to generate string meeting requirements after maximum attempts"
        case .secureRandomFailed:
            return "Failed to generate cryptographically secure random bytes"
        }
    }
}

class RandomStringGenerator {
    private static let maxAttempts = 100

    /// Generate a single random string
    static func generate(config: RandomStringConfig) throws -> String {
        guard config.isValid else {
            throw RandomStringError.invalidConfiguration
        }

        let characterPool = config.buildCharacterPool()
        guard !characterPool.isEmpty else {
            throw RandomStringError.emptyCharacterPool
        }

        // Try to generate a string that meets requirements
        for _ in 0..<maxAttempts {
            let randomString = try generateRandomString(length: config.length, characterPool: characterPool)

            // If no requirements, return immediately
            if !config.requireUppercase && !config.requireNumber && !config.requireSymbol {
                return randomString
            }

            // Check if meets requirements
            if config.meetsRequirements(randomString) {
                return randomString
            }
        }

        throw RandomStringError.failedToMeetRequirements
    }

    /// Generate multiple random strings
    static func generate(config: RandomStringConfig, count: Int) throws -> [String] {
        guard count >= 1 && count <= 100 else {
            throw RandomStringError.invalidConfiguration
        }

        var results: [String] = []
        for _ in 0..<count {
            let string = try generate(config: config)
            results.append(string)
        }
        return results
    }

    /// Generate a cryptographically secure random string
    private static func generateRandomString(length: Int, characterPool: String) throws -> String {
        let poolArray = Array(characterPool)
        let poolSize = poolArray.count

        guard poolSize > 0 else {
            throw RandomStringError.emptyCharacterPool
        }

        var randomString = ""

        for _ in 0..<length {
            let randomIndex = try secureRandomIndex(upperBound: poolSize)
            randomString.append(poolArray[randomIndex])
        }

        return randomString
    }

    /// Generate a cryptographically secure random index
    private static func secureRandomIndex(upperBound: Int) throws -> Int {
        guard upperBound > 0 else {
            throw RandomStringError.emptyCharacterPool
        }

        var randomBytes = [UInt8](repeating: 0, count: 1)
        let status = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)

        guard status == errSecSuccess else {
            throw RandomStringError.secureRandomFailed
        }

        // Use rejection sampling to avoid modulo bias
        let randomValue = Int(randomBytes[0])
        let range = 256 / upperBound * upperBound

        if randomValue < range {
            return randomValue % upperBound
        } else {
            // Retry if outside unbiased range
            return try secureRandomIndex(upperBound: upperBound)
        }
    }
}
