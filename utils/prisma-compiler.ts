import type { CompiledTable, CompiledColumn, CompiledRelation, CompiledSchema } from './sql-compiler'
import type { SyntaxDiagnosticError } from './dbml-compiler'

/**
 * Validates Prisma Schema syntax with precise line/column tracking
 */
export function validatePrismaCode(prismaCode: string): { valid: boolean; error: SyntaxDiagnosticError | null } {
  if (!prismaCode || !prismaCode.trim()) {
    return { valid: true, error: null }
  }

  const lines = prismaCode.split('\n')
  let openBraces = 0
  let currentBlockStartLine = -1
  let currentBlockType = ''
  const modelNames = new Set<string>()

  for (let i = 0; i < lines.length; i++) {
    const lineNum = i + 1
    const line = lines[i]
    const trimmed = line.trim()

    if (!trimmed || trimmed.startsWith('//') || trimmed.startsWith('///')) {
      continue
    }

    // Check for unmatched quotes in line
    const doubleQuotes = (line.match(/"/g) || []).length
    if (doubleQuotes % 2 !== 0) {
      return {
        valid: false,
        error: {
          message: 'Unterminated string literal in Prisma schema',
          lineNumber: lineNum,
          column: line.lastIndexOf('"') + 1,
          endLineNumber: lineNum,
          endColumn: line.length + 1,
        },
      }
    }

    // Check for block declaration headers
    const blockMatch = trimmed.match(/^(model|enum|datasource|generator|type|view)\s+([a-zA-Z0-9_]+)\s*(\{)?/i)
    if (blockMatch) {
      const blockType = blockMatch[1].toLowerCase()
      const blockName = blockMatch[2]

      if (blockType === 'model') {
        if (modelNames.has(blockName.toLowerCase())) {
          return {
            valid: false,
            error: {
              message: `Duplicate model '${blockName}' in Prisma schema`,
              lineNumber: lineNum,
              column: line.indexOf(blockName) + 1,
              endLineNumber: lineNum,
              endColumn: line.length + 1,
            },
          }
        }
        modelNames.add(blockName.toLowerCase())
      }

      if (blockMatch[3] === '{' || line.includes('{')) {
        openBraces++
        currentBlockStartLine = lineNum
        currentBlockType = blockType
      }
      continue
    }

    // Closing brace
    if (trimmed === '}' || trimmed.startsWith('}')) {
      openBraces--
      if (openBraces < 0) {
        return {
          valid: false,
          error: {
            message: 'Unexpected closing brace `}` in Prisma schema',
            lineNumber: lineNum,
            column: line.indexOf('}') + 1,
            endLineNumber: lineNum,
            endColumn: line.indexOf('}') + 2,
          },
        }
      }
      currentBlockType = ''
      continue
    }

    // Inside block
    if (openBraces > 0) {
      if (trimmed.startsWith('@@') || trimmed.startsWith('//')) {
        continue
      }

      if (currentBlockType === 'model') {
        // Field syntax: <fieldName> <TypeName>[?] [@attributes...]
        const fieldMatch = trimmed.match(/^([a-zA-Z0-9_]+)\s+([a-zA-Z0-9_]+(?:\[\]|\?)?)(.*)$/)
        if (!fieldMatch) {
          return {
            valid: false,
            error: {
              message: `Invalid field definition '${trimmed}'. Expected: <field_name> <Type>`,
              lineNumber: lineNum,
              column: line.search(/\S/) + 1,
              endLineNumber: lineNum,
              endColumn: line.length + 1,
            },
          }
        }

        // Validate @relation syntax if present
        const rawAttrs = fieldMatch[3] || ''
        if (rawAttrs.includes('@relation(')) {
          if (!rawAttrs.includes(')')) {
            return {
              valid: false,
              error: {
                message: 'Unclosed `@relation(...)` attribute',
                lineNumber: lineNum,
                column: line.indexOf('@relation') + 1,
                endLineNumber: lineNum,
                endColumn: line.length + 1,
              },
            }
          }
        }
      } else if (currentBlockType === 'datasource' || currentBlockType === 'generator') {
        // key = value
        if (!trimmed.includes('=')) {
          return {
            valid: false,
            error: {
              message: `Invalid assignment in ${currentBlockType} block: '${trimmed}'. Expected: <key> = <value>`,
              lineNumber: lineNum,
              column: line.search(/\S/) + 1,
              endLineNumber: lineNum,
              endColumn: line.length + 1,
            },
          }
        }
      }
    } else {
      // Top level statement without block header
      return {
        valid: false,
        error: {
          message: `Unexpected statement '${trimmed}'. Expected model, enum, datasource, or generator block.`,
          lineNumber: lineNum,
          column: line.search(/\S/) + 1,
          endLineNumber: lineNum,
          endColumn: line.length + 1,
        },
      }
    }
  }

  if (openBraces > 0) {
    return {
      valid: false,
      error: {
        message: 'Unclosed block: missing closing brace `}` in Prisma schema',
        lineNumber: currentBlockStartLine > 0 ? currentBlockStartLine : lines.length,
        column: 1,
        endLineNumber: lines.length,
        endColumn: (lines[lines.length - 1]?.length || 0) + 1,
      },
    }
  }

  return { valid: true, error: null }
}

/**
 * Parses Prisma Schema (schema.prisma) into the unified CompiledSchema AST
 */
export function parsePrisma(prismaCode: string): CompiledSchema {
  const tables: CompiledTable[] = []
  const relations: CompiledRelation[] = []

  if (!prismaCode || !prismaCode.trim()) {
    return { tables, relations }
  }

  const lines = prismaCode.split('\n')

  let currentTable: CompiledTable | null = null
  let currentModelRawName = ''
  let tableDocNote: string | null = null

  for (let i = 0; i < lines.length; i++) {
    const rawLine = lines[i].trim()
    if (!rawLine) continue

    // Collect doc comments (/// Note)
    if (rawLine.startsWith('///')) {
      const note = rawLine.replace(/^\/\/\/\s*/, '').trim()
      tableDocNote = note
      continue
    }

    if (rawLine.startsWith('//')) {
      continue
    }

    // Detect model start: model User { or model Post {
    const modelMatch = rawLine.match(/^model\s+([a-zA-Z0-9_]+)\s*\{/i)
    if (modelMatch) {
      currentModelRawName = modelMatch[1]
      currentTable = {
        name: currentModelRawName.toLowerCase(),
        columns: [],
        comment: tableDocNote,
      }
      tableDocNote = null
      continue
    }

    // Detect enum start: enum Role {
    const enumMatch = rawLine.match(/^enum\s+([a-zA-Z0-9_]+)\s*\{/i)
    if (enumMatch) {
      while (i < lines.length && !lines[i].includes('}')) {
        i++
      }
      continue
    }

    // Detect model end: }
    if (rawLine === '}' && currentTable) {
      tables.push(currentTable)
      currentTable = null
      currentModelRawName = ''
      continue
    }

    // Parse inside model
    if (currentTable) {
      // Table mapping: @@map("actual_table_name")
      const mapMatch = rawLine.match(/^@@map\(["']([^"']+)["']\)/i)
      if (mapMatch) {
        currentTable.name = mapMatch[1]
        continue
      }

      if (rawLine.startsWith('@@')) {
        continue
      }

      // Parse field line: id Int @id @default(autoincrement())
      // Example: author User @relation(fields: [authorId], references: [id])
      const fieldMatch = rawLine.match(/^([a-zA-Z0-9_]+)\s+([a-zA-Z0-9_]+)(\[\]|\?)?(.*)$/)
      if (fieldMatch) {
        const fieldName = fieldMatch[1]
        const typeName = fieldMatch[2]
        const typeModifier = fieldMatch[3] || ''
        const attributesStr = fieldMatch[4] || ''

        // Check if relation attribute: @relation(fields: [authorId], references: [id])
        const relMatch = attributesStr.match(/@relation\((?:.*fields:\s*\[([^\]]+)\].*)?(?:.*references:\s*\[([^\]]+)\].*)?\)/i)
        if (relMatch && relMatch[1] && relMatch[2]) {
          const fromCol = relMatch[1].trim()
          const toCol = relMatch[2].trim()
          const targetTable = typeName.toLowerCase()

          relations.push({
            from: `${currentTable.name}.${fromCol}`,
            to: `${targetTable}.${toCol}`,
            fromTable: currentTable.name,
            fromColumn: fromCol,
            toTable: targetTable,
            toColumn: toCol,
          })
          continue
        }

        // Virtual relation field pointing to another model -> skip as physical database column
        if (typeModifier === '[]' || isPrismaCustomModel(typeName)) {
          continue
        }

        let isPk = /@id\b/i.test(attributesStr)
        let isUnq = /@unique\b/i.test(attributesStr)
        let isNullable = typeModifier === '?'
        let defaultVal: string | null = null
        const constraintsList: string[] = []

        if (isPk) constraintsList.push('PRIMARY KEY')
        if (!isNullable && !isPk) constraintsList.push('NOT NULL')
        if (isUnq && !isPk) constraintsList.push('UNIQUE')

        // Default value extraction
        const defMatch = attributesStr.match(/@default\(([^)]+)\)/i)
        if (defMatch) {
          const rawD = defMatch[1].trim()
          if (/^autoincrement\(\)$/i.test(rawD)) {
            constraintsList.push('AUTO_INCREMENT')
          } else if (/^(?:now\(\)|uuid\(\)|cuid\(\)|dbgenerated\()/i.test(rawD)) {
            defaultVal = rawD
            constraintsList.push(`DEFAULT ${defaultVal}`)
          } else {
            defaultVal = rawD.replace(/^['"]|['"]$/g, '')
            constraintsList.push(`DEFAULT ${defaultVal}`)
          }
        }

        // Map Prisma type to SQL type representation
        const sqlMappedType = mapPrismaTypeToSql(typeName, attributesStr)

        const colObj: CompiledColumn = {
          name: fieldName,
          type: sqlMappedType,
          isPrimaryKey: isPk,
          isNullable,
          isUnique: isUnq,
          isForeignKey: false,
          defaultValue: defaultVal,
          references: null,
          comment: tableDocNote,
          constraintsList,
        }

        tableDocNote = null
        currentTable.columns.push(colObj)
      }
    }
  }

  // Final Pass: Link all relations to columns and attach foreign key indicators
  for (const rel of relations) {
    const fromTable = rel.fromTable || rel.from.split('.')[0]
    const fromCol = rel.fromColumn || rel.from.split('.')[1]
    const toTable = rel.toTable || rel.to.split('.')[0]
    const toCol = rel.toColumn || rel.to.split('.')[1]

    const targetTable = tables.find((t) => t.name.toLowerCase() === fromTable.toLowerCase())
    if (targetTable) {
      const targetColumn = targetTable.columns.find(
        (c) => c.name.toLowerCase() === fromCol.toLowerCase() || toCamelCase(c.name).toLowerCase() === fromCol.toLowerCase()
      )
      if (targetColumn) {
        targetColumn.isForeignKey = true
        targetColumn.references = { table: toTable, column: toCol }
        if (!targetColumn.constraintsList?.some((cl) => cl.startsWith('REFERENCES'))) {
          targetColumn.constraintsList = targetColumn.constraintsList || []
          targetColumn.constraintsList.push(`REFERENCES ${toTable}(${toCol})`)
        }
      }
    }
  }

  return { tables, relations }
}

function isPrismaCustomModel(typeName: string): boolean {
  const primitiveTypes = new Set([
    'Int',
    'BigInt',
    'Float',
    'Decimal',
    'String',
    'Boolean',
    'DateTime',
    'Json',
    'Bytes',
    'Unsupported',
  ])
  return !primitiveTypes.has(typeName)
}

function mapPrismaTypeToSql(prismaType: string, attributesStr: string): string {
  if (/@id\b/i.test(attributesStr) && /autoincrement\(\)/i.test(attributesStr)) {
    return prismaType === 'BigInt' ? 'bigserial' : 'serial'
  }

  switch (prismaType) {
    case 'Int':
      return 'integer'
    case 'BigInt':
      return 'bigint'
    case 'Float':
    case 'Decimal':
      return 'numeric'
    case 'String':
      if (/@db\.VarChar\((\d+)\)/i.test(attributesStr)) {
        const len = attributesStr.match(/@db\.VarChar\((\d+)\)/i)?.[1]
        return `varchar(${len})`
      }
      if (/@db\.Text\b/i.test(attributesStr)) {
        return 'text'
      }
      return 'varchar(255)'
    case 'Boolean':
      return 'boolean'
    case 'DateTime':
      return 'timestamptz'
    case 'Json':
      return 'jsonb'
    case 'Bytes':
      return 'bytea'
    default:
      return prismaType.toLowerCase()
  }
}

/**
 * Converts internal CompiledTable[] and relations into clean, idiomatic Prisma Schema format
 */
export function tablesToPrisma(tables: CompiledTable[], relations?: CompiledRelation[]): string {
  if (!tables || tables.length === 0) return ''

  const lines: string[] = [
    '// Prisma Schema definition',
    'datasource db {',
    '  provider = "postgresql"',
    '  url      = env("DATABASE_URL")',
    '}',
    '',
    'generator client {',
    '  provider = "prisma-client-js"',
    '}',
    '',
  ]

  for (const table of tables) {
    const modelName = capitalizeFirst(toCamelCase(table.name))

    if (table.comment) {
      lines.push(`/// ${table.comment.replace(/\n/g, ' ')}`)
    }
    lines.push(`model ${modelName} {`)

    for (const col of table.columns) {
      const fieldName = toCamelCase(col.name)
      const prismaType = mapSqlTypeToPrisma(col.type, col.isPrimaryKey)
      const attributes: string[] = []

      if (col.isPrimaryKey) {
        attributes.push('@id')
        if (col.type === 'serial' || col.type === 'bigserial' || col.constraintsList?.includes('AUTO_INCREMENT')) {
          attributes.push('@default(autoincrement())')
        }
      }

      if (col.isUnique && !col.isPrimaryKey) {
        attributes.push('@unique')
      }

      if (col.defaultValue && !col.isPrimaryKey) {
        const rawD = String(col.defaultValue).trim()
        if (/^(?:now\(\)|CURRENT_TIMESTAMP)/i.test(rawD)) {
          attributes.push('@default(now())')
        } else if (/^gen_random_uuid\(\)/i.test(rawD)) {
          attributes.push('@default(uuid())')
        } else if (/^(?:true|false|\d+(?:\.\d+)?)$/i.test(rawD)) {
          attributes.push(`@default(${rawD})`)
        } else {
          const cleanStr = rawD.replace(/^['"`]+|['"`]+$/g, '')
          attributes.push(`@default("${cleanStr.replace(/"/g, '\\"')}")`)
        }
      }

      if (fieldName !== col.name) {
        attributes.push(`@map("${col.name}")`)
      }

      const typeOptional = col.isNullable && !col.isPrimaryKey ? '?' : ''
      const attrStr = attributes.length ? ` ${attributes.join(' ')}` : ''

      if (col.comment) {
        lines.push(`  /// ${col.comment.replace(/\n/g, ' ')}`)
      }
      lines.push(`  ${fieldName} ${prismaType}${typeOptional}${attrStr}`)
    }

    // Add Relation fields
    if (relations && relations.length) {
      for (const rel of relations) {
        const fromParts = (rel.from || '').split('.')
        const toParts = (rel.to || '').split('.')
        const fromT = rel.fromTable || fromParts[0]
        const fromC = rel.fromColumn || fromParts[1]
        const toT = rel.toTable || toParts[0]
        const toC = rel.toColumn || toParts[1]

        if (fromT.toLowerCase() === table.name.toLowerCase()) {
          const targetModel = capitalizeFirst(toCamelCase(toT))
          const relFieldName = toCamelCase(targetModel)
          const localFieldName = toCamelCase(fromC)
          const targetKeyName = toCamelCase(toC)
          lines.push(`  ${relFieldName} ${targetModel} @relation(fields: [${localFieldName}], references: [${targetKeyName}], onDelete: Cascade)`)
        }
      }
    }

    if (modelName.toLowerCase() !== table.name) {
      lines.push(`\n  @@map("${table.name}")`)
    }

    lines.push('}')
    lines.push('')
  }

  return lines.join('\n')
}

function mapSqlTypeToPrisma(sqlType: string, isPk = false): string {
  const lower = (sqlType || '').toLowerCase()
  if (lower === 'serial' || lower === 'integer' || lower === 'int' || lower === 'smallint') return 'Int'
  if (lower === 'bigserial' || lower === 'bigint') return 'BigInt'
  if (lower === 'boolean' || lower === 'bool') return 'Boolean'
  if (lower === 'timestamp' || lower === 'timestamptz' || lower === 'date') return 'DateTime'
  if (lower === 'json' || lower === 'jsonb') return 'Json'
  if (lower === 'float' || lower === 'real' || lower === 'double precision' || lower === 'numeric' || lower === 'decimal') return 'Float'
  if (lower === 'bytea') return 'Bytes'
  return 'String'
}

function toCamelCase(str: string): string {
  return str.replace(/([-_][a-z])/gi, ($1) => $1.toUpperCase().replace('-', '').replace('_', ''))
}

function capitalizeFirst(str: string): string {
  if (!str) return ''
  return str.charAt(0).toUpperCase() + str.slice(1)
}

/**
 * Converts Prisma Schema into PostgreSQL DDL statements
 */
export function prismaToSql(prismaCode: string): string {
  const schema = parsePrisma(prismaCode)
  const statements: string[] = ['-- Generated PostgreSQL DDL Schema from Prisma Schema', '']

  for (const table of schema.tables) {
    const colDefs: string[] = []

    for (const col of table.columns) {
      const parts: string[] = [`    ${col.name} ${col.type.toUpperCase()}`]

      if (col.isPrimaryKey) {
        parts.push('PRIMARY KEY')
      }
      if (!col.isNullable && !col.isPrimaryKey) {
        parts.push('NOT NULL')
      }
      if (col.isUnique && !col.isPrimaryKey) {
        parts.push('UNIQUE')
      }
      if (col.defaultValue !== undefined && col.defaultValue !== null && col.defaultValue !== '') {
        const rawVal = String(col.defaultValue).trim()
        if (/^(?:true|false|null|\d+(?:\.\d+)?)$/i.test(rawVal) || /^(?:now\(\)|gen_random_uuid\(\)|current_timestamp)/i.test(rawVal)) {
          parts.push(`DEFAULT ${rawVal}`)
        } else {
          const cleanStr = rawVal.replace(/^['"`]+|['"`]+$/g, '')
          parts.push(`DEFAULT '${cleanStr.replace(/'/g, "''")}'`)
        }
      }
      if (col.references) {
        parts.push(`REFERENCES ${col.references.table}(${col.references.column})`)
      }

      colDefs.push(parts.join(' '))
    }

    statements.push(`CREATE TABLE ${table.name} (`)
    statements.push(colDefs.join(',\n'))
    statements.push(');')
    statements.push('')

    if (table.comment) {
      const cleanComment = String(table.comment).replace(/^['"`]+|['"`]+$/g, '')
      statements.push(`COMMENT ON TABLE ${table.name} IS '${cleanComment.replace(/'/g, "''")}';`)
    }

    for (const col of table.columns) {
      if (col.comment) {
        const cleanColComment = String(col.comment).replace(/^['"`]+|['"`]+$/g, '')
        statements.push(`COMMENT ON COLUMN ${table.name}.${col.name} IS '${cleanColComment.replace(/'/g, "''")}';`)
      }
    }

    statements.push('')
  }

  return statements.join('\n')
}
