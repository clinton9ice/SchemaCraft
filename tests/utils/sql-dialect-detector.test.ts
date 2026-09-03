import { describe, it, expect } from 'vitest'
import { readFileSync } from 'node:fs'
import { resolve } from 'node:path'
import { detectSqlDialect } from '../../utils/sql-dialect-detector'

describe('SQL Dialect Detector', () => {
  it('correctly detects MySQL dialect in vestnan1_db.sql', () => {
    const filePath = resolve(process.cwd(), 'vestnan1_db.sql')
    const sql = readFileSync(filePath, 'utf-8')

    const result = detectSqlDialect(sql)

    expect(result.isMysql).toBe(true)
    expect(result.dialect).toBe('mysql')
    expect(result.confidence).toBeGreaterThan(0.7)
    expect(result.reasons.length).toBeGreaterThan(3)
    expect(result.reasons.some(r => r.includes('Backtick'))).toBe(true)
    expect(result.reasons.some(r => r.includes('ENGINE'))).toBe(true)
  })

  it('correctly detects MySQL dialect in add_columns.sql due to USE and DESCRIBE', () => {
    const filePath = resolve(process.cwd(), 'add_columns.sql')
    const sql = readFileSync(filePath, 'utf-8')

    const result = detectSqlDialect(sql)

    expect(result.isMysql).toBe(true)
    expect(result.dialect).toBe('mysql')
    expect(result.reasons.some(r => r.includes('USE'))).toBe(true)
  })

  it('identifies standard PostgreSQL DDL as non-MySQL', () => {
    const postgresSql = `
      CREATE TABLE users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(50) NOT NULL UNIQUE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
      CREATE TABLE posts (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        title TEXT NOT NULL
      );
    `

    const result = detectSqlDialect(postgresSql)

    expect(result.isMysql).toBe(false)
    expect(result.dialect).toBe('postgres')
    expect(result.confidence).toBe(0)
    expect(result.reasons).toEqual([])
  })

  it('returns unknown for empty or whitespace-only code', () => {
    const result = detectSqlDialect('   \n  \t ')

    expect(result.isMysql).toBe(false)
    expect(result.dialect).toBe('unknown')
    expect(result.confidence).toBe(0)
  })
})
