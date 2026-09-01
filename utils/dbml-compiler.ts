import type { CompiledTable, CompiledColumn, CompiledRelation, CompiledSchema } from './sql-compiler'

export interface SyntaxDiagnosticError {
  message: string
  lineNumber: number
  column: number
  endLineNumber: number
  endColumn: number
}

/**
 * Validates DBML code syntax with precise line/column tracking
 */
export function validateDbmlCode(dbmlCode: string): { valid: boolean; error: SyntaxDiagnosticError | null } {
  if (!dbmlCode || !dbmlCode.trim()) {
    return { valid: true, error: null }
  }

  const lines = dbmlCode.split('\n')
  let openBraces = 0
  let currentTableStartLine = -1
  const tableNames = new Set<string>()

  for (let i = 0; i < lines.length; i++) {
    const lineNum = i + 1
    const line = lines[i]
    const trimmed = line.trim()

    if (!trimmed || trimmed.startsWith('//') || trimmed.startsWith('/*')) {
      continue
    }

    // Check for unmatched brackets in the line
    const openBracketsCount = (line.match(/\[/g) || []).length
    const closeBracketsCount = (line.match(/\]/g) || []).length
    if (openBracketsCount !== closeBracketsCount) {
      return {
        valid: false,
        error: {
          message: 'Unmatched settings bracket `[` or `]`',
          lineNumber: lineNum,
          column: 1,
          endLineNumber: lineNum,
          endColumn: line.length + 1,
        },
      }
    }

    // Check for Table definition header
    const tableHeaderMatch = trimmed.match(/^Table\s+(?:(?:"([^"]+)")|([a-zA-Z0-9_]+))(?:\s+as\s+[\w_]+)?\s*(\{)?/i)
    if (tableHeaderMatch) {
      const tableName = (tableHeaderMatch[1] || tableHeaderMatch[2] || '').toLowerCase()
      if (tableNames.has(tableName)) {
        return {
          valid: false,
          error: {
            message: `Duplicate Table definition '${tableName}'`,
            lineNumber: lineNum,
            column: line.indexOf(tableHeaderMatch[1] || tableHeaderMatch[2]) + 1,
            endLineNumber: lineNum,
            endColumn: line.length + 1,
          },
        }
      }
      tableNames.add(tableName)

      if (tableHeaderMatch[3] === '{' || line.includes('{')) {
        openBraces++
        currentTableStartLine = lineNum
      }
      continue
    }

    // Standalone Ref statement: Ref: posts.author_id > users.id
    if (/^Ref\b/i.test(trimmed)) {
      const refMatch = trimmed.match(/^Ref(?:\s+[\w_]+)?\s*:\s*([\w_]+)\.([\w_]+)\s*([><-])\s*([\w_]+)\.([\w_]+)/i)
      if (!refMatch) {
        return {
          valid: false,
          error: {
            message: "Malformed Ref syntax. Expected format: `Ref: from_table.col > to_table.col`",
            lineNumber: lineNum,
            column: 1,
            endLineNumber: lineNum,
            endColumn: line.length + 1,
          },
        }
      }
      continue
    }

    // Other valid top-level blocks
    if (/^(?:Enum|TableGroup|Project)\s+/i.test(trimmed)) {
      if (line.includes('{')) {
        openBraces++
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
            message: 'Unexpected closing brace `}`',
            lineNumber: lineNum,
            column: line.indexOf('}') + 1,
            endLineNumber: lineNum,
            endColumn: line.indexOf('}') + 2,
          },
        }
      }
      continue
    }

    // Inside a block (e.g. Table body)
    if (openBraces > 0) {
      if (trimmed.startsWith('Note:') || trimmed.startsWith('indexes {') || trimmed.startsWith('//')) {
        continue
      }

      // Column check: name type [settings]
      const colMatch = trimmed.match(/^([a-zA-Z0-9_]+)\s+([a-zA-Z0-9_]+(?:\([^)]+\))?)(?:\s*\[(.*)\])?/i)
      if (!colMatch) {
        return {
          valid: false,
          error: {
            message: `Invalid column syntax '${trimmed}'. Expected: <column_name> <type> [settings]`,
            lineNumber: lineNum,
            column: line.search(/\S/) + 1,
            endLineNumber: lineNum,
            endColumn: line.length + 1,
          },
        }
      }
    } else {
      // Top-level unhandled statement
      if (!trimmed.startsWith('//') && !trimmed.startsWith('/*')) {
        return {
          valid: false,
          error: {
            message: `Unexpected top-level statement '${trimmed}'. Expected Table, Ref, Enum, or TableGroup.`,
            lineNumber: lineNum,
            column: line.search(/\S/) + 1,
            endLineNumber: lineNum,
            endColumn: line.length + 1,
          },
        }
      }
    }
  }

  if (openBraces > 0) {
    return {
      valid: false,
      error: {
        message: 'Unclosed block: missing closing brace `}`',
        lineNumber: currentTableStartLine > 0 ? currentTableStartLine : lines.length,
        column: 1,
        endLineNumber: lines.length,
        endColumn: (lines[lines.length - 1]?.length || 0) + 1,
      },
    }
  }

  return { valid: true, error: null }
}

/**
 * Parses DBML (Database Markup Language) into the unified CompiledSchema AST
 */
export function parseDbml(dbmlCode: string): CompiledSchema {
  const tables: CompiledTable[] = []
  const relations: CompiledRelation[] = []

  if (!dbmlCode || !dbmlCode.trim()) {
    return { tables, relations }
  }

  // Remove comments (// or /* ... */)
  let cleanCode = dbmlCode.replace(/\/\*[\s\S]*?\*\//g, '')
  const lines = cleanCode.split('\n')

  let currentTable: CompiledTable | null = null
  let inIndexesBlock = false

  for (let i = 0; i < lines.length; i++) {
    const rawLine = lines[i].trim()
    if (!rawLine || rawLine.startsWith('//')) continue

    // Detect Standalone Relationship (Ref: posts.author_id > users.id)
    const refMatch = rawLine.match(/^Ref(?:\s+[\w_]+)?\s*:\s*([\w_]+)\.([\w_]+)\s*([><-])\s*([\w_]+)\.([\w_]+)/i)
    if (refMatch) {
      const [, fromTable, fromCol, , toTable, toCol] = refMatch
      relations.push({
        from: `${fromTable}.${fromCol}`,
        to: `${toTable}.${toCol}`,
        fromTable,
        fromColumn: fromCol,
        toTable,
        toColumn: toCol,
      })
      continue
    }

    // Detect Table start: Table users { or Table "users" as u {
    const tableHeaderMatch = rawLine.match(/^Table\s+(?:(?:"([^"]+)")|([a-zA-Z0-9_]+))(?:\s+as\s+[\w_]+)?\s*\{/i)
    if (tableHeaderMatch) {
      const tableName = tableHeaderMatch[1] || tableHeaderMatch[2]
      currentTable = {
        name: tableName,
        columns: [],
        comment: null,
      }
      inIndexesBlock = false
      continue
    }

    // Detect Table closing: }
    if (rawLine === '}' && currentTable) {
      if (inIndexesBlock) {
        inIndexesBlock = false
      } else {
        tables.push(currentTable)
        currentTable = null
      }
      continue
    }

    // Detect indexes block
    if (rawLine.match(/^indexes\s*\{/i)) {
      inIndexesBlock = true
      continue
    }

    // Parse column line inside Table
    if (currentTable && !inIndexesBlock) {
      // Table Note: Note: 'This is a description'
      const tableNoteMatch = rawLine.match(/^Note\s*:\s*(?:'([^']*)'|"([^"]*)")/i)
      if (tableNoteMatch) {
        currentTable.comment = tableNoteMatch[1] || tableNoteMatch[2]
        continue
      }

      // Column Definition: id integer [pk, increment, not null, default: 1, note: 'Primary identifier']
      const colMatch = rawLine.match(/^([a-zA-Z0-9_]+)\s+([a-zA-Z0-9_]+(?:\([^)]+\))?)(?:\s*\[(.*)\])?/i)
      if (colMatch) {
        const colName = colMatch[1]
        const colType = colMatch[2]
        const settingsStr = colMatch[3] || ''

        let isPk = false
        let isNotNull = false
        let isUnq = false
        let isFk = false
        let defaultVal: string | null = null
        let colNote: string | null = null
        let refTarget: { table: string; column: string } | null = null
        const constraintsList: string[] = []

        if (settingsStr) {
          const parts = splitSettings(settingsStr)

          for (const p of parts) {
            const trimmedP = p.trim()

            if (/^(?:pk|primary\s+key)$/i.test(trimmedP)) {
              isPk = true
              isNotNull = true
              constraintsList.push('PRIMARY KEY')
            } else if (/^not\s+null$/i.test(trimmedP)) {
              isNotNull = true
              constraintsList.push('NOT NULL')
            } else if (/^null$/i.test(trimmedP)) {
              isNotNull = false
            } else if (/^unique$/i.test(trimmedP)) {
              isUnq = true
              constraintsList.push('UNIQUE')
            } else if (/^increment$/i.test(trimmedP) || /^auto_increment$/i.test(trimmedP)) {
              constraintsList.push('AUTO_INCREMENT')
            } else if (/^default:\s*(.+)$/i.test(trimmedP)) {
              const dMatch = trimmedP.match(/^default:\s*(.+)$/i)
              if (dMatch) {
                const rawD = dMatch[1].trim()
                if (/^(?:true|false|null|\d+(?:\.\d+)?)$/i.test(rawD)) {
                  defaultVal = rawD
                } else if (/^`.*`$/.test(rawD)) {
                  defaultVal = rawD.slice(1, -1).trim()
                } else {
                  defaultVal = rawD.replace(/^['"`]+|['"`]+$/g, '')
                }
                constraintsList.push(`DEFAULT ${defaultVal}`)
              }
            } else if (/^note:\s*(.+)$/i.test(trimmedP)) {
              const nMatch = trimmedP.match(/^note:\s*(.+)$/i)
              if (nMatch) {
                colNote = nMatch[1].trim().replace(/^['"`]+|['"`]+$/g, '')
              }
            } else if (/^ref:\s*([><-])\s*([\w_]+)\.([\w_]+)$/i.test(trimmedP)) {
              const rMatch = trimmedP.match(/^ref:\s*([><-])\s*([\w_]+)\.([\w_]+)$/i)
              if (rMatch) {
                const targetTable = rMatch[2]
                const targetCol = rMatch[3]
                isFk = true
                refTarget = { table: targetTable, column: targetCol }
                constraintsList.push(`REFERENCES ${targetTable}(${targetCol})`)
                relations.push({
                  from: `${currentTable.name}.${colName}`,
                  to: `${targetTable}.${targetCol}`,
                  fromTable: currentTable.name,
                  fromColumn: colName,
                  toTable: targetTable,
                  toColumn: targetCol,
                })
              }
            }
          }
        }

        const columnObj: CompiledColumn = {
          name: colName,
          type: colType.toLowerCase(),
          isPrimaryKey: isPk,
          isNullable: !isNotNull && !isPk,
          isUnique: isUnq,
          isForeignKey: isFk,
          defaultValue: defaultVal,
          references: refTarget,
          comment: colNote,
          constraintsList,
        }

        currentTable.columns.push(columnObj)
      }
    }
  }

  // Final Pass: Link all standalone relationships to table columns for visual indicator pills
  for (const rel of relations) {
    const fromTable = rel.fromTable || rel.from.split('.')[0]
    const fromCol = rel.fromColumn || rel.from.split('.')[1]
    const toTable = rel.toTable || rel.to.split('.')[0]
    const toCol = rel.toColumn || rel.to.split('.')[1]

    const targetTable = tables.find((t) => t.name.toLowerCase() === fromTable.toLowerCase())
    if (targetTable) {
      const targetColumn = targetTable.columns.find((c) => c.name.toLowerCase() === fromCol.toLowerCase())
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

/**
 * Splits settings inside [ ... ] respecting quoted strings
 */
function splitSettings(settingsStr: string): string[] {
  const result: string[] = []
  let current = ''
  let inQuote = false
  let quoteChar = ''

  for (let i = 0; i < settingsStr.length; i++) {
    const char = settingsStr[i]

    if ((char === "'" || char === '"' || char === '`') && !inQuote) {
      inQuote = true
      quoteChar = char
      current += char
    } else if (char === quoteChar && inQuote) {
      inQuote = false
      quoteChar = ''
      current += char
    } else if (char === ',' && !inQuote) {
      result.push(current.trim())
      current = ''
    } else {
      current += char
    }
  }

  if (current.trim()) {
    result.push(current.trim())
  }

  return result
}

/**
 * Converts internal CompiledTable[] and relations into clean DBML format
 */
export function tablesToDbml(tables: CompiledTable[], relations?: CompiledRelation[]): string {
  if (!tables || tables.length === 0) return ''

  const lines: string[] = ['// Database Definition in DBML format', '']

  for (const table of tables) {
    lines.push(`Table ${table.name} {`)

    for (const col of table.columns) {
      const settings: string[] = []

      if (col.isPrimaryKey) {
        settings.push('pk')
      }
      if (!col.isNullable && !col.isPrimaryKey) {
        settings.push('not null')
      }
      if (col.isUnique && !col.isPrimaryKey) {
        settings.push('unique')
      }
      if (col.defaultValue !== undefined && col.defaultValue !== null && col.defaultValue !== '') {
        const rawVal = String(col.defaultValue).trim()
        if (/^(?:true|false|null|\d+(?:\.\d+)?)$/i.test(rawVal)) {
          settings.push(`default: ${rawVal}`)
        } else if (/^(?:now\(\)|gen_random_uuid\(\)|current_timestamp|uuid_generate_v4\(\))/i.test(rawVal)) {
          settings.push(`default: \`${rawVal}\``)
        } else {
          const cleanStr = rawVal.replace(/^['"`]+|['"`]+$/g, '')
          settings.push(`default: '${cleanStr.replace(/'/g, "\\'")}'`)
        }
      }
      if (col.comment) {
        const cleanComment = String(col.comment).replace(/^['"`]+|['"`]+$/g, '')
        settings.push(`note: '${cleanComment.replace(/'/g, "\\'")}'`)
      }
      if (col.references) {
        settings.push(`ref: > ${col.references.table}.${col.references.column}`)
      }

      const settingsFormatted = settings.length ? ` [${settings.join(', ')}]` : ''
      lines.push(`  ${col.name} ${col.type}${settingsFormatted}`)
    }

    if (table.comment) {
      const cleanTableNote = String(table.comment).replace(/^['"`]+|['"`]+$/g, '')
      lines.push(`  Note: '${cleanTableNote.replace(/'/g, "\\'")}'`)
    }

    lines.push('}')
    lines.push('')
  }

  // Standalone relationships that weren't captured inline
  if (relations && relations.length) {
    const existingInlineRefs = new Set<string>()
    for (const t of tables) {
      for (const c of t.columns) {
        if (c.references) {
          existingInlineRefs.add(`${t.name}.${c.name}->${c.references.table}.${c.references.column}`)
        }
      }
    }

    for (const rel of relations) {
      const key = `${rel.from}->${rel.to}`
      if (!existingInlineRefs.has(key)) {
        lines.push(`Ref: ${rel.from} > ${rel.to}`)
      }
    }
    lines.push('')
  }

  return lines.join('\n')
}

/**
 * Converts DBML code into standard PostgreSQL DDL statements
 */
export function dbmlToSql(dbmlCode: string): string {
  const schema = parseDbml(dbmlCode)
  const statements: string[] = ['-- Generated PostgreSQL DDL Schema from DBML', '']

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

    // Table comments
    if (table.comment) {
      const cleanComment = String(table.comment).replace(/^['"`]+|['"`]+$/g, '')
      statements.push(`COMMENT ON TABLE ${table.name} IS '${cleanComment.replace(/'/g, "''")}';`)
    }

    // Column comments
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
