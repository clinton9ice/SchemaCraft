import { describe, it, expect } from 'vitest'
import fs from 'fs'
import path from 'path'
import { sanitizeTypeScript, sanitizeDrizzle, sanitizeTypeORM } from '../../utils/ts-sanitizer'
import { sanitizePrisma } from '../../utils/prisma-compiler'
import { compileDrizzle } from '../../utils/drizzle-compiler'

describe('TypeScript & Drizzle / TypeORM Sanitizer', () => {
  it('strips block comments, line comments, and blank lines while preserving strings', () => {
    const raw = `
      /* Header block comment */
      import { pgTable, text } from 'drizzle-orm/pg-core';

      // Table definition
      export const users = pgTable('users', {
        endpoint: text('endpoint').default('https://api.example.com/v1'), // url comment
        bio: text('bio'),
      });
    `
    const sanitized = sanitizeTypeScript(raw)
    expect(sanitized).not.toContain('Header block comment')
    expect(sanitized).not.toContain('// Table definition')
    expect(sanitized).not.toContain('// url comment')
    // String literal with // must be preserved
    expect(sanitized).toContain("'https://api.example.com/v1'")
    expect(sanitized).toContain("export const users = pgTable('users', {")
  })

  it('drastically reduces sample fintech_drizzle_1.ts and compiles accurately', () => {
    const fPath = path.resolve(__dirname, '../../sample-db-files/fintech_drizzle_1.ts')
    if (fs.existsSync(fPath)) {
      const raw = fs.readFileSync(fPath, 'utf8')
      const sanitized = sanitizeDrizzle(raw)

      expect(sanitized.length).toBeLessThan(raw.length * 0.1) // over 90% reduction
      const compiled = compileDrizzle(sanitized)
      expect(compiled.tables.length).toBe(56)
    }
  })

  it('sanitizes 1MB fintech_drizzle_2.ts and compiles without errors', () => {
    const fPath = path.resolve(__dirname, '../../sample-db-files/fintech_drizzle_2.ts')
    if (fs.existsSync(fPath)) {
      const raw = fs.readFileSync(fPath, 'utf8')
      const sanitized = sanitizeDrizzle(raw)

      expect(sanitized.length).toBeLessThan(50000) // down from 1MB to ~25KB
      const compiled = compileDrizzle(sanitized)
      expect(compiled.tables.length).toBe(56)
    }
  })

  it('sanitizes TypeORM entity files with comments and blank lines', () => {
    const raw = `
      // Entity comment
      /* Multi-line decorator explanation */
      @Entity('orders')
      export class Order {
        @PrimaryGeneratedColumn()
        id: number; // primary key
      }
    `
    const sanitized = sanitizeTypeORM(raw)
    expect(sanitized).not.toContain('Entity comment')
    expect(sanitized).not.toContain('Multi-line decorator explanation')
    expect(sanitized).not.toContain('// primary key')
    expect(sanitized).toContain("@Entity('orders')")
  })
})

describe('Prisma Sanitizer', () => {
  it('strips block comments, // comments, blank lines while preserving /// doc notes', () => {
    const raw = `
      // Top comment
      /* Block comment */
      datasource db {
        provider = "postgresql"
      }

      /// Users table documentation
      model User {
        id Int @id // inline id comment
        name String
      }
    `
    const sanitized = sanitizePrisma(raw)
    expect(sanitized).not.toContain('Top comment')
    expect(sanitized).not.toContain('Block comment')
    expect(sanitized).not.toContain('inline id comment')
    expect(sanitized).toContain('/// Users table documentation')
    expect(sanitized).toContain('model User {')
  })
})
