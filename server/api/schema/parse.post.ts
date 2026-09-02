import pgQuery, { type PgQueryParser } from 'pg-query-emscripten'
import { compilePgAst } from '~/utils/sql-compiler'
import { parseDbml, validateDbmlCode } from '~/utils/dbml-compiler'
import { parsePrisma, validatePrismaCode } from '~/utils/prisma-compiler'
import { compileTypeORM } from '~/utils/typeorm-compiler'
import { compileDrizzle } from '~/utils/drizzle-compiler'

let parserInstance: PgQueryParser | null = null

async function getParser(): Promise<PgQueryParser> {
  if (parserInstance) return parserInstance
  const init = (pgQuery as unknown as { default?: () => Promise<PgQueryParser> }).default || pgQuery
  parserInstance = typeof init === 'function' ? await init() : (init as PgQueryParser)
  return parserInstance
}

export default defineEventHandler(async event => {
  const body = await readBody<{
    sql?: string
    language?: 'sql' | 'dbml' | 'prisma' | 'typeorm' | 'drizzle'
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

  // Handle Drizzle Parser
  if (
    language === 'drizzle' ||
    /\b(?:pgTable|mysqlTable|sqliteTable)\s*\(|from\s+['"]drizzle-orm/im.test(code)
  ) {
    try {
      const compiled = compileDrizzle(code)
      return {
        success: true,
        tables: compiled.tables,
        relations: compiled.relations,
        error: null,
      }
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Drizzle parsing error'
      return {
        success: false,
        tables: [],
        relations: [],
        error: { message: msg, lineNumber: 1, column: 1 },
      }
    }
  }

  // Handle TypeORM Parser
  if (language === 'typeorm' || /@Entity\b|from\s+['"]typeorm['"]/im.test(code)) {
    try {
      const compiled = compileTypeORM(code)
      return {
        success: true,
        tables: compiled.tables,
        relations: compiled.relations,
        error: null,
      }
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'TypeORM parsing error'
      return {
        success: false,
        tables: [],
        relations: [],
        error: { message: msg, lineNumber: 1, column: 1 },
      }
    }
  }

  // Handle Prisma Schema Parser
  if (language === 'prisma' || /^\s*model\s+[a-zA-Z0-9_]+\s*\{/im.test(code)) {
    const validation = validatePrismaCode(code)
    if (!validation.valid && validation.error) {
      return {
        success: false,
        tables: [],
        relations: [],
        error: validation.error,
      }
    }

    try {
      const compiled = parsePrisma(code)
      return {
        success: true,
        tables: compiled.tables,
        relations: compiled.relations,
        error: null,
      }
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Prisma parsing error'
      return {
        success: false,
        tables: [],
        relations: [],
        error: { message: msg, lineNumber: 1, column: 1 },
      }
    }
  }

  // Handle DBML Parser
  if (language === 'dbml' || /^\s*(?:Table|Ref\s*:)/i.test(code)) {
    const validation = validateDbmlCode(code)
    if (!validation.valid && validation.error) {
      return {
        success: false,
        tables: [],
        relations: [],
        error: validation.error,
      }
    }

    try {
      const compiled = parseDbml(code)
      return {
        success: true,
        tables: compiled.tables,
        relations: compiled.relations,
        error: null,
      }
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'DBML parsing error'
      return {
        success: false,
        tables: [],
        relations: [],
        error: { message: msg, lineNumber: 1, column: 1 },
      }
    }
  }

  // Handle SQL / PostgreSQL Parser
  try {
    const parser = await getParser()
    const result = parser.parse(code)

    if (result && result.error) {
      return {
        success: false,
        tables: [],
        relations: [],
        error: result.error,
      }
    }

    // Compile AST into diagram data structure
    const compiled = compilePgAst(result.parse_tree || [])

    return {
      success: true,
      tables: compiled.tables,
      relations: compiled.relations,
      error: null,
    }
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : 'SQL parsing error'
    return {
      success: false,
      tables: [],
      relations: [],
      error: { message: msg },
    }
  }
})
