import { describe, it, expect } from 'vitest'
import { readFileSync } from 'node:fs'
import { resolve } from 'node:path'
import pgQuery, { type PgQueryParser } from 'pg-query-emscripten'
import { transformMysqlToPostgres } from '../../utils/mysql-to-postgres-transformer'
import { compilePgAst } from '../../utils/sql-compiler'

describe('MySQL to PostgreSQL DDL Transformer', () => {
  it('successfully transforms vestnan1_db.sql into valid PostgreSQL DDL', async () => {
    const filePath = resolve(process.cwd(), 'vestnan1_db.sql')
    const rawSql = readFileSync(filePath, 'utf-8')

    const result = transformMysqlToPostgres(rawSql)

    expect(result.sql).toBeTruthy()
    expect(result.tableCount).toBe(3)
    expect(result.changesApplied.length).toBeGreaterThan(0)

    // Verify backticks are eliminated
    expect(result.sql.includes('`')).toBe(false)

    // Verify MySQL storage options are removed
    expect(result.sql.includes('ENGINE=InnoDB')).toBe(false)
    expect(result.sql.includes('DEFAULT CHARSET')).toBe(false)
    expect(result.sql.includes('COLLATE=utf8mb4_general_ci')).toBe(false)

    // Verify MySQL conditional comments are removed
    expect(result.sql.includes('/*!40101')).toBe(false)

    // Verify INSERT INTO statements are stripped
    expect(result.sql.includes('INSERT INTO')).toBe(false)

    // Verify column conversions
    expect(result.sql.includes('SERIAL')).toBe(true)
    expect(result.sql.includes('longtext')).toBe(false)
    expect(result.sql.includes('TEXT')).toBe(true)

    // Verify preserved mixed-case identifier quotes
    expect(result.sql.includes('"Track_ID"')).toBe(true)
    expect(result.sql.includes('"loginCookie"')).toBe(true)

    // Validate directly against pg-query-emscripten (the real PostgreSQL parser)
    const init =
      (pgQuery as unknown as { default?: () => Promise<PgQueryParser> }).default || pgQuery
    const parser = typeof init === 'function' ? await init() : (init as PgQueryParser)

    const parseResult = parser.parse(result.sql)

    // Must parse with ZERO syntax errors in PostgreSQL!
    expect(parseResult.error).toBeNull()

    const compiled = compilePgAst(parseResult.parse_tree || [])
    expect(compiled.tables.length).toBe(3)
    const tableNames = compiled.tables.map(t => t.name)
    expect(tableNames).toContain('message')
    expect(tableNames).toContain('product')
    expect(tableNames).toContain('users')
  })

  it('transforms add_columns.sql by stripping USE and DESCRIBE while keeping ALTER TABLE', async () => {
    const filePath = resolve(process.cwd(), 'add_columns.sql')
    const rawSql = readFileSync(filePath, 'utf-8')

    const result = transformMysqlToPostgres(rawSql)

    expect(result.sql).toBeTruthy()
    expect(result.sql.includes('USE ')).toBe(false)
    expect(result.sql.includes('DESCRIBE ')).toBe(false)
    expect(result.sql.includes('ALTER TABLE product ADD COLUMN alert TEXT')).toBe(true)
    expect(result.sql.includes('ALTER TABLE product ADD COLUMN rand VARCHAR(250)')).toBe(true)

    // Validate with pg-query-emscripten
    const init =
      (pgQuery as unknown as { default?: () => Promise<PgQueryParser> }).default || pgQuery
    const parser = typeof init === 'function' ? await init() : (init as PgQueryParser)

    const parseResult = parser.parse(result.sql)
    expect(parseResult.error).toBeNull()
  })

  it('handles empty input gracefully', () => {
    const result = transformMysqlToPostgres('')
    expect(result.sql).toBe('')
    expect(result.tableCount).toBe(0)
    expect(result.changesApplied).toEqual([])
  })
})
