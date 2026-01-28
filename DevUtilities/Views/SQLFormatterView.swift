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

import SwiftUI
import AppKit

struct SQLFormatterView: View {
    let screenName = "SQL Formatter"
    let module = "sql_formatter"
    @State private var sqlInput: String = ""
    @State private var sqlInput2: String = ""
    @State private var sqlOutput: String = ""
    @State private var selectedMode: SQLMode = .format
    @State private var validationMessage: String = ""
    @State private var isValid: Bool = true
    
    var body: some View {
        VStack(spacing: 20) {
            // Mode Selection
            Picker("Mode", selection: $selectedMode) {
                ForEach(SQLMode.allCases, id: \.self) { mode in
                    Text(mode.title)
                        .tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selectedMode) { _, _ in
                processSQL()
            }

            if selectedMode == .diff {
                // Diff Mode Layout - Single visual diff editor
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("SQL Diff Comparison")
                            .font(.headline)
                        Spacer()
                        Button("Clear") {
                            sqlInput = ""
                            sqlInput2 = ""
                            sqlOutput = ""
                            validationMessage = ""
                        }
                        .buttonStyle(.borderless)
                    }

                    CodeDiffEditor.sql(leftContent: $sqlInput, rightContent: $sqlInput2, readOnly: false)
                        .frame(maxHeight: .infinity)
                        .onChange(of: sqlInput) { _, _ in
                            updateComparisonStatus()
                        }
                        .onChange(of: sqlInput2) { _, _ in
                            updateComparisonStatus()
                        }

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("SQL 1 (Left): \(sqlInput.count) characters, \(sqlInput.components(separatedBy: .newlines).count) lines")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("SQL 2 (Right): \(sqlInput2.count) characters, \(sqlInput2.components(separatedBy: .newlines).count) lines")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    if !validationMessage.isEmpty {
                        Text(validationMessage)
                            .font(.caption)
                            .foregroundColor(isValid ? .green : .red)
                    }
                }
                .padding(.horizontal, 0)
            } else {
                // Standard Mode Layout - Two columns
                HStack(alignment: .top, spacing: 20) {
                // Input Section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("SQL Input")
                            .font(.headline)
                        Spacer()
                        Button("Clear") {
                            sqlInput = ""
                            sqlOutput = ""
                            validationMessage = ""
                        }
                        .buttonStyle(.borderless)
                    }
                    
                    CodeEditor.sql(text: $sqlInput)
                        .padding(5)
                        .frame(maxHeight: .infinity)
                        .onChange(of: sqlInput) { _, _ in
                            processSQL()
                        }
                    
                    HStack {
                        Text("\(sqlInput.count) characters, \(sqlInput.components(separatedBy: .newlines).count) lines")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if !validationMessage.isEmpty {
                            Text(validationMessage)
                                .font(.caption)
                                .foregroundColor(isValid ? .green : .red)
                        }
                    }
                }
                
                Image(systemName: "arrow.right")
                    .font(.title)
                    .foregroundColor(.blue)
                    .frame(maxHeight: .infinity, alignment: .center)
                
                // Output Section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("SQL Output")
                            .font(.headline)
                        Spacer()
                        Button("Copy") {
                            copyToClipboard(sqlOutput)
                        }
                        .buttonStyle(.borderless)
                        .disabled(sqlOutput.isEmpty)
                    }
                    
                    CodeEditor.sql(text: .constant(sqlOutput.isEmpty ? "Formatted SQL will appear here" : sqlOutput), readOnly: true)
                        .padding(5)
                        .frame(maxHeight: .infinity)
                    
                    Text("\(sqlOutput.count) characters, \(sqlOutput.components(separatedBy: .newlines).count) lines")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                }
                .padding(.horizontal, 0)
            }

            // Action Buttons
            HStack(spacing: 20) {
                Button("Sample") {
                    if selectedMode == .diff {
                        sqlInput = sampleSQL1
                        sqlInput2 = sampleSQL2
                    } else {
                        sqlInput = sampleSQL
                    }
                    processSQL()
                }
                .buttonStyle(.bordered)
                
                Button("Format") {
                    selectedMode = .format
                    processSQL()
                }
                .buttonStyle(.bordered)
                
                Button("Minify") {
                    selectedMode = .minify
                    processSQL()
                }
                .buttonStyle(.bordered)
                
                Button("Validate") {
                    selectedMode = .validate
                    processSQL()
                }
                .buttonStyle(.bordered)
                
                Button("Analyze") {
                    selectedMode = .analyze
                    processSQL()
                }
                .buttonStyle(.bordered)

                Button("Diff") {
                    selectedMode = .diff
                    processSQL()
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("\(screenName)")
        .onAppear {
            loadState()
        }
        .onDisappear {
            saveState()
        }
        .onChange(of: selectedMode) { oldValue, newValue in
            Task.detached {
                await EventManager.shared.reportSubmoduleSwitch(
                    module: module,
                    from: "\(oldValue)".lowercased(),
                    to: "\(newValue)".lowercased()
                )
            }
        }
    }
    
    private func processSQL() {
        guard !sqlInput.isEmpty else {
            sqlOutput = ""
            validationMessage = ""
            return
        }
        
        switch selectedMode {
        case .format:
            formatSQL()
        case .minify:
            minifySQL()
        case .validate:
            validateSQL()
        case .analyze:
            analyzeSQL()
        case .diff:
            diffSQL()
        }
    }
    
    private func formatSQL() {
        let formatted = formatSQLString(sqlInput)
        sqlOutput = formatted
        isValid = true
        validationMessage = "✅ SQL formatted"
    }
    
    private func minifySQL() {
        let minified = minifySQLString(sqlInput)
        sqlOutput = minified
        isValid = true
        validationMessage = "✅ SQL minified"
    }
    
    private func validateSQL() {
        let issues = validateSQLString(sqlInput)
        
        if issues.isEmpty {
            sqlOutput = "✅ SQL syntax appears valid\n\n" + getSQLInfo(sqlInput)
            isValid = true
            validationMessage = "✅ Valid SQL"
        } else {
            sqlOutput = "❌ SQL validation issues found:\n\n" + issues.joined(separator: "\n\n")
            isValid = false
            validationMessage = "❌ Found \(issues.count) issue(s)"
        }
    }
    
    private func analyzeSQL() {
        let analysis = analyzeSQLString(sqlInput)
        sqlOutput = analysis
        isValid = true
        validationMessage = "✅ SQL analyzed"
    }

    private func diffSQL() {
        // Handle empty inputs
        guard !sqlInput.isEmpty || !sqlInput2.isEmpty else {
            validationMessage = "Enter SQL in both fields to compare"
            isValid = false
            return
        }

        if sqlInput.isEmpty {
            validationMessage = "SQL 1 is empty"
            isValid = false
            return
        }

        if sqlInput2.isEmpty {
            validationMessage = "SQL 2 is empty"
            isValid = false
            return
        }

        // Format both SQL inputs for better diff visualization
        let formatted1 = formatSQLString(sqlInput)
        let formatted2 = formatSQLString(sqlInput2)

        sqlInput = formatted1
        sqlInput2 = formatted2

        validationMessage = "✅ Both SQLs formatted - differences shown in diff view"
        isValid = true
    }
    
    private func formatSQLString(_ sql: String) -> String {
        guard !sql.isEmpty else { return "" }
        
        do {
            // Use the ParquetViewer library's SQL formatter with beautify style
            return try ParquetViewer.formatSql(sql, style: .beautify)
        } catch {
            // If formatting fails, return the original SQL with basic cleanup
            return sql.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    private func minifySQLString(_ sql: String) -> String {
        guard !sql.isEmpty else { return "" }
        
        do {
            // Use the ParquetViewer library's SQL formatter with minimal style
            return try ParquetViewer.formatSql(sql, style: .minimal)
        } catch {
            // If formatting fails, return basic minification
            return sql.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
                     .trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    private func validateSQLString(_ sql: String) -> [String] {
        var issues: [String] = []
        let lowercaseSQL = sql.lowercased()
        
        // Check for basic SQL structure
        if !containsSQLKeywords(lowercaseSQL) {
            issues.append("⚠️ No SQL keywords detected (SELECT, INSERT, UPDATE, DELETE, CREATE, etc.)")
        }
        
        // Check for unmatched parentheses
        let openParens = sql.filter { $0 == "(" }.count
        let closeParens = sql.filter { $0 == ")" }.count
        if openParens != closeParens {
            issues.append("⚠️ Unmatched parentheses: \(openParens) opening vs \(closeParens) closing")
        }
        
        // Check for unmatched quotes
        let singleQuotes = sql.filter { $0 == "'" }.count
        let doubleQuotes = sql.filter { $0 == "\"" }.count
        if singleQuotes % 2 != 0 {
            issues.append("⚠️ Unmatched single quotes")
        }
        if doubleQuotes % 2 != 0 {
            issues.append("⚠️ Unmatched double quotes")
        }
        
        // Check for SELECT without FROM (unless it's a simple expression)
        if lowercaseSQL.contains("select") && !lowercaseSQL.contains("from") && !isSimpleSelectExpression(lowercaseSQL) {
            issues.append("⚠️ SELECT statement without FROM clause")
        }
        
        // Check for common syntax issues
        if lowercaseSQL.contains("where") && lowercaseSQL.contains("group by") {
            let whereIndex = lowercaseSQL.range(of: "where")?.lowerBound
            let groupByIndex = lowercaseSQL.range(of: "group by")?.lowerBound
            if let whereIdx = whereIndex, let groupIdx = groupByIndex, whereIdx > groupIdx {
                issues.append("⚠️ WHERE clause should come before GROUP BY")
            }
        }
        
        // Check for missing semicolon at end (if it looks like a complete statement)
        let trimmed = sql.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !trimmed.hasSuffix(";") && isCompleteStatement(lowercaseSQL) {
            issues.append("⚠️ Statement should end with semicolon (;)")
        }
        
        return issues
    }
    
    private func getSQLInfo(_ sql: String) -> String {
        var info = ""
        let lowercaseSQL = sql.lowercased()
        
        // Detect SQL statement types
        var statementTypes: [String] = []
        if lowercaseSQL.contains("select") { statementTypes.append("SELECT") }
        if lowercaseSQL.contains("insert") { statementTypes.append("INSERT") }
        if lowercaseSQL.contains("update") { statementTypes.append("UPDATE") }
        if lowercaseSQL.contains("delete") { statementTypes.append("DELETE") }
        if lowercaseSQL.contains("create") { statementTypes.append("CREATE") }
        if lowercaseSQL.contains("alter") { statementTypes.append("ALTER") }
        if lowercaseSQL.contains("drop") { statementTypes.append("DROP") }
        
        if !statementTypes.isEmpty {
            info += "Statement types: \(statementTypes.joined(separator: ", "))\n"
        }
        
        // Count clauses
        var clauses: [String] = []
        if lowercaseSQL.contains("where") { clauses.append("WHERE") }
        if lowercaseSQL.contains("group by") { clauses.append("GROUP BY") }
        if lowercaseSQL.contains("having") { clauses.append("HAVING") }
        if lowercaseSQL.contains("order by") { clauses.append("ORDER BY") }
        if lowercaseSQL.contains("limit") { clauses.append("LIMIT") }
        
        if !clauses.isEmpty {
            info += "Clauses: \(clauses.joined(separator: ", "))\n"
        }
        
        // Count joins
        let joinTypes = ["inner join", "left join", "right join", "full join", "cross join", "join"]
        var joinCount = 0
        for joinType in joinTypes {
            joinCount += countOccurrences(of: joinType, in: lowercaseSQL)
        }
        if joinCount > 0 {
            info += "Joins: \(joinCount)\n"
        }
        
        // Count subqueries (rough estimate)
        let subqueryCount = max(0, sql.filter { $0 == "(" }.count - 1)
        if subqueryCount > 0 {
            info += "Potential subqueries: \(subqueryCount)\n"
        }
        
        return info
    }
    
    private func analyzeSQLString(_ sql: String) -> String {
        var analysis = "📊 SQL Query Analysis\n\n"
        let lowercaseSQL = sql.lowercased()
        
        // Query complexity analysis
        analysis += "🔍 Complexity Analysis:\n"
        
        let selectCount = countOccurrences(of: "select", in: lowercaseSQL)
        let joinCount = countOccurrences(of: "join", in: lowercaseSQL)
        let subqueryCount = max(0, sql.filter { $0 == "(" }.count - joinCount)
        let whereConditions = countOccurrences(of: "and", in: lowercaseSQL) + countOccurrences(of: "or", in: lowercaseSQL) + 1
        
        analysis += "• SELECT statements: \(selectCount)\n"
        analysis += "• JOINs: \(joinCount)\n"
        analysis += "• Subqueries: \(subqueryCount)\n"
        analysis += "• WHERE conditions: \(whereConditions)\n\n"
        
        // Performance considerations
        analysis += "⚡ Performance Considerations:\n"
        
        if lowercaseSQL.contains("select *") {
            analysis += "⚠️  Using SELECT * - consider specifying columns\n"
        }
        
        if !lowercaseSQL.contains("where") && (lowercaseSQL.contains("select") || lowercaseSQL.contains("update") || lowercaseSQL.contains("delete")) {
            analysis += "⚠️  No WHERE clause - may affect large datasets\n"
        }
        
        if joinCount > 3 {
            analysis += "⚠️  Multiple JOINs (\(joinCount)) - consider query optimization\n"
        }
        
        if subqueryCount > 2 {
            analysis += "⚠️  Multiple subqueries - consider using JOINs or CTEs\n"
        }
        
        if lowercaseSQL.contains("order by") && !lowercaseSQL.contains("limit") {
            analysis += "⚠️  ORDER BY without LIMIT - may be expensive\n"
        }
        
        if lowercaseSQL.contains("like '%") && lowercaseSQL.contains("%'") {
            analysis += "⚠️  Leading wildcard in LIKE - cannot use indexes\n"
        }
        
        analysis += "\n"
        
        // Security considerations
        analysis += "🔐 Security Notes:\n"
        if sql.contains("--") {
            analysis += "ℹ️  Contains SQL comments\n"
        }
        
        analysis += "ℹ️  Always use parameterized queries for user input\n"
        analysis += "ℹ️  Validate and sanitize all input data\n\n"
        
        // Suggestions
        analysis += "💡 Suggestions:\n"
        analysis += "• Use EXPLAIN to analyze execution plan\n"
        analysis += "• Consider indexing columns used in WHERE, JOIN, ORDER BY\n"
        analysis += "• Use LIMIT for large result sets\n"
        analysis += "• Consider using CTEs for complex subqueries\n"
        
        return analysis
    }
    
    private func containsSQLKeywords(_ sql: String) -> Bool {
        let keywords = ["select", "insert", "update", "delete", "create", "alter", "drop", "with"]
        return keywords.contains { sql.contains($0) }
    }
    
    private func isSimpleSelectExpression(_ sql: String) -> Bool {
        // Check if it's a simple SELECT expression like "SELECT 1" or "SELECT NOW()"
        let pattern = #"^\s*select\s+[\w\(\)\s\,\*\+\-\/]+\s*$"#
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        return regex.firstMatch(in: sql, range: NSRange(sql.startIndex..., in: sql)) != nil
    }
    
    private func isCompleteStatement(_ sql: String) -> Bool {
        let statementKeywords = ["select", "insert", "update", "delete", "create", "alter", "drop"]
        return statementKeywords.contains { sql.contains($0) }
    }
    
    private func countOccurrences(of substring: String, in string: String) -> Int {
        return string.components(separatedBy: substring).count - 1
    }
    
    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(text, forType: .string)
    }
    
    private func saveState() {
        let defaults = UserDefaults.standard
        defaults.set(sqlInput, forKey: "SQLFormatter.sqlInput")
        defaults.set(sqlInput2, forKey: "SQLFormatter.sqlInput2")
        defaults.set(sqlOutput, forKey: "SQLFormatter.sqlOutput")
        defaults.set(selectedMode.title, forKey: "SQLFormatter.selectedMode")
        defaults.set(validationMessage, forKey: "SQLFormatter.validationMessage")
        defaults.set(isValid, forKey: "SQLFormatter.isValid")
    }
    
    private func loadState() {
        let defaults = UserDefaults.standard
        sqlInput = defaults.string(forKey: "SQLFormatter.sqlInput") ?? ""
        sqlInput2 = defaults.string(forKey: "SQLFormatter.sqlInput2") ?? ""
        sqlOutput = defaults.string(forKey: "SQLFormatter.sqlOutput") ?? ""
        validationMessage = defaults.string(forKey: "SQLFormatter.validationMessage") ?? ""
        isValid = defaults.bool(forKey: "SQLFormatter.isValid")

        if let modeTitle = defaults.string(forKey: "SQLFormatter.selectedMode") {
            selectedMode = SQLMode.allCases.first { $0.title == modeTitle } ?? .format
        }

        // If we have input, trigger processing
        if !sqlInput.isEmpty || !sqlInput2.isEmpty {
            processSQL()
        }
    }

    private func updateComparisonStatus() {
        if sqlInput.isEmpty && sqlInput2.isEmpty {
            validationMessage = ""
            isValid = true
        } else if sqlInput == sqlInput2 {
            isValid = true
            validationMessage = "✅ Both SQLs are the same"
        } else {
            isValid = false
            validationMessage = "❌ SQLs are different"
        }
    }
}

enum SQLMode: CaseIterable {
    case format, minify, validate, analyze, diff

    var title: String {
        switch self {
        case .format: return "Format"
        case .minify: return "Minify"
        case .validate: return "Validate"
        case .analyze: return "Analyze"
        case .diff: return "Diff"
        }
    }
}

private let sampleSQL = """
SELECT u.id, u.name, u.email, p.title as project_title, COUNT(t.id) as task_count FROM users u INNER JOIN projects p ON u.id = p.user_id LEFT JOIN tasks t ON p.id = t.project_id WHERE u.active = 1 AND p.status = 'active' AND t.completed = 0 GROUP BY u.id, p.id HAVING COUNT(t.id) > 0 ORDER BY u.name, task_count DESC LIMIT 10;
"""

private let sampleSQL1 = """
SELECT id, name, email FROM users WHERE active = 1 ORDER BY name LIMIT 10;
"""

private let sampleSQL2 = """
SELECT id, name, email, created_at FROM users WHERE active = 1 AND verified = 1 ORDER BY name, created_at DESC LIMIT 20;
"""

#Preview {
    SQLFormatterView()
}