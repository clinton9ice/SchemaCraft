import { describe, it, expect } from 'vitest'
import {
  compileDrizzle,
  tablesToDrizzle,
  drizzleToSql,
  drizzleToDbml,
  drizzleToPrisma,
  drizzleToTypeORM,
} from '../../utils/drizzle-compiler'

describe('Drizzle ORM Compiler', () => {
  const sampleDrizzle = `
    import { pgTable, serial, varchar, text, integer, boolean, timestamp } from 'drizzle-orm/pg-core'

    export const users = pgTable('users', {
      id: serial('id').primaryKey(),
      username: varchar('username', { length: 50 }).notNull().unique(),
      email: varchar('email', { length: 255 }).notNull().unique(),
      bio: text('bio'),
      isActive: boolean('is_active').default(true),
      createdAt: timestamp('created_at').defaultNow(),
    })

    export const posts = pgTable('posts', {
      id: serial('id').primaryKey(),
      userId: integer('user_id').notNull().references(() => users.id),
      title: varchar('title', { length: 255 }).notNull(),
      content: text('content'),
    })
  `

  it('should extract tables and columns from Drizzle code (compileDrizzle)', () => {
    const result = compileDrizzle(sampleDrizzle)

    expect(result.tables.length).toBe(2)

    const userTable = result.tables.find((t) => t.name === 'users')
    expect(userTable).toBeDefined()

    const idCol = userTable?.columns.find((c) => c.name === 'id')
    expect(idCol?.isPrimaryKey).toBe(true)

    const usernameCol = userTable?.columns.find((c) => c.name === 'username')
    expect(usernameCol?.type).toBe('varchar(50)')
    expect(usernameCol?.isUnique).toBe(true)
    expect(usernameCol?.isNullable).toBe(false)

    const bioCol = userTable?.columns.find((c) => c.name === 'bio')
    expect(bioCol?.type).toBe('text')
    expect(bioCol?.isNullable).toBe(true)

    const activeCol = userTable?.columns.find((c) => c.name === 'is_active')
    expect(activeCol?.defaultValue).toBe('true')

    const createdCol = userTable?.columns.find((c) => c.name === 'created_at')
    expect(createdCol?.defaultValue).toBe('now()')
  })

  it('should extract foreign key references and relations (compileDrizzle)', () => {
    const result = compileDrizzle(sampleDrizzle)

    const postTable = result.tables.find((t) => t.name === 'posts')
    expect(postTable).toBeDefined()

    const userFkCol = postTable?.columns.find((c) => c.name === 'user_id')
    expect(userFkCol?.isForeignKey).toBe(true)
    expect(userFkCol?.references).toEqual({ table: 'users', column: 'id' })

    const rel = result.relations.find((r) => r.fromTable === 'posts' && r.toTable === 'users')
    expect(rel).toBeDefined()
    expect(rel?.fromColumn).toBe('user_id')
    expect(rel?.toColumn).toBe('id')
  })

  it('should generate Drizzle code from tables and relations (tablesToDrizzle)', () => {
    const tables = [
      {
        name: 'categories',
        columns: [
          { name: 'id', type: 'integer', isPrimaryKey: true, isNullable: false, isUnique: false, isForeignKey: false },
          { name: 'name', type: 'varchar(60)', isPrimaryKey: false, isNullable: false, isUnique: true, isForeignKey: false },
          { name: 'description', type: 'text', isPrimaryKey: false, isNullable: true, isUnique: false, isForeignKey: false },
        ],
      },
    ]

    const drizzleCode = tablesToDrizzle(tables)
    expect(drizzleCode).toContain("import { pgTable, serial, varchar, text } from 'drizzle-orm/pg-core'")
    expect(drizzleCode).toContain("export const categories = pgTable('categories', {")
    expect(drizzleCode).toContain("id: serial('id').primaryKey()")
    expect(drizzleCode).toContain("name: varchar('name', { length: 60 }).notNull().unique()")
    expect(drizzleCode).toContain("description: text('description')")
  })

  it('should convert Drizzle code to standard SQL DDL (drizzleToSql)', () => {
    const sql = drizzleToSql(sampleDrizzle)
    expect(sql).toContain('CREATE TABLE users')
    expect(sql).toContain('CREATE TABLE posts')
    expect(sql).toContain('REFERENCES')
  })

  it('should convert Drizzle code to DBML (drizzleToDbml)', () => {
    const dbml = drizzleToDbml(sampleDrizzle)
    expect(dbml).toContain('Table users {')
    expect(dbml).toContain('Table posts {')
    expect(dbml).toContain('ref: > users.id')
  })

  it('should convert Drizzle code to Prisma Schema (drizzleToPrisma)', () => {
    const prisma = drizzleToPrisma(sampleDrizzle)
    expect(prisma).toContain('model Users {')
    expect(prisma).toContain('model Posts {')
    expect(prisma).toContain('@relation')
  })

  it('should convert Drizzle code to TypeORM Entities (drizzleToTypeORM)', () => {
    const typeorm = drizzleToTypeORM(sampleDrizzle)
    expect(typeorm).toContain("@Entity('users')")
    expect(typeorm).toContain('export class Users {')
    expect(typeorm).toContain('@PrimaryGeneratedColumn()')
    expect(typeorm).toContain("@Entity('posts')")
    expect(typeorm).toContain('@ManyToOne(() => Users)')
  })
})
