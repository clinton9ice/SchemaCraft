import { defineEventHandler, readBody } from 'h3'
import pgQuery, { type PgQueryParser } from 'pg-query-emscripten'
import { compilePgAst } from '~/utils/sql-compiler'
import { parseDbml, validateDbmlCode, sanitizeDbml } from '~/utils/dbml-compiler'
import { parsePrisma, validatePrismaCode, sanitizePrisma } from '~/utils/prisma-compiler'
import { compileTypeORM } from '~/utils/typeorm-compiler'
import { compileDrizzle } from '~/utils/drizzle-compiler'
import { transformMysqlToPostgres } from '~/utils/mysql-to-postgres-transformer'
import { detectSqlDialect } from '~/utils/sql-dialect-detector'
import { sanitizeSqlDdl } from '~/utils/sql-sanitizer'

export interface ParseResult {
  success: boolean
  tables: unknown[]
  relations: unknown[]
  error: unknown
}

function hashPayload(lang: string, code: string): string {
  let h = 5381
  const str = `${lang}::${code}`
  for (let i = 0; i < str.length; i++) {
    h = (h * 33) ^ str.charCodeAt(i)
  }
  return (h >>> 0).toString(36)
}

/**
 * Creates a fresh PgQueryParser WebAssembly instance.
 * Re-instantiating per parse is critical because pg-query-emscripten retains
 * linear memory allocations across parses; reusing a singleton instance
 * corrupts internal function pointer tables (Ma[...] is not a function) on repeated complex DDL.
 */
async function createFreshParser(): Promise<PgQueryParser> {
  const init = (pgQuery as unknown as { default?: () => Promise<PgQueryParser> }).default || pgQuery
  return typeof init === 'function' ? await init() : (init as PgQueryParser)
}

async function executeParse(language: string, code: string): Promise<ParseResult> {
  const startTime = performance.now()
  const rawBytes = Buffer.byteLength(code, 'utf8')
  console.info(`[parse:start] language=${language} raw_bytes=${rawBytes}`)

  // Handle Drizzle Parser
  if (
    language === 'drizzle' ||
    /\b(?:pgTable|mysqlTable|sqliteTable)\s*\(|from\s+['"]drizzle-orm/im.test(code)
  ) {
    try {
      console.info('[parse] Running Drizzle compiler')
      const compiled = compileDrizzle(code)
      console.info(
        `[parse] Drizzle OK: tables=${compiled.tables.length} relations=${compiled.relations.length}`
      )
      return {
        success: true,
        tables: compiled.tables,
        relations: compiled.relations,
        error: null,
      }
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Drizzle parsing error'
      console.error('[parse] Drizzle error:', msg, JSON.stringify(code, null, 2))
      return {
        success: false,
        tables: [],
        relations: [],
        error: { message: msg },
      }
    }
  }

  // Handle TypeORM Parser
  if (
    language === 'typeorm' ||
    /\b(?:@Entity|@Column|@PrimaryGeneratedColumn)\s*\(|from\s+['"]typeorm/im.test(code)
  ) {
    try {
      console.info('[parse] Running TypeORM compiler')
      const compiled = compileTypeORM(code)
      console.info(
        `[parse] TypeORM OK: tables=${compiled.tables.length} relations=${compiled.relations.length}`
      )
      return {
        success: true,
        tables: compiled.tables,
        relations: compiled.relations,
        error: null,
      }
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'TypeORM parsing error'
      console.error('[parse] TypeORM error:', msg, JSON.stringify(code, null, 2))
      return {
        success: false,
        tables: [],
        relations: [],
        error: { message: msg },
      }
    }
  }

  // Handle DBML Parser
  if (
    language === 'dbml' ||
    /^\s*(?:Table\s+[\w"]+|Ref(?:\s+[\w_]+)?\s*:|Enum\s+[\w"]+|TableGroup\s+[\w"]+)/im.test(code)
  ) {
    try {
      console.info('[parse] Running DBML compiler')
      const codeToParse = sanitizeDbml(code)
      const val = validateDbmlCode(codeToParse)
      if (!val.valid && val.error) {
        console.warn('[parse] DBML validation error:', val.error.message)
        return {
          success: false,
          tables: [],
          relations: [],
          error: val.error,
        }
      }

      const compiled = parseDbml(codeToParse)
      console.info(
        `[parse] DBML OK: tables=${compiled.tables.length} relations=${compiled.relations.length}`
      )
      return {
        success: true,
        tables: compiled.tables,
        relations: compiled.relations,
        error: null,
      }
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'DBML parsing error'
      console.error('[parse] DBML error:', msg, JSON.stringify(code, null, 2))
      return {
        success: false,
        tables: [],
        relations: [],
        error: { message: msg },
      }
    }
  }

  // Handle Prisma Parser
  if (
    language === 'prisma' ||
    /^\s*(?:model\s+[a-zA-Z0-9_]+\s*\{|datasource\s+\w+\s*\{|generator\s+\w+\s*\{)/im.test(code)
  ) {
    try {
      console.info('[parse] Running Prisma compiler')
      const codeToParse = sanitizePrisma(code)
      const val = validatePrismaCode(codeToParse)
      if (!val.valid && val.error) {
        console.warn('[parse] Prisma validation error:', val.error.message)
        return {
          success: false,
          tables: [],
          relations: [],
          error: val.error,
        }
      }

      const compiled = parsePrisma(codeToParse)
      console.info(
        `[parse] Prisma OK: tables=${compiled.tables.length} relations=${compiled.relations.length}`
      )
      return {
        success: true,
        tables: compiled.tables,
        relations: compiled.relations,
        error: null,
      }
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Prisma parsing error'
      console.error('[parse] Prisma error:', msg, JSON.stringify(code, null, 2))
      return {
        success: false,
        tables: [],
        relations: [],
        error: { message: msg },
      }
    }
  }

  // Handle SQL / PostgreSQL / MySQL Parser
  try {
    const isMysqlDialect =
      language === 'mysql' || (language === 'sql' && detectSqlDialect(code).isMysql)

    // Sanitize: strip comments, blank lines, and INSERT data before WASM parse.
    // For MySQL, transform first then sanitize; for all others sanitize directly.
    const codeToParse =
      language === 'mysql'
        ? sanitizeSqlDdl(transformMysqlToPostgres(code).sql)
        : sanitizeSqlDdl(code)

    const sanitizedBytes = Buffer.byteLength(codeToParse, 'utf8')
    console.info(
      `[parse:sql] isMysql=${isMysqlDialect} ` +
        `raw_bytes=${rawBytes} ` +
        `sanitized_bytes=${sanitizedBytes}`
    )

    // Fresh WebAssembly parser instance for every parse
    const parser = await createFreshParser()
    const result = parser.parse(codeToParse)

    if (result && result.error) {
      console.warn('[parse:sql-syntax-error]', result.error)
      return {
        success: false,
        tables: [],
        relations: [],
        error: {
          ...result.error,
          isMysql: isMysqlDialect,
        },
      }
    }

    // Compile AST into diagram data structure
    const compiled = compilePgAst(result.parse_tree || [])
    const elapsed = (performance.now() - startTime).toFixed(1)
    console.info(
      `[parse:done] SQL OK: tables=${compiled.tables.length} ` +
        `relations=${compiled.relations.length} in ${elapsed}ms`
    )

    return {
      success: true,
      tables: compiled.tables,
      relations: compiled.relations,
      error: null,
    }
  } catch (err: unknown) {
    const elapsed = (performance.now() - startTime).toFixed(1)
    let msg = err instanceof Error ? err.message : 'SQL parsing error'
    console.error(
      `[parse:error] SQL exception in ${elapsed}ms:`,
      msg,
      JSON.stringify(code, null, 2)
    )
    if (msg.includes('offset is out of bounds') || msg.includes('is not a function')) {
      msg =
        'Query exceeds WebAssembly memory limit. Non-DDL statements have been stripped; please ensure only structural CREATE/ALTER TABLE statements are present.'
    }
    return {
      success: false,
      tables: [],
      relations: [],
      error: { message: msg },
    }
  }
}

// Nitro cached function: persists parsed AST responses using Nitro caching engine
const parseSchemaCached =
  typeof defineCachedFunction === 'function'
    ? defineCachedFunction(
        async (language: string, code: string): Promise<ParseResult> => {
          return await executeParse(language, code)
        },
        {
          maxAge: 60 * 60 * 24 * 7, // 7 days
          name: 'schema-parse',
          getKey: (language: string, code: string) => hashPayload(language, code),
        }
      )
    : async (language: string, code: string): Promise<ParseResult> => {
        return await executeParse(language, code)
      }

export default defineEventHandler(async event => {
  const startTime = performance.now()
  const body = await readBody<{
    sql?: string
    language?: 'sql' | 'mysql' | 'dbml' | 'prisma' | 'typeorm' | 'drizzle'
  }>(event)
  const code = body?.sql || ''
  const language = body?.language || 'sql'

  if (!code.trim()) {
    return {
      success: true,
      tables: [],
      relations: [],
      error: null,
    }
  }

  const elapsed = (performance.now() - startTime).toFixed(1)
  const result = await parseSchemaCached(language, code)
  console.info(`[parse:completed] language=${language} elapsed=${elapsed}ms`)
  return result
})
