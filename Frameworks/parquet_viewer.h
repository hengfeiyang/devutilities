#ifndef PARQUET_VIEWER_H
#define PARQUET_VIEWER_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Key-value pair structure
 */
typedef struct CKeyValue {
    char* key;
    char* value;
} CKeyValue;

/**
 * File metadata structure
 */
typedef struct CFileMetadata {
    size_t file_size;
    int64_t total_records;
    size_t total_fields;
    size_t total_row_groups;
    int32_t version;
    char* created_by;  // NULL if not available
    CKeyValue* key_value_metadata;  // Array of key-value pairs, NULL if none
    size_t key_value_count;  // Number of key-value pairs
} CFileMetadata;

/**
 * Schema field structure
 */
typedef struct CField {
    char* name;
    char* data_type;
    int nullable;  // 1 for nullable, 0 for not nullable
} CField;

/**
 * Schema structure
 */
typedef struct CSchema {
    CField* fields;  // Array of fields
    size_t num_fields;
} CSchema;

/**
 * Record batch structure
 */
typedef struct CRecordBatch {
    char* json;  // JSON representation of the batch
    size_t num_rows;
    size_t num_columns;
} CRecordBatch;

/**
 * Array of record batches
 */
typedef struct CRecordBatchArray {
    CRecordBatch* batches;
    size_t count;
} CRecordBatchArray;

/**
 * Read schema from a Parquet or Arrow file
 * 
 * @param file_path Path to the file (null-terminated string)
 * @return Pointer to CSchema on success, NULL on error. 
 *         Caller must free with parquet_viewer_free_schema()
 */
CSchema* parquet_viewer_read_schema(const char* file_path);

/**
 * Read metadata from a Parquet or Arrow file
 * 
 * @param file_path Path to the file (null-terminated string)
 * @return Pointer to CFileMetadata on success, NULL on error.
 *         Caller must free with parquet_viewer_free_metadata()
 */
CFileMetadata* parquet_viewer_read_metadata(const char* file_path);

/**
 * Read data from a Parquet or Arrow file
 * 
 * @param file_path Path to the file (null-terminated string)
 * @param batch_size Batch size for reading (0 for default)
 * @param limit Maximum number of rows to read (0 for no limit)
 * @return Pointer to CRecordBatchArray on success, NULL on error.
 *         Caller must free with parquet_viewer_free_data()
 */
CRecordBatchArray* parquet_viewer_read_data(const char* file_path, size_t batch_size, size_t limit);

/**
 * Read data with projection from a Parquet or Arrow file
 * 
 * @param file_path Path to the file (null-terminated string)
 * @param column_indices Array of column indices to read
 * @param column_count Number of column indices
 * @param batch_size Batch size for reading (0 for default)
 * @param limit Maximum number of rows to read (0 for no limit)
 * @return Pointer to CRecordBatchArray on success, NULL on error.
 *         Caller must free with parquet_viewer_free_data()
 */
CRecordBatchArray* parquet_viewer_read_data_with_projection(const char* file_path, const size_t* column_indices, size_t column_count, size_t batch_size, size_t limit);

/**
 * Free a CSchema structure
 * 
 * @param schema Pointer to the schema to free
 */
void parquet_viewer_free_schema(CSchema* schema);

/**
 * Free a CFileMetadata structure
 * 
 * @param metadata Pointer to the metadata to free
 */
void parquet_viewer_free_metadata(CFileMetadata* metadata);

/**
 * Free a CRecordBatchArray structure
 * 
 * @param data Pointer to the data array to free
 */
void parquet_viewer_free_data(CRecordBatchArray* data);

/**
 * Get the last error message
 * 
 * @return Pointer to error message string, or NULL if no error.
 *         Caller should NOT free this string.
 */
const char* parquet_viewer_get_last_error(void);

#ifdef __cplusplus
}
#endif

#endif /* PARQUET_VIEWER_H */