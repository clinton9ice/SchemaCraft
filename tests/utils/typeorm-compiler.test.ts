import { describe, it, expect } from 'vitest'
import {
  compileTypeORM,
  tablesToTypeORM,
  typeormToSql,
  typeormToDbml,
  typeormToPrisma,
} from '../../utils/typeorm-compiler'
import path from 'path'

describe('TypeORM Compiler', () => {
  const entityFiles = [
    path.resolve(__dirname, '../entities/user.ts'),
    path.resolve(__dirname, '../entities/post.ts'),
    path.resolve(__dirname, '../entities/category.ts'),
    path.resolve(__dirname, '../entities/comment.ts'),
    path.resolve(__dirname, '../entities/product.ts'),
  ]

  it('should extract entities and columns', () => {
    const result = compileTypeORM(entityFiles)

    const userTable = result.tables.find(t => t.name === 'users')
    expect(userTable).toBeDefined()
    expect(userTable?.columns.find(c => c.name === 'id')?.isPrimaryKey).toBe(true)
    expect(userTable?.columns.find(c => c.name === 'username')?.isUnique).toBe(true)
    expect(userTable?.columns.find(c => c.name === 'email')?.isNullable).toBe(false)
  })

  it('should extract relations', () => {
    const result = compileTypeORM(entityFiles)

    const postTable = result.tables.find(t => t.name === 'posts')
    expect(postTable).toBeDefined()

    const userRelation = result.relations.find(
      r => r.fromTable === 'posts' && r.toTable === 'users'
    )
    expect(userRelation).toBeDefined()
    expect(userRelation?.fromColumn).toBe('user')
    expect(userRelation?.toColumn).toBe('id')
  })

  it('should map TypeScript types to SQL types', () => {
    const result = compileTypeORM(entityFiles)
    const userTable = result.tables.find(t => t.name === 'users')

    expect(userTable?.columns.find(c => c.name === 'id')?.type).toBe('integer')
    expect(userTable?.columns.find(c => c.name === 'username')?.type).toBe('varchar')
  })

  it('should handle OneToMany relationships', () => {
    const result = compileTypeORM(entityFiles)

    const categoryTable = result.tables.find(t => t.name === 'categories')
    expect(categoryTable).toBeDefined()

    // Check that the relationship is correctly identified
    const relation = result.relations.find(
      r => r.fromTable === 'posts' && r.toTable === 'categories'
    )
    expect(relation).toBeDefined()
  })

  it('should handle OneToOne relationships with JoinColumn', () => {
    const result = compileTypeORM(entityFiles)

    const commentTable = result.tables.find(t => t.name === 'comments')
    expect(commentTable).toBeDefined()

    // Check that the relationship is correctly identified
    const relation = result.relations.find(r => r.fromTable === 'comments' && r.toTable === 'posts')
    expect(relation).toBeDefined()
  })

  it('should handle custom column types', () => {
    const result = compileTypeORM(entityFiles)

    const productTable = result.tables.find(t => t.name === 'products')
    expect(productTable).toBeDefined()

    // Check that decimal type is correctly handled
    const priceColumn = productTable?.columns.find(c => c.name === 'price')
    expect(priceColumn).toBeDefined()
    expect(priceColumn?.type).toBe('decimal')
  })

  it('should handle ManyToOne relationships with custom table names', () => {
    const result = compileTypeORM(entityFiles)

    // Check that the relationship between Post and Category works correctly
    const relation = result.relations.find(
      r => r.fromTable === 'products' && r.toTable === 'categories'
    )
    expect(relation).toBeDefined()
    expect(relation?.fromColumn).toBe('category')
    expect(relation?.toColumn).toBe('id')
  })

  it('should handle complex column configurations', () => {
    const result = compileTypeORM(entityFiles)

    const userTable = result.tables.find(t => t.name === 'users')
    expect(userTable).toBeDefined()

    // Check that columns with specific configurations are handled correctly
    const emailColumn = userTable?.columns.find(c => c.name === 'email')
    expect(emailColumn).toBeDefined()
    expect(emailColumn?.isNullable).toBe(false)

    const usernameColumn = userTable?.columns.find(c => c.name === 'username')
    expect(usernameColumn).toBeDefined()
    expect(usernameColumn?.isUnique).toBe(true)
  })

  it('should generate TypeORM entity classes from CompiledTable schema (tablesToTypeORM)', () => {
    const tables = [
      {
        name: 'users',
        columns: [
          {
            name: 'id',
            type: 'integer',
            isPrimaryKey: true,
            isNullable: false,
            isUnique: false,
            isForeignKey: false,
          },
          {
            name: 'username',
            type: 'varchar',
            isPrimaryKey: false,
            isNullable: false,
            isUnique: true,
            isForeignKey: false,
          },
          {
            name: 'email',
            type: 'text',
            isPrimaryKey: false,
            isNullable: true,
            isUnique: false,
            isForeignKey: false,
          },
        ],
      },
      {
        name: 'posts',
        columns: [
          {
            name: 'id',
            type: 'integer',
            isPrimaryKey: true,
            isNullable: false,
            isUnique: false,
            isForeignKey: false,
          },
          {
            name: 'user_id',
            type: 'integer',
            isPrimaryKey: false,
            isNullable: false,
            isUnique: false,
            isForeignKey: true,
          },
          {
            name: 'title',
            type: 'varchar',
            isPrimaryKey: false,
            isNullable: false,
            isUnique: false,
            isForeignKey: false,
          },
        ],
      },
    ]

    const relations = [
      {
        from: 'posts.user_id',
        to: 'users.id',
        fromTable: 'posts',
        fromColumn: 'user_id',
        toTable: 'users',
        toColumn: 'id',
      },
    ]

    const generatedCode = tablesToTypeORM(tables, relations)
    expect(generatedCode).toContain("@Entity('users')")
    expect(generatedCode).toContain('export class Users {')
    expect(generatedCode).toContain('@PrimaryGeneratedColumn()')
    expect(generatedCode).toContain('id: number')
    expect(generatedCode).toContain('@Column({ unique: true, nullable: false })')
    expect(generatedCode).toContain("@Entity('posts')")
    expect(generatedCode).toContain('export class Posts {')
    expect(generatedCode).toContain('@ManyToOne(() => Users)')
    expect(generatedCode).toContain("@JoinColumn({ name: 'user_id' })")
  })

  it('should convert TypeORM code to SQL DDL (typeormToSql)', () => {
    const typeormCode = `
      import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm'

      @Entity('users')
      export class Users {
        @PrimaryGeneratedColumn()
        id: number

        @Column({ unique: true })
        username: string
      }

      @Entity('posts')
      export class Posts {
        @PrimaryGeneratedColumn()
        id: number

        @ManyToOne(() => Users)
        @JoinColumn({ name: 'user_id' })
        user: Users
      }
    `

    const sql = typeormToSql(typeormCode)
    expect(sql).toContain('CREATE TABLE')
    expect(sql).toContain('users')
    expect(sql).toContain('posts')
    expect(sql).toContain('REFERENCES')
  })

  it('should convert TypeORM code to DBML (typeormToDbml)', () => {
    const typeormCode = `
      import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm'

      @Entity('members')
      export class Members {
        @PrimaryGeneratedColumn()
        id: number

        @Column()
        email: string
      }
    `

    const dbml = typeormToDbml(typeormCode)
    expect(dbml).toContain('Table members {')
    expect(dbml).toContain('id integer [pk]')
    expect(dbml).toContain('email varchar')
  })

  it('should convert TypeORM code to Prisma schema (typeormToPrisma)', () => {
    const typeormCode = `
      import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm'

      @Entity('accounts')
      export class Accounts {
        @PrimaryGeneratedColumn()
        id: number

        @Column({ unique: true })
        handle: string
      }
    `

    const prisma = typeormToPrisma(typeormCode)
    expect(prisma).toContain('model Accounts {')
    expect(prisma).toContain('id Int @id @default(autoincrement())')
    expect(prisma).toContain('handle String @unique')
  })
})
