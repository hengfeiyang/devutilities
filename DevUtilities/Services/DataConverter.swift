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
import Yams

/// Front door for the Data Converter tool: parse any supported text format into a
/// `DataValue`, serialize a `DataValue` back to any supported format, and convert
/// directly between two formats.
enum DataConverter {
    static func parse(_ text: String, from format: DataFormat, coerceCSVTypes: Bool = true) throws -> DataValue {
        switch format {
        case .json: return try JSONDataParser.parse(text)
        case .yaml: return try YAMLDataCodec.parse(text)
        case .toml: return try TOMLDataParser.parse(text)
        case .csv: return try CSVDataCodec.parse(text, coerceTypes: coerceCSVTypes)
        }
    }

    static func serialize(_ value: DataValue, to format: DataFormat) throws -> String {
        switch format {
        case .json: return JSONDataSerializer.serialize(value)
        case .yaml: return try YAMLDataCodec.serialize(value)
        case .toml: return try TOMLDataSerializer.serialize(value)
        case .csv: return try CSVDataCodec.serialize(value)
        }
    }

    static func convert(_ text: String, from source: DataFormat, to target: DataFormat, coerceCSVTypes: Bool = true) throws -> String {
        let value = try parse(text, from: source, coerceCSVTypes: coerceCSVTypes)
        return try serialize(value, to: target)
    }
}

// MARK: - Shared scalar inference

enum DataScalar {
    static let dateRegex = #"^\d{4}-\d{2}-\d{2}([T ]\d{2}:\d{2}(:\d{2})?(\.\d+)?(Z|[+-]\d{2}:?\d{2})?)?$"#

    static func looksLikeDate(_ s: String) -> Bool {
        s.count >= 10 && s.range(of: dateRegex, options: .regularExpression) != nil
    }

    /// Infer a typed scalar from an unquoted token (used by CSV coercion, YAML plain
    /// scalars, and TOML bare values). `yamlBooleans` widens bool keywords to YAML's
    /// yes/no. `emptyIsNull` controls whether "" becomes null or an empty string.
    static func infer(_ raw: String, yamlBooleans: Bool = false, emptyIsNull: Bool = false) -> DataValue {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return emptyIsNull ? .null : .string("") }
        let lowered = trimmed.lowercased()
        if lowered == "null" || trimmed == "~" { return .null }
        if lowered == "true" { return .bool(true) }
        if lowered == "false" { return .bool(false) }
        if yamlBooleans && (lowered == "yes" || lowered == "no") { return .bool(lowered == "yes") }
        if looksLikeDate(trimmed) { return .date(trimmed) }
        if let i = Int64(trimmed) { return .int(i) }
        // Avoid treating leading-zero strings ("007") or "+1" phone-like values as numbers
        // when they would not round-trip; Int64/Double already reject most of these.
        if let d = Double(trimmed), !trimmed.hasPrefix("0") || trimmed == "0" || trimmed.hasPrefix("0.") {
            return .double(d)
        }
        return .string(trimmed)
    }
}

// MARK: - JSON

enum JSONDataParser {
    static func parse(_ text: String) throws -> DataValue {
        var parser = Scanner(Array(text.unicodeScalars))
        parser.skipWhitespace()
        guard !parser.isAtEnd else { throw DataConvertError(message: "Empty JSON input") }
        let value = try parser.parseValue()
        parser.skipWhitespace()
        guard parser.isAtEnd else { throw DataConvertError(message: "Unexpected trailing characters in JSON") }
        return value
    }

    /// Minimal order-preserving JSON scanner (JSONSerialization loses key order).
    private struct Scanner {
        let scalars: [Unicode.Scalar]
        var i = 0
        init(_ s: [Unicode.Scalar]) { scalars = s }

        var isAtEnd: Bool { i >= scalars.count }
        func peek() -> Unicode.Scalar? { i < scalars.count ? scalars[i] : nil }

        mutating func skipWhitespace() {
            while i < scalars.count {
                let c = scalars[i]
                if c == " " || c == "\t" || c == "\n" || c == "\r" { i += 1 } else { break }
            }
        }

        mutating func parseValue() throws -> DataValue {
            skipWhitespace()
            guard let c = peek() else { throw DataConvertError(message: "Unexpected end of JSON") }
            switch c {
            case "{": return try parseObject()
            case "[": return try parseArray()
            case "\"": return .string(try parseString())
            case "t", "f": return try parseBool()
            case "n": try parseLiteral("null"); return .null
            default: return try parseNumber()
            }
        }

        mutating func parseObject() throws -> DataValue {
            i += 1 // {
            var pairs: [(key: String, value: DataValue)] = []
            skipWhitespace()
            if peek() == "}" { i += 1; return .object(pairs) }
            while true {
                skipWhitespace()
                guard peek() == "\"" else { throw DataConvertError(message: "Expected string key in JSON object") }
                let key = try parseString()
                skipWhitespace()
                guard peek() == ":" else { throw DataConvertError(message: "Expected ':' in JSON object") }
                i += 1
                let value = try parseValue()
                pairs.append((key, value))
                skipWhitespace()
                if peek() == "," { i += 1; continue }
                if peek() == "}" { i += 1; break }
                throw DataConvertError(message: "Expected ',' or '}' in JSON object")
            }
            return .object(pairs)
        }

        mutating func parseArray() throws -> DataValue {
            i += 1 // [
            var items: [DataValue] = []
            skipWhitespace()
            if peek() == "]" { i += 1; return .array(items) }
            while true {
                let value = try parseValue()
                items.append(value)
                skipWhitespace()
                if peek() == "," { i += 1; continue }
                if peek() == "]" { i += 1; break }
                throw DataConvertError(message: "Expected ',' or ']' in JSON array")
            }
            return .array(items)
        }

        mutating func parseString() throws -> String {
            i += 1 // opening quote
            var result = String.UnicodeScalarView()
            while i < scalars.count {
                let c = scalars[i]; i += 1
                if c == "\"" { return String(result) }
                if c == "\\" {
                    guard i < scalars.count else { break }
                    let esc = scalars[i]; i += 1
                    switch esc {
                    case "\"": result.append("\"")
                    case "\\": result.append("\\")
                    case "/": result.append("/")
                    case "n": result.append("\n")
                    case "t": result.append("\t")
                    case "r": result.append("\r")
                    case "b": result.append("\u{08}")
                    case "f": result.append("\u{0C}")
                    case "u":
                        let hex = try readHex4()
                        if let s = Unicode.Scalar(hex) { result.append(s) }
                    default: result.append(esc)
                    }
                } else {
                    result.append(c)
                }
            }
            throw DataConvertError(message: "Unterminated string in JSON")
        }

        mutating func readHex4() throws -> UInt32 {
            var value: UInt32 = 0
            for _ in 0..<4 {
                guard i < scalars.count, let d = Character(scalars[i]).hexDigitValue else {
                    throw DataConvertError(message: "Invalid \\u escape in JSON")
                }
                value = value * 16 + UInt32(d)
                i += 1
            }
            return value
        }

        mutating func parseBool() throws -> DataValue {
            if peek() == "t" { try parseLiteral("true"); return .bool(true) }
            try parseLiteral("false"); return .bool(false)
        }

        mutating func parseLiteral(_ literal: String) throws {
            for ch in literal.unicodeScalars {
                guard i < scalars.count, scalars[i] == ch else {
                    throw DataConvertError(message: "Invalid JSON literal, expected '\(literal)'")
                }
                i += 1
            }
        }

        mutating func parseNumber() throws -> DataValue {
            let start = i
            var isDouble = false
            while i < scalars.count {
                let c = scalars[i]
                if (c >= "0" && c <= "9") || c == "-" || c == "+" { i += 1 }
                else if c == "." || c == "e" || c == "E" { isDouble = true; i += 1 }
                else { break }
            }
            guard i > start else { throw DataConvertError(message: "Invalid JSON value") }
            let text = String(String.UnicodeScalarView(scalars[start..<i]))
            if !isDouble, let intVal = Int64(text) { return .int(intVal) }
            guard let dbl = Double(text) else { throw DataConvertError(message: "Invalid number '\(text)' in JSON") }
            return .double(dbl)
        }
    }
}

enum JSONDataSerializer {
    static func serialize(_ value: DataValue) -> String {
        var out = ""
        write(value, indent: 0, into: &out)
        return out + "\n"
    }

    private static func write(_ value: DataValue, indent: Int, into out: inout String) {
        switch value {
        case .string(let s), .date(let s): out += quote(s)
        case .int(let i): out += String(i)
        case .double(let d): out += DataValue.formatDouble(d)
        case .bool(let b): out += b ? "true" : "false"
        case .null: out += "null"
        case .array(let items):
            if items.isEmpty { out += "[]"; return }
            out += "[\n"
            let pad = String(repeating: "  ", count: indent + 1)
            for (idx, item) in items.enumerated() {
                out += pad
                write(item, indent: indent + 1, into: &out)
                out += idx == items.count - 1 ? "\n" : ",\n"
            }
            out += String(repeating: "  ", count: indent) + "]"
        case .object(let pairs):
            if pairs.isEmpty { out += "{}"; return }
            out += "{\n"
            let pad = String(repeating: "  ", count: indent + 1)
            for (idx, pair) in pairs.enumerated() {
                out += pad + quote(pair.key) + ": "
                write(pair.value, indent: indent + 1, into: &out)
                out += idx == pairs.count - 1 ? "\n" : ",\n"
            }
            out += String(repeating: "  ", count: indent) + "}"
        }
    }

    static func quote(_ s: String) -> String {
        var result = "\""
        for ch in s.unicodeScalars {
            switch ch {
            case "\"": result += "\\\""
            case "\\": result += "\\\\"
            case "\n": result += "\\n"
            case "\t": result += "\\t"
            case "\r": result += "\\r"
            case "\u{08}": result += "\\b"
            case "\u{0C}": result += "\\f"
            default:
                if ch.value < 0x20 {
                    result += String(format: "\\u%04x", ch.value)
                } else {
                    result.unicodeScalars.append(ch)
                }
            }
        }
        result += "\""
        return result
    }
}

// MARK: - YAML (via Yams, order-preserving through Node)

enum YAMLDataCodec {
    static func parse(_ text: String) throws -> DataValue {
        do {
            guard let node = try Yams.compose(yaml: text) else {
                throw DataConvertError(message: "Empty YAML input")
            }
            return convert(node)
        } catch let e as DataConvertError {
            throw e
        } catch {
            throw DataConvertError(message: "YAML parse error: \(error.localizedDescription)")
        }
    }

    private static func convert(_ node: Node) -> DataValue {
        switch node {
        case .scalar(let scalar):
            let quoted = scalar.style == .singleQuoted || scalar.style == .doubleQuoted
                || scalar.style == .literal || scalar.style == .folded
            if quoted { return .string(scalar.string) }
            return DataScalar.infer(scalar.string, yamlBooleans: true, emptyIsNull: true)
        case .mapping(let mapping):
            var pairs: [(key: String, value: DataValue)] = []
            for (k, v) in mapping {
                let key = k.string ?? ""
                pairs.append((key, convert(v)))
            }
            return .object(pairs)
        case .sequence(let sequence):
            return .array(sequence.map { convert($0) })
        case .alias:
            // Yams exposes aliases as references without the anchored value here.
            return .null
        @unknown default:
            // Any future node kinds collapse to null.
            return .null
        }
    }

    static func serialize(_ value: DataValue) throws -> String {
        let node = makeNode(value)
        do {
            return try Yams.serialize(node: node)
        } catch {
            throw DataConvertError(message: "YAML serialize error: \(error.localizedDescription)")
        }
    }

    private static func makeNode(_ value: DataValue) -> Node {
        switch value {
        case .string(let s): return Node.scalar(Node.Scalar(s, Tag(.str)))
        case .int(let i): return Node.scalar(Node.Scalar(String(i), Tag(.int)))
        case .double(let d): return Node.scalar(Node.Scalar(DataValue.formatDouble(d), Tag(.float)))
        case .bool(let b): return Node.scalar(Node.Scalar(b ? "true" : "false", Tag(.bool)))
        case .date(let s): return Node.scalar(Node.Scalar(s, Tag(.str)))
        case .null: return Node.scalar(Node.Scalar("null", Tag(.null)))
        case .array(let items):
            return Node.sequence(Node.Sequence(items.map { makeNode($0) }, Tag(.seq)))
        case .object(let pairs):
            let mapped = pairs.map { (Node.scalar(Node.Scalar($0.key, Tag(.str))), makeNode($0.value)) }
            return Node.mapping(Node.Mapping(mapped, Tag(.map)))
        }
    }
}

// MARK: - TOML

enum TOMLDataParser {
    static func parse(_ text: String) throws -> DataValue {
        let root = TOMLObject()
        var current = root
        for rawLine in text.components(separatedBy: "\n") {
            var line = rawLine.trimmingCharacters(in: .whitespaces)
            if line.isEmpty || line.hasPrefix("#") { continue }
            line = stripComment(line)
            if line.isEmpty { continue }

            if line.hasPrefix("[[") && line.hasSuffix("]]") {
                let header = String(line.dropFirst(2).dropLast(2)).trimmingCharacters(in: .whitespaces)
                current = root.arrayTable(path: splitKey(header))
                continue
            }
            if line.hasPrefix("[") && line.hasSuffix("]") {
                let header = String(line.dropFirst().dropLast()).trimmingCharacters(in: .whitespaces)
                current = root.table(path: splitKey(header))
                continue
            }
            guard let eq = line.firstIndex(of: "=") else { continue }
            let key = String(line[..<eq]).trimmingCharacters(in: .whitespaces)
            let valueRaw = String(line[line.index(after: eq)...]).trimmingCharacters(in: .whitespaces)
            current.set(path: splitKey(key), value: parseValue(valueRaw))
        }
        return root.toDataValue()
    }

    private static func splitKey(_ raw: String) -> [String] {
        raw.split(separator: ".").map { $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: CharacterSet(charactersIn: "\"'")) }
    }

    private static func stripComment(_ line: String) -> String {
        var inSingle = false, inDouble = false
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

    private static func parseValue(_ raw: String) -> DataValue {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return .null }
        if trimmed.hasPrefix("\"\"\"") && trimmed.hasSuffix("\"\"\"") && trimmed.count >= 6 {
            return .string(String(trimmed.dropFirst(3).dropLast(3)))
        }
        if (trimmed.hasPrefix("\"") && trimmed.hasSuffix("\"") && trimmed.count >= 2)
            || (trimmed.hasPrefix("'") && trimmed.hasSuffix("'") && trimmed.count >= 2) {
            return .string(String(trimmed.dropFirst().dropLast()))
        }
        if trimmed.hasPrefix("[") && trimmed.hasSuffix("]") {
            let inner = String(trimmed.dropFirst().dropLast())
            return .array(splitInline(inner).map { parseValue($0) })
        }
        if trimmed.hasPrefix("{") && trimmed.hasSuffix("}") {
            let inner = String(trimmed.dropFirst().dropLast())
            var pairs: [(key: String, value: DataValue)] = []
            for part in splitInline(inner) {
                if let eq = part.firstIndex(of: "=") {
                    let k = String(part[..<eq]).trimmingCharacters(in: .whitespaces).trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                    let v = String(part[part.index(after: eq)...]).trimmingCharacters(in: .whitespaces)
                    pairs.append((k, parseValue(v)))
                }
            }
            return .object(pairs)
        }
        let noUnderscore = trimmed.replacingOccurrences(of: "_", with: "")
        if trimmed == "true" { return .bool(true) }
        if trimmed == "false" { return .bool(false) }
        if DataScalar.looksLikeDate(trimmed) { return .date(trimmed) }
        if let i = Int64(noUnderscore) { return .int(i) }
        if let d = Double(noUnderscore) { return .double(d) }
        return .string(trimmed)
    }

    private static func splitInline(_ src: String) -> [String] {
        var result: [String] = []
        var current = ""
        var depth = 0, inSingle = false, inDouble = false
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
}

/// Mutable intermediate used while parsing TOML so that tables and arrays-of-tables
/// can be navigated by dotted path before being frozen into a `DataValue`.
private final class TOMLObject {
    var keys: [String] = []
    var values: [String: TOMLNode] = [:]

    enum TOMLNode {
        case scalar(DataValue)
        case object(TOMLObject)
        case array([TOMLObject])
    }

    func child(_ key: String) -> TOMLObject {
        if case .object(let o)? = values[key] { return o }
        let o = TOMLObject()
        if values[key] == nil { keys.append(key) }
        values[key] = .object(o)
        return o
    }

    func table(path: [String]) -> TOMLObject {
        var cur = self
        for k in path { cur = cur.child(k) }
        return cur
    }

    func arrayTable(path: [String]) -> TOMLObject {
        guard !path.isEmpty else { return self }
        var keysCopy = path
        let last = keysCopy.removeLast()
        let parent = table(path: keysCopy)
        var arr: [TOMLObject]
        if case .array(let existing)? = parent.values[last] { arr = existing }
        else { arr = []; if parent.values[last] == nil { parent.keys.append(last) } }
        let entry = TOMLObject()
        arr.append(entry)
        parent.values[last] = .array(arr)
        return entry
    }

    func set(path: [String], value: DataValue) {
        if path.count == 1 {
            if values[path[0]] == nil { keys.append(path[0]) }
            values[path[0]] = .scalar(value)
            return
        }
        var keysCopy = path
        let last = keysCopy.removeLast()
        let target = table(path: keysCopy)
        if target.values[last] == nil { target.keys.append(last) }
        target.values[last] = .scalar(value)
    }

    func toDataValue() -> DataValue {
        var pairs: [(key: String, value: DataValue)] = []
        for k in keys {
            switch values[k] {
            case .scalar(let v): pairs.append((k, v))
            case .object(let o): pairs.append((k, o.toDataValue()))
            case .array(let arr): pairs.append((k, .array(arr.map { $0.toDataValue() })))
            case .none: break
            }
        }
        return .object(pairs)
    }
}

enum TOMLDataSerializer {
    static func serialize(_ value: DataValue) throws -> String {
        guard case .object(let pairs) = value else {
            throw DataConvertError(message: "TOML output requires an object at the root")
        }
        var out = ""
        emitTable(pairs, header: [], into: &out)
        return out.trimmingCharacters(in: .newlines) + "\n"
    }

    private static func emitTable(_ pairs: [(key: String, value: DataValue)], header: [String], into out: inout String) {
        // Scalars and scalar-arrays first, then nested tables / arrays-of-tables.
        for pair in pairs {
            if !isTableLike(pair.value) {
                out += "\(keyText(pair.key)) = \(scalarText(pair.value))\n"
            }
        }
        for pair in pairs {
            switch pair.value {
            case .object(let childPairs):
                let path = header + [pair.key]
                out += "\n[\(path.map(keyText).joined(separator: "."))]\n"
                emitTable(childPairs, header: path, into: &out)
            case .array(let items) where items.allSatisfy({ $0.isObject }) && !items.isEmpty:
                let path = header + [pair.key]
                for item in items {
                    if case .object(let childPairs) = item {
                        out += "\n[[\(path.map(keyText).joined(separator: "."))]]\n"
                        emitTable(childPairs, header: path, into: &out)
                    }
                }
            default:
                break
            }
        }
    }

    private static func isTableLike(_ value: DataValue) -> Bool {
        switch value {
        case .object: return true
        case .array(let items): return !items.isEmpty && items.allSatisfy { $0.isObject }
        default: return false
        }
    }

    private static func keyText(_ key: String) -> String {
        let bare = key.range(of: "^[A-Za-z0-9_-]+$", options: .regularExpression) != nil
        return bare ? key : JSONDataSerializer.quote(key)
    }

    private static func scalarText(_ value: DataValue) -> String {
        switch value {
        case .string(let s): return JSONDataSerializer.quote(s)
        case .int(let i): return String(i)
        case .double(let d): return DataValue.formatDouble(d)
        case .bool(let b): return b ? "true" : "false"
        case .date(let s): return s   // TOML date literals are unquoted
        case .null: return "\"\""
        case .array(let items): return "[" + items.map { scalarText($0) }.joined(separator: ", ") + "]"
        case .object: return "{}"
        }
    }
}

// MARK: - CSV

enum CSVDataCodec {
    // MARK: Parse

    static func parse(_ text: String, coerceTypes: Bool) throws -> DataValue {
        let rows = parseRows(text)
        guard let header = rows.first else { throw DataConvertError(message: "Empty CSV input") }
        let dataRows = rows.dropFirst()
        var objects: [DataValue] = []
        for row in dataRows {
            if row.count == 1 && row[0].isEmpty { continue }   // skip blank trailing line
            var flat: [(path: String, value: DataValue)] = []
            for (idx, col) in header.enumerated() {
                let cell = idx < row.count ? row[idx] : ""
                let value: DataValue = coerceTypes ? DataScalar.infer(cell, emptyIsNull: true) : .string(cell)
                flat.append((col, value))
            }
            objects.append(unflatten(flat))
        }
        return .array(objects)
    }

    /// RFC-4180 row reader handling quoted fields, embedded commas/newlines, and "" escapes.
    private static func parseRows(_ text: String) -> [[String]] {
        var rows: [[String]] = []
        var field = ""
        var record: [String] = []
        var inQuotes = false
        let scalars = Array(text.unicodeScalars)
        var i = 0
        func endField() { record.append(field); field = "" }
        func endRecord() { endField(); rows.append(record); record = [] }
        while i < scalars.count {
            let c = scalars[i]
            if inQuotes {
                if c == "\"" {
                    if i + 1 < scalars.count && scalars[i + 1] == "\"" { field.unicodeScalars.append("\""); i += 2; continue }
                    inQuotes = false; i += 1; continue
                }
                field.unicodeScalars.append(c); i += 1; continue
            }
            switch c {
            case "\"": inQuotes = true; i += 1
            case ",": endField(); i += 1
            case "\r":
                if i + 1 < scalars.count && scalars[i + 1] == "\n" { i += 1 }
                endRecord(); i += 1
            case "\n": endRecord(); i += 1
            default: field.unicodeScalars.append(c); i += 1
            }
        }
        // flush trailing field/record
        if !field.isEmpty || !record.isEmpty { endRecord() }
        return rows
    }

    /// Rebuild nested structure from dotted-path keys. Numeric path segments become arrays.
    private static func unflatten(_ flat: [(path: String, value: DataValue)]) -> DataValue {
        let root = Builder()
        for entry in flat {
            let segments = entry.path.split(separator: ".").map(String.init)
            root.insert(segments, value: entry.value)
        }
        return root.freeze()
    }

    private final class Builder {
        var keys: [String] = []
        var children: [String: Builder] = [:]
        var leaf: DataValue?

        func insert(_ segments: [String], value: DataValue) {
            guard let head = segments.first else { leaf = value; return }
            if children[head] == nil { keys.append(head); children[head] = Builder() }
            children[head]!.insert(Array(segments.dropFirst()), value: value)
        }

        func freeze() -> DataValue {
            if let leaf = leaf, children.isEmpty { return leaf }
            // Array if every key is a non-negative integer.
            let asInts = keys.compactMap { Int($0) }
            if !keys.isEmpty && asInts.count == keys.count {
                let ordered = asInts.sorted()
                return .array(ordered.map { children[String($0)]!.freeze() })
            }
            return .object(keys.map { ($0, children[$0]!.freeze()) })
        }
    }

    // MARK: Serialize

    static func serialize(_ value: DataValue) throws -> String {
        let rows: [DataValue]
        switch value {
        case .array(let items): rows = items
        case .object: rows = [value]
        default: throw DataConvertError(message: "CSV output requires an object or an array of objects")
        }
        // Flatten every row, collecting the ordered union of leaf paths as the header.
        var header: [String] = []
        var headerSet = Set<String>()
        var flatRows: [[String: String]] = []
        for row in rows {
            var flat: [(String, String)] = []
            flatten(row, prefix: "", into: &flat)
            var map: [String: String] = [:]
            for (path, cell) in flat {
                map[path] = cell
                if !headerSet.contains(path) { headerSet.insert(path); header.append(path) }
            }
            flatRows.append(map)
        }
        guard !header.isEmpty else { throw DataConvertError(message: "Nothing to write to CSV") }
        var lines = [header.map(escapeCell).joined(separator: ",")]
        for map in flatRows {
            lines.append(header.map { escapeCell(map[$0] ?? "") }.joined(separator: ","))
        }
        return lines.joined(separator: "\n") + "\n"
    }

    private static func flatten(_ value: DataValue, prefix: String, into out: inout [(String, String)]) {
        switch value {
        case .object(let pairs):
            if pairs.isEmpty { out.append((prefix, "")) ; return }
            for pair in pairs {
                let key = prefix.isEmpty ? pair.key : "\(prefix).\(pair.key)"
                flatten(pair.value, prefix: key, into: &out)
            }
        case .array(let items):
            if items.isEmpty { out.append((prefix, "")); return }
            for (idx, item) in items.enumerated() {
                let key = prefix.isEmpty ? String(idx) : "\(prefix).\(idx)"
                flatten(item, prefix: key, into: &out)
            }
        default:
            out.append((prefix, value.scalarText ?? ""))
        }
    }

    private static func escapeCell(_ s: String) -> String {
        if s.contains(",") || s.contains("\"") || s.contains("\n") || s.contains("\r") {
            return "\"" + s.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return s
    }
}
