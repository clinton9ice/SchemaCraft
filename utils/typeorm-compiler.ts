import { Project, SyntaxKind, Node } from 'ts-morph'
import type {
  CompiledSchema,
  CompiledTable,
  CompiledColumn,
  CompiledRelation,
} from '~/utils/sql-compiler'
import { tablesToDbml, dbmlToSql } from '~/utils/dbml-compiler'
import { tablesToPrisma } from '~/utils/prisma-compiler'
import { sanitizeTypeORM } from '~/utils/ts-sanitizer'

/**
 * Extracts database schema information from TypeORM entity files using ts-morph
 */
export function compileTypeORM(input: string | string[]): CompiledSchema {
  const isPaths = Array.isArray(input)
  const project = new Project(isPaths ? undefined : { useInMemoryFileSystem: true })

  if (Array.isArray(input)) {
    project.addSourceFilesAtPaths(input)
  } else {
    project.createSourceFile('entity.ts', sanitizeTypeORM(input), { overwrite: true })
  }

  const tables: CompiledTable[] = []
  const relations: CompiledRelation[] = []

  const sourceFiles = project.getSourceFiles()

  for (const sourceFile of sourceFiles) {
    const classes = sourceFile.getClasses()
    for (const classNode of classes) {
      const entityDecorator = classNode.getDecorator('Entity')
      if (!entityDecorator) {
        continue
      }

      // Get table name from @Entity('table_name') or use class name
      let tableName = classNode.getName() || 'UnnamedTable'
      const entityArg = entityDecorator.getArguments()[0]
      if (entityArg && Node.isStringLiteral(entityArg)) {
        tableName = entityArg.getLiteralValue()
      }

      const columns: CompiledColumn[] = []
      const classProperties = classNode.getProperties()

      for (const prop of classProperties) {
        const propName = prop.getName()
        const decorators = prop.getDecorators()
        if (decorators.length === 0) continue

        const isOneToMany = decorators.some(d => d.getName() === 'OneToMany')
        const isManyToMany = decorators.some(d => d.getName() === 'ManyToMany')
        const isColumnLike = decorators.some(d =>
          [
            'Column',
            'PrimaryGeneratedColumn',
            'PrimaryColumn',
            'CreateDateColumn',
            'UpdateDateColumn',
            'DeleteDateColumn',
            'VersionColumn',
          ].includes(d.getName())
        )

        let isPk = false
        let isUnq = false
        let isNull = true
        let isFk = false
        let customType: string | null = null
        let refTarget: { table: string; column: string } | null = null
        let colName = propName
        const constraintsList: string[] = []

        // Extract JoinColumn name if specified
        const joinColDec = prop.getDecorator('JoinColumn')
        if (joinColDec) {
          const joinArg = joinColDec.getArguments()[0]
          if (joinArg && Node.isObjectLiteralExpression(joinArg)) {
            const nameProp = joinArg.getProperty('name')
            if (nameProp && Node.isPropertyAssignment(nameProp)) {
              const nameInit = nameProp.getInitializer()
              if (nameInit && Node.isStringLiteral(nameInit)) {
                colName = nameInit.getLiteralValue()
              }
            }
          }
        }

        for (const dec of decorators) {
          const decName = dec.getName()

          // Primary Key
          if (decName === 'PrimaryGeneratedColumn' || decName === 'PrimaryColumn') {
            isPk = true
            isNull = false
            constraintsList.push('PRIMARY KEY')
            if (decName === 'PrimaryGeneratedColumn') {
              constraintsList.push('AUTO_INCREMENT')
            }
          }

          // Standard Column
          if (decName === 'Column') {
            isNull = false // In TypeORM, @Column() defaults to NOT NULL unless { nullable: true }
            const args = dec.getArguments()
            if (args.length > 0) {
              const firstArg = args[0]
              if (Node.isStringLiteral(firstArg)) {
                customType = firstArg.getLiteralValue()
              } else if (Node.isObjectLiteralExpression(firstArg)) {
                const typeProp = firstArg.getProperty('type')
                if (typeProp && Node.isPropertyAssignment(typeProp)) {
                  const typeInit = typeProp.getInitializer()
                  if (typeInit && Node.isStringLiteral(typeInit)) {
                    customType = typeInit.getLiteralValue()
                  }
                }

                const uniqueProp = firstArg.getProperty('unique')
                if (uniqueProp && Node.isPropertyAssignment(uniqueProp)) {
                  const val = uniqueProp.getInitializer()
                  if (val?.getKind() === SyntaxKind.TrueKeyword) {
                    isUnq = true
                    constraintsList.push('UNIQUE')
                  }
                }

                const nullableProp = firstArg.getProperty('nullable')
                if (nullableProp && Node.isPropertyAssignment(nullableProp)) {
                  const val = nullableProp.getInitializer()
                  if (val?.getKind() === SyntaxKind.TrueKeyword) {
                    isNull = true
                  } else if (val?.getKind() === SyntaxKind.FalseKeyword) {
                    isNull = false
                  }
                }
              }
            }
          }

          // ManyToOne Relation
          if (decName === 'ManyToOne') {
            isFk = true
            let targetClassName: string | null = null

            // 1. Try decorator argument 0: () => TargetClass or TargetClass
            const args = dec.getArguments()
            if (args.length > 0) {
              const firstArg = args[0]
              if (Node.isArrowFunction(firstArg)) {
                const body = firstArg.getBody()
                if (Node.isIdentifier(body)) {
                  targetClassName = body.getText()
                }
              } else if (Node.isIdentifier(firstArg)) {
                targetClassName = firstArg.getText()
              }
            }

            // 2. Try type symbol / type text
            if (!targetClassName) {
              const type = prop.getType()
              const symbol = type.getSymbol()
              if (symbol) {
                targetClassName = symbol.getName()
              } else {
                const rawType = cleanTsType(prop.getType().getText()).trim()
                if (rawType && rawType !== 'any' && !/^[a-z]/.test(rawType)) {
                  targetClassName = rawType
                }
              }
            }

            if (targetClassName) {
              const targetEntity = project
                .getSourceFiles()
                .flatMap(sf => sf.getClasses())
                .find(c => c.getName() === targetClassName)

              let targetTable = targetClassName.toLowerCase()
              const targetEntityDec = targetEntity?.getDecorator('Entity')
              if (targetEntityDec) {
                const arg = targetEntityDec.getArguments()[0]
                if (arg && Node.isStringLiteral(arg)) {
                  targetTable = arg.getLiteralValue()
                }
              }

              refTarget = { table: targetTable, column: 'id' }
              constraintsList.push(`REFERENCES ${targetTable}(id)`)

              const relationExists = relations.some(
                r =>
                  r.fromTable === tableName && r.toTable === targetTable && r.fromColumn === colName
              )
              if (!relationExists) {
                relations.push({
                  from: `${tableName}.${colName}`,
                  to: `${targetTable}.id`,
                  fromTable: tableName,
                  fromColumn: colName,
                  toTable: targetTable,
                  toColumn: 'id',
                })
              }
            }
          }

          // OneToOne Relation
          if (decName === 'OneToOne') {
            isFk = true
            let targetClassName: string | null = null

            const args = dec.getArguments()
            if (args.length > 0) {
              const firstArg = args[0]
              if (Node.isArrowFunction(firstArg)) {
                const body = firstArg.getBody()
                if (Node.isIdentifier(body)) {
                  targetClassName = body.getText()
                }
              } else if (Node.isIdentifier(firstArg)) {
                targetClassName = firstArg.getText()
              }
            }

            if (!targetClassName) {
              const type = prop.getType()
              const symbol = type.getSymbol()
              if (symbol) {
                targetClassName = symbol.getName()
              } else {
                const rawType = cleanTsType(prop.getType().getText()).trim()
                if (rawType && rawType !== 'any' && !/^[a-z]/.test(rawType)) {
                  targetClassName = rawType
                }
              }
            }

            if (targetClassName) {
              const targetEntity = project
                .getSourceFiles()
                .flatMap(sf => sf.getClasses())
                .find(c => c.getName() === targetClassName)

              let targetTable = targetClassName.toLowerCase()
              const targetEntityDec = targetEntity?.getDecorator('Entity')
              if (targetEntityDec) {
                const arg = targetEntityDec.getArguments()[0]
                if (arg && Node.isStringLiteral(arg)) {
                  targetTable = arg.getLiteralValue()
                }
              }

              refTarget = { table: targetTable, column: 'id' }
              constraintsList.push(`REFERENCES ${targetTable}(id)`)

              const relationExists = relations.some(
                r =>
                  r.fromTable === tableName && r.toTable === targetTable && r.fromColumn === colName
              )
              if (!relationExists) {
                relations.push({
                  from: `${tableName}.${colName}`,
                  to: `${targetTable}.id`,
                  fromTable: tableName,
                  fromColumn: colName,
                  toTable: targetTable,
                  toColumn: 'id',
                })
              }
            }
          }

          // OneToMany Relation (Virtual relation, never a database column)
          if (decName === 'OneToMany') {
            const args = dec.getArguments()
            let targetClassName: string | null = null
            let targetInverseProp: string | null = null

            // Determine target entity from argument 0: () => TargetClass or type
            if (args.length > 0) {
              const firstArg = args[0]
              if (Node.isArrowFunction(firstArg)) {
                const body = firstArg.getBody()
                if (Node.isIdentifier(body)) {
                  targetClassName = body.getText()
                }
              } else if (Node.isIdentifier(firstArg)) {
                targetClassName = firstArg.getText()
              }
            }

            if (!targetClassName) {
              const arrayType = prop.getType().getArrayElementType()
              const symbol = arrayType?.getSymbol() || prop.getType().getSymbol()
              if (symbol) {
                targetClassName = symbol.getName()
              }
            }

            // Determine inverse property name from argument 1: target => target.prop
            if (args.length > 1) {
              const secondArg = args[1]
              if (Node.isArrowFunction(secondArg)) {
                const body = secondArg.getBody()
                if (Node.isPropertyAccessExpression(body)) {
                  targetInverseProp = body.getName()
                }
              }
            }

            if (targetClassName) {
              const targetEntity = project
                .getSourceFiles()
                .flatMap(sf => sf.getClasses())
                .find(c => c.getName() === targetClassName)

              let targetTable = targetClassName.toLowerCase()
              const targetEntityDec = targetEntity?.getDecorator('Entity')
              if (targetEntityDec) {
                const arg = targetEntityDec.getArguments()[0]
                if (arg && Node.isStringLiteral(arg)) {
                  targetTable = arg.getLiteralValue()
                }
              }

              const fromCol = targetInverseProp || propName
              const relationExists = relations.some(
                r =>
                  r.fromTable === targetTable && r.toTable === tableName && r.fromColumn === fromCol
              )

              if (!relationExists) {
                relations.push({
                  from: `${targetTable}.${fromCol}`,
                  to: `${tableName}.id`,
                  fromTable: targetTable,
                  fromColumn: fromCol,
                  toTable: tableName,
                  toColumn: 'id',
                })
              }
            }
          }
        }

        // Virtual navigation properties (@OneToMany, @ManyToMany) are relations, not physical columns
        if (isOneToMany || isManyToMany) {
          continue
        }

        // Infer type: prefer custom column type over TS inferred type
        let typeStr: string
        if (customType) {
          typeStr = customType
        } else if (isFk && !isColumnLike) {
          typeStr = 'integer'
        } else {
          const tsType = cleanTsType(prop.getType().getText())
          typeStr = mapTsTypeToSql(tsType)
        }

        // Avoid adding duplicate column if already declared
        const existingCol = columns.find(c => c.name === colName)
        if (existingCol) {
          if (isFk) {
            existingCol.isForeignKey = true
            existingCol.references = refTarget
          }
          continue
        }

        columns.push({
          name: colName,
          type: typeStr,
          isPrimaryKey: isPk,
          isNullable: isNull,
          isUnique: isUnq,
          isForeignKey: isFk,
          defaultValue: null,
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

  return { tables, relations }
}

function cleanTsType(tsType: string): string {
  return tsType.replace(/import\([^)]+\)\./g, '')
}

function mapTsTypeToSql(tsType: string): string {
  const clean = cleanTsType(tsType).trim()
  const typeMap: Record<string, string> = {
    number: 'integer',
    string: 'varchar',
    boolean: 'boolean',
    Date: 'timestamp',
  }
  if (typeMap[clean]) return typeMap[clean]
  const lower = clean.toLowerCase()
  if (lower.endsWith('[]')) {
    const base = lower.slice(0, -2)
    return `${typeMap[base] || base}[]`
  }
  return typeMap[lower] || lower
}

function toPascalCase(name: string): string {
  if (!name) return ''
  return name.replace(/(?:^|_|-)+([a-z0-9])/gi, (_, c) => c.toUpperCase())
}

function mapSqlTypeToTs(sqlType: string): string {
  const t = sqlType.toLowerCase()
  if (
    t.includes('int') ||
    t.includes('serial') ||
    t.includes('numeric') ||
    t.includes('decimal') ||
    t.includes('float') ||
    t.includes('double') ||
    t.includes('real')
  ) {
    return 'number'
  }
  if (t.includes('bool')) return 'boolean'
  if (t.includes('time') || t.includes('date')) return 'Date'
  if (t.includes('json')) return 'Record<string, unknown>'
  if (t.endsWith('[]')) return 'string[]'
  return 'string'
}

/**
 * Converts internal CompiledTable[] and relations into clean, idiomatic TypeORM Entity classes
 */
export function tablesToTypeORM(tables: CompiledTable[], relations?: CompiledRelation[]): string {
  if (!tables || tables.length === 0) return ''

  const lines: string[] = [
    "import { Entity, PrimaryGeneratedColumn, PrimaryColumn, Column, ManyToOne, OneToMany, JoinColumn } from 'typeorm'",
    '',
  ]

  const relList = relations || []

  for (const table of tables) {
    const className = toPascalCase(table.name)
    lines.push(`@Entity('${table.name}')`)
    lines.push(`export class ${className} {`)

    // Columns
    for (const col of table.columns) {
      if (col.comment) {
        lines.push(`  // ${col.comment.replace(/\n/g, ' ')}`)
      }

      if (col.isPrimaryKey) {
        const isNumeric = /int|serial/i.test(col.type)
        if (isNumeric) {
          lines.push('  @PrimaryGeneratedColumn()')
          lines.push(`  ${col.name}: number`)
        } else if (/uuid/i.test(col.type)) {
          lines.push("  @PrimaryGeneratedColumn('uuid')")
          lines.push(`  ${col.name}: string`)
        } else {
          lines.push('  @PrimaryColumn()')
          lines.push(`  ${col.name}: ${mapSqlTypeToTs(col.type)}`)
        }
        lines.push('')
        continue
      }

      // Check if this column is a foreign key with a relation
      const fkRelation = relList.find(
        r =>
          (r.fromTable || r.from.split('.')[0]) === table.name &&
          (r.fromColumn || r.from.split('.')[1]) === col.name
      )

      if (fkRelation) {
        const targetTable = fkRelation.toTable || fkRelation.to.split('.')[0] || ''
        const targetClass = toPascalCase(targetTable)
        const relPropName = col.name.replace(/_id$/i, '') || col.name
        lines.push(`  @ManyToOne(() => ${targetClass})`)
        lines.push(`  @JoinColumn({ name: '${col.name}' })`)
        lines.push(`  ${relPropName}: ${targetClass}`)
        lines.push('')
        continue
      }

      // Normal column
      const colOptions: string[] = []
      const lowerType = col.type.toLowerCase()
      if (lowerType.includes('decimal') || lowerType.includes('numeric')) {
        colOptions.push("type: 'decimal'")
      } else if (lowerType === 'text') {
        colOptions.push("type: 'text'")
      }

      if (col.isUnique) {
        colOptions.push('unique: true')
      }
      if (!col.isNullable) {
        colOptions.push('nullable: false')
      }

      const optStr = colOptions.length > 0 ? `{ ${colOptions.join(', ')} }` : ''
      lines.push(`  @Column(${optStr})`)
      lines.push(`  ${col.name}: ${mapSqlTypeToTs(col.type)}`)
      lines.push('')
    }

    // Inverse relations (OneToMany)
    const inverseRels = relList.filter(r => (r.toTable || r.to.split('.')[0]) === table.name)
    for (const inv of inverseRels) {
      const invFromTable = inv.fromTable || inv.from.split('.')[0] || ''
      const invFromCol = inv.fromColumn || inv.from.split('.')[1] || ''
      const sourceClass = toPascalCase(invFromTable)
      const propName = invFromTable
      const relPropName = invFromCol.replace(/_id$/i, '') || invFromCol
      lines.push(
        `  @OneToMany(() => ${sourceClass}, (${sourceClass.toLowerCase()}) => ${sourceClass.toLowerCase()}.${relPropName})`
      )
      lines.push(`  ${propName}: ${sourceClass}[]`)
      lines.push('')
    }

    lines.push('}')
    lines.push('')
  }

  return lines.join('\n').trim()
}

/**
 * Converts TypeORM entity TypeScript code into standard SQL DDL
 */
export function typeormToSql(typeormCode: string): string {
  const schema = compileTypeORM(typeormCode)
  if (!schema.tables || schema.tables.length === 0) return ''
  return dbmlToSql(tablesToDbml(schema.tables, schema.relations))
}

/**
 * Converts TypeORM entity TypeScript code into DBML format
 */
export function typeormToDbml(typeormCode: string): string {
  const schema = compileTypeORM(typeormCode)
  if (!schema.tables || schema.tables.length === 0) return ''
  return tablesToDbml(schema.tables, schema.relations)
}

/**
 * Converts TypeORM entity TypeScript code into Prisma Schema format
 */
export function typeormToPrisma(typeormCode: string): string {
  const schema = compileTypeORM(typeormCode)
  if (!schema.tables || schema.tables.length === 0) return ''
  return tablesToPrisma(schema.tables, schema.relations)
}
