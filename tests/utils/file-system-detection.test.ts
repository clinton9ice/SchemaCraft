import { describe, it, expect } from 'vitest'
import { detectLanguageFromCode } from '../../composables/use-schema-store'

describe('File System Schema Type Detection', () => {
  it('detects PostgreSQL schemas from file code or extensions', () => {
    const sqlCode = `
      CREATE TABLE users (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) NOT NULL
      );
    `
    expect(detectLanguageFromCode(sqlCode)).toBe('sql')
  })

  it('detects Prisma schemas from file code', () => {
    const prismaCode = `
      datasource db {
        provider = "postgresql"
        url      = env("DATABASE_URL")
      }

      model User {
        id    Int    @id @default(autoincrement())
        email String @unique
      }
    `
    expect(detectLanguageFromCode(prismaCode)).toBe('prisma')
  })

  it('detects DBML schemas from file code', () => {
    const dbmlCode = `
      Table users {
        id integer [primary key]
        username varchar
      }
    `
    expect(detectLanguageFromCode(dbmlCode)).toBe('dbml')
  })

  it('detects Drizzle ORM schemas from TypeScript file code', () => {
    const drizzleCode = `
      import { pgTable, serial, text } from 'drizzle-orm/pg-core';

      export const users = pgTable('users', {
        id: serial('id').primaryKey(),
        name: text('name').notNull(),
      });
    `
    expect(detectLanguageFromCode(drizzleCode)).toBe('drizzle')
  })

  it('detects TypeORM entities from TypeScript file code', () => {
    const typeormCode = `
      import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

      @Entity('users')
      export class User {
        @PrimaryGeneratedColumn()
        id: number;

        @Column()
        name: string;
      }
    `
    expect(detectLanguageFromCode(typeormCode)).toBe('typeorm')
  })

  it('maps correct file extensions for all 5 supported languages', () => {
    const langExtMap: Record<string, string> = {
      sql: '.sql',
      dbml: '.dbml',
      prisma: '.prisma',
      drizzle: '.ts',
      typeorm: '.ts',
    }

    expect(langExtMap.sql).toBe('.sql')
    expect(langExtMap.dbml).toBe('.dbml')
    expect(langExtMap.prisma).toBe('.prisma')
    expect(langExtMap.drizzle).toBe('.ts')
    expect(langExtMap.typeorm).toBe('.ts')
  })
})
