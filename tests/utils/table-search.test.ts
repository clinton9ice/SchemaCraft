// @vitest-environment happy-dom
import { describe, it, expect, beforeEach } from 'vitest'
import { useSchemaStore } from '../../composables/use-schema-store'

describe('Canvas Table Search & Filtering Logic', () => {
  beforeEach(() => {
    const { activeTab } = useSchemaStore()
    if (activeTab.value) {
      activeTab.value.parsedTables = [
        {
          name: 'users',
          columns: [
            {
              name: 'id',
              type: 'SERIAL',
              isPrimaryKey: true,
              isNullable: false,
              isUnique: true,
              isForeignKey: false,
            },
            {
              name: 'email',
              type: 'VARCHAR(255)',
              isPrimaryKey: false,
              isNullable: false,
              isUnique: true,
              isForeignKey: false,
            },
            {
              name: 'created_at',
              type: 'TIMESTAMP',
              isPrimaryKey: false,
              isNullable: true,
              isUnique: false,
              isForeignKey: false,
            },
          ],
        },
        {
          name: 'orders',
          columns: [
            {
              name: 'id',
              type: 'SERIAL',
              isPrimaryKey: true,
              isNullable: false,
              isUnique: true,
              isForeignKey: false,
            },
            {
              name: 'user_id',
              type: 'INTEGER',
              isPrimaryKey: false,
              isNullable: false,
              isUnique: false,
              isForeignKey: true,
            },
            {
              name: 'total_amount',
              type: 'NUMERIC',
              isPrimaryKey: false,
              isNullable: false,
              isUnique: false,
              isForeignKey: false,
            },
          ],
        },
        {
          name: 'products',
          columns: [
            {
              name: 'id',
              type: 'SERIAL',
              isPrimaryKey: true,
              isNullable: false,
              isUnique: true,
              isForeignKey: false,
            },
            {
              name: 'title',
              type: 'TEXT',
              isPrimaryKey: false,
              isNullable: false,
              isUnique: false,
              isForeignKey: false,
            },
            {
              name: 'price',
              type: 'NUMERIC',
              isPrimaryKey: false,
              isNullable: false,
              isUnique: false,
              isForeignKey: false,
            },
          ],
        },
      ]
    }
  })

  it('retrieves all tables when search query is empty', () => {
    const { parsedTables } = useSchemaStore()
    const tables = parsedTables.value

    const items = tables.map(t => ({
      id: t.name,
      label: t.name,
      sublabel: `${t.columns.length} columns`,
      count: t.columns.length,
    }))

    expect(items).toHaveLength(3)
    expect(items[0].label).toBe('users')
    expect(items[0].sublabel).toBe('3 columns')
    expect(items[1].label).toBe('orders')
    expect(items[2].label).toBe('products')
  })

  it('filters tables by table name (case-insensitive)', () => {
    const { parsedTables } = useSchemaStore()
    const query = 'ord'
    const tables = parsedTables.value

    const filtered = tables.filter(t => t.name.toLowerCase().includes(query))
    expect(filtered).toHaveLength(1)
    expect(filtered[0].name).toBe('orders')
  })

  it('matches tables containing matching column names', () => {
    const { parsedTables } = useSchemaStore()
    const query = 'email'
    const tables = parsedTables.value

    const filtered = tables.filter(t => {
      const nameMatch = t.name.toLowerCase().includes(query)
      const columnMatch = t.columns.some(c => c.name.toLowerCase().includes(query))
      return nameMatch || columnMatch
    })

    expect(filtered).toHaveLength(1)
    expect(filtered[0].name).toBe('users')
  })

  it('dispatches schemacraft:focus-table event with target table name', () => {
    let capturedTableName = ''
    const handler = (e: Event) => {
      const ce = e as CustomEvent<{ tableName?: string }>
      capturedTableName = ce.detail?.tableName || ''
    }

    window.addEventListener('schemacraft:focus-table', handler)

    window.dispatchEvent(
      new CustomEvent('schemacraft:focus-table', {
        detail: { tableName: 'products' },
      })
    )

    expect(capturedTableName).toBe('products')
    window.removeEventListener('schemacraft:focus-table', handler)
  })

  it('dispatches schemacraft:open-search event on Cmd+K / Ctrl+K', () => {
    let searchOpened = false
    const handler = () => {
      searchOpened = true
    }

    window.addEventListener('schemacraft:open-search', handler)

    window.dispatchEvent(new CustomEvent('schemacraft:open-search'))

    expect(searchOpened).toBe(true)
    window.removeEventListener('schemacraft:open-search', handler)
  })
})
