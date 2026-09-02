import { describe, it, expect, vi, beforeEach } from 'vitest'
import { useSqlParser } from '../../composables/use-sql-parser'

describe('useSqlParser Composable', () => {
  beforeEach(() => {
    vi.restoreAllMocks()
  })

  it('initializes with empty schema and null error', () => {
    const { schema, error, isParsing } = useSqlParser()
    expect(schema.value.tables).toEqual([])
    expect(schema.value.relations).toEqual([])
    expect(error.value).toBeNull()
    expect(isParsing.value).toBe(false)
  })

  it('updates schema upon successful parse', async () => {
    const mockResponse = {
      success: true,
      tables: [{ name: 'users', columns: [] }],
      relations: [],
    }

    vi.stubGlobal('$fetch', vi.fn().mockResolvedValue(mockResponse))

    const { schema, error, isParsing, parseSql } = useSqlParser()
    await parseSql('CREATE TABLE users ();')

    expect(schema.value.tables.length).toBe(1)
    expect(schema.value.tables[0].name).toBe('users')
    expect(error.value).toBeNull()
    expect(isParsing.value).toBe(false)
  })

  it('sets error state when parser returns an error', async () => {
    const mockResponse = {
      success: false,
      tables: [],
      relations: [],
      error: { message: 'Syntax error at token' },
    }

    vi.stubGlobal('$fetch', vi.fn().mockResolvedValue(mockResponse))

    const { schema, error, parseSql } = useSqlParser()
    await parseSql('INVALID SQL')

    expect(error.value).toBe('Syntax error at token')
    expect(schema.value.tables).toEqual([])
  })
})
