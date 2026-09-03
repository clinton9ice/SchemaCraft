/**
 * Global Constants for Postgres Visual Architect (SchemaCraft)
 */

/** Maximum number of active schema tabs allowed in the workspace per session */
export const MAX_WORKSPACE_TABS = 10

/** Maximum file size in bytes for schema uploads (1 Megabyte = 1,048,576 bytes) */
export const MAX_FILE_SIZE_BYTES = 1_048_576

/** Maximum number of files allowed in a single multi-file upload batch */
export const MAX_UPLOAD_FILES = 3

/**
 * Maximum safe size (in bytes) of sanitized DDL content that can be passed to the
 * WebAssembly pg-query-emscripten parser without hitting linear memory limits.
 * Content exceeding this is skipped and a soft warning is surfaced instead.
 */
export const MAX_DDL_BYTES = 100_000
