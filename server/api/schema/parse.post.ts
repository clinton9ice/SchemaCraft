import pgQuery from 'pg-query-emscripten'
import { compilePgAst } from '~/utils/sql-compiler'
import { parseDbml, validateDbmlCode } from '~/utils/dbml-compiler'
import { parsePrisma, validatePrismaCode } from '~/utils/prisma-compiler'

let parserInstance: any = null

async function getParser() {
  if (parserInstance) return parserInstance
  const init = pgQuery.default || pgQuery
  parserInstance = typeof init === 'function' ? await init() : init
  return parserInstance
}

export default defineEventHandler(async (event) => {
  const body = await readBody<{ sql?: string; language?: 'sql' | 'dbml' | 'prisma' }>(event)
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
    } catch (err: any) {
      return {
        success: false,
        tables: [],
        relations: [],
        error: { message: err?.message || 'Prisma parsing error', lineNumber: 1, column: 1 },
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
    } catch (err: any) {
      return {
        success: false,
        tables: [],
        relations: [],
        error: { message: err?.message || 'DBML parsing error', lineNumber: 1, column: 1 },
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
    const compiled = compilePgAst(result.parse_tree)

    return {
      success: true,
      tables: compiled.tables,
      relations: compiled.relations,
      error: null,
    }
  } catch (err: any) {
    return {
      success: false,
      tables: [],
      relations: [],
      error: { message: err?.message || 'SQL parsing error' },
    }
  }
})
