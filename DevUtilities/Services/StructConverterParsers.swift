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

// MARK: - JSON parser

enum StructParserFactory {
    static func parse(_ input: String, format: StructInputFormat, rootName: String) throws -> StructSchema {
        let trimmedRoot = rootName.trimmingCharacters(in: .whitespaces)
        let baseName = trimmedRoot.isEmpty ? "Root" : StructNaming.pascalCase(trimmedRoot)
        switch format {
        case .json: return try JSONStructParser().parse(input, rootName: baseName)
        case .toml: return try TOMLStructParser().parse(input, rootName: baseName)
        case .yaml: return try YAMLStructParser().parse(input, rootName: baseName)
        case .sqlDDL: return try SQLDDLStructParser().parse(input, rootName: baseName)
        }
    }
}

private struct JSONStructParser {
    func parse(_ input: String, rootName: String) throws -> StructSchema {
        guard let data = input.data(using: .utf8) else {
            throw StructConverterError(message: "Invalid UTF-8 input")
        }
        let object: Any
        do {
            object = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
        } catch {
            throw StructConverterError(message: "JSON parse error: \(error.localizedDescription)")
        }

        let builder = SchemaBuilder()
        let rootStructName = builder.reserveUniqueName(rootName)
        if let dict = object as? [String: Any] {
            let fields = buildFields(from: dict, parentHint: rootStructName, builder: builder)
            builder.add(StructDef(name: rootStructName, fields: fields))
        } else if let array = object as? [Any] {
            // Treat root array of objects as a struct array; struct = first object's shape
            let elementType = inferArrayElementType(array, parentHint: StructNaming.singularize(rootStructName), builder: builder)
            let field = StructField(name: "items", type: .array(elementType), isOptional: false)
            builder.add(StructDef(name: rootStructName, fields: [field]))
        } else {
            throw StructConverterError(message: "JSON root must be an object or array")
        }
        return builder.build(rootName: rootStructName)
    }

    private func buildFields(from dict: [String: Any], parentHint: String, builder: SchemaBuilder) -> [StructField] {
        // Preserve insertion order if the dictionary came from an OrderedDictionary. JSONSerialization
        // does not preserve order, so we sort alphabetically for deterministic output.
        let keys = dict.keys.sorted()
        return keys.map { key in
            let value = dict[key]!
            let type = inferType(from: value, fieldHint: key, builder: builder)
            let isOptional = value is NSNull
            return StructField(name: key, type: type, isOptional: isOptional)
        }
    }

    private func inferType(from value: Any, fieldHint: String, builder: SchemaBuilder) -> IRType {
        if value is NSNull { return .null }
        if let str = value as? String {
            return looksLikeISO8601(str) ? .date : .string
        }
        if let num = value as? NSNumber {
            if CFGetTypeID(num) == CFBooleanGetTypeID() { return .bool }
            let typeChar = String(cString: num.objCType)
            if typeChar == "c" || typeChar == "B" { return .bool }
            if typeChar == "f" || typeChar == "d" { return .double }
            if num.doubleValue == Double(num.int64Value) { return .integer }
            return .double
        }
        if let array = value as? [Any] {
            let element = inferArrayElementType(array, parentHint: StructNaming.singularize(fieldHint), builder: builder)
            return .array(element)
        }
        if let dict = value as? [String: Any] {
            let structName = builder.reserveUniqueName(fieldHint)
            let fields = buildFields(from: dict, parentHint: structName, builder: builder)
            builder.add(StructDef(name: structName, fields: fields))
            return .object(structName)
        }
        return .anyValue
    }

    private func inferArrayElementType(_ array: [Any], parentHint: String, builder: SchemaBuilder) -> IRType {
        guard !array.isEmpty else { return .anyValue }
        // If any element is a dictionary, merge keys from all dictionaries.
        if array.contains(where: { $0 is [String: Any] }) {
            let dicts = array.compactMap { $0 as? [String: Any] }
            let merged = mergeDictionaries(dicts)
            let structName = builder.reserveUniqueName(parentHint)
            let fields = buildFields(from: merged.shape, parentHint: structName, builder: builder)
                .map { f in StructField(name: f.name, type: f.type, isOptional: !merged.required.contains(f.name)) }
            builder.add(StructDef(name: structName, fields: fields))
            return .object(structName)
        }
        // Otherwise infer from the first element; fall back to anyValue if mixed scalar types.
        var seenType: IRType? = nil
        for v in array {
            let t = inferType(from: v, fieldHint: parentHint, builder: builder)
            if seenType == nil {
                seenType = t
            } else if seenType != t {
                return .anyValue
            }
        }
        return seenType ?? .anyValue
    }

    private struct MergedShape {
        var shape: [String: Any]
        var required: Set<String>
    }

    private func mergeDictionaries(_ dicts: [[String: Any]]) -> MergedShape {
        var shape: [String: Any] = [:]
        var keyCount: [String: Int] = [:]
        for dict in dicts {
            for (k, v) in dict {
                if shape[k] == nil { shape[k] = v }
                keyCount[k, default: 0] += 1
            }
        }
        var required: Set<String> = []
        for (k, count) in keyCount where count == dicts.count {
            required.insert(k)
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

// MARK: - TOML parser

private struct TOMLStructParser {
    func parse(_ input: String, rootName: String) throws -> StructSchema {
        let lines = input.components(separatedBy: "\n")
        let rootMap = NSMutableDictionary()
        var currentTable: NSMutableDictionary = rootMap
        for raw in lines {
            var line = raw.trimmingCharacters(in: .whitespaces)
            if line.isEmpty || line.hasPrefix("#") { continue }
            line = stripTrailingComment(line)

            if line.hasPrefix("[[") && line.hasSuffix("]]") {
                let header = String(line.dropFirst(2).dropLast(2)).trimmingCharacters(in: .whitespaces)
                let path = splitDottedKey(header)
                currentTable = appendArrayTable(into: rootMap, path: path)
                continue
            }
            if line.hasPrefix("[") && line.hasSuffix("]") {
                let header = String(line.dropFirst().dropLast()).trimmingCharacters(in: .whitespaces)
                let path = splitDottedKey(header)
                currentTable = ensureTable(into: rootMap, path: path)
                continue
            }
            guard let eqIdx = line.firstIndex(of: "=") else { continue }
            let keyRaw = line[..<eqIdx].trimmingCharacters(in: .whitespaces)
            let valueRaw = line[line.index(after: eqIdx)...].trimmingCharacters(in: .whitespaces)
            let keyPath = splitDottedKey(keyRaw)
            let value = parseValue(String(valueRaw))
            assignNested(into: currentTable, keyPath: keyPath, value: value)
        }

        let builder = SchemaBuilder()
        let rootStructName = builder.reserveUniqueName(rootName)
        let fields = buildFields(from: nsDictToSwift(rootMap), parentHint: rootStructName, builder: builder)
        builder.add(StructDef(name: rootStructName, fields: fields))
        return builder.build(rootName: rootStructName)
    }

    private func nsDictToSwift(_ dict: NSDictionary) -> [String: Any] {
        var result: [String: Any] = [:]
        for (k, v) in dict {
            guard let key = k as? String else { continue }
            result[key] = convertNSValue(v)
        }
        return result
    }

    private func convertNSValue(_ v: Any) -> Any {
        if let d = v as? NSDictionary { return nsDictToSwift(d) }
        if let a = v as? NSArray { return a.map { convertNSValue($0) } }
        return v
    }

    private func splitDottedKey(_ raw: String) -> [String] {
        raw.split(separator: ".").map { $0.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\"", with: "") }
    }

    private func stripTrailingComment(_ line: String) -> String {
        var inSingle = false
        var inDouble = false
        var idx = line.startIndex
        while idx < line.endIndex {
            let ch = line[idx]
            if ch == "'" && !inDouble { inSingle.toggle() }
            else if ch == "\"" && !inSingle { inDouble.toggle() }
            else if ch == "#" && !inSingle && !inDouble {
                return String(line[..<idx]).trimmingCharacters(in: .whitespaces)
            }
            idx = line.index(after: idx)
        }
        return line
    }

    private func ensureTable(into root: NSMutableDictionary, path: [String]) -> NSMutableDictionary {
        var current = root
        for k in path {
            if let existing = current[k] as? NSMutableDictionary {
                current = existing
            } else {
                let newDict = NSMutableDictionary()
                current[k] = newDict
                current = newDict
            }
        }
        return current
    }

    private func appendArrayTable(into root: NSMutableDictionary, path: [String]) -> NSMutableDictionary {
        guard !path.isEmpty else { return root }
        var keys = path
        let last = keys.removeLast()
        var current = root
        for k in keys {
            if let existing = current[k] as? NSMutableDictionary {
                current = existing
            } else {
                let newDict = NSMutableDictionary()
                current[k] = newDict
                current = newDict
            }
        }
        let array: NSMutableArray
        if let existing = current[last] as? NSMutableArray {
            array = existing
        } else {
            array = NSMutableArray()
            current[last] = array
        }
        let entry = NSMutableDictionary()
        array.add(entry)
        return entry
    }

    private func assignNested(into dict: NSMutableDictionary, keyPath: [String], value: Any) {
        guard !keyPath.isEmpty else { return }
        if keyPath.count == 1 {
            dict[keyPath[0]] = value
            return
        }
        var current = dict
        for k in keyPath.dropLast() {
            if let existing = current[k] as? NSMutableDictionary {
                current = existing
            } else {
                let newDict = NSMutableDictionary()
                current[k] = newDict
                current = newDict
            }
        }
        current[keyPath.last!] = value
    }

    private func parseValue(_ raw: String) -> Any {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return NSNull() }
        // String
        if trimmed.hasPrefix("\"\"\"") && trimmed.hasSuffix("\"\"\"") && trimmed.count >= 6 {
            return String(trimmed.dropFirst(3).dropLast(3))
        }
        if (trimmed.hasPrefix("\"") && trimmed.hasSuffix("\"")) || (trimmed.hasPrefix("'") && trimmed.hasSuffix("'")) {
            return String(trimmed.dropFirst().dropLast())
        }
        // Bool
        if trimmed == "true" { return true }
        if trimmed == "false" { return false }
        // Inline array
        if trimmed.hasPrefix("[") && trimmed.hasSuffix("]") {
            let inner = String(trimmed.dropFirst().dropLast())
            return splitInline(inner).map { parseValue($0) }
        }
        // Inline table
        if trimmed.hasPrefix("{") && trimmed.hasSuffix("}") {
            let inner = String(trimmed.dropFirst().dropLast())
            var dict: [String: Any] = [:]
            for part in splitInline(inner) {
                if let eq = part.firstIndex(of: "=") {
                    let k = part[..<eq].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\"", with: "")
                    let v = String(part[part.index(after: eq)...]).trimmingCharacters(in: .whitespaces)
                    dict[k] = parseValue(v)
                }
            }
            return dict
        }
        // Date-like (TOML date/datetime literal — keep as date marker via NSDate placeholder)
        let dateRegex = #"^\d{4}-\d{2}-\d{2}([T ]\d{2}:\d{2}(:\d{2})?(\.\d+)?(Z|[+-]\d{2}:?\d{2})?)?$"#
        if trimmed.range(of: dateRegex, options: .regularExpression) != nil {
            return ISO8601DateMarker()
        }
        // Number
        if let intVal = Int64(trimmed.replacingOccurrences(of: "_", with: "")) {
            return NSNumber(value: intVal)
        }
        if let dblVal = Double(trimmed.replacingOccurrences(of: "_", with: "")) {
            return NSNumber(value: dblVal)
        }
        return trimmed
    }

    private func splitInline(_ src: String) -> [String] {
        var result: [String] = []
        var current = ""
        var depth = 0
        var inSingle = false
        var inDouble = false
        for ch in src {
            if !inDouble && ch == "'" { inSingle.toggle(); current.append(ch); continue }
            if !inSingle && ch == "\"" { inDouble.toggle(); current.append(ch); continue }
            if !inSingle && !inDouble {
                if ch == "[" || ch == "{" { depth += 1 }
                else if ch == "]" || ch == "}" { depth -= 1 }
                else if ch == "," && depth == 0 {
                    let t = current.trimmingCharacters(in: .whitespaces)
                    if !t.isEmpty { result.append(t) }
                    current = ""
                    continue
                }
            }
            current.append(ch)
        }
        let t = current.trimmingCharacters(in: .whitespaces)
        if !t.isEmpty { result.append(t) }
        return result
    }

    private func buildFields(from dict: [String: Any], parentHint: String, builder: SchemaBuilder) -> [StructField] {
        let keys = dict.keys.sorted()
        return keys.map { key in
            let value = dict[key]!
            let type = inferType(from: value, fieldHint: key, builder: builder)
            return StructField(name: key, type: type, isOptional: false)
        }
    }

    private func inferType(from value: Any, fieldHint: String, builder: SchemaBuilder) -> IRType {
        if value is NSNull { return .null }
        if value is ISO8601DateMarker { return .date }
        if value is String { return .string }
        if let num = value as? NSNumber {
            if CFGetTypeID(num) == CFBooleanGetTypeID() { return .bool }
            let typeChar = String(cString: num.objCType)
            if typeChar == "c" || typeChar == "B" { return .bool }
            if typeChar == "f" || typeChar == "d" { return .double }
            if num.doubleValue == Double(num.int64Value) { return .integer }
            return .double
        }
        if let arr = value as? [[String: Any]] {
            let merged = mergeDicts(arr)
            let structName = builder.reserveUniqueName(StructNaming.singularize(fieldHint))
            let fields = buildFields(from: merged, parentHint: structName, builder: builder)
            builder.add(StructDef(name: structName, fields: fields))
            return .array(.object(structName))
        }
        if let arr = value as? [Any] {
            guard !arr.isEmpty else { return .array(.anyValue) }
            var seen: IRType? = nil
            for v in arr {
                let t = inferType(from: v, fieldHint: fieldHint, builder: builder)
                if seen == nil { seen = t }
                else if seen != t { return .array(.anyValue) }
            }
            return .array(seen ?? .anyValue)
        }
        if let dict = value as? [String: Any] {
            let structName = builder.reserveUniqueName(fieldHint)
            let fields = buildFields(from: dict, parentHint: structName, builder: builder)
            builder.add(StructDef(name: structName, fields: fields))
            return .object(structName)
        }
        return .anyValue
    }

    private func mergeDicts(_ dicts: [[String: Any]]) -> [String: Any] {
        var merged: [String: Any] = [:]
        for d in dicts {
            for (k, v) in d where merged[k] == nil { merged[k] = v }
        }
        return merged
    }
}

private struct ISO8601DateMarker {}

// MARK: - YAML parser (minimal block style)

private struct YAMLStructParser {
    func parse(_ input: String, rootName: String) throws -> StructSchema {
        var lines: [(indent: Int, text: String)] = []
        for raw in input.components(separatedBy: "\n") {
            let stripped = stripComment(raw)
            if stripped.trimmingCharacters(in: .whitespaces).isEmpty { continue }
            let indent = raw.prefix { $0 == " " }.count
            lines.append((indent, stripped))
        }
        var index = 0
        let value = parseNode(lines: lines, index: &index, baseIndent: 0)
        let builder = SchemaBuilder()
        let rootStructName = builder.reserveUniqueName(rootName)
        if let dict = value as? [String: Any] {
            let fields = buildFields(from: dict, parentHint: rootStructName, builder: builder)
            builder.add(StructDef(name: rootStructName, fields: fields))
        } else if let arr = value as? [Any] {
            let element = inferArrayElementType(arr, parentHint: StructNaming.singularize(rootStructName), builder: builder)
            builder.add(StructDef(name: rootStructName, fields: [StructField(name: "items", type: .array(element), isOptional: false)]))
        } else {
            throw StructConverterError(message: "YAML root must be a mapping or sequence")
        }
        return builder.build(rootName: rootStructName)
    }

    private func stripComment(_ line: String) -> String {
        var inSingle = false
        var inDouble = false
        var idx = line.startIndex
        while idx < line.endIndex {
            let ch = line[idx]
            if ch == "'" && !inDouble { inSingle.toggle() }
            else if ch == "\"" && !inSingle { inDouble.toggle() }
            else if ch == "#" && !inSingle && !inDouble {
                return String(line[..<idx])
            }
            idx = line.index(after: idx)
        }
        return line
    }

    private func parseNode(lines: [(indent: Int, text: String)], index: inout Int, baseIndent: Int) -> Any {
        guard index < lines.count else { return NSNull() }
        let first = lines[index]
        let trimmed = first.text.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("- ") || trimmed == "-" {
            return parseSequence(lines: lines, index: &index, baseIndent: first.indent)
        }
        return parseMapping(lines: lines, index: &index, baseIndent: first.indent)
    }

    private func parseMapping(lines: [(indent: Int, text: String)], index: inout Int, baseIndent: Int) -> [String: Any] {
        var result: [String: Any] = [:]
        while index < lines.count {
            let line = lines[index]
            if line.indent < baseIndent { break }
            if line.indent > baseIndent { break }
            let text = line.text.trimmingCharacters(in: .whitespaces)
            if text.hasPrefix("- ") || text == "-" { break }
            guard let colonIdx = findUnquotedColon(text) else { index += 1; continue }
            let key = String(text[..<colonIdx]).trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "'", with: "")
            let valueRaw = String(text[text.index(after: colonIdx)...]).trimmingCharacters(in: .whitespaces)
            index += 1
            if valueRaw.isEmpty {
                if index < lines.count && lines[index].indent > baseIndent {
                    let childIndent = lines[index].indent
                    let childText = lines[index].text.trimmingCharacters(in: .whitespaces)
                    if childText.hasPrefix("- ") || childText == "-" {
                        result[key] = parseSequence(lines: lines, index: &index, baseIndent: childIndent)
                    } else {
                        result[key] = parseMapping(lines: lines, index: &index, baseIndent: childIndent)
                    }
                } else {
                    result[key] = NSNull()
                }
            } else {
                result[key] = parseScalar(valueRaw)
            }
        }
        return result
    }

    private func parseSequence(lines: [(indent: Int, text: String)], index: inout Int, baseIndent: Int) -> [Any] {
        var result: [Any] = []
        while index < lines.count {
            let line = lines[index]
            if line.indent < baseIndent { break }
            if line.indent > baseIndent { break }
            let text = line.text.trimmingCharacters(in: .whitespaces)
            guard text.hasPrefix("-") else { break }
            let after = String(text.dropFirst()).trimmingCharacters(in: .whitespaces)
            index += 1
            if after.isEmpty {
                // Block element on following indented lines
                if index < lines.count && lines[index].indent > baseIndent {
                    let childIndent = lines[index].indent
                    let childText = lines[index].text.trimmingCharacters(in: .whitespaces)
                    if childText.hasPrefix("- ") || childText == "-" {
                        result.append(parseSequence(lines: lines, index: &index, baseIndent: childIndent))
                    } else {
                        result.append(parseMapping(lines: lines, index: &index, baseIndent: childIndent))
                    }
                } else {
                    result.append(NSNull())
                }
            } else if let colon = findUnquotedColon(after), !after.hasSuffix(":") {
                // Inline mapping starts on this line: e.g. "- id: 2"
                let key = String(after[..<colon]).trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "'", with: "")
                let value = String(after[after.index(after: colon)...]).trimmingCharacters(in: .whitespaces)
                var dict: [String: Any] = [key: parseScalar(value)]
                // Continue collecting siblings of this mapping: lines with indent == baseIndent + (offset of after)
                // Best-effort: child-mapping lines have indent > baseIndent and don't start with '-'
                let inlineKeyIndent = baseIndent + 2
                while index < lines.count && lines[index].indent >= inlineKeyIndent {
                    let l = lines[index]
                    let t = l.text.trimmingCharacters(in: .whitespaces)
                    if t.hasPrefix("- ") || t == "-" { break }
                    if l.indent != inlineKeyIndent { break }
                    guard let c = findUnquotedColon(t) else { index += 1; continue }
                    let k = String(t[..<c]).trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "'", with: "")
                    let vRaw = String(t[t.index(after: c)...]).trimmingCharacters(in: .whitespaces)
                    index += 1
                    if vRaw.isEmpty {
                        if index < lines.count && lines[index].indent > inlineKeyIndent {
                            let childIndent = lines[index].indent
                            let childText = lines[index].text.trimmingCharacters(in: .whitespaces)
                            if childText.hasPrefix("- ") {
                                dict[k] = parseSequence(lines: lines, index: &index, baseIndent: childIndent)
                            } else {
                                dict[k] = parseMapping(lines: lines, index: &index, baseIndent: childIndent)
                            }
                        } else {
                            dict[k] = NSNull()
                        }
                    } else {
                        dict[k] = parseScalar(vRaw)
                    }
                }
                result.append(dict)
            } else {
                result.append(parseScalar(after))
            }
        }
        return result
    }

    private func findUnquotedColon(_ s: String) -> String.Index? {
        var inSingle = false
        var inDouble = false
        var idx = s.startIndex
        while idx < s.endIndex {
            let ch = s[idx]
            if ch == "'" && !inDouble { inSingle.toggle() }
            else if ch == "\"" && !inSingle { inDouble.toggle() }
            else if ch == ":" && !inSingle && !inDouble {
                return idx
            }
            idx = s.index(after: idx)
        }
        return nil
    }

    private func parseScalar(_ raw: String) -> Any {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return NSNull() }
        if trimmed == "null" || trimmed == "~" || trimmed == "Null" || trimmed == "NULL" { return NSNull() }
        if (trimmed.hasPrefix("\"") && trimmed.hasSuffix("\"")) || (trimmed.hasPrefix("'") && trimmed.hasSuffix("'")) {
            return String(trimmed.dropFirst().dropLast())
        }
        let lowered = trimmed.lowercased()
        if lowered == "true" || lowered == "yes" { return true }
        if lowered == "false" || lowered == "no" { return false }
        let dateRegex = #"^\d{4}-\d{2}-\d{2}([T ]\d{2}:\d{2}(:\d{2})?(\.\d+)?(Z|[+-]\d{2}:?\d{2})?)?$"#
        if trimmed.range(of: dateRegex, options: .regularExpression) != nil {
            return ISO8601DateMarker()
        }
        if let intVal = Int64(trimmed) { return NSNumber(value: intVal) }
        if let dbl = Double(trimmed) { return NSNumber(value: dbl) }
        return trimmed
    }

    private func buildFields(from dict: [String: Any], parentHint: String, builder: SchemaBuilder) -> [StructField] {
        let keys = dict.keys.sorted()
        return keys.map { key in
            let value = dict[key]!
            let type = inferType(from: value, fieldHint: key, builder: builder)
            return StructField(name: key, type: type, isOptional: value is NSNull)
        }
    }

    private func inferType(from value: Any, fieldHint: String, builder: SchemaBuilder) -> IRType {
        if value is NSNull { return .null }
        if value is ISO8601DateMarker { return .date }
        if value is String { return .string }
        if let num = value as? NSNumber {
            if CFGetTypeID(num) == CFBooleanGetTypeID() { return .bool }
            let typeChar = String(cString: num.objCType)
            if typeChar == "c" || typeChar == "B" { return .bool }
            if typeChar == "f" || typeChar == "d" { return .double }
            if num.doubleValue == Double(num.int64Value) { return .integer }
            return .double
        }
        if let arr = value as? [Any] {
            return .array(inferArrayElementType(arr, parentHint: StructNaming.singularize(fieldHint), builder: builder))
        }
        if let dict = value as? [String: Any] {
            let structName = builder.reserveUniqueName(fieldHint)
            let fields = buildFields(from: dict, parentHint: structName, builder: builder)
            builder.add(StructDef(name: structName, fields: fields))
            return .object(structName)
        }
        return .anyValue
    }

    private func inferArrayElementType(_ array: [Any], parentHint: String, builder: SchemaBuilder) -> IRType {
        guard !array.isEmpty else { return .anyValue }
        if array.contains(where: { $0 is [String: Any] }) {
            var merged: [String: Any] = [:]
            for d in array.compactMap({ $0 as? [String: Any] }) {
                for (k, v) in d where merged[k] == nil { merged[k] = v }
            }
            let structName = builder.reserveUniqueName(parentHint)
            let fields = buildFields(from: merged, parentHint: structName, builder: builder)
            builder.add(StructDef(name: structName, fields: fields))
            return .object(structName)
        }
        var seen: IRType? = nil
        for v in array {
            let t = inferType(from: v, fieldHint: parentHint, builder: builder)
            if seen == nil { seen = t }
            else if seen != t { return .anyValue }
        }
        return seen ?? .anyValue
    }
}
