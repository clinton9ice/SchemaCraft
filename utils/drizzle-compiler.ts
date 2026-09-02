import { Project, SyntaxKind, Node, type CallExpression, type ObjectLiteralExpression } from 'ts-morph'
import type { CompiledSchema, CompiledTable, CompiledColumn, CompiledRelation } from '~/utils/sql-compiler'
import { tablesToDbml, dbmlToSql } from '~/utils/dbml-compiler'
import { tablesToPrisma } from '~/utils/prisma-compiler'
import { tablesToTypeORM } from '~/utils/typeorm-compiler'

interface DrizzleMethodCall {
  methodName: string
  args: Node[]
}

function unwrapCallChain(expr: Node): { baseCall: CallExpression | null; chain: DrizzleMethodCall[] } {
  const chain: DrizzleMethodCall[] = []
  let current: Node = expr

  while (Node.isCallExpression(current)) {
    const caller = current.getExpression()
    if (Node.isPropertyAccessExpression(caller)) {
      chain.unshift({
        methodName: caller.getName(),
        args: current.getArguments(),
      })
      current = caller.getExpression()
    } else {
      return { baseCall: current, chain }
    }
  }

  return { baseCall: null, chain }
}

function mapDrizzleBaseTypeToSql(funcName: string, configArg?: Node): string {
  const lower = funcName.toLowerCase()

  if (lower === 'varchar' || lower === 'char') {
    if (configArg && Node.isObjectLiteralExpression(configArg)) {
      const lenProp = configArg.getProperty('length')
      if (lenProp && Node.isPropertyAssignment(lenProp)) {
        const init = lenProp.getInitializer()
        if (init && Node.isNumericLiteral(init)) {
          return `${lower}(${init.getLiteralValue()})`
        }
      }
    }
    return lower === 'char' ? 'char' : 'varchar'
  }

  if (lower === 'decimal' || lower === 'numeric') {
    if (configArg && Node.isObjectLiteralExpression(configArg)) {
      const precProp = configArg.getProperty('precision')
      const scaleProp = configArg.getProperty('scale')
      if (
        precProp &&
        Node.isPropertyAssignment(precProp) &&
        scaleProp &&
        Node.isPropertyAssignment(scaleProp)
      ) {
        const precInit = precProp.getInitializer()
        const scaleInit = scaleProp.getInitializer()
        if (precInit && Node.isNumericLiteral(precInit) && scaleInit && Node.isNumericLiteral(scaleInit)) {
          return `decimal(${precInit.getLiteralValue()}, ${scaleInit.getLiteralValue()})`
        }
      }
    }
    return 'decimal'
  }

  const typeMap: Record<string, string> = {
    serial: 'serial',
    bigserial: 'bigserial',
    smallserial: 'smallserial',
    integer: 'integer',
    int: 'integer',
    smallint: 'smallint',
    bigint: 'bigint',
    boolean: 'boolean',
    text: 'text',
    timestamp: 'timestamp',
    date: 'date',
    time: 'time',
    real: 'real',
    doubleprecision: 'double precision',
    uuid: 'uuid',
    json: 'json',
    jsonb: 'jsonb',
  }

  return typeMap[lower] || lower
}

/**
 * Extracts database schema information from Drizzle ORM TypeScript code using ts-morph
 */
export function compileDrizzle(input: string | string[]): CompiledSchema {
  const isPaths = Array.isArray(input)
  const project = new Project(isPaths ? undefined : { useInMemoryFileSystem: true })

  if (Array.isArray(input)) {
    project.addSourceFilesAtPaths(input)
  } else {
    project.createSourceFile('schema.ts', input, { overwrite: true })
  }

  const tables: CompiledTable[] = []
  const relations: CompiledRelation[] = []
  const tableVarNameToTableName = new Map<string, string>()

  const sourceFiles = project.getSourceFiles()

  // First Pass: Find all table declarations (pgTable, mysqlTable, sqliteTable)
  for (const sourceFile of sourceFiles) {
    const varStatements = sourceFile.getVariableStatements()

    for (const varStmt of varStatements) {
      for (const decl of varStmt.getDeclarations()) {
        const varName = decl.getName()
        const init = decl.getInitializer()
        if (!init || !Node.isCallExpression(init)) continue

        const callerExpr = init.getExpression()
        const callerName = callerExpr.getText()
        if (!/^(?:pgTable|mysqlTable|sqliteTable)$/.test(callerName)) continue

        const args = init.getArguments()
        if (args.length === 0) continue

        let tableName = varName
        const firstArg = args[0]
        if (Node.isStringLiteral(firstArg)) {
          tableName = firstArg.getLiteralValue()
        }
        tableVarNameToTableName.set(varName, tableName)
      }
    }
  }

  // Second Pass: Parse table columns and foreign keys
  for (const sourceFile of sourceFiles) {
    const varStatements = sourceFile.getVariableStatements()

    for (const varStmt of varStatements) {
      for (const decl of varStmt.getDeclarations()) {
        const varName = decl.getName()
        const init = decl.getInitializer()
        if (!init || !Node.isCallExpression(init)) continue

        const callerExpr = init.getExpression()
        const callerName = callerExpr.getText()
        if (!/^(?:pgTable|mysqlTable|sqliteTable)$/.test(callerName)) continue

        const args = init.getArguments()
        if (args.length < 2) continue

        let tableName = varName
        const firstArg = args[0]
        if (Node.isStringLiteral(firstArg)) {
          tableName = firstArg.getLiteralValue()
        }

        const columnsObj = args[1]
        if (!Node.isObjectLiteralExpression(columnsObj)) continue

        const columns: CompiledColumn[] = []

        for (const prop of columnsObj.getProperties()) {
          if (!Node.isPropertyAssignment(prop)) continue

          const propKeyName = prop.getName()
          const propInit = prop.getInitializer()
          if (!propInit) continue

          const { baseCall, chain } = unwrapCallChain(propInit)
          if (!baseCall) continue

          const baseFuncName = baseCall.getExpression().getText()
          const baseArgs = baseCall.getArguments()

          let dbColName = propKeyName
          if (baseArgs.length > 0 && Node.isStringLiteral(baseArgs[0])) {
            dbColName = baseArgs[0].getLiteralValue()
          }

          const configArg = baseArgs.length > 1 ? baseArgs[1] : undefined
          const sqlType = mapDrizzleBaseTypeToSql(baseFuncName, configArg)

          let isPk = baseFuncName.toLowerCase().includes('serial')
          let isNull = true
          let isUnq = false
          let isFk = false
          let defaultValue: string | null = null
          let refTarget: { table: string; column: string } | null = null
          const constraintsList: string[] = []

          if (isPk) {
            isNull = false
            constraintsList.push('PRIMARY KEY')
          }

          for (const method of chain) {
            const mName = method.methodName

            if (mName === 'primaryKey') {
              isPk = true
              isNull = false
              if (!constraintsList.includes('PRIMARY KEY')) {
                constraintsList.push('PRIMARY KEY')
              }
            } else if (mName === 'notNull') {
              isNull = false
            } else if (mName === 'unique') {
              isUnq = true
              if (!constraintsList.includes('UNIQUE')) {
                constraintsList.push('UNIQUE')
              }
            } else if (mName === 'default') {
              if (method.args.length > 0) {
                const defValNode = method.args[0]
                if (Node.isStringLiteral(defValNode)) {
                  defaultValue = `'${defValNode.getLiteralValue()}'`
                } else {
                  defaultValue = defValNode.getText()
                }
              }
            } else if (mName === 'defaultNow') {
              defaultValue = 'now()'
            } else if (mName === 'defaultRandom') {
              defaultValue = 'gen_random_uuid()'
            } else if (mName === 'references') {
              if (method.args.length > 0) {
                const refFn = method.args[0]
                let targetVar = ''
                let targetCol = 'id'

                if (Node.isArrowFunction(refFn)) {
                  const body = refFn.getBody()
                  if (Node.isPropertyAccessExpression(body)) {
                    targetVar = body.getExpression().getText()
                    targetCol = body.getName()
                  }
                }

                if (targetVar) {
                  const targetTableName = tableVarNameToTableName.get(targetVar) || targetVar
                  isFk = true
                  refTarget = { table: targetTableName, column: targetCol }
                  constraintsList.push(`REFERENCES ${targetTableName}(${targetCol})`)

                  const relKey = `${tableName}.${dbColName}->${targetTableName}.${targetCol}`
                  const exists = relations.some((r) => `${r.from}->${r.to}` === relKey)
                  if (!exists) {
                    relations.push({
                      from: `${tableName}.${dbColName}`,
                      to: `${targetTableName}.${targetCol}`,
                      fromTable: tableName,
                      fromColumn: dbColName,
                      toTable: targetTableName,
                      toColumn: targetCol,
                    })
                  }
                }
              }
            }
          }

          columns.push({
            name: dbColName,
            type: sqlType,
            isPrimaryKey: isPk,
            isNullable: isNull,
            isUnique: isUnq,
            isForeignKey: isFk,
            defaultValue,
            references: refTarget,
            comment: null,
            checkCondition: null,
            constraintsList,
          })
        }

        tables.push({
          name: tableName,
          columns,
          comment: null,
        })
      }
    }
  }

  return { tables, relations }
}

function toCamelCase(str: string): string {
  return str.replace(/[-_]([a-z0-9])/g, (_, char: string) => char.toUpperCase())
}

/**
 * Converts internal CompiledTable[] and relations into clean Drizzle ORM TypeScript code
 */
export function tablesToDrizzle(tables: CompiledTable[], relations?: CompiledRelation[]): string {
  if (!tables || tables.length === 0) return ''

  const usedTypes = new Set<string>(['pgTable'])
  const relList = relations || []

  // Pre-scan types to construct optimal imports
  for (const table of tables) {
    for (const col of table.columns) {
      const lower = col.type.toLowerCase()
      if (col.isPrimaryKey && (lower.includes('serial') || lower.includes('int'))) {
        usedTypes.add('serial')
      } else if (lower.includes('serial')) {
        usedTypes.add('serial')
      } else if (lower.includes('varchar')) {
        usedTypes.add('varchar')
      } else if (lower.includes('text')) {
        usedTypes.add('text')
      } else if (lower.includes('int') || lower.includes('smallint') || lower.includes('bigint')) {
        usedTypes.add('integer')
      } else if (lower.includes('bool')) {
        usedTypes.add('boolean')
      } else if (lower.includes('time') || lower.includes('date')) {
        usedTypes.add('timestamp')
      } else if (lower.includes('decimal') || lower.includes('numeric')) {
        usedTypes.add('decimal')
      } else if (lower.includes('uuid')) {
        usedTypes.add('uuid')
      } else if (lower.includes('json')) {
        usedTypes.add('jsonb')
      } else {
        usedTypes.add('text')
      }
    }
  }

  const importList = Array.from(usedTypes).join(', ')
  const lines: string[] = [
    `import { ${importList} } from 'drizzle-orm/pg-core'`,
    '',
  ]

  for (const table of tables) {
    const varName = toCamelCase(table.name)
    lines.push(`export const ${varName} = pgTable('${table.name}', {`)

    for (const col of table.columns) {
      const propName = toCamelCase(col.name)
      const lower = col.type.toLowerCase()
      const chain: string[] = []

      // Base function call
      if (col.isPrimaryKey && (lower.includes('serial') || lower.includes('int'))) {
        chain.push(`serial('${col.name}').primaryKey()`)
      } else if (lower.includes('varchar')) {
        const match = lower.match(/\((\d+)\)/)
        const len = match ? match[1] : '255'
        chain.push(`varchar('${col.name}', { length: ${len} })`)
      } else if (lower.includes('text')) {
        chain.push(`text('${col.name}')`)
      } else if (lower.includes('int')) {
        chain.push(`integer('${col.name}')`)
      } else if (lower.includes('bool')) {
        chain.push(`boolean('${col.name}')`)
      } else if (lower.includes('time') || lower.includes('date')) {
        chain.push(`timestamp('${col.name}')`)
      } else if (lower.includes('decimal') || lower.includes('numeric')) {
        chain.push(`decimal('${col.name}', { precision: 10, scale: 2 })`)
      } else if (lower.includes('uuid')) {
        chain.push(`uuid('${col.name}')`)
      } else if (lower.includes('json')) {
        chain.push(`jsonb('${col.name}')`)
      } else {
        chain.push(`text('${col.name}')`)
      }

      // Chain primary key (if not serial)
      if (col.isPrimaryKey && !lower.includes('serial') && !chain[0].includes('.primaryKey()')) {
        chain.push('primaryKey()')
      }

      // Chain notNull
      if (!col.isNullable && !col.isPrimaryKey) {
        chain.push('notNull()')
      }

      // Chain unique
      if (col.isUnique && !col.isPrimaryKey) {
        chain.push('unique()')
      }

      // Chain references
      const fkRel = relList.find(
        (r) => (r.fromTable || r.from.split('.')[0]) === table.name && (r.fromColumn || r.from.split('.')[1]) === col.name
      )
      if (fkRel) {
        const targetTable = fkRel.toTable || fkRel.to.split('.')[0]
        const targetCol = fkRel.toColumn || fkRel.to.split('.')[1] || 'id'
        const targetVar = toCamelCase(targetTable)
        chain.push(`references(() => ${targetVar}.${toCamelCase(targetCol)})`)
      }

      // Chain default value
      if (col.defaultValue !== undefined && col.defaultValue !== null && col.defaultValue !== '') {
        const raw = String(col.defaultValue).trim()
        if (/now\(\)|CURRENT_TIMESTAMP/i.test(raw)) {
          chain.push('defaultNow()')
        } else if (/gen_random_uuid\(\)/i.test(raw)) {
          chain.push('defaultRandom()')
        } else if (/^(?:true|false|\d+(?:\.\d+)?)$/i.test(raw)) {
          chain.push(`default(${raw})`)
        } else {
          const clean = raw.replace(/^['"`]+|['"`]+$/g, '')
          chain.push(`default('${clean.replace(/'/g, "\\'")}')`)
        }
      }

      const fullCall = chain.join('.')
      lines.push(`  ${propName}: ${fullCall},`)
    }

    lines.push('})')
    lines.push('')
  }

  return lines.join('\n').trim()
}

/**
 * Converts Drizzle ORM schema TypeScript code into standard SQL DDL
 */
export function drizzleToSql(drizzleCode: string): string {
  const schema = compileDrizzle(drizzleCode)
  if (!schema.tables || schema.tables.length === 0) return ''
  return dbmlToSql(tablesToDbml(schema.tables, schema.relations))
}

/**
 * Converts Drizzle ORM schema TypeScript code into DBML format
 */
export function drizzleToDbml(drizzleCode: string): string {
  const schema = compileDrizzle(drizzleCode)
  if (!schema.tables || schema.tables.length === 0) return ''
  return tablesToDbml(schema.tables, schema.relations)
}

/**
 * Converts Drizzle ORM schema TypeScript code into Prisma Schema format
 */
export function drizzleToPrisma(drizzleCode: string): string {
  const schema = compileDrizzle(drizzleCode)
  if (!schema.tables || schema.tables.length === 0) return ''
  return tablesToPrisma(schema.tables, schema.relations)
}

/**
 * Converts Drizzle ORM schema TypeScript code into TypeORM Entity format
 */
export function drizzleToTypeORM(drizzleCode: string): string {
  const schema = compileDrizzle(drizzleCode)
  if (!schema.tables || schema.tables.length === 0) return ''
  return tablesToTypeORM(schema.tables, schema.relations)
}
