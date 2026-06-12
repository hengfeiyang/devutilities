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

indirect enum IRType: Equatable {
    case string
    case integer
    case double
    case bool
    case date
    case anyValue
    case null
    case array(IRType)
    case object(String)
    case dictionary(IRType)
}

struct StructField: Equatable {
    let name: String
    let type: IRType
    var isOptional: Bool
}

struct StructDef: Equatable {
    let name: String
    let fields: [StructField]
}

struct StructSchema {
    let rootName: String
    /// Ordered so that referenced structs appear before their referrers when reversed,
    /// or simply collected in discovery order. Generators may sort as needed.
    var structs: [StructDef]

    func struct_(named: String) -> StructDef? {
        structs.first { $0.name == named }
    }
}

enum StructInputFormat: String, CaseIterable, Identifiable {
    case json = "JSON"
    case yaml = "YAML"
    case toml = "TOML"
    case sqlDDL = "SQL DDL"

    var id: String { rawValue }

    var sample: String {
        switch self {
        case .json: return sampleJSON
        case .yaml: return sampleYAML
        case .toml: return sampleTOML
        case .sqlDDL: return sampleSQLDDL
        }
    }
}

enum StructOutputLanguage: String, CaseIterable, Identifiable {
    case typescript = "TypeScript"
    case python = "Python"
    case go = "Go"
    case java = "Java"
    case rust = "Rust"
    case swift = "Swift"
    case php = "PHP"

    var id: String { rawValue }
}

struct StructConverterError: Error, LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

// MARK: - Naming helpers

enum StructNaming {
    static func pascalCase(_ raw: String) -> String {
        let cleaned = raw.replacingOccurrences(of: "[^A-Za-z0-9_ -]", with: "", options: .regularExpression)
        let parts = cleaned.split(whereSeparator: { $0 == "_" || $0 == "-" || $0 == " " })
        if parts.isEmpty { return "Field" }
        return parts.map { capitalizeFirst(String($0)) }.joined()
    }

    static func camelCase(_ raw: String) -> String {
        let pascal = pascalCase(raw)
        guard let first = pascal.first else { return pascal }
        return first.lowercased() + pascal.dropFirst()
    }

    static func snakeCase(_ raw: String) -> String {
        var result = ""
        var previousLowerOrDigit = false
        for ch in raw {
            if ch.isUppercase {
                if previousLowerOrDigit { result.append("_") }
                result.append(Character(ch.lowercased()))
                previousLowerOrDigit = false
            } else if ch == "-" || ch == " " {
                result.append("_")
                previousLowerOrDigit = false
            } else {
                result.append(ch)
                previousLowerOrDigit = ch.isLetter || ch.isNumber
            }
        }
        return result
    }

    static func singularize(_ name: String) -> String {
        // Naive singularization for default struct naming.
        if name.hasSuffix("ies") && name.count > 3 {
            return String(name.dropLast(3)) + "y"
        }
        if name.hasSuffix("ses") && name.count > 3 {
            return String(name.dropLast(2))
        }
        if name.hasSuffix("s") && !name.hasSuffix("ss") && name.count > 1 {
            return String(name.dropLast())
        }
        return name
    }

    private static func capitalizeFirst(_ s: String) -> String {
        guard let first = s.first else { return s }
        return first.uppercased() + s.dropFirst().lowercased()
    }
}

// MARK: - Sample inputs

private let sampleJSON = """
{
  "id": 1024,
  "name": "Alice",
  "is_active": true,
  "score": 98.5,
  "created_at": "2026-05-08T10:30:00Z",
  "address": {
    "street": "123 Main St",
    "city": "New York",
    "zip_code": "10001"
  },
  "tags": ["swift", "macos"],
  "friends": [
    { "id": 2, "name": "Bob" }
  ]
}
"""

private let sampleTOML = """
title = "DevUtilities"
version = 24
enabled = true

[owner]
name = "Hengfei"
joined = 2026-05-08

[[servers]]
host = "alpha.example.com"
port = 8080

[[servers]]
host = "beta.example.com"
port = 8443
"""

private let sampleYAML = """
id: 1024
name: Alice
is_active: true
score: 98.5
address:
  street: 123 Main St
  city: New York
  zip_code: "10001"
tags:
  - swift
  - macos
friends:
  - id: 2
    name: Bob
"""

private let sampleSQLDDL = """
CREATE TABLE users (
  id BIGINT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE,
  is_active BOOLEAN DEFAULT TRUE,
  balance DECIMAL(10, 2),
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP
);
"""
