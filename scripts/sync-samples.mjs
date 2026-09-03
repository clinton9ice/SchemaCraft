import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)
const rootDir = path.resolve(__dirname, '..')

const sampleSourceDir = path.resolve(rootDir, 'sample-db-files')
const publicSampleDir = path.resolve(rootDir, 'public', 'sample-db-files')

function detectSqlDialect(sql) {
  const isMysql =
    /AUTO_INCREMENT/i.test(sql) ||
    /ENGINE\s*=\s*\w+/i.test(sql) ||
    /`\w+`/i.test(sql) ||
    /TINYINT|MEDIUMINT|DATETIME/i.test(sql)
  return { isMysql }
}

function transformMysqlToPostgres(rawSql) {
  let sql = rawSql

  // 1. Remove MySQL conditional comments: /*!40101 ... */;
  sql = sql.replace(/\/\*!\d{5}[\s\S]*?\*\/\s*;?/g, '')

  // 2. Remove session and administrative commands
  const directivePatterns = [
    /\bSET\s+(?:SQL_MODE|time_zone|FOREIGN_KEY_CHECKS|UNIQUE_CHECKS|NAMES|@OLD_[\w_]+)\s*=[^;]+;/gi,
    /\bUSE\s+[`"]?[\w_]+[`"]?\s*;/gi,
    /\b(?:CREATE|DROP)\s+DATABASE\s+[^;]+;/gi,
    /\bSTART\s+TRANSACTION\s*;/gi,
    /\bCOMMIT\s*;/gi,
    /\bDESCRIBE\s+[`"]?[\w_]+[`"]?\s*;/gi,
    /\bSHOW\s+[^;]+;/gi,
    /\bLOCK\s+TABLES\s+[^;]+;/gi,
    /\bUNLOCK\s+TABLES\s*;/gi,
  ]

  for (const pattern of directivePatterns) {
    sql = sql.replace(pattern, '')
  }

  // 3. Remove Data Dump (INSERT INTO) statements
  sql = sql.replace(/\bINSERT\s+INTO\s+[^;]+;/gis, '')

  // 4. Extract AUTO_INCREMENT modifiers
  const modifyRegex =
    /\bALTER\s+TABLE\s+[`"]?([\w_]+)[`"]?\s+MODIFY\s+[`"]?([\w_]+)[`"]?[^;]*\bAUTO_INCREMENT\b[^;]*;/gi
  sql = sql.replace(modifyRegex, '')

  // 5. Replace backticks with ANSI quotes
  sql = sql.replace(/`([\w_]+)`/g, (_m, ident) => {
    if (/[A-Z]/.test(ident)) {
      return `"${ident}"`
    }
    return ident
  })

  // 6. Strip table engine and charset options
  const tableOptionsRegex =
    /\)\s*(?:ENGINE\s*=\s*[\w_]+|DEFAULT\s+CHARSET\s*=\s*[\w_]+|CHARSET\s*=\s*[\w_]+|COLLATE\s*=\s*[\w_]+|AUTO_INCREMENT\s*=\s*\d+|ROW_FORMAT\s*=\s*[\w_]+|\s)+;/gi
  sql = sql.replace(tableOptionsRegex, ');')

  // 7. Process CREATE TABLE statements line by line
  const createTableRegex = /CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?([^\s(]+)\s*\(([\s\S]*?)\);/gi
  sql = sql.replace(createTableRegex, (fullMatch, tableNameRaw, body) => {
    const lines = body.split('\n')
    const transformedLines = []

    for (const line of lines) {
      let l = line.trim()
      if (!l) continue

      if (/^(?:FULLTEXT\s+|SPATIAL\s+)?(?:KEY|INDEX)\s+[`"]?[\w_]+[`"]?\s*\([^)]+\)/i.test(l)) {
        continue
      }

      if (/\bUNIQUE\s+KEY\s+[`"]?([\w_]+)[`"]?\s*\(([^)]+)\)/i.test(l)) {
        l = l.replace(
          /\bUNIQUE\s+KEY\s+[`"]?([\w_]+)[`"]?\s*\(([^)]+)\)/gi,
          'CONSTRAINT $1 UNIQUE ($2)'
        )
      } else if (/\bUNIQUE\s+KEY\s*\(([^)]+)\)/i.test(l)) {
        l = l.replace(/\bUNIQUE\s+KEY\s*\(([^)]+)\)/gi, 'UNIQUE ($1)')
      }

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

      l = l.replace(/\bCHARACTER\s+SET\s+[\w_]+/gi, '')
      l = l.replace(/\bCOLLATE\s+[\w_]+/gi, '')
      l = l.replace(/\btinyint\s*\(\s*1\s*\)/gi, 'BOOLEAN')
      l = l.replace(/\btinyint(?:\s*\(\s*\d+\s*\))?/gi, 'SMALLINT')
      l = l.replace(/\bsmallint(?:\s*\(\s*\d+\s*\))?/gi, 'SMALLINT')
      l = l.replace(/\bmediumint(?:\s*\(\s*\d+\s*\))?/gi, 'INTEGER')
      l = l.replace(/\bint(?:eger)?\s*\(\s*\d+\s*\)/gi, 'INTEGER')
      l = l.replace(/\bbigint\s*\(\s*\d+\s*\)/gi, 'BIGINT')
      l = l.replace(/\b(?:longtext|mediumtext|tinytext)\b/gi, 'TEXT')
      l = l.replace(/\bdatetime\b/gi, 'TIMESTAMP WITH TIME ZONE')
      l = l.replace(/\bdouble\b/gi, 'DOUBLE PRECISION')
      l = l.replace(/\b(?:longblob|mediumblob|tinyblob|blob)\b/gi, 'BYTEA')
      l = l.replace(/\s{2,}/g, ' ')

      transformedLines.push(`  ${l}`)
    }

    if (transformedLines.length > 0) {
      const lastIdx = transformedLines.length - 1
      if (transformedLines[lastIdx].endsWith(',')) {
        transformedLines[lastIdx] = transformedLines[lastIdx].slice(0, -1)
      }
    }

    return `CREATE TABLE ${tableNameRaw} (\n${transformedLines.join('\n')}\n);`
  })

  return { sql }
}

function sanitizeSqlDdl(rawSql) {
  if (!rawSql || !rawSql.trim()) return ''
  let sql = rawSql
  sql = sql.replace(/\/\*[\s\S]*?\*\//g, ' ')
  sql = sql.replace(/(?:^|\n)\s*INSERT\s+INTO\s+[\s\S]*?;\s*(?=\n|$)/gi, '\n')
  sql = sql.replace(
    /(?:^|\n)\s*(?:UPDATE|DELETE\s+FROM|TRUNCATE(?:\s+TABLE)?)\b[\s\S]*?;\s*(?=\n|$)/gi,
    '\n'
  )
  sql = sql.replace(
    /(?:^|\n)\s*(?:LOCK\s+TABLES|UNLOCK\s+TABLES|COMMIT|BEGIN(?:\s+TRANSACTION)?|START\s+TRANSACTION)\b[^;]*;\s*(?=\n|$)/gi,
    '\n'
  )
  sql = sql.replace(
    /(?:^|\n)\s*(?:USE\s+[`"]?[\w_]+[`"]?|(?:CREATE|DROP)\s+DATABASE\s+[^;]+|(?:CREATE|DROP)\s+SCHEMA\s+[^;]+)\s*;\s*(?=\n|$)/gi,
    '\n'
  )
  sql = sql.replace(
    /(?:^|\n)\s*(?:SET\s+[^;]+|SHOW\s+[^;]+|DESCRIBE\s+[^;]+|EXPLAIN\s+[^;]+)\s*;\s*(?=\n|$)/gi,
    '\n'
  )
  return sql
    .split('\n')
    .map(line => {
      const commentIdx = line.indexOf('--')
      return commentIdx === -1 ? line : line.slice(0, commentIdx)
    })
    .filter(line => line.trim().length > 0)
    .join('\n')
    .trim()
}

function sanitizeTypeScript(rawTs) {
  if (!rawTs || !rawTs.trim()) return ''
  const noBlock = rawTs.replace(/\/\*[\s\S]*?\*\//g, ' ')
  return noBlock
    .split('\n')
    .map(line => {
      const slashIdx = line.indexOf('//')
      return slashIdx === -1 ? line : line.slice(0, slashIdx)
    })
    .filter(line => line.trim().length > 0)
    .join('\n')
    .trim()
}

export function syncSampleFiles() {
  if (!fs.existsSync(sampleSourceDir)) {
    console.warn(`[sync-samples] Source directory not found: ${sampleSourceDir}`)
    return []
  }

  if (!fs.existsSync(publicSampleDir)) {
    fs.mkdirSync(publicSampleDir, { recursive: true })
  }

  const entries = fs.readdirSync(sampleSourceDir)
  const items = []

  for (const entry of entries) {
    if (entry.startsWith('.') || entry === 'README.md') continue

    const fullSourcePath = path.join(sampleSourceDir, entry)
    if (!fs.statSync(fullSourcePath).isFile()) continue

    const lastDotIndex = entry.lastIndexOf('.')
    const ext = lastDotIndex !== -1 ? entry.slice(lastDotIndex + 1).toLowerCase() : ''
    const baseName = lastDotIndex !== -1 ? entry.slice(0, lastDotIndex) : entry
    const rawContent = fs.readFileSync(fullSourcePath, 'utf8')

    let language = 'sql'
    let sanitizedContent = rawContent

    if (ext === 'dbml') {
      language = 'dbml'
      sanitizedContent = sanitizeTypeScript(rawContent)
    } else if (ext === 'prisma') {
      language = 'prisma'
      sanitizedContent = sanitizeTypeScript(rawContent)
    } else if (ext === 'ts' || ext === 'js') {
      language = /@Entity\b/.test(rawContent) ? 'typeorm' : 'drizzle'
      sanitizedContent = sanitizeTypeScript(rawContent)
    } else if (ext === 'sql') {
      language = 'sql'
      const dialect = detectSqlDialect(rawContent)
      if (dialect.isMysql) {
        const transformed = transformMysqlToPostgres(rawContent)
        sanitizedContent = sanitizeSqlDdl(transformed.sql)
      } else {
        sanitizedContent = sanitizeSqlDdl(rawContent)
      }
    }

    const item = {
      fileName: entry,
      baseName,
      ext,
      language,
      content: sanitizedContent,
    }

    items.push(item)

    // Copy original raw file to public directory
    const destFilePath = path.join(publicSampleDir, entry)
    fs.writeFileSync(destFilePath, rawContent, 'utf8')
  }

  items.sort((a, b) => a.fileName.localeCompare(b.fileName))

  // Write pre-compiled manifest.json to public directory
  const manifestPath = path.join(publicSampleDir, 'manifest.json')
  fs.writeFileSync(manifestPath, JSON.stringify(items, null, 2), 'utf8')

  console.info(
    `[sync-samples] Synchronized ${items.length} sample files to public/sample-db-files/ and generated manifest.json`
  )
  return items
}

// Execute immediately when run as a script
syncSampleFiles()
