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

function transformMysqlToPostgres(sql) {
  let transformed = sql
    .replace(/`([^`]+)`/g, '"$1"')
    .replace(/\bAUTO_INCREMENT\b/gi, '')
    .replace(/\bENGINE\s*=\s*\w+\b/gi, '')
    .replace(/\bDEFAULT\s+CHARSET\s*=\s*\w+\b/gi, '')
    .replace(/\bCOLLATE\s*=\s*\w+\b/gi, '')
    .replace(/\bTINYINT\s*\(\d+\)/gi, 'SMALLINT')
    .replace(/\bTINYINT\b/gi, 'SMALLINT')
    .replace(/\bMEDIUMINT\b/gi, 'INTEGER')
    .replace(/\bINT\s*\(\d+\)/gi, 'INTEGER')
    .replace(/\bBIGINT\s*\(\d+\)/gi, 'BIGINT')
    .replace(/\bDATETIME\b/gi, 'TIMESTAMP')
    .replace(/\bDOUBLE\b/gi, 'DOUBLE PRECISION')
    .replace(/\bLONGTEXT\b/gi, 'TEXT')
    .replace(/\bMEDIUMTEXT\b/gi, 'TEXT')
    .replace(/\bTINYTEXT\b/gi, 'TEXT')
    .replace(/\bUNSIGNED\b/gi, '')
  return { sql: transformed }
}

function sanitizeSqlDdl(sql) {
  return sql
    .replace(/^\s*INSERT\s+INTO[\s\S]*?;/gim, '')
    .replace(/^\s*UPDATE[\s\S]*?;/gim, '')
    .replace(/^\s*DELETE\s+FROM[\s\S]*?;/gim, '')
    .replace(/^\s*LOCK\s+TABLES[\s\S]*?;/gim, '')
    .replace(/^\s*UNLOCK\s+TABLES[\s\S]*?;/gim, '')
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
    } else if (ext === 'prisma') {
      language = 'prisma'
    } else if (ext === 'ts' || ext === 'js') {
      language = /@Entity\b/.test(rawContent) ? 'typeorm' : 'drizzle'
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
