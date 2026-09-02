import { describe, it, expect } from 'vitest'
import type * as monacoType from 'monaco-editor'
import {
  getSqlCompletions,
  getDbmlCompletions,
  getPrismaCompletions,
  getTypeScriptCompletions,
  registerAllCompletions,
  getWordRange,
} from '~/utils/monaco-completions'
import type { CompiledSchema } from '~/utils/sql-compiler'

// Mock Monaco Editor instance
const mockMonaco = {
  languages: {
    CompletionItemKind: {
      Snippet: 27,
      Keyword: 14,
      TypeParameter: 25,
      Property: 10,
      Class: 7,
      Field: 5,
      Reference: 18,
      Function: 3,
    },
    CompletionItemInsertTextRule: {
      InsertAsSnippet: 4,
    },
    registerCompletionItemProvider: (_lang: string, _provider: unknown) => ({
      dispose: () => {},
    }),
  },
} as unknown as typeof monacoType

function createMockModel(content: string): monacoType.editor.ITextModel {
  const lines = content.split('\n')
  return {
    getLineContent: (line: number) => lines[line - 1] ?? '',
    getWordUntilPosition: (pos: monacoType.Position) => {
      const line = lines[pos.lineNumber - 1] ?? ''
      const before = line.slice(0, pos.column - 1)
      const match = before.match(/([a-zA-Z0-9_]+)$/)
      const word = match ? match[1] : ''
      return {
        word,
        startColumn: pos.column - word.length,
        endColumn: pos.column,
      }
    },
  } as unknown as monacoType.editor.ITextModel
}

const mockSchema: CompiledSchema = {
  tables: [
    {
      name: 'users',
      columns: [
        {
          name: 'id',
          type: 'integer',
          isPrimaryKey: true,
          isNullable: false,
          isUnique: true,
          isForeignKey: false,
        },
        {
          name: 'email',
          type: 'varchar(255)',
          isPrimaryKey: false,
          isNullable: false,
          isUnique: true,
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
          isUnique: true,
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
      ],
    },
  ],
  relations: [
    {
      from: 'posts.user_id',
      to: 'users.id',
    },
  ],
}

describe('Monaco Completions', () => {
  describe('getWordRange', () => {
    it('calculates correct column range for word under cursor', () => {
      const model = createMockModel('CREATE TABLE users')
      const pos = { lineNumber: 1, column: 19 } as monacoType.Position
      const range = getWordRange(model, pos)
      expect(range).toEqual({
        startLineNumber: 1,
        endLineNumber: 1,
        startColumn: 14,
        endColumn: 19,
      })
    })
  })

  describe('SQL Completions', () => {
    it('returns standard DDL snippets, keywords, and data types', () => {
      const model = createMockModel('CRE')
      const pos = { lineNumber: 1, column: 4 } as monacoType.Position
      const completions = getSqlCompletions(mockMonaco, model, pos)

      expect(completions.some((c) => c.label === 'CREATE TABLE')).toBe(true)
      expect(completions.some((c) => c.label === 'CREATE TABLE (UUID)')).toBe(true)
      expect(completions.some((c) => c.label === 'FOREIGN KEY')).toBe(true)
      expect(completions.some((c) => c.label === 'PRIMARY KEY')).toBe(true)
      expect(completions.some((c) => c.label === 'varchar(255)')).toBe(true)
      expect(completions.some((c) => c.label === 'uuid')).toBe(true)
    })

    it('suggests table names when typing REFERENCES', () => {
      const model = createMockModel('ALTER TABLE posts ADD FOREIGN KEY (user_id) REFERENCES ')
      const pos = { lineNumber: 1, column: 56 } as monacoType.Position
      const completions = getSqlCompletions(mockMonaco, model, pos, {
        getSchema: () => mockSchema,
      })

      expect(completions.some((c) => c.label === 'users')).toBe(true)
      expect(completions.some((c) => c.label === 'posts')).toBe(true)
    })

    it('suggests target table columns when typing REFERENCES table(', () => {
      const model = createMockModel('ALTER TABLE posts ADD FOREIGN KEY (user_id) REFERENCES users(')
      const pos = { lineNumber: 1, column: 62 } as monacoType.Position
      const completions = getSqlCompletions(mockMonaco, model, pos, {
        getSchema: () => mockSchema,
      })

      expect(completions.some((c) => c.label === 'id')).toBe(true)
      expect(completions.some((c) => c.label === 'email')).toBe(true)
    })
  })

  describe('DBML Completions', () => {
    it('returns table, enum, ref snippets and types', () => {
      const model = createMockModel('Tab')
      const pos = { lineNumber: 1, column: 4 } as monacoType.Position
      const completions = getDbmlCompletions(mockMonaco, model, pos)

      expect(completions.some((c) => c.label === 'Table')).toBe(true)
      expect(completions.some((c) => c.label === 'Ref')).toBe(true)
      expect(completions.some((c) => c.label === 'Enum')).toBe(true)
      expect(completions.some((c) => c.label === 'int')).toBe(true)
    })

    it('suggests field settings inside brackets [', () => {
      const model = createMockModel('  id int [')
      const pos = { lineNumber: 1, column: 11 } as monacoType.Position
      const completions = getDbmlCompletions(mockMonaco, model, pos)

      expect(completions.some((c) => c.label === 'pk')).toBe(true)
      expect(completions.some((c) => c.label === 'increment')).toBe(true)
      expect(completions.some((c) => c.label === 'not null')).toBe(true)
      expect(completions.some((c) => c.label === 'unique')).toBe(true)
    })

    it('suggests table.column pairs after Ref: or relational operators', () => {
      const model = createMockModel('Ref: ')
      const pos = { lineNumber: 1, column: 6 } as monacoType.Position
      const completions = getDbmlCompletions(mockMonaco, model, pos, {
        getSchema: () => mockSchema,
      })

      expect(completions.some((c) => c.label === 'users.id')).toBe(true)
      expect(completions.some((c) => c.label === 'posts.user_id')).toBe(true)
    })
  })

  describe('Prisma Completions', () => {
    it('returns model, enum, datasource snippets and scalar types', () => {
      const model = createMockModel('mod')
      const pos = { lineNumber: 1, column: 4 } as monacoType.Position
      const completions = getPrismaCompletions(mockMonaco, model, pos)

      expect(completions.some((c) => c.label === 'model')).toBe(true)
      expect(completions.some((c) => c.label === 'model (UUID)')).toBe(true)
      expect(completions.some((c) => c.label === 'datasource')).toBe(true)
      expect(completions.some((c) => c.label === 'String')).toBe(true)
      expect(completions.some((c) => c.label === 'DateTime')).toBe(true)
    })

    it('suggests attributes when typing @', () => {
      const model = createMockModel('  id Int @')
      const pos = { lineNumber: 1, column: 11 } as monacoType.Position
      const completions = getPrismaCompletions(mockMonaco, model, pos)

      expect(completions.some((c) => c.label === '@id')).toBe(true)
      expect(completions.some((c) => c.label === '@unique')).toBe(true)
      expect(completions.some((c) => c.label === '@default(autoincrement())')).toBe(true)
      expect(completions.some((c) => c.label === '@relation')).toBe(true)
      expect(completions.some((c) => c.label === '@updatedAt')).toBe(true)
    })

    it('suggests existing models as relation types', () => {
      const model = createMockModel('  user ')
      const pos = { lineNumber: 1, column: 8 } as monacoType.Position
      const completions = getPrismaCompletions(mockMonaco, model, pos, {
        getSchema: () => mockSchema,
      })

      expect(completions.some((c) => c.label === 'users')).toBe(true)
      expect(completions.some((c) => c.label === 'posts')).toBe(true)
    })
  })

  describe('TypeScript Completions (Drizzle & TypeORM)', () => {
    it('returns TypeORM and Drizzle snippets and column helpers', () => {
      const model = createMockModel('')
      const pos = { lineNumber: 1, column: 1 } as monacoType.Position
      const completions = getTypeScriptCompletions(mockMonaco, model, pos)

      expect(completions.some((c) => c.label === 'TypeORM @Entity')).toBe(true)
      expect(completions.some((c) => c.label === 'TypeORM @ManyToOne')).toBe(true)
      expect(completions.some((c) => c.label === 'Drizzle pgTable')).toBe(true)
      expect(completions.some((c) => c.label === 'Drizzle relations')).toBe(true)
      expect(completions.some((c) => c.label === "serial('id').primaryKey()")).toBe(true)
    })
  })

  describe('registerAllCompletions', () => {
    it('registers completion providers for sql, dbml, prisma, and typescript', () => {
      const disposables = registerAllCompletions(mockMonaco, () => mockSchema)
      expect(disposables).toHaveLength(4)
    })
  })
})
