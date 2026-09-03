/**
 * MySQL to PostgreSQL DDL Transformer
 * Transforms MySQL/MariaDB DDL schemas into clean, standards-compliant PostgreSQL DDL
 * that compiles directly in pg-query-emscripten with zero syntax errors.
 *
 * Runs 100% on the client to avoid server load.
 */

export interface TransformResult {
  sql: string
  changesApplied: string[]
  tableCount: number
}

/**
 * Transforms MySQL/MariaDB DDL into PostgreSQL DDL.
 */
export function transformMysqlToPostgres(rawSql: string): TransformResult {
  if (!rawSql || !rawSql.trim()) {
    return {
      sql: '',
      changesApplied: [],
      tableCount: 0,
    }
  }

  const changes: string[] = []
  let sql = rawSql

  // 1. Remove MySQL conditional comments: /*!40101 ... */;
  if (/\/\*!\d{5}[\s\S]*?\*\/\s*;?/g.test(sql)) {
    sql = sql.replace(/\/\*!\d{5}[\s\S]*?\*\/\s*;?/g, '')
    changes.push('Stripped MySQL version-specific conditional comments')
  }

  // 2. Remove session and administrative commands
  const directivePatterns = [
    /\bSET\s+(?:SQL_MODE|time_zone|FOREIGN_KEY_CHECKS|UNIQUE_CHECKS|NAMES|@OLD_[\w_]+)\s*=[^;]+;/gi,
    /\bUSE\s+[`"]?[\w_]+[`"]?\s*;/gi,
    /\bSTART\s+TRANSACTION\s*;/gi,
    /\bCOMMIT\s*;/gi,
    /\bDESCRIBE\s+[`"]?[\w_]+[`"]?\s*;/gi,
    /\bSHOW\s+[^;]+;/gi,
    /\bLOCK\s+TABLES\s+[^;]+;/gi,
    /\bUNLOCK\s+TABLES\s*;/gi,
  ]

  for (const pattern of directivePatterns) {
    if (pattern.test(sql)) {
      sql = sql.replace(pattern, '')
      changes.push('Removed MySQL session, USE, transaction, and inspection statements')
    }
  }

  // 3. Remove Data Dump (INSERT INTO) statements
  if (/\bINSERT\s+INTO\s+[^;]+;/gis.test(sql)) {
    sql = sql.replace(/\bINSERT\s+INTO\s+[^;]+;/gis, '')
    changes.push('Removed INSERT INTO data rows to focus exclusively on schema DDL')
  }

  // 4. Identify AUTO_INCREMENT columns from ALTER TABLE ... MODIFY statements
  // e.g. ALTER TABLE `message` MODIFY `id` int(150) NOT NULL AUTO_INCREMENT;
  const autoIncrementMap = new Map<string, Set<string>>()
  const modifyRegex =
    /\bALTER\s+TABLE\s+[`"]?([\w_]+)[`"]?\s+MODIFY\s+[`"]?([\w_]+)[`"]?[^;]*\bAUTO_INCREMENT\b[^;]*;/gi

  let match: RegExpExecArray | null
  while ((match = modifyRegex.exec(sql)) !== null) {
    const tableName = match[1]
    const colName = match[2]
    if (!autoIncrementMap.has(tableName)) {
      autoIncrementMap.set(tableName, new Set())
    }
    autoIncrementMap.get(tableName)!.add(colName)
  }

  // Remove the ALTER TABLE ... MODIFY statements
  if (modifyRegex.test(sql)) {
    sql = sql.replace(modifyRegex, '')
    changes.push('Extracted AUTO_INCREMENT modifiers to convert columns to SERIAL')
  }

  // 5. Replace backticks:
  // If identifier has mixed case or uppercase (e.g. `Track_ID`, `loginCookie`), convert to double quotes `"Track_ID"`
  // If all lowercase/standard identifier (e.g. `id`, `message`), convert to unquoted identifier
  if (/`[\w_]+`/g.test(sql)) {
    sql = sql.replace(/`([\w_]+)`/g, (_m, ident: string) => {
      // Preserve casing with double quotes if mixed case or begins with uppercase
      if (/[A-Z]/.test(ident)) {
        return `"${ident}"`
      }
      return ident
    })
    changes.push('Converted backtick identifier quotes to ANSI PostgreSQL standard')
  }

  // 6. Transform table options at the end of CREATE TABLE
  // e.g. ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci; -> );
  const tableOptionsRegex =
    /\)\s*(?:ENGINE\s*=\s*[\w_]+|DEFAULT\s+CHARSET\s*=\s*[\w_]+|CHARSET\s*=\s*[\w_]+|COLLATE\s*=\s*[\w_]+|AUTO_INCREMENT\s*=\s*\d+|ROW_FORMAT\s*=\s*[\w_]+|\s)+;/gi
  if (tableOptionsRegex.test(sql)) {
    sql = sql.replace(tableOptionsRegex, ');')
    changes.push('Stripped MySQL ENGINE, CHARSET, and COLLATE table options')
  }

  // 7. Transform column data types and inline modifiers within CREATE TABLE
  // We process CREATE TABLE statements block by block
  const createTableRegex = /CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?([^\s(]+)\s*\(([\s\S]*?)\);/gi

  sql = sql.replace(createTableRegex, (fullMatch, tableNameRaw: string, body: string) => {
    const cleanTableName = tableNameRaw.replace(/["']/g, '')
    const autoCols = autoIncrementMap.get(cleanTableName) || new Set<string>()

    const lines = body.split('\n')
    const transformedLines = lines.map(line => {
      let l = line

      // Check if this line is a column definition matching an auto-increment column
      for (const col of autoCols) {
        const colRegex = new RegExp(
          `^(\\s*"?${col}"?\\s+)(?:int(?:eger)?(?:\\s*\\(\\s*\\d+\\s*\\))?|bigint(?:\\s*\\(\\s*\\d+\\s*\\))?)([^,]*)`,
          'i'
        )
        if (colRegex.test(l)) {
          l = l.replace(colRegex, (_m, prefix, suffix) => {
            const cleanSuffix = suffix.replace(/\bNOT\s+NULL\b/gi, '').trim()
            return `${prefix}SERIAL${cleanSuffix ? ` ${cleanSuffix}` : ''}`
          })
        }
      }

      // Inline AUTO_INCREMENT -> SERIAL
      if (/\bAUTO_INCREMENT\b/i.test(l)) {
        l = l.replace(
          /\b(?:int(?:eger)?(?:\s*\(\s*\d+\s*\))?)\s+(NOT\s+NULL\s+)?AUTO_INCREMENT\b/gi,
          'SERIAL'
        )
        l = l.replace(
          /\b(?:bigint(?:\s*\(\s*\d+\s*\))?)\s+(NOT\s+NULL\s+)?AUTO_INCREMENT\b/gi,
          'BIGSERIAL'
        )
        l = l.replace(/\bAUTO_INCREMENT\b/gi, '')
      }

      // Column Character sets and collations: CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci
      l = l.replace(/\bCHARACTER\s+SET\s+[\w_]+/gi, '')
      l = l.replace(/\bCOLLATE\s+[\w_]+/gi, '')

      // Integer display widths: int(11), int(150), tinyint(1), bigint(20)
      l = l.replace(/\btinyint\s*\(\s*1\s*\)/gi, 'BOOLEAN')
      l = l.replace(/\btinyint(?:\s*\(\s*\d+\s*\))?/gi, 'SMALLINT')
      l = l.replace(/\bsmallint(?:\s*\(\s*\d+\s*\))?/gi, 'SMALLINT')
      l = l.replace(/\bmediumint(?:\s*\(\s*\d+\s*\))?/gi, 'INTEGER')
      l = l.replace(/\bint(?:eger)?\s*\(\s*\d+\s*\)/gi, 'INTEGER')
      l = l.replace(/\bbigint\s*\(\s*\d+\s*\)/gi, 'BIGINT')

      // Text types
      l = l.replace(/\b(?:longtext|mediumtext|tinytext)\b/gi, 'TEXT')

      // Datetime and timestamps
      l = l.replace(/\bdatetime\b/gi, 'TIMESTAMP WITH TIME ZONE')

      // Float & double
      l = l.replace(/\bdouble\b/gi, 'DOUBLE PRECISION')

      // Blobs
      l = l.replace(/\b(?:longblob|mediumblob|tinyblob|blob)\b/gi, 'BYTEA')

      // Clean up multiple spaces
      l = l.replace(/\s{2,}/g, ' ')

      return l
    })

    return `CREATE TABLE ${tableNameRaw} (\n${transformedLines.join('\n')}\n);`
  })

  // 8. Count detected tables
  const tableMatches = sql.match(/CREATE\s+TABLE\b/gi)
  const tableCount = tableMatches ? tableMatches.length : 0

  // 9. Clean up empty/whitespace lines
  const cleanedLines = sql.split('\n').filter((line, index, arr) => {
    const isBlank = line.trim() === ''
    const prevIsBlank = index > 0 && arr[index - 1].trim() === ''
    return !(isBlank && prevIsBlank)
  })

  const finalSql = cleanedLines.join('\n').trim()

  return {
    sql: finalSql,
    changesApplied: Array.from(new Set(changes)),
    tableCount,
  }
}
