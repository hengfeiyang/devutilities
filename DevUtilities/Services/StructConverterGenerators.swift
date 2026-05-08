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

protocol StructCodeGenerator {
    func generate(_ schema: StructSchema) -> String
}

enum StructGeneratorFactory {
    static func generator(for language: StructOutputLanguage) -> StructCodeGenerator {
        switch language {
        case .swift: return SwiftGenerator()
        case .go: return GoGenerator()
        case .typescript: return TypeScriptGenerator()
        case .rust: return RustGenerator()
        case .python: return PythonGenerator()
        case .java: return JavaGenerator()
        case .php: return PHPGenerator()
        }
    }
}

// MARK: - Ordering helper

private func orderedStructs(_ schema: StructSchema) -> [StructDef] {
    // Emit referenced (child) structs before referrers, root last.
    var visited: Set<String> = []
    var ordered: [StructDef] = []
    let byName = Dictionary(uniqueKeysWithValues: schema.structs.map { ($0.name, $0) })

    func visit(_ name: String) {
        if visited.contains(name) { return }
        visited.insert(name)
        guard let def = byName[name] else { return }
        for field in def.fields {
            for refName in referencedStructs(in: field.type) {
                visit(refName)
            }
        }
        ordered.append(def)
    }

    visit(schema.rootName)
    // Append any orphan structs (e.g. additional CREATE TABLE blocks) that weren't referenced.
    for def in schema.structs where !visited.contains(def.name) {
        visited.insert(def.name)
        ordered.append(def)
    }
    return ordered
}

private func referencedStructs(in type: IRType) -> [String] {
    switch type {
    case .object(let n): return [n]
    case .array(let inner): return referencedStructs(in: inner)
    case .dictionary(let inner): return referencedStructs(in: inner)
    default: return []
    }
}

// MARK: - Swift

private struct SwiftGenerator: StructCodeGenerator {
    func generate(_ schema: StructSchema) -> String {
        let structs = orderedStructs(schema)
        let body = structs.map { renderStruct($0) }.joined(separator: "\n\n")
        return "import Foundation\n\n" + body + "\n"
    }

    private func renderStruct(_ def: StructDef) -> String {
        var lines: [String] = []
        lines.append("struct \(def.name): Codable {")
        for field in def.fields {
            let propName = StructNaming.camelCase(field.name)
            let typeStr = swiftType(field.type)
            let optMark = (field.isOptional || field.type == .null) ? "?" : ""
            lines.append("    let \(propName): \(typeStr)\(optMark)")
        }
        if def.fields.contains(where: { StructNaming.camelCase($0.name) != $0.name }) {
            lines.append("")
            lines.append("    enum CodingKeys: String, CodingKey {")
            for field in def.fields {
                let propName = StructNaming.camelCase(field.name)
                if propName != field.name {
                    lines.append("        case \(propName) = \"\(field.name)\"")
                } else {
                    lines.append("        case \(propName)")
                }
            }
            lines.append("    }")
        }
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    private func swiftType(_ type: IRType) -> String {
        switch type {
        case .string: return "String"
        case .integer: return "Int"
        case .double: return "Double"
        case .bool: return "Bool"
        case .date: return "Date"
        case .anyValue, .null: return "AnyCodable?"
        case .array(let inner): return "[\(swiftType(inner))]"
        case .object(let name): return name
        case .dictionary(let inner): return "[String: \(swiftType(inner))]"
        }
    }
}

// MARK: - Go

private struct GoGenerator: StructCodeGenerator {
    func generate(_ schema: StructSchema) -> String {
        let structs = orderedStructs(schema)
        let body = structs.map { renderStruct($0) }.joined(separator: "\n\n")
        return "package main\n\nimport \"time\"\n\n" + body + "\n"
    }

    private func renderStruct(_ def: StructDef) -> String {
        var lines: [String] = ["type \(def.name) struct {"]
        let widths = computeColumnWidths(def.fields)
        for field in def.fields {
            let goName = goExportedName(field.name)
            let goTypeStr = goType(field.type, isOptional: field.isOptional)
            let nameCol = goName.padding(toLength: widths.name, withPad: " ", startingAt: 0)
            let typeCol = goTypeStr.padding(toLength: widths.type, withPad: " ", startingAt: 0)
            let tag = "`json:\"\(field.name)\(field.isOptional ? ",omitempty" : "")\"`"
            lines.append("    \(nameCol) \(typeCol) \(tag)")
        }
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    private func computeColumnWidths(_ fields: [StructField]) -> (name: Int, type: Int) {
        var nameWidth = 0
        var typeWidth = 0
        for f in fields {
            nameWidth = max(nameWidth, goExportedName(f.name).count)
            typeWidth = max(typeWidth, goType(f.type, isOptional: f.isOptional).count)
        }
        return (nameWidth, typeWidth)
    }

    private func goExportedName(_ raw: String) -> String {
        StructNaming.pascalCase(raw)
    }

    private func goType(_ type: IRType, isOptional: Bool) -> String {
        switch type {
        case .string: return "string"
        case .integer: return "int64"
        case .double: return "float64"
        case .bool: return "bool"
        case .date: return "time.Time"
        case .anyValue, .null: return "interface{}"
        case .array(let inner): return "[]\(goType(inner, isOptional: false))"
        case .object(let name): return isOptional ? "*\(name)" : name
        case .dictionary(let inner): return "map[string]\(goType(inner, isOptional: false))"
        }
    }
}

// MARK: - TypeScript

private struct TypeScriptGenerator: StructCodeGenerator {
    func generate(_ schema: StructSchema) -> String {
        orderedStructs(schema).map { renderInterface($0) }.joined(separator: "\n\n") + "\n"
    }

    private func renderInterface(_ def: StructDef) -> String {
        var lines: [String] = ["export interface \(def.name) {"]
        for field in def.fields {
            let opt = field.isOptional ? "?" : ""
            lines.append("  \(safeKey(field.name))\(opt): \(tsType(field.type));")
        }
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    private func safeKey(_ raw: String) -> String {
        let validIdentifier = raw.range(of: "^[A-Za-z_$][A-Za-z0-9_$]*$", options: .regularExpression) != nil
        return validIdentifier ? raw : "\"\(raw)\""
    }

    private func tsType(_ type: IRType) -> String {
        switch type {
        case .string: return "string"
        case .integer, .double: return "number"
        case .bool: return "boolean"
        case .date: return "string"
        case .anyValue: return "any"
        case .null: return "null"
        case .array(let inner): return "\(tsType(inner))[]"
        case .object(let name): return name
        case .dictionary(let inner): return "Record<string, \(tsType(inner))>"
        }
    }
}

// MARK: - Rust

private struct RustGenerator: StructCodeGenerator {
    func generate(_ schema: StructSchema) -> String {
        let structs = orderedStructs(schema)
        let body = structs.map { renderStruct($0) }.joined(separator: "\n\n")
        return "use serde::{Deserialize, Serialize};\nuse chrono::{DateTime, Utc};\n\n" + body + "\n"
    }

    private func renderStruct(_ def: StructDef) -> String {
        var lines: [String] = []
        lines.append("#[derive(Debug, Clone, Serialize, Deserialize)]")
        lines.append("pub struct \(def.name) {")
        for field in def.fields {
            let snakeName = StructNaming.snakeCase(field.name)
            if snakeName != field.name {
                lines.append("    #[serde(rename = \"\(field.name)\")]")
            }
            let optWrapper = field.isOptional || field.type == .null
            let baseType = rustType(field.type)
            let typeStr = optWrapper ? "Option<\(baseType)>" : baseType
            lines.append("    pub \(rustSafeIdent(snakeName)): \(typeStr),")
        }
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    private func rustSafeIdent(_ name: String) -> String {
        let reserved: Set<String> = ["type", "fn", "struct", "enum", "match", "ref", "use", "mod", "trait", "impl", "let", "const", "static", "pub", "self", "super", "where", "move", "loop", "while", "for", "if", "else", "return", "break", "continue", "as", "in", "crate", "extern", "unsafe", "true", "false", "box"]
        return reserved.contains(name) ? "r#\(name)" : name
    }

    private func rustType(_ type: IRType) -> String {
        switch type {
        case .string: return "String"
        case .integer: return "i64"
        case .double: return "f64"
        case .bool: return "bool"
        case .date: return "DateTime<Utc>"
        case .anyValue, .null: return "serde_json::Value"
        case .array(let inner): return "Vec<\(rustType(inner))>"
        case .object(let name): return name
        case .dictionary(let inner): return "std::collections::HashMap<String, \(rustType(inner))>"
        }
    }
}

// MARK: - Python (dataclass)

private struct PythonGenerator: StructCodeGenerator {
    func generate(_ schema: StructSchema) -> String {
        let structs = orderedStructs(schema)
        let body = structs.map { renderClass($0) }.joined(separator: "\n\n\n")
        return """
        from dataclasses import dataclass
        from typing import Any, Dict, List, Optional
        from datetime import datetime


        \(body)
        """ + "\n"
    }

    private func renderClass(_ def: StructDef) -> String {
        var lines: [String] = ["@dataclass", "class \(def.name):"]
        if def.fields.isEmpty {
            lines.append("    pass")
            return lines.joined(separator: "\n")
        }
        // Required fields first, optional last to satisfy dataclass ordering.
        let required = def.fields.filter { !$0.isOptional && $0.type != .null }
        let optional = def.fields.filter { $0.isOptional || $0.type == .null }
        for field in required {
            lines.append("    \(StructNaming.snakeCase(field.name)): \(pythonType(field.type, optional: false))")
        }
        for field in optional {
            lines.append("    \(StructNaming.snakeCase(field.name)): \(pythonType(field.type, optional: true)) = None")
        }
        return lines.joined(separator: "\n")
    }

    private func pythonType(_ type: IRType, optional: Bool) -> String {
        let base: String
        switch type {
        case .string: base = "str"
        case .integer: base = "int"
        case .double: base = "float"
        case .bool: base = "bool"
        case .date: base = "datetime"
        case .anyValue, .null: base = "Any"
        case .array(let inner): base = "List[\(pythonType(inner, optional: false))]"
        case .object(let name): base = name
        case .dictionary(let inner): base = "Dict[str, \(pythonType(inner, optional: false))]"
        }
        return optional ? "Optional[\(base)]" : base
    }
}

// MARK: - Java

private struct JavaGenerator: StructCodeGenerator {
    func generate(_ schema: StructSchema) -> String {
        orderedStructs(schema).map { renderClass($0) }.joined(separator: "\n\n") + "\n"
    }

    private func renderClass(_ def: StructDef) -> String {
        var lines: [String] = ["public class \(def.name) {"]
        for field in def.fields {
            lines.append("    private \(javaType(field.type)) \(StructNaming.camelCase(field.name));")
        }
        lines.append("")
        for field in def.fields {
            let camel = StructNaming.camelCase(field.name)
            let pascal = StructNaming.pascalCase(field.name)
            let type = javaType(field.type)
            lines.append("    public \(type) get\(pascal)() { return this.\(camel); }")
            lines.append("    public void set\(pascal)(\(type) \(camel)) { this.\(camel) = \(camel); }")
        }
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    private func javaType(_ type: IRType) -> String {
        switch type {
        case .string: return "String"
        case .integer: return "Long"
        case .double: return "Double"
        case .bool: return "Boolean"
        case .date: return "java.time.Instant"
        case .anyValue, .null: return "Object"
        case .array(let inner): return "java.util.List<\(javaBoxedType(inner))>"
        case .object(let name): return name
        case .dictionary(let inner): return "java.util.Map<String, \(javaBoxedType(inner))>"
        }
    }

    private func javaBoxedType(_ type: IRType) -> String {
        return javaType(type)
    }
}

// MARK: - PHP

private struct PHPGenerator: StructCodeGenerator {
    func generate(_ schema: StructSchema) -> String {
        let body = orderedStructs(schema).map { renderClass($0) }.joined(separator: "\n\n")
        return "<?php\n\n" + body + "\n"
    }

    private func renderClass(_ def: StructDef) -> String {
        var lines: [String] = ["class \(def.name)", "{"]
        for field in def.fields {
            let nullable = (field.isOptional || field.type == .null) ? "?" : ""
            lines.append("    public \(nullable)\(phpType(field.type)) $\(StructNaming.camelCase(field.name));")
        }
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    private func phpType(_ type: IRType) -> String {
        switch type {
        case .string: return "string"
        case .integer: return "int"
        case .double: return "float"
        case .bool: return "bool"
        case .date: return "\\DateTimeImmutable"
        case .anyValue, .null: return "mixed"
        case .array: return "array"
        case .object(let name): return name
        case .dictionary: return "array"
        }
    }
}
