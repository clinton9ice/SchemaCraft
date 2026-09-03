import fs from 'node:fs'
import path from 'node:path'
import { defineEventHandler } from 'h3'
import { detectSqlDialect } from '~/utils/sql-dialect-detector'
import { transformMysqlToPostgres } from '~/utils/mysql-to-postgres-transformer'
import { sanitizeSqlDdl } from '~/utils/sql-sanitizer'
import { sanitizeDbml } from '~/utils/dbml-compiler'
import { sanitizeTypeScript } from '~/utils/ts-sanitizer'
import { sanitizePrisma } from '~/utils/prisma-compiler'
import type { SupportedLanguage } from '~/composables/use-schema-store'

export interface SampleFileInfo {
  fileName: string
  baseName: string
  ext: string
  language: SupportedLanguage
  content: string
}

let cachedSampleFiles: SampleFileInfo[] | null = null

export default defineEventHandler((): SampleFileInfo[] => {
  if (cachedSampleFiles) {
    return cachedSampleFiles
  }

  const sampleDir = path.resolve(process.cwd(), 'sample-db-files')
  if (!fs.existsSync(sampleDir)) {
    return []
  }

  const entries = fs.readdirSync(sampleDir)
  const items: SampleFileInfo[] = []

  for (const entry of entries) {
    if (entry.startsWith('.') || entry === 'README.md') {
      continue
    }

    const fullPath = path.join(sampleDir, entry)
    const stat = fs.statSync(fullPath)
    if (!stat.isFile()) {
      continue
    }

    const rawContent = fs.readFileSync(fullPath, 'utf8')
    const parsedPath = path.parse(entry)
    const ext = parsedPath.ext.replace(/^\./, '').toLowerCase()
    const baseName = parsedPath.name

    let language: SupportedLanguage = 'sql'
    let sanitizedContent = rawContent

    if (ext === 'dbml') {
      language = 'dbml'
      sanitizedContent = sanitizeDbml(rawContent)
    } else if (ext === 'prisma') {
      language = 'prisma'
      sanitizedContent = sanitizePrisma(rawContent)
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

    items.push({
      fileName: entry,
      baseName,
      ext,
      language,
      content: sanitizedContent,
    })
  }

  // Sort alphabetically by file name
  items.sort((a, b) => a.fileName.localeCompare(b.fileName))
  cachedSampleFiles = items
  return items
})
