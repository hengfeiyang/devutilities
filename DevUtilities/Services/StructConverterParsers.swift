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

// MARK: - Schema builder

final class SchemaBuilder {
    private(set) var structs: [String: StructDef] = [:]
    private(set) var order: [String] = []
    private var nameCounters: [String: Int] = [:]

    func reserveUniqueName(_ baseName: String) -> String {
        let trimmed = StructNaming.pascalCase(baseName).isEmpty ? "Item" : StructNaming.pascalCase(baseName)
        if structs[trimmed] == nil {
            return trimmed
        }
        var counter = nameCounters[trimmed] ?? 1
        while structs["\(trimmed)\(counter)"] != nil {
            counter += 1
        }
        nameCounters[trimmed] = counter + 1
        return "\(trimmed)\(counter)"
    }

    func add(_ def: StructDef) {
        if structs[def.name] == nil {
            order.append(def.name)
        }
        structs[def.name] = def
    }

    func build(rootName: String) -> StructSchema {
        let defs = order.compactMap { structs[$0] }
        return StructSchema(rootName: rootName, structs: defs)
    }
}

// MARK: - Parser factory

enum StructParserFactory {
    static func parse(_ input: String, format: StructInputFormat, rootName: String) throws -> StructSchema {
        let trimmedRoot = rootName.trimmingCharacters(in: .whitespaces)
        let baseName = trimmedRoot.isEmpty ? "Root" : StructNaming.pascalCase(trimmedRoot)
        switch format {
        case .json:
            return try StructSchemaInferrer().infer(DataConverter.parse(input, from: .json), rootName: baseName)
        case .toml:
            return try StructSchemaInferrer().infer(DataConverter.parse(input, from: .toml), rootName: baseName)
        case .yaml:
            return try StructSchemaInferrer().infer(DataConverter.parse(input, from: .yaml), rootName: baseName)
        case .sqlDDL:
            return try SQLDDLStructParser().parse(input, rootName: baseName)
        }
    }
}

// MARK: - Schema inference from a DataValue

/// Walks a parsed `DataValue` tree and produces a `StructSchema` (types only). Shared by
/// all data-format inputs (JSON/TOML/YAML). Field names are emitted in alphabetical order
/// for stable output, and ISO-8601-looking strings are promoted to a date type — matching
/// the converter's long-standing behavior independent of which parser produced the values.
struct StructSchemaInferrer {
    func infer(_ value: DataValue, rootName: String) throws -> StructSchema {
        let builder = SchemaBuilder()
        let rootStructName = builder.reserveUniqueName(rootName)
        switch value {
        case .object(let pairs):
            let fields = buildFields(from: pairs, builder: builder)
            builder.add(StructDef(name: rootStructName, fields: fields))
        case .array(let items):
            let element = inferArrayElementType(items, parentHint: StructNaming.singularize(rootStructName), builder: builder)
            builder.add(StructDef(name: rootStructName, fields: [StructField(name: "items", type: .array(element), isOptional: false)]))
        default:
            throw StructConverterError(message: "Root must be an object or array")
        }
        return builder.build(rootName: rootStructName)
    }

    private func buildFields(from pairs: [(key: String, value: DataValue)], builder: SchemaBuilder) -> [StructField] {
        let sorted = pairs.sorted { $0.key < $1.key }
        return sorted.map { pair in
            let type = inferType(from: pair.value, fieldHint: pair.key, builder: builder)
            let isOptional = pair.value == .null
            return StructField(name: pair.key, type: type, isOptional: isOptional)
        }
    }

    private func inferType(from value: DataValue, fieldHint: String, builder: SchemaBuilder) -> IRType {
        switch value {
        case .null: return .null
        case .bool: return .bool
        case .int: return .integer
        case .double: return .double
        case .date: return .date
        case .string(let s): return looksLikeISO8601(s) ? .date : .string
        case .array(let items):
            return .array(inferArrayElementType(items, parentHint: StructNaming.singularize(fieldHint), builder: builder))
        case .object(let pairs):
            let structName = builder.reserveUniqueName(fieldHint)
            let fields = buildFields(from: pairs, builder: builder)
            builder.add(StructDef(name: structName, fields: fields))
            return .object(structName)
        }
    }

    private func inferArrayElementType(_ items: [DataValue], parentHint: String, builder: SchemaBuilder) -> IRType {
        guard !items.isEmpty else { return .anyValue }
        // If any element is an object, merge keys across all object elements.
        if items.contains(where: { $0.isObject }) {
            let objects = items.compactMap { value -> [(key: String, value: DataValue)]? in
                if case .object(let pairs) = value { return pairs }
                return nil
            }
            let merged = mergeObjects(objects)
            let structName = builder.reserveUniqueName(parentHint)
            let fields = buildFields(from: merged.shape, builder: builder).map { field in
                StructField(name: field.name, type: field.type, isOptional: !merged.required.contains(field.name))
            }
            builder.add(StructDef(name: structName, fields: fields))
            return .object(structName)
        }
        // Otherwise infer from elements; fall back to anyValue when scalar types differ.
        var seen: IRType? = nil
        for item in items {
            let t = inferType(from: item, fieldHint: parentHint, builder: builder)
            if seen == nil { seen = t }
            else if seen != t { return .anyValue }
        }
        return seen ?? .anyValue
    }

    private struct MergedShape {
        var shape: [(key: String, value: DataValue)]
        var required: Set<String>
    }

    private func mergeObjects(_ objects: [[(key: String, value: DataValue)]]) -> MergedShape {
        var shape: [(key: String, value: DataValue)] = []
        var seenKeys = Set<String>()
        var keyCount: [String: Int] = [:]
        for object in objects {
            for pair in object {
                if !seenKeys.contains(pair.key) {
                    seenKeys.insert(pair.key)
                    shape.append(pair)
                }
                keyCount[pair.key, default: 0] += 1
            }
        }
        var required = Set<String>()
        for (key, count) in keyCount where count == objects.count {
            required.insert(key)
        }
        return MergedShape(shape: shape, required: required)
    }

    private func looksLikeISO8601(_ s: String) -> Bool {
        guard s.count >= 10 else { return false }
        let pattern = #"^\d{4}-\d{2}-\d{2}([T ]\d{2}:\d{2}(:\d{2})?(\.\d+)?(Z|[+-]\d{2}:?\d{2})?)?$"#
        return s.range(of: pattern, options: .regularExpression) != nil
    }
}

// MARK: - SQL DDL parser

private struct SQLDDLStructParser {
    func parse(_ input: String, rootName: String) throws -> StructSchema {
        // Strip line comments and block comments
        var src = stripComments(input)
        src = src.replacingOccurrences(of: "\r", with: "")

        let pattern = #"(?is)CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?([^\s(]+)\s*\(([\s\S]+?)\)\s*(?:;|$)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            throw StructConverterError(message: "Internal regex error")
        }
        let matches = regex.matches(in: src, range: NSRange(src.startIndex..., in: src))
        guard !matches.isEmpty else {
            throw StructConverterError(message: "No CREATE TABLE statement found")
        }

        let builder = SchemaBuilder()
        var firstStructName: String? = nil
        for match in matches {
            guard let nameRange = Range(match.range(at: 1), in: src),
                  let bodyRange = Range(match.range(at: 2), in: src) else { continue }
            let rawName = String(src[nameRange]).replacingOccurrences(of: "`", with: "").replacingOccurrences(of: "\"", with: "")
            let tableName = rawName.split(separator: ".").last.map(String.init) ?? rawName
            let structName = builder.reserveUniqueName(StructNaming.pascalCase(tableName))
            let body = String(src[bodyRange])
            let fields = parseColumns(body)
            builder.add(StructDef(name: structName, fields: fields))
            if firstStructName == nil { firstStructName = structName }
        }

        guard let root = firstStructName else {
            throw StructConverterError(message: "No valid table definitions found")
        }
        return builder.build(rootName: root)
    }

    private func stripComments(_ src: String) -> String {
        var result = src
        // Strip /* ... */
        if let regex = try? NSRegularExpression(pattern: #"/\*[\s\S]*?\*/"#) {
            result = regex.stringByReplacingMatches(in: result, range: NSRange(result.startIndex..., in: result), withTemplate: "")
        }
        // Strip -- to end of line and # comments
        var lines: [String] = []
        for line in result.components(separatedBy: "\n") {
            var trimmed = line
            if let dashRange = trimmed.range(of: "--") {
                trimmed = String(trimmed[..<dashRange.lowerBound])
            }
            lines.append(trimmed)
        }
        return lines.joined(separator: "\n")
    }

    private func parseColumns(_ body: String) -> [StructField] {
        let parts = splitTopLevel(body, by: ",")
        var fields: [StructField] = []
        for raw in parts {
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            // Skip table-level constraints
            let upper = trimmed.uppercased()
            if upper.hasPrefix("PRIMARY KEY") || upper.hasPrefix("FOREIGN KEY") ||
               upper.hasPrefix("UNIQUE ") || upper.hasPrefix("UNIQUE(") ||
               upper.hasPrefix("CHECK") || upper.hasPrefix("CONSTRAINT") ||
               upper.hasPrefix("INDEX") || upper.hasPrefix("KEY ") || upper.hasPrefix("KEY(") {
                continue
            }
            let tokens = tokenize(trimmed)
            guard tokens.count >= 2 else { continue }
            let name = tokens[0].replacingOccurrences(of: "`", with: "").replacingOccurrences(of: "\"", with: "")
            let typeTokens = Array(tokens.dropFirst())
            let typeRaw = typeTokens.first ?? "TEXT"
            let typeUpper = typeRaw.uppercased()
            let irType = mapSQLType(typeUpper)
            let restUpper = typeTokens.dropFirst().joined(separator: " ").uppercased()
            let isNotNull = restUpper.contains("NOT NULL") || restUpper.contains("PRIMARY KEY")
            fields.append(StructField(name: name, type: irType, isOptional: !isNotNull))
        }
        return fields
    }

    private func splitTopLevel(_ src: String, by separator: Character) -> [String] {
        var results: [String] = []
        var current = ""
        var depth = 0
        var inSingle = false
        var inDouble = false
        var inBacktick = false
        for ch in src {
            if !inDouble && !inBacktick && ch == "'" { inSingle.toggle(); current.append(ch); continue }
            if !inSingle && !inBacktick && ch == "\"" { inDouble.toggle(); current.append(ch); continue }
            if !inSingle && !inDouble && ch == "`" { inBacktick.toggle(); current.append(ch); continue }
            if !inSingle && !inDouble && !inBacktick {
                if ch == "(" { depth += 1 }
                else if ch == ")" { depth -= 1 }
                else if ch == separator && depth == 0 {
                    results.append(current)
                    current = ""
                    continue
                }
            }
            current.append(ch)
        }
        if !current.isEmpty { results.append(current) }
        return results
    }

    private func tokenize(_ src: String) -> [String] {
        var tokens: [String] = []
        var current = ""
        var depth = 0
        var inSingle = false
        var inDouble = false
        var inBacktick = false
        for ch in src {
            if !inDouble && !inBacktick && ch == "'" { inSingle.toggle(); current.append(ch); continue }
            if !inSingle && !inBacktick && ch == "\"" { inDouble.toggle(); current.append(ch); continue }
            if !inSingle && !inDouble && ch == "`" { inBacktick.toggle(); current.append(ch); continue }
            if !inSingle && !inDouble && !inBacktick {
                if ch == "(" { depth += 1; current.append(ch); continue }
                if ch == ")" { depth -= 1; current.append(ch); continue }
                if ch.isWhitespace && depth == 0 {
                    if !current.isEmpty { tokens.append(current); current = "" }
                    continue
                }
            }
            current.append(ch)
        }
        if !current.isEmpty { tokens.append(current) }
        return tokens
    }

    private func mapSQLType(_ raw: String) -> IRType {
        let base = raw.split(separator: "(").first.map(String.init)?.uppercased() ?? raw
        switch base {
        case "INT", "INTEGER", "SMALLINT", "TINYINT", "MEDIUMINT", "BIGINT", "INT2", "INT4", "INT8", "SERIAL", "BIGSERIAL":
            return .integer
        case "FLOAT", "DOUBLE", "REAL", "DECIMAL", "NUMERIC", "DEC":
            return .double
        case "BOOL", "BOOLEAN", "BIT":
            return .bool
        case "DATE", "DATETIME", "TIMESTAMP", "TIMESTAMPTZ", "TIME":
            return .date
        case "JSON", "JSONB":
            return .anyValue
        default:
            return .string
        }
    }
}
