import Foundation

// MARK: - C Structs

/// C-compatible key-value pair structure
public struct CKeyValue {
    public let key: UnsafeMutablePointer<CChar>?
    public let value: UnsafeMutablePointer<CChar>?
}

/// C-compatible file metadata structure
public struct CFileMetadata {
    public let fileSize: UInt
    public let totalRecords: Int64
    public let totalFields: UInt
    public let totalRowGroups: UInt
    public let version: Int32
    public let createdBy: UnsafeMutablePointer<CChar>?
    public let keyValueMetadata: UnsafeMutablePointer<CKeyValue>?
    public let keyValueCount: UInt
}

/// C-compatible field structure
public struct CField {
    public let name: UnsafeMutablePointer<CChar>?
    public let dataType: UnsafeMutablePointer<CChar>?
    public let nullable: Int32
}

/// C-compatible schema structure
public struct CSchema {
    public let fields: UnsafeMutablePointer<CField>?
    public let numFields: UInt
}

/// C-compatible record batch structure
public struct CRecordBatch {
    public let json: UnsafeMutablePointer<CChar>?
    public let numRows: UInt
    public let numColumns: UInt
}

/// C-compatible record batch array structure
public struct CRecordBatchArray {
    public let batches: UnsafeMutablePointer<CRecordBatch>?
    public let count: UInt
}

// MARK: - C Function Declarations

@_silgen_name("parquet_viewer_read_schema")
private func parquet_viewer_read_schema(_ filePath: UnsafePointer<CChar>?) -> UnsafeMutablePointer<CSchema>?

@_silgen_name("parquet_viewer_read_metadata")
private func parquet_viewer_read_metadata(_ filePath: UnsafePointer<CChar>?) -> UnsafeMutablePointer<CFileMetadata>?

@_silgen_name("parquet_viewer_read_data")
private func parquet_viewer_read_data(_ filePath: UnsafePointer<CChar>?, _ batchSize: UInt, _ limit: UInt) -> UnsafeMutablePointer<CRecordBatchArray>?

@_silgen_name("parquet_viewer_read_data_with_projection")
private func parquet_viewer_read_data_with_projection(_ filePath: UnsafePointer<CChar>?, _ columnIndices: UnsafePointer<UInt>?, _ columnCount: UInt, _ batchSize: UInt, _ limit: UInt) -> UnsafeMutablePointer<CRecordBatchArray>?

@_silgen_name("parquet_viewer_free_schema")
private func parquet_viewer_free_schema(_ schema: UnsafeMutablePointer<CSchema>?)

@_silgen_name("parquet_viewer_free_metadata")
private func parquet_viewer_free_metadata(_ metadata: UnsafeMutablePointer<CFileMetadata>?)

@_silgen_name("parquet_viewer_free_data")
private func parquet_viewer_free_data(_ data: UnsafeMutablePointer<CRecordBatchArray>?)

@_silgen_name("parquet_viewer_sql_format")
private func parquet_viewer_sql_format(_ sql: UnsafePointer<CChar>?, _ style: Int32) -> UnsafeMutablePointer<CChar>?

@_silgen_name("parquet_viewer_free_string")
private func parquet_viewer_free_string(_ string: UnsafeMutablePointer<CChar>?)

@_silgen_name("parquet_viewer_get_last_error")
private func parquet_viewer_get_last_error() -> UnsafePointer<CChar>?

// MARK: - Swift Models

/// Swift representation of a key-value pair
public struct KeyValue {
    public let key: String
    public let value: String
    
    init(cKeyValue: CKeyValue) {
        self.key = cKeyValue.key.map { String(cString: $0) } ?? ""
        self.value = cKeyValue.value.map { String(cString: $0) } ?? ""
    }
    
    // Test initializer for unit tests
    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

/// Swift representation of file metadata
public struct FileMetadata {
    public let fileSize: UInt
    public let totalRecords: Int64
    public let totalFields: UInt
    public let totalRowGroups: UInt
    public let version: Int32
    public let createdBy: String?
    public let keyValueMetadata: [KeyValue]
    
    init(cMetadata: CFileMetadata) {
        self.fileSize = cMetadata.fileSize
        self.totalRecords = cMetadata.totalRecords
        self.totalFields = cMetadata.totalFields
        self.totalRowGroups = cMetadata.totalRowGroups
        self.version = cMetadata.version
        self.createdBy = cMetadata.createdBy.map { String(cString: $0) }
        
        if let kvPtr = cMetadata.keyValueMetadata, cMetadata.keyValueCount > 0 {
            let kvArray = Array(UnsafeBufferPointer(start: kvPtr, count: Int(cMetadata.keyValueCount)))
            self.keyValueMetadata = kvArray.map { KeyValue(cKeyValue: $0) }
        } else {
            self.keyValueMetadata = []
        }
    }
    
    // Test initializer for unit tests
    init(fileSize: UInt, totalRecords: Int64, totalFields: UInt, totalRowGroups: UInt, version: Int32, createdBy: String?, keyValueMetadata: [KeyValue]) {
        self.fileSize = fileSize
        self.totalRecords = totalRecords
        self.totalFields = totalFields
        self.totalRowGroups = totalRowGroups
        self.version = version
        self.createdBy = createdBy
        self.keyValueMetadata = keyValueMetadata
    }
}

/// Swift representation of a schema field
public struct SchemaField {
    public let name: String
    public let dataType: String
    public let nullable: Bool
}

/// Swift representation of a schema
public struct Schema {
    public let fields: [SchemaField]
    public let numFields: UInt
    
    init(cSchema: CSchema) {
        self.numFields = cSchema.numFields
        
        if let fieldsPtr = cSchema.fields, cSchema.numFields > 0 {
            let fieldsArray = Array(UnsafeBufferPointer(start: fieldsPtr, count: Int(cSchema.numFields)))
            self.fields = fieldsArray.map { cField in
                let name = cField.name.map { String(cString: $0) } ?? ""
                let dataType = cField.dataType.map { String(cString: $0) } ?? ""
                let nullable = cField.nullable != 0
                return SchemaField(name: name, dataType: dataType, nullable: nullable)
            }
        } else {
            self.fields = []
        }
    }
    
    // Test initializer for unit tests
    init(fields: [SchemaField], numFields: UInt) {
        self.fields = fields
        self.numFields = numFields
    }
    
    // Convenience initializer for backward compatibility
    init(fields: [(name: String, dataType: String, nullable: Bool)], numFields: UInt) {
        self.fields = fields.map { SchemaField(name: $0.name, dataType: $0.dataType, nullable: $0.nullable) }
        self.numFields = numFields
    }
}

/// Swift representation of a record batch
public struct RecordBatch {
    public let json: String
    public let numRows: UInt
    public let numColumns: UInt
    
    init(cBatch: CRecordBatch) {
        self.json = cBatch.json.map { String(cString: $0) } ?? "{}"
        self.numRows = cBatch.numRows
        self.numColumns = cBatch.numColumns
    }
    
    // Test initializer for unit tests
    init(json: String, numRows: UInt, numColumns: UInt) {
        self.json = json
        self.numRows = numRows
        self.numColumns = numColumns
    }
}

/// SQL formatting style
public enum SqlFormatStyle: Int32 {
    case minimal = 0
    case beautify = 1
}

// MARK: - Main ParquetViewer Class

public class ParquetViewer {
    
    /// Read schema from a Parquet or Arrow file
    /// - Parameter filePath: Path to the file
    /// - Returns: Schema information
    /// - Throws: ParquetViewerError if the operation fails
    public static func readSchema(filePath: String) throws -> Schema {
        guard let cFilePath = filePath.cString(using: .utf8) else {
            throw ParquetViewerError.invalidFilePath
        }
        
        let cSchemaPtr = cFilePath.withUnsafeBufferPointer { buffer in
            parquet_viewer_read_schema(buffer.baseAddress)
        }
        
        guard let cSchemaPtr = cSchemaPtr else {
            throw ParquetViewerError.operationFailed
        }
        
        defer {
            parquet_viewer_free_schema(cSchemaPtr)
        }
        
        let cSchema = cSchemaPtr.pointee
        return Schema(cSchema: cSchema)
    }
    
    /// Read metadata from a Parquet or Arrow file
    /// - Parameter filePath: Path to the file
    /// - Returns: File metadata
    /// - Throws: ParquetViewerError if the operation fails
    public static func readMetadata(filePath: String) throws -> FileMetadata {
        guard let cFilePath = filePath.cString(using: .utf8) else {
            throw ParquetViewerError.invalidFilePath
        }
        
        let cMetadataPtr = cFilePath.withUnsafeBufferPointer { buffer in
            parquet_viewer_read_metadata(buffer.baseAddress)
        }
        
        guard let cMetadataPtr = cMetadataPtr else {
            throw ParquetViewerError.operationFailed
        }
        
        defer {
            parquet_viewer_free_metadata(cMetadataPtr)
        }
        
        let cMetadata = cMetadataPtr.pointee
        return FileMetadata(cMetadata: cMetadata)
    }
    
    /// Read data from a Parquet or Arrow file
    /// - Parameters:
    ///   - filePath: Path to the file
    ///   - batchSize: Optional batch size (0 for default)
    ///   - limit: Optional maximum number of rows to read (0 for no limit)
    /// - Returns: Array of record batches
    /// - Throws: ParquetViewerError if the operation fails
    public static func readData(filePath: String, batchSize: UInt = 0, limit: UInt = 0) throws -> [RecordBatch] {
        guard let cFilePath = filePath.cString(using: .utf8) else {
            throw ParquetViewerError.invalidFilePath
        }
        
        let cDataPtr = cFilePath.withUnsafeBufferPointer { buffer in
            parquet_viewer_read_data(buffer.baseAddress, batchSize, limit)
        }
        
        guard let cDataPtr = cDataPtr else {
            throw ParquetViewerError.operationFailed
        }
        
        defer {
            parquet_viewer_free_data(cDataPtr)
        }
        
        let cData = cDataPtr.pointee
        
        if let batchesPtr = cData.batches, cData.count > 0 {
            let batchesArray = Array(UnsafeBufferPointer(start: batchesPtr, count: Int(cData.count)))
            return batchesArray.map { RecordBatch(cBatch: $0) }
        } else {
            return []
        }
    }
    
    /// Read data with projection from a Parquet or Arrow file
    /// - Parameters:
    ///   - filePath: Path to the file
    ///   - columnIndices: Array of column indices to read
    ///   - batchSize: Optional batch size (0 for default)
    ///   - limit: Optional maximum number of rows to read (0 for no limit)
    /// - Returns: Array of record batches
    /// - Throws: ParquetViewerError if the operation fails
    public static func readDataWithProjection(filePath: String, columnIndices: [UInt], batchSize: UInt = 0, limit: UInt = 0) throws -> [RecordBatch] {
        guard let cFilePath = filePath.cString(using: .utf8) else {
            throw ParquetViewerError.invalidFilePath
        }
        
        let cDataPtr = cFilePath.withUnsafeBufferPointer { buffer in
            columnIndices.withUnsafeBufferPointer { indicesBuffer in
                parquet_viewer_read_data_with_projection(buffer.baseAddress, indicesBuffer.baseAddress, UInt(columnIndices.count), batchSize, limit)
            }
        }
        
        guard let cDataPtr = cDataPtr else {
            throw ParquetViewerError.operationFailed
        }
        
        defer {
            parquet_viewer_free_data(cDataPtr)
        }
        
        let cData = cDataPtr.pointee
        
        if let batchesPtr = cData.batches, cData.count > 0 {
            let batchesArray = Array(UnsafeBufferPointer(start: batchesPtr, count: Int(cData.count)))
            return batchesArray.map { RecordBatch(cBatch: $0) }
        } else {
            return []
        }
    }
    
    /// Format SQL query with specified style
    /// - Parameters:
    ///   - sql: SQL query string to format
    ///   - style: Formatting style (minimal or beautify)
    /// - Returns: Formatted SQL string
    /// - Throws: ParquetViewerError if the operation fails
    public static func formatSql(_ sql: String, style: SqlFormatStyle = .beautify) throws -> String {
        guard let cSql = sql.cString(using: .utf8) else {
            throw ParquetViewerError.invalidData
        }
        
        let formattedPtr = cSql.withUnsafeBufferPointer { buffer in
            parquet_viewer_sql_format(buffer.baseAddress, style.rawValue)
        }
        
        guard let formattedPtr = formattedPtr else {
            throw ParquetViewerError.operationFailed
        }
        
        defer {
            parquet_viewer_free_string(formattedPtr)
        }
        
        return String(cString: formattedPtr)
    }
    
    /// Get the last error message from the library
    /// - Returns: Error message string
    public static func getLastError() -> String {
        guard let errorPtr = parquet_viewer_get_last_error() else {
            return "Unknown error"
        }
        return String(cString: errorPtr)
    }
}

// MARK: - Error Types

public enum ParquetViewerError: Error, LocalizedError {
    case invalidFilePath
    case operationFailed
    case fileNotFound
    case invalidData
    case sqlParsingError
    
    public var errorDescription: String? {
        switch self {
        case .invalidFilePath:
            return "Invalid file path"
        case .operationFailed:
            return "Operation failed: \(ParquetViewer.getLastError())"
        case .fileNotFound:
            return "File not found"
        case .invalidData:
            return "Invalid data format"
        case .sqlParsingError:
            return "SQL parsing error: \(ParquetViewer.getLastError())"
        }
    }
}
