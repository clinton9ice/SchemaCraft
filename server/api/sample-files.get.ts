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

function processRawFile(fileName: string, rawContent: string): SampleFileInfo | null {
  if (!fileName || fileName.startsWith('.') || fileName === 'README.md') {
    return null
  }

  const lastDotIndex = fileName.lastIndexOf('.')
  const ext = lastDotIndex !== -1 ? fileName.slice(lastDotIndex + 1).toLowerCase() : ''
  const baseName = lastDotIndex !== -1 ? fileName.slice(0, lastDotIndex) : fileName

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

  return {
    fileName,
    baseName,
    ext,
    language,
    content: sanitizedContent,
  }
}

const handler = async (): Promise<SampleFileInfo[]> => {
  if (cachedSampleFiles && cachedSampleFiles.length > 0) {
    return cachedSampleFiles
  }
  console.time('Reading sample files from serverAssets')
  console.info('[sample-files:start] Reading sample files from serverAssets')
  const items: SampleFileInfo[] = []

  // 1. Try Nitro serverAssets via useStorage (standard for Vercel/serverless builds)
  try {
    if (typeof useStorage === 'function') {
      const storage = useStorage('assets:samples')
      const keys = await storage.getKeys()
      if (keys && keys.length > 0) {
        for (const key of keys) {
          // key may be "fintech_dbml_2.dbml" or "samples:fintech_dbml_2.dbml"
          const fileName = key.includes(':') ? key.split(':').pop()! : key
          const rawContent = (await storage.getItem(key)) as string | null
          if (typeof rawContent === 'string') {
            const item = processRawFile(fileName, rawContent)
            if (item) {
              items.push(item)
            }
          }
        }
      }
    }
  } catch (error) {
    // Ignore storage error and fall back to filesystem
    console.error('[sample-files:error] Error reading sample files from serverAssets', error)
  }

  // 2. Fallback to filesystem if serverAssets yielded no files (local dev or vitest)
  if (items.length === 0) {
    const candidateDirs = [
      path.resolve(process.cwd(), 'sample-db-files'),
      path.resolve(process.cwd(), '../sample-db-files'),
      path.resolve(path.dirname(new URL(import.meta.url).pathname), '../../sample-db-files'),
    ]
    const startTime = performance.now()
    for (const sampleDir of candidateDirs) {
      if (fs.existsSync(sampleDir)) {
        const entries = fs.readdirSync(sampleDir)
        for (const entry of entries) {
          const fullPath = path.join(sampleDir, entry)
          if (!fs.statSync(fullPath).isFile()) continue

          const rawContent = fs.readFileSync(fullPath, 'utf8')
          const item = processRawFile(entry, rawContent)
          if (item) {
            items.push(item)
          }
        }
        console.info(`Found ${items.length} sample files in ${sampleDir}`)
        if (items.length > 0) break
      }
    }
    const elapsed = (performance.now() - startTime).toFixed(1)
    console.info(`[sample-files:filesystem] cachedSampleFiles=${items.length} elapsed=${elapsed}ms`)
  }

  items.sort((a, b) => a.fileName.localeCompare(b.fileName))
  cachedSampleFiles = items
  console.timeEnd('Reading sample files from serverAssets')
  return items
}

export default typeof defineCachedEventHandler === 'function'
  ? defineCachedEventHandler(handler, {
      maxAge: 60 * 60 * 24 * 30, // 30 days
      swr: true,
      name: 'sample-files',
      getKey: () => 'all',
    })
  : defineEventHandler(handler)
