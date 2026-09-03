import { describe, it, expect } from 'vitest'
import fs from 'fs'
import path from 'path'
import { sanitizeDbml, validateDbmlCode, parseDbml } from '../../utils/dbml-compiler'

describe('DBML Compiler and Sanitizer', () => {
  it('strips block comments, // comments, -- comments and blank lines', () => {
    const raw = `
      // Top level comment
      /* Block comment */
      Project my_proj { database_type: 'PostgreSQL' }

      Table users {
        id int [pk] // inline comment
        name varchar
        -- sql style comment
      }
    `
    const sanitized = sanitizeDbml(raw)
    expect(sanitized).not.toContain('Top level comment')
    expect(sanitized).not.toContain('Block comment')
    expect(sanitized).not.toContain('inline comment')
    expect(sanitized).not.toContain('sql style comment')
    expect(sanitized).toContain('Table users {')
    expect(sanitized).toContain('id int [pk]')
  })

  it('validates single-line blocks like Project or Table without brace errors', () => {
    const code = `
      Project test { database_type: 'PostgreSQL' Note: 'Single line project' }
      Table posts {
        id int [pk]
        title varchar
      }
    `
    const res = validateDbmlCode(code)
    expect(res.valid).toBe(true)
    expect(res.error).toBeNull()
  })

  it('successfully validates and parses sample fintech_dbml_1.dbml and fintech_dbml_2.dbml', () => {
    const f1Path = path.resolve(__dirname, '../../sample-db-files/fintech_dbml_1.dbml')
    const f2Path = path.resolve(__dirname, '../../sample-db-files/fintech_dbml_2.dbml')

    if (fs.existsSync(f1Path)) {
      const raw1 = fs.readFileSync(f1Path, 'utf8')
      const sanitized1 = sanitizeDbml(raw1)
      const val1 = validateDbmlCode(sanitized1)
      expect(val1.valid).toBe(true)
      const parsed1 = parseDbml(sanitized1)
      expect(parsed1.tables.length).toBe(56)
      expect(parsed1.relations.length).toBe(94)
    }

    if (fs.existsSync(f2Path)) {
      const raw2 = fs.readFileSync(f2Path, 'utf8')
      const sanitized2 = sanitizeDbml(raw2)
      const val2 = validateDbmlCode(sanitized2)
      expect(val2.valid).toBe(true)
      const parsed2 = parseDbml(sanitized2)
      expect(parsed2.tables.length).toBe(56)
      expect(parsed2.relations.length).toBe(94)
    }
  })
})
