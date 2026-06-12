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

/// A canonical, order-preserving value tree shared by the Data Converter and the
/// Struct Converter. Parsers (JSON/TOML/YAML/CSV) produce a `DataValue`; serializers
/// turn it back into a text format, and the Struct Converter infers a schema from it.
///
/// Object keys are stored as ordered pairs (not a dictionary) so that round-tripping
/// between formats preserves the author's field order. Dates are kept as the verbatim
/// source text so we never lose precision or the original representation.
indirect enum DataValue: Equatable {
    case string(String)
    case int(Int64)
    case double(Double)
    case bool(Bool)
    /// ISO-8601 / format-native date or datetime literal, stored verbatim.
    case date(String)
    case null
    case array([DataValue])
    case object([(key: String, value: DataValue)])

    static func == (lhs: DataValue, rhs: DataValue) -> Bool {
        switch (lhs, rhs) {
        case let (.string(a), .string(b)): return a == b
        case let (.int(a), .int(b)): return a == b
        case let (.double(a), .double(b)): return a == b
        case let (.bool(a), .bool(b)): return a == b
        case let (.date(a), .date(b)): return a == b
        case (.null, .null): return true
        case let (.array(a), .array(b)): return a == b
        case let (.object(a), .object(b)):
            guard a.count == b.count else { return false }
            for (lp, rp) in zip(a, b) where lp.key != rp.key || lp.value != rp.value {
                return false
            }
            return true
        default: return false
        }
    }
}

extension DataValue {
    var isObject: Bool { if case .object = self { return true }; return false }
    var isArray: Bool { if case .array = self { return true }; return false }

    /// The scalar rendered as a plain string (used for CSV cells and TOML/YAML scalars).
    var scalarText: String? {
        switch self {
        case .string(let s): return s
        case .int(let i): return String(i)
        case .double(let d): return DataValue.formatDouble(d)
        case .bool(let b): return b ? "true" : "false"
        case .date(let s): return s
        case .null: return ""
        case .array, .object: return nil
        }
    }

    /// Render a Double without a trailing ".0" loss-of-fidelity surprise while still
    /// emitting whole-valued doubles as integers where round-tripping allows.
    static func formatDouble(_ d: Double) -> String {
        if d == d.rounded() && abs(d) < 1e15 {
            return String(format: "%.1f", d)
        }
        return String(d)
    }
}

/// Data interchange formats supported by the Data Converter (both as source and target).
enum DataFormat: String, CaseIterable, Identifiable {
    case json = "JSON"
    case yaml = "YAML"
    case toml = "TOML"
    case csv = "CSV"

    var id: String { rawValue }

    var sample: String {
        switch self {
        case .json: return sampleJSONData
        case .yaml: return sampleYAMLData
        case .toml: return sampleTOMLData
        case .csv: return sampleCSVData
        }
    }
}

struct DataConvertError: Error, LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

// MARK: - Sample inputs

private let sampleJSONData = """
{
  "id": 1024,
  "name": "Alice",
  "is_active": true,
  "score": 98.5,
  "created_at": "2026-05-08T10:30:00Z",
  "address": {
    "street": "123 Main St",
    "city": "New York"
  },
  "tags": ["swift", "macos"]
}
"""

private let sampleYAMLData = """
id: 1024
name: Alice
is_active: true
score: 98.5
created_at: "2026-05-08T10:30:00Z"
address:
  street: 123 Main St
  city: New York
tags:
  - swift
  - macos
"""

private let sampleTOMLData = """
id = 1024
name = "Alice"
is_active = true
score = 98.5
created_at = "2026-05-08T10:30:00Z"

[address]
street = "123 Main St"
city = "New York"
"""

private let sampleCSVData = """
id,name,is_active,score
1024,Alice,true,98.5
1025,Bob,false,75.0
"""
