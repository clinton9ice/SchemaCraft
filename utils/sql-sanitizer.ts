/**
 * SQL DDL Sanitizer
 * Strips non-DDL content from SQL to prevent WebAssembly heap exhaustion
 * ("offset is out of bounds") while preserving all structural statements:
 * CREATE TABLE, ALTER TABLE, CREATE INDEX, constraints, SET clauses, etc.
 */

/**
 * Strips INSERT INTO data statements, SQL single-line comments (--) and block
 * comments, and blank lines from SQL so the WASM parser only receives meaningful DDL.
 *
 * This is critical for large files where comment padding can inflate a
 * 22KB DDL payload to 500KB+, exceeding WebAssembly linear memory limits.
 */
export function sanitizeSqlDdl(rawSql: string): string {
  if (!rawSql || !rawSql.trim()) return ''

  let sql = rawSql

  // 1. Strip block comments /* ... */ and MySQL conditional comments /*!40101 ... */
  sql = sql.replace(/\/\*[\s\S]*?\*\//g, ' ')

  // 2. Strip standalone INSERT INTO ... ; statements (may span multiple lines)
  sql = sql.replace(/(?:^|\n)\s*INSERT\s+INTO\s+[\s\S]*?;\s*(?=\n|$)/gi, '\n')

  // 3. Strip data modification statements: UPDATE, DELETE, TRUNCATE
  sql = sql.replace(
    /(?:^|\n)\s*(?:UPDATE|DELETE\s+FROM|TRUNCATE(?:\s+TABLE)?)\b[\s\S]*?;\s*(?=\n|$)/gi,
    '\n'
  )

  // 4. Strip table locks and transaction boundaries: LOCK/UNLOCK TABLES, COMMIT, BEGIN, START TRANSACTION
  sql = sql.replace(
    /(?:^|\n)\s*(?:LOCK\s+TABLES|UNLOCK\s+TABLES|COMMIT|BEGIN(?:\s+TRANSACTION)?|START\s+TRANSACTION)\b[^;]*;\s*(?=\n|$)/gi,
    '\n'
  )

  // 5. Strip database/schema creation and switching commands: USE, CREATE/DROP DATABASE, CREATE/DROP SCHEMA
  sql = sql.replace(
    /(?:^|\n)\s*(?:USE\s+[`"]?[\w_]+[`"]?|(?:CREATE|DROP)\s+DATABASE\s+[^;]+|(?:CREATE|DROP)\s+SCHEMA\s+[^;]+)\s*;\s*(?=\n|$)/gi,
    '\n'
  )

  // 6. Strip session and inspection directives: SET, SHOW, DESCRIBE, EXPLAIN
  sql = sql.replace(
    /(?:^|\n)\s*(?:SET\s+[^;]+|SHOW\s+[^;]+|DESCRIBE\s+[^;]+|EXPLAIN\s+[^;]+)\s*;\s*(?=\n|$)/gi,
    '\n'
  )

  // 7. Strip single-line SQL comments (-- ...) line by line, keeping the line
  //    only if there is non-comment DDL content on it
  sql = sql
    .split('\n')
    .map(line => {
      // Remove inline -- comment portion, keep anything before it
      const commentIdx = line.indexOf('--')
      return commentIdx === -1 ? line : line.slice(0, commentIdx)
    })
    .filter(line => line.trim().length > 0) // drop now-empty lines
    .join('\n')

  return sql.trim()
}
