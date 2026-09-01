function toPascalCase(name: string): string {
  if (!name) return ''
  return name.charAt(0).toUpperCase() + name.slice(1).replace(/_([a-z])/g, (_, l) => l.toUpperCase())
}

export default defineEventHandler(async (event) => {
  const body = await readBody<{
    format: 'typescript' | 'prisma' | 'dbml' | 'json'
    tables: Array<{
      name: string
      columns: Array<{
        name: string
        type: string
        isPrimaryKey: boolean
        isForeignKey: boolean
        isNullable: boolean
        isUnique: boolean
        references?: { table: string; column: string }
      }>
    }>
  }>(event)

  const format = body?.format || 'typescript'
  const tables = body?.tables || []

  if (format === 'json') {
    return {
      success: true,
      format: 'json',
      content: JSON.stringify(tables, null, 2),
    }
  }

  if (format === 'typescript') {
    const mapPgToTs = (pgType: string): string => {
      const t = pgType.toLowerCase()
      if (t.includes('int') || t.includes('serial') || t.includes('numeric') || t.includes('decimal') || t.includes('float') || t.includes('double')) {
        return 'number'
      }
      if (t.includes('bool')) return 'boolean'
      if (t.includes('json')) return 'Record<string, any>'
      if (t.includes('time') || t.includes('date')) return 'Date'
      return 'string'
    }

    const tsOutput = tables
      .map((table) => {
        const typeName = toPascalCase(table.name)
        const fields = table.columns
          .map((col) => {
            const optional = col.isNullable ? '?' : ''
            return `  ${col.name}${optional}: ${mapPgToTs(col.type)}`
          })
          .join('\n')

        return `export interface ${typeName} {\n${fields}\n}`
      })
      .join('\n\n')

    return {
      success: true,
      format: 'typescript',
      content: tsOutput || '// No tables defined',
    }
  }

  if (format === 'prisma') {
    const mapPgToPrisma = (pgType: string): string => {
      const t = pgType.toLowerCase()
      if (t.includes('int') || t.includes('serial')) return 'Int'
      if (t.includes('numeric') || t.includes('decimal') || t.includes('float') || t.includes('double')) return 'Float'
      if (t.includes('bool')) return 'Boolean'
      if (t.includes('json')) return 'Json'
      if (t.includes('time') || t.includes('date')) return 'DateTime'
      if (t.includes('uuid')) return 'String @default(uuid())'
      return 'String'
    }

    const prismaModels = tables
      .map((table) => {
        const modelName = toPascalCase(table.name)
        const fields = table.columns
          .map((col) => {
            let fieldType = mapPgToPrisma(col.type)
            const attributes: string[] = []
            if (col.isPrimaryKey) attributes.push('@id')
            if (col.type.includes('serial')) attributes.push('@default(autoincrement())')
            if (col.isUnique && !col.isPrimaryKey) attributes.push('@unique')
            if (col.isNullable && !col.isPrimaryKey) fieldType += '?'

            return `  ${col.name} ${fieldType} ${attributes.join(' ')}`.trimEnd()
          })
          .join('\n')

        return `model ${modelName} {\n${fields}\n}`
      })
      .join('\n\n')

    return {
      success: true,
      format: 'prisma',
      content: `datasource db {\n  provider = "postgresql"\n  url      = env("DATABASE_URL")\n}\n\ngenerator client {\n  provider = "prisma-client-js"\n}\n\n${prismaModels}`,
    }
  }

  if (format === 'dbml') {
    const dbmlOutput = tables
      .map((table) => {
        const cols = table.columns
          .map((col) => {
            const notes: string[] = []
            if (col.isPrimaryKey) notes.push('pk')
            if (col.isUnique && !col.isPrimaryKey) notes.push('unique')
            if (!col.isNullable && !col.isPrimaryKey) notes.push('not null')
            const noteStr = notes.length ? ` [${notes.join(', ')}]` : ''
            return `  ${col.name} ${col.type}${noteStr}`
          })
          .join('\n')

        return `Table ${table.name} {\n${cols}\n}`
      })
      .join('\n\n')

    return {
      success: true,
      format: 'dbml',
      content: dbmlOutput || '// No tables defined',
    }
  }

  return {
    success: false,
    content: '',
    error: 'Unsupported format',
  }
})
