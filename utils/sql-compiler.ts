export interface ColumnCheckCondition {
  raw: string
  humanReadable: string
}

export interface CompiledColumn {
  name: string
  type: string
  isPrimaryKey: boolean
  isNullable: boolean
  isUnique: boolean
  isForeignKey: boolean
  defaultValue?: string | null
  references?: {
    table: string
    column: string
  } | null
  comment?: string | null
  checkCondition?: ColumnCheckCondition | null
  constraintsList?: string[]
}

export interface CompiledTable {
  name: string
  columns: CompiledColumn[]
  comment?: string | null
}

export interface CompiledRelation {
  from: string // e.g. "posts.user_id"
  to: string   // e.g. "users.id"
  fromTable?: string
  fromColumn?: string
  toTable?: string
  toColumn?: string
}

export interface CompiledSchema {
  tables: CompiledTable[]
  relations: CompiledRelation[]
}

/**
 * Normalizes PostgreSQL internal type representations into human-readable SQL types
 */
function normalizeTypeName(typeNameObj: any): string {
  if (!typeNameObj) return 'text'

  const names = typeNameObj.names || []
  let rawName =
    names
      .map((n: any) => n?.String?.sval || n?.sval || '')
      .filter((n: string) => n && n !== 'pg_catalog')
      .join('.')
      .toLowerCase() || 'text'

  // Map PostgreSQL internal aliases to standard SQL names
  const typeMap: Record<string, string> = {
    int4: 'integer',
    int8: 'bigint',
    int2: 'smallint',
    bool: 'boolean',
    float4: 'real',
    float8: 'double precision',
    timestamptz: 'timestamptz',
    timestamp: 'timestamp',
    timetz: 'timetz',
    time: 'time',
    varchar: 'varchar',
    bpchar: 'char',
  }

  if (typeMap[rawName]) {
    rawName = typeMap[rawName]
  }

  // Handle typmods (e.g. varchar(255), numeric(10, 2))
  if (Array.isArray(typeNameObj.typmods) && typeNameObj.typmods.length > 0) {
    const mods = typeNameObj.typmods
      .map((mod: any) => {
        if (mod?.A_Const?.ival?.ival !== undefined) return mod.A_Const.ival.ival
        if (mod?.A_Const?.fval?.fval !== undefined) return mod.A_Const.fval.fval
        if (mod?.A_Const?.sval?.sval !== undefined) return `'${mod.A_Const.sval.sval}'`
        return null
      })
      .filter((v: any) => v !== null)

    if (mods.length > 0) {
      rawName += `(${mods.join(', ')})`
    }
  }

  // Handle Array types (e.g. text[])
  if (Array.isArray(typeNameObj.arrayBounds) && typeNameObj.arrayBounds.length > 0) {
    rawName += '[]'
  }

  return rawName
}

/**
 * Stringifies raw AST expressions into readable SQL strings, replacing wildcard references with the actual column name
 */
export function rawExprToString(expr: any, defaultColName = ''): string {
  if (!expr) return ''

  // Constant literals (numbers, strings, booleans, null)
  if (expr.A_Const) {
    const c = expr.A_Const
    if (c.ival?.ival !== undefined) return String(c.ival.ival)
    if (c.fval?.fval !== undefined) return String(c.fval.fval)
    if (c.sval?.sval !== undefined) return `'${c.sval.sval}'`
    if (c.boolval?.boolval !== undefined) return String(c.boolval.boolval)
    if (c.isnull) return 'NULL'
    return '0'
  }

  // Column identifiers
  if (expr.ColumnRef) {
    const fields = expr.ColumnRef.fields || []
    const strFields = fields
      .map((f: any) => {
        if (f?.A_Star) return defaultColName || '*'
        return f?.String?.sval || ''
      })
      .filter(Boolean)

    if (!strFields.length && defaultColName) {
      return defaultColName
    }
    return strFields.join('.')
  }

  // Function calls (e.g. length(title), now())
  if (expr.FuncCall) {
    const fnNames = expr.FuncCall.funcname || []
    const fnName = fnNames.map((n: any) => n?.String?.sval || '').filter(Boolean).join('.')
    const args = (expr.FuncCall.args || []).map((arg: any) => rawExprToString(arg, defaultColName)).join(', ')
    return `${fnName}(${args})`
  }

  // TypeCast (e.g. 'active'::text)
  if (expr.TypeCast) {
    return rawExprToString(expr.TypeCast.arg, defaultColName)
  }

  // Binary / Comparison Expressions (A_Expr)
  if (expr.A_Expr) {
    const ae = expr.A_Expr
    const op = (ae.name || []).map((n: any) => n?.String?.sval || '').join('')
    const left = rawExprToString(ae.lexpr, defaultColName)

    // IN / NOT IN list expressions
    if (ae.kind === 'AEXPR_IN') {
      const isNotIn = op === '<>' || op === '!='
      const listItems = (ae.rexpr?.List?.items || []).map((item: any) => rawExprToString(item, defaultColName))
      return `${left} ${isNotIn ? 'NOT IN' : 'IN'} (${listItems.join(', ')})`
    }

    // LIKE / ILIKE / BETWEEN / Operators
    if (ae.kind === 'AEXPR_LIKE') {
      const right = rawExprToString(ae.rexpr, defaultColName)
      return `${left} LIKE ${right}`
    }

    const right = rawExprToString(ae.rexpr, defaultColName)
    return `${left} ${op || '='} ${right}`
  }

  // Boolean logic (AND, OR, NOT)
  if (expr.BoolExpr) {
    const be = expr.BoolExpr
    const boolOp = be.boolop === 0 ? 'AND' : be.boolop === 1 ? 'OR' : 'NOT'
    const args = (be.args || []).map((arg: any) => rawExprToString(arg, defaultColName))
    if (boolOp === 'NOT') {
      return `NOT (${args.join('')})`
    }
    return args.join(` ${boolOp} `)
  }

  // Null Test (IS NULL, IS NOT NULL)
  if (expr.NullTest) {
    const nt = expr.NullTest
    const arg = rawExprToString(nt.arg, defaultColName)
    return `${arg} ${nt.nulltesttype === 1 ? 'IS NOT NULL' : 'IS NULL'}`
  }

  return defaultColName || ''
}

/**
 * Interprets SQL CHECK constraints into friendly, human-readable sentences
 */
export function interpretCheckCondition(rawCondition: string): string {
  if (!rawCondition) return ''

  let trimmed = rawCondition.trim()
  if (trimmed.startsWith('(') && trimmed.endsWith(')')) {
    trimmed = trimmed.slice(1, -1).trim()
  }

  // Matches: length(column) >= value
  const lenMatch = trimmed.match(/^length\((.+?)\)\s*(>=|<=|>|<|=)\s*(\d+)$/i)
  if (lenMatch) {
    const [, col, op, val] = lenMatch
    switch (op) {
      case '>':
        return `length of ${col} must be greater than ${val} characters`
      case '>=':
        return `length of ${col} must be at least ${val} characters`
      case '<':
        return `length of ${col} must be less than ${val} characters`
      case '<=':
        return `length of ${col} must be at most ${val} characters`
      case '=':
        return `length of ${col} must be exactly ${val} characters`
    }
  }

  // Matches: column IN ('a', 'b', 'c')
  const inMatch = trimmed.match(/^([a-zA-Z0-9_.]+)\s+IN\s*\(([\s\S]+)\)$/i)
  if (inMatch) {
    const [, col, list] = inMatch
    const cleanList = list
      .split(',')
      .map((item) => item.trim().replace(/^['"]|['"]$/g, ''))
      .join(', ')
    return `${col} must be one of: ${cleanList}`
  }

  // Matches: column NOT IN ('a', 'b')
  const notInMatch = trimmed.match(/^([a-zA-Z0-9_.]+)\s+NOT\s+IN\s*\(([\s\S]+)\)$/i)
  if (notInMatch) {
    const [, col, list] = notInMatch
    const cleanList = list
      .split(',')
      .map((item) => item.trim().replace(/^['"]|['"]$/g, ''))
      .join(', ')
    return `${col} cannot be any of: ${cleanList}`
  }

  // Matches: column LIKE '%pattern%'
  const likeMatch = trimmed.match(/^([a-zA-Z0-9_.]+)\s+LIKE\s+(.+)$/i)
  if (likeMatch) {
    const [, col, pattern] = likeMatch
    return `${col} must match pattern ${pattern.trim()}`
  }

  // Matches: column > value / column >= value / column < value / column <= value / column = value
  const compMatch = trimmed.match(/^([a-zA-Z0-9_.]+)\s*(>=|<=|!=|<>|>|<|=)\s*(.+)$/i)
  if (compMatch) {
    const [, col, op, val] = compMatch
    const cleanVal = val.trim()

    switch (op) {
      case '>':
        return `${col} must be greater than ${cleanVal}`
      case '>=':
        return `${col} must be at least ${cleanVal}`
      case '<':
        return `${col} must be less than ${cleanVal}`
      case '<=':
        return `${col} must be at most ${cleanVal}`
      case '=':
        return `${col} must equal ${cleanVal}`
      case '!=':
      case '<>':
        return `${col} cannot equal ${cleanVal}`
    }
  }

  return `Condition: ${trimmed}`
}

/**
 * Extracts default value string from raw_expr AST node
 */
function extractDefaultExpr(rawExpr: any, defaultColName = ''): string | null {
  const str = rawExprToString(rawExpr, defaultColName)
  return str || null
}

/**
 * Compiles a pg-query AST (Abstract Syntax Tree) into a diagram-ready schema structure
 */
export function compilePgAst(ast: any): CompiledSchema {
  const tables: CompiledTable[] = []
  const relations: CompiledRelation[] = []

  if (!ast) {
    return { tables, relations }
  }

  const stmts = ast.stmts || []

  // Map to collect column and table comments across statements
  const columnCommentsMap: Record<string, string> = {} // key: "table.column"
  const tableCommentsMap: Record<string, string> = {}  // key: "table"

  // Pass 1: Collect all comments (COMMENT ON TABLE / COMMENT ON COLUMN)
  for (const stmtWrapper of stmts) {
    const stmt = stmtWrapper?.stmt || stmtWrapper
    const commentStmt = stmt?.CommentStmt

    if (commentStmt && commentStmt.comment) {
      const objtype = commentStmt.objtype
      const items = commentStmt.object?.List?.items || []

      // COMMENT ON COLUMN table.column IS '...'
      if (objtype === 'OBJECT_COLUMN' || objtype === 8) {
        if (items.length >= 2) {
          const tbl = items[0]?.String?.sval || ''
          const col = items[1]?.String?.sval || ''
          if (tbl && col) {
            columnCommentsMap[`${tbl}.${col}`] = commentStmt.comment
          }
        }
      }

      // COMMENT ON TABLE table IS '...'
      if (objtype === 'OBJECT_TABLE' || objtype === 36) {
        if (items.length >= 1) {
          const tbl = items[0]?.String?.sval || ''
          if (tbl) {
            tableCommentsMap[tbl] = commentStmt.comment
          }
        }
      }
    }
  }

  // Pass 2: Parse table definitions (CREATE TABLE)
  for (const stmtWrapper of stmts) {
    const stmt = stmtWrapper?.stmt || stmtWrapper
    const createStmt = stmt?.CreateStmt

    if (!createStmt) continue

    const tableName = createStmt.relation?.relname || 'unnamed_table'
    const columns: CompiledColumn[] = []
    const tableLevelPrimaryKeys = new Set<string>()
    const tableLevelUniques = new Set<string>()
    const tableLevelChecks: Record<string, ColumnCheckCondition> = {}

    const tableElts = createStmt.tableElts || []

    // Step A: Parse Column Definitions & Inline Constraints
    for (const elt of tableElts) {
      const colDef = elt?.ColumnDef
      if (!colDef) continue

      const colName = colDef.colname
      let typeStr = normalizeTypeName(colDef.typeName)
      let isPk = false
      let isNotNull = Boolean(colDef.is_not_null)
      let isUnq = false
      let isFk = false
      let defaultVal: string | null = null
      let refTarget: { table: string; column: string } | null = null
      let checkCond: ColumnCheckCondition | null = null
      const constraintsList: string[] = []

      const constraints = colDef.constraints || []
      for (const c of constraints) {
        const constraint = c?.Constraint
        if (!constraint) continue

        const contype = constraint.contype

        // Primary Key
        if (contype === 'CONSTR_PRIMARY' || contype === 4) {
          isPk = true
          isNotNull = true
          constraintsList.push('PRIMARY KEY')
        }
        // Not Null
        if (contype === 'CONSTR_NOTNULL' || contype === 1) {
          isNotNull = true
          constraintsList.push('NOT NULL')
        }
        // Unique
        if (contype === 'CONSTR_UNIQUE' || contype === 5) {
          isUnq = true
          constraintsList.push('UNIQUE')
        }
        // Default value
        if (contype === 'CONSTR_DEFAULT' || contype === 2) {
          defaultVal = extractDefaultExpr(constraint.raw_expr, colName)
          if (defaultVal) {
            constraintsList.push(`DEFAULT ${defaultVal}`)
          }
        }
        // CHECK Constraint (Column-level)
        if (contype === 'CONSTR_CHECK' || contype === 3) {
          const rawSql = rawExprToString(constraint.raw_expr, colName)
          if (rawSql) {
            checkCond = {
              raw: rawSql,
              humanReadable: interpretCheckCondition(rawSql),
            }
            constraintsList.push(`CHECK (${rawSql})`)
          }
        }
        // Foreign Key (Column-level)
        if (contype === 'CONSTR_FOREIGN' || contype === 7 || constraint.pktable) {
          const targetTable = constraint.pktable?.relname || ''
          const targetCol = constraint.pk_attrs?.[0]?.String?.sval || 'id'
          if (targetTable) {
            isFk = true
            refTarget = { table: targetTable, column: targetCol }
            constraintsList.push(`REFERENCES ${targetTable}(${targetCol})`)
            relations.push({
              from: `${tableName}.${colName}`,
              to: `${targetTable}.${targetCol}`,
              fromTable: tableName,
              fromColumn: colName,
              toTable: targetTable,
              toColumn: targetCol,
            })
          }
        }
      }

      // Check if type is SERIAL shorthand
      if (typeStr === 'serial' || typeStr === 'bigserial' || typeStr === 'smallserial') {
        isNotNull = true
        if (!constraintsList.includes('NOT NULL') && !isPk) {
          constraintsList.push('NOT NULL')
        }
      }

      // Check comment for this column
      const commentKey = `${tableName}.${colName}`
      const colComment = columnCommentsMap[commentKey] || null

      columns.push({
        name: colName,
        type: typeStr,
        isPrimaryKey: isPk,
        isNullable: !isNotNull && !isPk,
        isUnique: isUnq,
        isForeignKey: isFk,
        defaultValue: defaultVal,
        references: refTarget,
        comment: colComment,
        checkCondition: checkCond,
        constraintsList,
      })
    }

    // Step B: Parse Table-Level Constraints
    for (const elt of tableElts) {
      const constraint = elt?.Constraint
      if (!constraint) continue

      const contype = constraint.contype

      // Table-level PRIMARY KEY (col1, col2, ...)
      if ((contype === 'CONSTR_PRIMARY' || contype === 4) && Array.isArray(constraint.keys)) {
        for (const k of constraint.keys) {
          const pkCol = k?.String?.sval
          if (pkCol) {
            tableLevelPrimaryKeys.add(pkCol)
          }
        }
      }

      // Table-level UNIQUE (col1, col2, ...)
      if ((contype === 'CONSTR_UNIQUE' || contype === 5) && Array.isArray(constraint.keys)) {
        for (const k of constraint.keys) {
          const unqCol = k?.String?.sval
          if (unqCol) {
            tableLevelUniques.add(unqCol)
          }
        }
      }

      // Table-level CHECK (expr)
      if (contype === 'CONSTR_CHECK' || contype === 3) {
        const rawSql = rawExprToString(constraint.raw_expr)
        if (rawSql) {
          const foundCol = columns.find((c) => rawSql.includes(c.name))
          const colName = foundCol?.name || ''
          const humanReadable = interpretCheckCondition(rawSql)

          if (foundCol) {
            tableLevelChecks[colName] = {
              raw: rawSql,
              humanReadable,
            }
          }
        }
      }

      // Table-level FOREIGN KEY (col1) REFERENCES target_table (col2)
      if (
        (contype === 'CONSTR_FOREIGN' || contype === 7) &&
        constraint.pktable &&
        Array.isArray(constraint.fk_attrs)
      ) {
        const targetTable = constraint.pktable?.relname || ''
        const fkCols = constraint.fk_attrs || []
        const pkCols = constraint.pk_attrs || []

        fkCols.forEach((src: any, idx: number) => {
          const srcColName = src?.String?.sval || ''
          const tgtColName = pkCols[idx]?.String?.sval || 'id'

          if (srcColName && targetTable) {
            const col = columns.find((c) => c.name === srcColName)
            if (col) {
              col.isForeignKey = true
              col.references = { table: targetTable, column: tgtColName }
              if (!col.constraintsList?.some((cl) => cl.startsWith('REFERENCES'))) {
                col.constraintsList?.push(`REFERENCES ${targetTable}(${tgtColName})`)
              }
            }

            relations.push({
              from: `${tableName}.${srcColName}`,
              to: `${targetTable}.${tgtColName}`,
              fromTable: tableName,
              fromColumn: srcColName,
              toTable: targetTable,
              toColumn: tgtColName,
            })
          }
        })
      }
    }

    // Apply table-level primary keys, uniques, and check conditions
    for (const col of columns) {
      if (tableLevelPrimaryKeys.has(col.name)) {
        col.isPrimaryKey = true
        col.isNullable = false
        if (!col.constraintsList?.includes('PRIMARY KEY')) {
          col.constraintsList?.unshift('PRIMARY KEY')
        }
      }
      if (tableLevelUniques.has(col.name)) {
        col.isUnique = true
        if (!col.constraintsList?.includes('UNIQUE')) {
          col.constraintsList?.push('UNIQUE')
        }
      }
      if (!col.checkCondition && tableLevelChecks[col.name]) {
        col.checkCondition = tableLevelChecks[col.name]
        col.constraintsList?.push(`CHECK (${col.checkCondition.raw})`)
      }
    }

    tables.push({
      name: tableName,
      columns,
      comment: tableCommentsMap[tableName] || null,
    })
  }

  return {
    tables,
    relations,
  }
}
