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
import UniformTypeIdentifiers
import AppKit

// Data row structure for Table view
struct ParquetRow: Identifiable {
    let id = UUID()
    let values: [String]
    
    subscript(index: Int) -> String {
        guard index < values.count else { return "" }
        return values[index]
    }
}

// Schema information structure
struct SchemaInfo: Identifiable {
    let id = UUID()
    let columnName: String
    let dataType: String
    let nullable: String
}

// Metadata key/value row structure
struct MetadataRow: Identifiable {
    let id = UUID()
    let key: String
    let value: String
}

enum FileType {
    case parquet
    case arrow
}

struct ParquetViewerView: View {
    let screenName = "Parquet"
    @State private var selectedTab = "schema"
    @State private var fileURL: URL?
    @State private var fileName: String = ""
    @State private var parquetFilePath: String = ""
    @State private var fileType: FileType = .parquet
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @State private var tableRows: [ParquetRow] = []
    @State private var columnNames: [String] = []
    @State private var columnTypes: [String] = []
    @State private var schemaRows: [SchemaInfo] = []
    @State private var metadata: String = ""
    @State private var metadataRows: [MetadataRow] = []
    
    @State private var rowCount: Int = 0
    @State private var columnCount: Int = 0
    @State private var fileSize: String = ""
    
    @State private var selectedRows = Set<ParquetRow.ID>()
    @State private var isDragOver: Bool = false

    private let maxPreviewRows = 100
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                Button(action: selectFile) {
                    Label("Select File", systemImage: "doc.badge.plus")
                }
                .buttonStyle(.borderedProminent)
                
                if fileURL != nil {
                    Button(action: clearFile) {
                        Label("Clear", systemImage: "xmark.circle")
                    }
                    .buttonStyle(.bordered)
                }
            }

            if fileURL != nil {
                TabView(selection: $selectedTab) {
                    schemaView
                        .tabItem {
                            Label("Schema", systemImage: "list.bullet.rectangle")
                        }
                        .tag("schema")
                    dataView
                        .tabItem {
                            Label("Data", systemImage: "tablecells")
                        }
                        .tag("data")
                    metadataView
                        .tabItem {
                            Label("Metadata", systemImage: "info.circle")
                        }
                        .tag("metadata")
                }
                .frame(maxHeight: .infinity)
            } else {
                // Drop zone for drag and drop
                VStack(spacing: 20) {
                    Image(systemName: isDragOver ? "arrow.down.circle.fill" : "doc.text.magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundColor(isDragOver ? .accentColor : .secondary)
                    
                    Text(isDragOver ? "Drop the file here" : "Select a Parquet or Arrow file to view its contents")
                        .font(.title3)
                        .foregroundColor(isDragOver ? .accentColor : .secondary)
                    
                    Text(isDragOver ? "Release to load the file" : "or drag and drop a file here")
                        .font(.caption)
                        .foregroundColor(isDragOver ? .accentColor : .secondary.opacity(0.6))
                    
                    Text("Click to browse files")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.5))
                        .padding(.top, 5)
                }
                .frame(width: 400, height: 300)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isDragOver ? Color.accentColor : Color.secondary.opacity(0.3),
                            style: StrokeStyle(lineWidth: isDragOver ? 3 : 2, dash: [8])
                        )
                        .background(
                            isDragOver ? Color.accentColor.opacity(0.1) : Color.secondary.opacity(0.05)
                        )
                        .cornerRadius(12)
                )
                .scaleEffect(isDragOver ? 1.02 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isDragOver)
                .onDrop(of: [.fileURL], isTargeted: $isDragOver) { providers in
                    handleDrop(providers: providers)
                    return true
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectFile()
                }
            }
            
            if let errorMessage = errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .textSelection(.enabled)
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .navigationTitle("\(screenName)")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {}
    }
    
    @ViewBuilder
    private var dataView: some View {
        VStack(alignment: .leading, spacing: 10) {
            dataHeaderView
            
            if isLoading {
                ProgressView("Loading data...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !tableRows.isEmpty {
                tableContentView
            } else {
                Text("No data available")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private var dataHeaderView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Data")
                    .font(.headline)
                Spacer()
                if rowCount > 0 {
                    Text("\(rowCount) rows × \(columnCount) columns")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Button(action: exportToCSV) {
                    Label("Export CSV", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
                .disabled(tableRows.isEmpty)
                Button(action: exportToJSON) {
                    Label("Export JSON", systemImage: "doc.text")
                }
                .buttonStyle(.bordered)
                .disabled(tableRows.isEmpty)
            }
            .padding(.horizontal)
        }
    }
    
    private var tableContentView: some View {
        ParquetTableViewRepresentable(
            rows: tableRows,
            columns: columnNames,
            columnTypes: columnTypes,
            columnWidth: 150
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private struct RowCellView: View {
        let text: String
        var body: some View {
            Text(text)
                .font(.system(.caption, design: .monospaced))
                .lineLimit(1)
                .truncationMode(.tail)
                .textSelection(.enabled)
                .help(text)
        }
    }
    
    private func tableHeaderRow(columnWidth: CGFloat) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(columnNames.enumerated()), id: \.offset) { index, columnName in
                headerCell(columnName: columnName, index: index, columnWidth: columnWidth)
            }
        }
    }
    
    @ViewBuilder
    private func headerCell(columnName: String, index: Int, columnWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(columnName)
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.bold)
                .lineLimit(1)
                .truncationMode(.tail)
            if index < columnTypes.count {
                Text(columnTypes[index])
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .padding(8)
        .frame(width: columnWidth, alignment: .leading)
        .background(AppConstants.lightGrayBackground)
        .overlay(
            Rectangle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
        )
    }
    
    private func tableDataRow(row: ParquetRow, rowIndex: Int, columnWidth: CGFloat) -> some View {
        HStack(spacing: 0) {
            ForEach(0..<columnNames.count, id: \.self) { colIndex in
                dataCell(value: row[colIndex], rowIndex: rowIndex, columnWidth: columnWidth)
            }
        }
    }
    
    private func dataCell(value: String, rowIndex: Int, columnWidth: CGFloat) -> some View {
        Text(value)
            .font(.system(.caption, design: .monospaced))
            .lineLimit(1)
            .truncationMode(.tail)
            .padding(8)
            .frame(width: columnWidth, alignment: .leading)
            .background(rowIndex % 2 == 0 ? Color.clear : Color.gray.opacity(0.05))
            .overlay(
                Rectangle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
            )
            .textSelection(.enabled)
            .help(value) // Show full text on hover
    }
    
    private var schemaView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Schema Information")
                    .font(.headline)
                
                Spacer()
                
                if !schemaRows.isEmpty {
                    Text("\(schemaRows.count) columns")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Button(action: exportSchemaToCSV) {
                    Label("Export CSV", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
                .disabled(schemaRows.isEmpty)
                
                Button(action: exportSchemaToJSON) {
                    Label("Export JSON", systemImage: "doc.text")
                }
                .buttonStyle(.bordered)
                .disabled(schemaRows.isEmpty)
            }
            .padding(.horizontal)
            
            if schemaRows.isEmpty {
                Text("No schema information available")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                SchemaTableViewRepresentable(rows: schemaRows)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private var metadataView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("File Metadata")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { copyToClipboard(metadata) }) {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                .buttonStyle(.bordered)
                .disabled(metadata.isEmpty)
            }
            .padding(.horizontal)
            
            if metadataRows.isEmpty {
                ScrollView {
                    Text(metadata.isEmpty ? "No metadata available" : metadata)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
            } else {
                MetadataTableViewRepresentable(rows: metadataRows)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private func selectFile() {
        let panel = NSOpenPanel()
        panel.title = "Select Parquet or Arrow File"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [
            UTType(filenameExtension: "parquet") ?? .data,
            UTType(filenameExtension: "arrow") ?? .data,
            UTType(filenameExtension: "feather") ?? .data,
            UTType(filenameExtension: "ipc") ?? .data
        ]
        
        if panel.runModal() == .OK, let url = panel.url {
            loadFile(url)
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        guard let provider = providers.first else { return }
        
        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (data, error) in
            if let error = error {
                print("Error loading dropped item: \(error)")
                return
            }
            
            guard let data = data as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil) else {
                return
            }
            
            // Check if the file has a supported extension
            let ext = url.pathExtension.lowercased()
            let supportedExtensions = ["parquet", "arrow", "feather", "ipc"]
            
            guard supportedExtensions.contains(ext) else {
                DispatchQueue.main.async {
                    self.errorMessage = "Unsupported file type. Please use .parquet, .arrow, .feather, or .ipc files."
                }
                return
            }
            
            // Load the file on the main thread
            DispatchQueue.main.async {
                self.loadFile(url)
            }
        }
    }
    
    private func clearFile() {
        fileURL = nil
        fileName = ""
        tableRows = []
        columnNames = []
        columnTypes = []
        schemaRows = []
        metadata = ""
        metadataRows = []
        rowCount = 0
        columnCount = 0
        fileSize = ""
        errorMessage = nil
        selectedRows = Set<ParquetRow.ID>()
        selectedTab = "schema"
    }
    
    private func loadFile(_ url: URL) {
        fileURL = url
        fileName = url.lastPathComponent
        parquetFilePath = url.path
        isLoading = true
        errorMessage = nil
        selectedTab = "schema"
        
        // Detect file type based on extension
        let ext = url.pathExtension.lowercased()
        if ext == "parquet" {
            fileType = .parquet
        } else if ext == "arrow" || ext == "feather" || ext == "ipc" {
            fileType = .arrow
        } else {
            // Default to parquet if unknown
            fileType = .parquet
        }
        
        // Track file open event
        EventManager.shared.reportFileOpen(fileType: ext, fileName: fileName)
        
        // Get file size
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let size = attributes[.size] as? Int64 {
                fileSize = String(size)
            }
        } catch {
            print("Failed to get file attributes: \(error)")
        }
        
        Task {
            await parseFileWithParquetViewer(url)
        }
    }
    
    private func parseFileWithParquetViewer(_ url: URL) async {
        let isSecurityScoped = url.startAccessingSecurityScopedResource()
        
        defer {
            if isSecurityScoped {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            let filePath = url.path
            
            // Read schema
            let schema = try ParquetViewer.readSchema(filePath: filePath)
            
            // Read metadata
            let metadata = try ParquetViewer.readMetadata(filePath: filePath)
            
            // Read data
            let batches = try ParquetViewer.readData(filePath: filePath, batchSize: UInt(maxPreviewRows), limit: UInt(maxPreviewRows))
            
            // Process schema
            var colNames: [String] = []
            var colTypes: [String] = []
            var schemaInfoRows: [SchemaInfo] = []
            
            for field in schema.fields {
                colNames.append(field.name)
                colTypes.append(field.dataType)
                
                schemaInfoRows.append(SchemaInfo(
                    columnName: field.name,
                    dataType: field.dataType,
                    nullable: field.nullable ? "Yes" : "No"
                ))
            }
            
            // Process data from first batch
            var rows: [ParquetRow] = []
            if let firstBatch = batches.first, !firstBatch.json.isEmpty {
                // Parse JSON data
                if let jsonData = firstBatch.json.data(using: .utf8),
                   let jsonArray = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] {
                    
                    for jsonRow in jsonArray.prefix(maxPreviewRows) {
                        var rowValues: [String] = []
                        for colName in colNames {
                            if let value = jsonRow[colName] {
                                if value is NSNull {
                                    rowValues.append("NULL")
                                } else {
                                    rowValues.append(String(describing: value))
                                }
                            } else {
                                rowValues.append("")
                            }
                        }
                        rows.append(ParquetRow(values: rowValues))
                    }
                }
            }
            
            // Build metadata information
            var metadataRows: [MetadataRow] = []
            metadataRows.append(MetadataRow(key: "File Name", value: fileName))
            metadataRows.append(MetadataRow(key: "File Size", value: fileSize))
            metadataRows.append(MetadataRow(key: "Total Columns", value: String(metadata.totalFields)))
            metadataRows.append(MetadataRow(key: "Total Rows", value: String(metadata.totalRecords)))
            metadataRows.append(MetadataRow(key: "Total Row Groups", value: String(metadata.totalRowGroups)))
            metadataRows.append(MetadataRow(key: "Format Version", value: String(metadata.version)))
            
            if let createdBy = metadata.createdBy {
                metadataRows.append(MetadataRow(key: "Created By", value: createdBy))
            }
            
            // Add key-value metadata
            for kv in metadata.keyValueMetadata {
                metadataRows.append(MetadataRow(key: kv.key, value: kv.value))
            }
            
            await MainActor.run {
                self.columnNames = colNames
                self.columnTypes = colTypes
                self.columnCount = colNames.count
                self.schemaRows = schemaInfoRows
                self.tableRows = rows
                self.rowCount = Int(metadata.totalRecords)
                self.metadataRows = metadataRows
                self.metadata = self.generateMetadataText(from: metadataRows)
                self.isLoading = false
                self.selectedTab = "schema"
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load file: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    private func exportToCSV() {
        let savePanel = NSSavePanel()
        savePanel.title = "Export as CSV"
        savePanel.nameFieldStringValue = fileName.replacingOccurrences(of: ".parquet", with: ".csv")
        savePanel.allowedContentTypes = [UTType.commaSeparatedText]
        
        if savePanel.runModal() == .OK, let url = savePanel.url {
            // For export, we need to load all data - do this in a separate query
            Task {
                await exportAllDataAsCSV(to: url)
            }
        }
    }
    
    private func exportAllDataAsCSV(to url: URL) async {
        do {
            // Export current result shown in the Data tab
            var csvContent = columnNames.map { "\"\($0)\"" }.joined(separator: ",") + "\n"
            for row in tableRows {
                let line = row.values.map { "\"\($0)\"" }.joined(separator: ",")
                csvContent += line + "\n"
            }
            try csvContent.write(to: url, atomically: true, encoding: .utf8)
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to export CSV: \(error.localizedDescription)"
            }
        }
    }
    
    private func exportSchemaToCSV() {
        let savePanel = NSSavePanel()
        savePanel.title = "Export Schema as CSV"
        savePanel.nameFieldStringValue = fileName.replacingOccurrences(of: ".parquet", with: "_schema.csv")
        savePanel.allowedContentTypes = [UTType.commaSeparatedText]
        
        if savePanel.runModal() == .OK, let url = savePanel.url {
            var csvContent = "Column Name,Data Type,Nullable\n"
            
            for row in schemaRows {
                csvContent += "\"\(row.columnName)\",\"\(row.dataType)\",\"\(row.nullable)\"\n"
            }
            
            do {
                try csvContent.write(to: url, atomically: true, encoding: .utf8)
            } catch {
                self.errorMessage = "Failed to export schema: \(error.localizedDescription)"
            }
        }
    }
    
    private func exportSchemaToJSON() {
        let savePanel = NSSavePanel()
        savePanel.title = "Export Schema as JSON"
        savePanel.nameFieldStringValue = fileName.replacingOccurrences(of: ".parquet", with: "_schema.json")
        savePanel.allowedContentTypes = [UTType.json]
        
        if savePanel.runModal() == .OK, let url = savePanel.url {
            var jsonArray: [[String: String]] = []
            
            for row in schemaRows {
                let jsonObject: [String: String] = [
                    "column_name": row.columnName,
                    "data_type": row.dataType,
                    "nullable": row.nullable
                ]
                jsonArray.append(jsonObject)
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: jsonArray, options: [.prettyPrinted, .sortedKeys])
                try jsonData.write(to: url)
            } catch {
                self.errorMessage = "Failed to export schema as JSON: \(error.localizedDescription)"
            }
        }
    }
    
    private func exportToJSON() {
        let savePanel = NSSavePanel()
        savePanel.title = "Export as JSON"
        savePanel.nameFieldStringValue = fileName.replacingOccurrences(of: ".parquet", with: ".json")
        savePanel.allowedContentTypes = [UTType.json]
        
        if savePanel.runModal() == .OK, let url = savePanel.url {
            // For export, we need to load all data - do this in a separate query
            Task {
                await exportAllDataAsJSON(to: url)
            }
        }
    }
    
    private func exportAllDataAsJSON(to url: URL) async {
        do {
            // Export current result shown in the Data tab
            var jsonArray: [[String: String]] = []
            for row in tableRows {
                var jsonObject: [String: String] = [:]
                for (idx, name) in columnNames.enumerated() {
                    jsonObject[name] = row[idx]
                }
                jsonArray.append(jsonObject)
            }
            let jsonData = try JSONSerialization.data(withJSONObject: jsonArray, options: [.prettyPrinted, .sortedKeys])
            try jsonData.write(to: url)
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to export JSON: \(error.localizedDescription)"
            }
        }
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    private func generateMetadataText(from rows: [MetadataRow]) -> String {
        var text = ""
        for row in rows {
            text += "\(row.key): \(row.value)\n"
        }
        return text
    }
}

// MARK: - NSTableView-backed SwiftUI wrapper for performant reuse
fileprivate struct ParquetTableViewRepresentable: NSViewRepresentable {
    let rows: [ParquetRow]
    let columns: [String]
    let columnTypes: [String]
    let columnWidth: CGFloat

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        let tableView = NSTableView()
        tableView.usesAlternatingRowBackgroundColors = true
        tableView.allowsMultipleSelection = false
        tableView.headerView = NSTableHeaderView()
        tableView.delegate = context.coordinator
        tableView.dataSource = context.coordinator
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        tableView.selectionHighlightStyle = .none
        tableView.focusRingType = .none

        // Create columns
        for (idx, name) in columns.enumerated() {
            let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("col_\(idx)"))
            let typeSuffix = (idx < columnTypes.count && !columnTypes[idx].isEmpty) ? " (\(columnTypes[idx]))" : ""
            column.title = name + typeSuffix
            column.width = columnWidth
            column.minWidth = 60
            column.headerCell.alignment = .left
            tableView.addTableColumn(column)
        }

        scrollView.documentView = tableView
        context.coordinator.tableView = tableView
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let tableView = nsView.documentView as? NSTableView else { return }

        // Update columns if schema changed
        if tableView.numberOfColumns != columns.count {
            while tableView.tableColumns.count > 0 { tableView.removeTableColumn(tableView.tableColumns[0]) }
            for (idx, name) in columns.enumerated() {
                let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("col_\(idx)"))
                let typeSuffix = (idx < columnTypes.count && !columnTypes[idx].isEmpty) ? " (\(columnTypes[idx]))" : ""
                column.title = name + typeSuffix
                column.width = columnWidth
                column.minWidth = 60
                column.headerCell.alignment = .left
                tableView.addTableColumn(column)
            }
        }

        context.coordinator.rows = rows
        context.coordinator.columns = columns
        context.coordinator.columnTypes = columnTypes
        tableView.reloadData()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(rows: rows, columns: columns, columnTypes: columnTypes)
    }

    final class Coordinator: NSObject, NSTableViewDataSource, NSTableViewDelegate {
        var rows: [ParquetRow]
        var columns: [String]
        var columnTypes: [String]
        weak var tableView: NSTableView?

        init(rows: [ParquetRow], columns: [String], columnTypes: [String]) {
            self.rows = rows
            self.columns = columns
            self.columnTypes = columnTypes
        }

        func numberOfRows(in tableView: NSTableView) -> Int {
            rows.count
        }

        func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            guard let tableColumn = tableColumn else { return nil }
            guard let columnIndex = tableView.tableColumns.firstIndex(of: tableColumn) else { return nil }
            let identifier = NSUserInterfaceItemIdentifier("cell_\(columnIndex)")

            if let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as? NSTableCellView {
                let value = (row < rows.count) ? rows[row][columnIndex] : ""
                cell.textField?.stringValue = value
                return cell
            } else {
                let cell = NSTableCellView()
                cell.identifier = identifier
                let value = (row < rows.count) ? rows[row][columnIndex] : ""
                let textField = NSTextField()
                textField.stringValue = value
                textField.font = NSFont.monospacedSystemFont(ofSize: NSFont.smallSystemFontSize, weight: .regular)
                textField.lineBreakMode = NSLineBreakMode.byTruncatingTail
                textField.usesSingleLineMode = true
                textField.translatesAutoresizingMaskIntoConstraints = false
                textField.isEditable = false
                textField.isSelectable = true
                textField.isBordered = false
                textField.backgroundColor = NSColor.clear
                textField.allowsEditingTextAttributes = false
                textField.cell?.wraps = false
                textField.cell?.isScrollable = true
                cell.addSubview(textField)
                cell.textField = textField
                NSLayoutConstraint.activate([
                    textField.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 6),
                    textField.trailingAnchor.constraint(lessThanOrEqualTo: cell.trailingAnchor, constant: -6),
                    textField.topAnchor.constraint(equalTo: cell.topAnchor, constant: 4),
                    textField.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -4)
                ])
                return cell
            }
        }
    }
}

fileprivate struct SchemaTableViewRepresentable: NSViewRepresentable {
    let rows: [SchemaInfo]

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        let tableView = NSTableView()
        tableView.usesAlternatingRowBackgroundColors = true
        tableView.allowsMultipleSelection = false
        tableView.headerView = NSTableHeaderView()
        tableView.delegate = context.coordinator
        tableView.dataSource = context.coordinator
        tableView.rowHeight = 22
        tableView.intercellSpacing = NSSize(width: 0, height: 0)
        tableView.selectionHighlightStyle = .none
        tableView.focusRingType = .none

        let nameCol = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("name"))
        nameCol.title = "Column Name"
        nameCol.width = 500
        nameCol.headerCell.alignment = .left
        tableView.addTableColumn(nameCol)

        let typeCol = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("type"))
        typeCol.title = "Data Type"
        typeCol.width = 150
        typeCol.headerCell.alignment = .left
        tableView.addTableColumn(typeCol)

        let nullableCol = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("nullable"))
        nullableCol.title = "Nullable"
        nullableCol.width = 100
        nullableCol.headerCell.alignment = .left
        tableView.addTableColumn(nullableCol)

        scrollView.documentView = tableView
        context.coordinator.tableView = tableView
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        context.coordinator.rows = rows
        (nsView.documentView as? NSTableView)?.reloadData()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(rows: rows)
    }

    final class Coordinator: NSObject, NSTableViewDataSource, NSTableViewDelegate {
        var rows: [SchemaInfo]
        weak var tableView: NSTableView?

        init(rows: [SchemaInfo]) { self.rows = rows }

        func numberOfRows(in tableView: NSTableView) -> Int { rows.count }

        func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            guard let tableColumn = tableColumn else { return nil }
            let identifier = NSUserInterfaceItemIdentifier("schema_\(tableColumn.identifier.rawValue)")

            let text: String
            switch tableColumn.identifier.rawValue {
            case "name": text = rows[row].columnName
            case "type": text = rows[row].dataType
            case "nullable": text = rows[row].nullable
            default: text = ""
            }

            if let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = text
                return cell
            } else {
                let cell = NSTableCellView()
                cell.identifier = identifier
                let textField = NSTextField()
                textField.stringValue = text
                textField.font = NSFont.monospacedSystemFont(ofSize: NSFont.smallSystemFontSize, weight: .regular)
                textField.lineBreakMode = .byTruncatingTail
                textField.usesSingleLineMode = true
                textField.translatesAutoresizingMaskIntoConstraints = false
                textField.isEditable = false
                textField.isSelectable = true
                textField.isBordered = false
                textField.backgroundColor = NSColor.clear
                textField.allowsEditingTextAttributes = false
                textField.cell?.wraps = false
                textField.cell?.isScrollable = true
                textField.cell?.truncatesLastVisibleLine = true
                cell.addSubview(textField)
                cell.textField = textField
                NSLayoutConstraint.activate([
                    textField.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 6),
                    textField.trailingAnchor.constraint(lessThanOrEqualTo: cell.trailingAnchor, constant: -6),
                    textField.topAnchor.constraint(equalTo: cell.topAnchor, constant: 4),
                    textField.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -4)
                ])
                return cell
            }
        }
    }
}

fileprivate struct MetadataTableViewRepresentable: NSViewRepresentable {
    let rows: [MetadataRow]

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        let tableView = NSTableView()
        tableView.usesAlternatingRowBackgroundColors = true
        tableView.allowsMultipleSelection = false
        tableView.headerView = NSTableHeaderView()
        tableView.delegate = context.coordinator
        tableView.dataSource = context.coordinator
        tableView.rowHeight = 22
        tableView.intercellSpacing = NSSize(width: 0, height: 0)
        tableView.selectionHighlightStyle = .none
        tableView.focusRingType = .none

        let keyCol = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("key"))
        keyCol.title = "Key"
        keyCol.width = 300
        keyCol.headerCell.alignment = .left
        tableView.addTableColumn(keyCol)

        let valueCol = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("value"))
        valueCol.title = "Value"
        valueCol.width = 600
        valueCol.headerCell.alignment = .left
        tableView.addTableColumn(valueCol)

        scrollView.documentView = tableView
        context.coordinator.tableView = tableView
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        context.coordinator.rows = rows
        (nsView.documentView as? NSTableView)?.reloadData()
    }

    func makeCoordinator() -> Coordinator { Coordinator(rows: rows) }

    final class Coordinator: NSObject, NSTableViewDataSource, NSTableViewDelegate {
        var rows: [MetadataRow]
        weak var tableView: NSTableView?

        init(rows: [MetadataRow]) { self.rows = rows }

        func numberOfRows(in tableView: NSTableView) -> Int { rows.count }

        func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            guard let tableColumn = tableColumn else { return nil }
            let identifier = NSUserInterfaceItemIdentifier("meta_\(tableColumn.identifier.rawValue)")

            let text: String
            switch tableColumn.identifier.rawValue {
            case "key": text = rows[row].key
            case "value": text = rows[row].value
            default: text = ""
            }

            if let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = text
                return cell
            } else {
                let cell = NSTableCellView()
                cell.identifier = identifier
                let textField = NSTextField()
                textField.stringValue = text
                textField.font = NSFont.monospacedSystemFont(ofSize: NSFont.smallSystemFontSize, weight: .regular)
                textField.lineBreakMode = .byTruncatingTail
                textField.usesSingleLineMode = true
                textField.translatesAutoresizingMaskIntoConstraints = false
                textField.isEditable = false
                textField.isSelectable = true
                textField.isBordered = false
                textField.backgroundColor = NSColor.clear
                textField.allowsEditingTextAttributes = false
                textField.cell?.wraps = false
                textField.cell?.isScrollable = true
                textField.cell?.truncatesLastVisibleLine = true
                cell.addSubview(textField)
                cell.textField = textField
                NSLayoutConstraint.activate([
                    textField.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 6),
                    textField.trailingAnchor.constraint(lessThanOrEqualTo: cell.trailingAnchor, constant: -6),
                    textField.topAnchor.constraint(equalTo: cell.topAnchor, constant: 4),
                    textField.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -4)
                ])
                return cell
            }
        }
    }
}
// Safe array access extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    ParquetViewerView()
        .frame(width: 800, height: 600)
}
