import { Project, Node, type CallExpression } from 'ts-morph'
import type {
  CompiledSchema,
  CompiledTable,
  CompiledColumn,
  CompiledRelation,
} from '~/utils/sql-compiler'
import { tablesToDbml, dbmlToSql } from '~/utils/dbml-compiler'
import { tablesToPrisma } from '~/utils/prisma-compiler'
import { tablesToTypeORM } from '~/utils/typeorm-compiler'
import { sanitizeDrizzle } from '~/utils/ts-sanitizer'

interface DrizzleMethodCall {
  methodName: string
  args: Node[]
}

function unwrapCallChain(expr: Node): {
  baseCall: CallExpression | null
  chain: DrizzleMethodCall[]
} {
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
        if (
          precInit &&
          Node.isNumericLiteral(precInit) &&
          scaleInit &&
          Node.isNumericLiteral(scaleInit)
        ) {
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
    project.createSourceFile('schema.ts', sanitizeDrizzle(input), { overwrite: true })
  }

  const tables: CompiledTable[] = []
  const relations: CompiledRelation[] = []
  const tableVarNameToTableName = new Map<string, string>()
  const tableVarToPropMap = new Map<string, Map<string, string>>()

  const sourceFiles = project.getSourceFiles()

  function resolveColumnName(tableVarOrName: string, propOrCol: string): string {
    const map = tableVarToPropMap.get(tableVarOrName)
    if (map && map.has(propOrCol)) {
      return map.get(propOrCol)!
    }
    // Also check if tableVarOrName was resolved to actual table name
    const resolvedName = tableVarNameToTableName.get(tableVarOrName)
    if (resolvedName && tableVarToPropMap.has(resolvedName)) {
      const resolvedMap = tableVarToPropMap.get(resolvedName)
      if (resolvedMap && resolvedMap.has(propOrCol)) {
        return resolvedMap.get(propOrCol)!
      }
    }
    return propOrCol
  }

  function extractTargetVarAndProp(node: Node): { targetVar: string; targetProp: string } | null {
    if (Node.isArrowFunction(node) || Node.isFunctionExpression(node)) {
      const body = node.getBody()
      if (Node.isPropertyAccessExpression(body)) {
        return {
          targetVar: body.getExpression().getText(),
          targetProp: body.getName(),
        }
      } else if (Node.isBlock(body)) {
        for (const stmt of body.getStatements()) {
          if (Node.isReturnStatement(stmt)) {
            const expr = stmt.getExpression()
            if (expr && Node.isPropertyAccessExpression(expr)) {
              return {
                targetVar: expr.getExpression().getText(),
                targetProp: expr.getName(),
              }
            }
          }
        }
      }
    } else if (Node.isPropertyAccessExpression(node)) {
      return {
        targetVar: node.getExpression().getText(),
        targetProp: node.getName(),
      }
    }
    return null
  }

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
        tableVarNameToTableName.set(tableName, tableName)
      }
    }
  }

  // Second Pass: Parse table columns, property maps, inline .references(), and extraConfig foreignKey
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
        const propToCol = new Map<string, string>()

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

          propToCol.set(propKeyName, dbColName)
          propToCol.set(dbColName, dbColName)

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
                const extracted = extractTargetVarAndProp(refFn)

                if (extracted && extracted.targetVar) {
                  const targetVar = extracted.targetVar
                  const targetTableName = tableVarNameToTableName.get(targetVar) || targetVar
                  const targetCol = resolveColumnName(targetVar, extracted.targetProp)

                  isFk = true
                  refTarget = { table: targetTableName, column: targetCol }
                  constraintsList.push(`REFERENCES ${targetTableName}(${targetCol})`)

                  const relKey = `${tableName}.${dbColName}->${targetTableName}.${targetCol}`
                  const exists = relations.some(r => `${r.from}->${r.to}` === relKey)
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

        tableVarToPropMap.set(varName, propToCol)
        tableVarToPropMap.set(tableName, propToCol)

        // Parse extraConfig callback (e.g. 3rd arg: (table) => ({ fk: foreignKey(...) }))
        if (args.length >= 3) {
          const extraConfigArg = args[2]
          let configNode: Node | null = null

          if (Node.isArrowFunction(extraConfigArg) || Node.isFunctionExpression(extraConfigArg)) {
            const body = extraConfigArg.getBody()
            if (Node.isObjectLiteralExpression(body) || Node.isArrayLiteralExpression(body)) {
              configNode = body
            } else if (Node.isParenthesizedExpression(body)) {
              configNode = body.getExpression()
            }
          }

          if (configNode) {
            const calls: CallExpression[] = []
            if (Node.isObjectLiteralExpression(configNode)) {
              for (const p of configNode.getProperties()) {
                if (Node.isPropertyAssignment(p)) {
                  const initExpr = p.getInitializer()
                  if (initExpr && Node.isCallExpression(initExpr)) calls.push(initExpr)
                }
              }
            } else if (Node.isArrayLiteralExpression(configNode)) {
              for (const el of configNode.getElements()) {
                if (Node.isCallExpression(el)) calls.push(el)
              }
            }

            for (const call of calls) {
              const callText = call.getExpression().getText()
              if (callText.includes('foreignKey')) {
                const fkArgs = call.getArguments()
                if (fkArgs.length > 0 && Node.isObjectLiteralExpression(fkArgs[0])) {
                  const cfgObj = fkArgs[0]
                  const colsProp = cfgObj.getProperty('columns')
                  const fColsProp = cfgObj.getProperty('foreignColumns')

                  let fromList: string[] = []
                  let toTableTarget = ''
                  let toList: string[] = []

                  if (colsProp && Node.isPropertyAssignment(colsProp)) {
                    const cInit = colsProp.getInitializer()
                    if (cInit && Node.isArrayLiteralExpression(cInit)) {
                      fromList = cInit.getElements().map(el => {
                        const ext = extractTargetVarAndProp(el)
                        const pName = ext ? ext.targetProp : el.getText().split('.').pop() || ''
                        return resolveColumnName(varName, pName)
                      })
                    }
                  }

                  if (fColsProp && Node.isPropertyAssignment(fColsProp)) {
                    const fcInit = fColsProp.getInitializer()
                    if (fcInit && Node.isArrayLiteralExpression(fcInit)) {
                      toList = fcInit.getElements().map(el => {
                        const ext = extractTargetVarAndProp(el)
                        if (ext) {
                          toTableTarget =
                            tableVarNameToTableName.get(ext.targetVar) || ext.targetVar
                          return resolveColumnName(ext.targetVar, ext.targetProp)
                        }
                        return el.getText().split('.').pop() || ''
                      })
                    }
                  }

                  for (let i = 0; i < Math.min(fromList.length, toList.length); i++) {
                    const fCol = fromList[i]
                    const tCol = toList[i]
                    if (fCol && tCol && toTableTarget) {
                      const relKey = `${tableName}.${fCol}->${toTableTarget}.${tCol}`
                      const exists = relations.some(r => `${r.from}->${r.to}` === relKey)
                      if (!exists) {
                        relations.push({
                          from: `${tableName}.${fCol}`,
                          to: `${toTableTarget}.${tCol}`,
                          fromTable: tableName,
                          fromColumn: fCol,
                          toTable: toTableTarget,
                          toColumn: tCol,
                        })

                        const c = columns.find(col => col.name === fCol)
                        if (c) {
                          c.isForeignKey = true
                          c.references = { table: toTableTarget, column: tCol }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }

        tables.push({
          name: tableName,
          columns,
          comment: null,
        })
      }
    }
  }

  // Third Pass: Parse Drizzle relations() function declarations
  for (const sourceFile of sourceFiles) {
    const varStatements = sourceFile.getVariableStatements()

    for (const varStmt of varStatements) {
      for (const decl of varStmt.getDeclarations()) {
        const init = decl.getInitializer()
        if (!init || !Node.isCallExpression(init)) continue

        const callerExpr = init.getExpression()
        const callerName = callerExpr.getText()
        if (callerName !== 'relations') continue

        const args = init.getArguments()
        if (args.length < 2) continue

        // First arg is the source table variable
        const sourceTableVar = args[0].getText()
        const fromTableName = tableVarNameToTableName.get(sourceTableVar) || sourceTableVar

        // Second arg is callback: ({ one, many }) => ({ ... })
        const callbackArg = args[1]
        let relsObj: Node | null = null

        if (Node.isArrowFunction(callbackArg) || Node.isFunctionExpression(callbackArg)) {
          const body = callbackArg.getBody()
          if (Node.isObjectLiteralExpression(body)) {
            relsObj = body
          } else if (Node.isParenthesizedExpression(body)) {
            const inner = body.getExpression()
            if (Node.isObjectLiteralExpression(inner)) {
              relsObj = inner
            }
          } else if (Node.isBlock(body)) {
            for (const stmt of body.getStatements()) {
              if (Node.isReturnStatement(stmt)) {
                const expr = stmt.getExpression()
                if (expr && Node.isObjectLiteralExpression(expr)) {
                  relsObj = expr
                }
              }
            }
          }
        }

        if (!relsObj || !Node.isObjectLiteralExpression(relsObj)) continue

        for (const prop of relsObj.getProperties()) {
          if (!Node.isPropertyAssignment(prop)) continue
          const relInit = prop.getInitializer()
          if (!relInit || !Node.isCallExpression(relInit)) continue

          const helperName = relInit.getExpression().getText()
          const helperArgs = relInit.getArguments()

          // We handle one(...) which defines fields & references
          if (helperName === 'one' && helperArgs.length >= 2) {
            const targetTableVar = helperArgs[0].getText()
            const toTableName = tableVarNameToTableName.get(targetTableVar) || targetTableVar

            const config = helperArgs[1]
            if (Node.isObjectLiteralExpression(config)) {
              const fieldsProp = config.getProperty('fields')
              const refsProp = config.getProperty('references')

              let fromCols: string[] = []
              let toCols: string[] = []

              if (fieldsProp && Node.isPropertyAssignment(fieldsProp)) {
                const fieldsInit = fieldsProp.getInitializer()
                if (fieldsInit && Node.isArrayLiteralExpression(fieldsInit)) {
                  fromCols = fieldsInit.getElements().map(el => {
                    const extracted = extractTargetVarAndProp(el)
                    const propName = extracted
                      ? extracted.targetProp
                      : el.getText().split('.').pop() || 'id'
                    return resolveColumnName(sourceTableVar, propName)
                  })
                }
              }

              if (refsProp && Node.isPropertyAssignment(refsProp)) {
                const refsInit = refsProp.getInitializer()
                if (refsInit && Node.isArrayLiteralExpression(refsInit)) {
                  toCols = refsInit.getElements().map(el => {
                    const extracted = extractTargetVarAndProp(el)
                    const propName = extracted
                      ? extracted.targetProp
                      : el.getText().split('.').pop() || 'id'
                    return resolveColumnName(targetTableVar, propName)
                  })
                }
              }

              for (let i = 0; i < Math.min(fromCols.length, toCols.length); i++) {
                const fromCol = fromCols[i]
                const toCol = toCols[i]
                const relKey = `${fromTableName}.${fromCol}->${toTableName}.${toCol}`
                const exists = relations.some(r => `${r.from}->${r.to}` === relKey)
                if (!exists) {
                  relations.push({
                    from: `${fromTableName}.${fromCol}`,
                    to: `${toTableName}.${toCol}`,
                    fromTable: fromTableName,
                    fromColumn: fromCol,
                    toTable: toTableName,
                    toColumn: toCol,
                  })

                  // Mark isForeignKey on the source table's column
                  const srcTable = tables.find(t => t.name === fromTableName)
                  if (srcTable) {
                    const col = srcTable.columns.find(c => c.name === fromCol)
                    if (col) {
                      col.isForeignKey = true
                      col.references = { table: toTableName, column: toCol }
                    }
                  }
                }
              }
            }
          }
        }
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
  const lines: string[] = [`import { ${importList} } from 'drizzle-orm/pg-core'`, '']

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
        r =>
          (r.fromTable || r.from.split('.')[0]) === table.name &&
          (r.fromColumn || r.from.split('.')[1]) === col.name
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
