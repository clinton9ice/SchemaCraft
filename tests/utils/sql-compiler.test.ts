import { describe, it, expect } from 'vitest'
import { compilePgAst, rawExprToString, interpretCheckCondition } from '../../utils/sql-compiler'

describe('SQL Compiler Utility Functions', () => {
  describe('rawExprToString', () => {
    it('should handle constant literals', () => {
      expect(rawExprToString({ A_Const: { ival: { ival: 10 } } })).toBe('10')
      expect(rawExprToString({ A_Const: { fval: { fval: 12.34 } } })).toBe('12.34')
      expect(rawExprToString({ A_Const: { sval: { sval: 'hello' } } })).toBe("'hello'")
      expect(rawExprToString({ A_Const: { boolval: { boolval: true } } })).toBe('true')
      expect(rawExprToString({ A_Const: { isnull: true } })).toBe('NULL')
      expect(rawExprToString({})).toBe('')
    })

    it('should handle column references', () => {
      expect(rawExprToString({ ColumnRef: { fields: [{ String: { sval: 'user_id' } }] } })).toBe(
        'user_id'
      )
      expect(rawExprToString({ ColumnRef: { fields: [{ A_Star: true }] } }, 'id')).toBe('id')
      expect(rawExprToString({ ColumnRef: { fields: [{ A_Star: true }] } })).toBe('*')
      expect(rawExprToString({ ColumnRef: { fields: [] } }, 'id')).toBe('id')
      expect(rawExprToString({ ColumnRef: { fields: [] } })).toBe('')
    })

    it('should handle function calls', () => {
      expect(
        rawExprToString({
          FuncCall: {
            funcname: [{ String: { sval: 'length' } }],
            args: [{ ColumnRef: { fields: [{ String: { sval: 'name' } }] } }],
          },
        })
      ).toBe('length(name)')
      expect(
        rawExprToString({
          FuncCall: {
            funcname: [],
            args: [],
          },
        })
      ).toBe('()')
    })

    it('should handle type casts', () => {
      expect(
        rawExprToString({
          TypeCast: { arg: { A_Const: { sval: { sval: 'active' } } } },
        })
      ).toBe("'active'")
    })

    it('should handle A_Expr (comparisons and operators)', () => {
      // Simple comparison
      expect(
        rawExprToString({
          A_Expr: {
            lexpr: { ColumnRef: { fields: [{ String: { sval: 'age' } }] } },
            name: [{ String: { sval: '>' } }],
            rexpr: { A_Const: { ival: { ival: 18 } } },
            kind: 'AEXPR_OP',
          },
        })
      ).toBe('age > 18')

      // IN expression
      expect(
        rawExprToString({
          A_Expr: {
            lexpr: { ColumnRef: { fields: [{ String: { sval: 'status' } }] } },
            name: [{ String: { sval: '=' } }],
            rexpr: {
              List: {
                items: [
                  { A_Const: { sval: { sval: 'active' } } },
                  { A_Const: { sval: { sval: 'pending' } } },
                ],
              },
            },
            kind: 'AEXPR_IN',
          },
        })
      ).toBe("status IN ('active', 'pending')")

      // NOT IN expression
      expect(
        rawExprToString({
          A_Expr: {
            lexpr: { ColumnRef: { fields: [{ String: { sval: 'status' } }] } },
            name: [{ String: { sval: '<>' } }],
            rexpr: { List: { items: [{ A_Const: { sval: { sval: 'deleted' } } }] } },
            kind: 'AEXPR_IN',
          },
        })
      ).toBe("status NOT IN ('deleted')")

      // LIKE expression
      expect(
        rawExprToString({
          A_Expr: {
            lexpr: { ColumnRef: { fields: [{ String: { sval: 'email' } }] } },
            rexpr: { A_Const: { sval: { sval: '%@gmail.com' } } },
            kind: 'AEXPR_LIKE',
          },
        })
      ).toBe("email LIKE '%@gmail.com'")
    })

    it('should handle boolean expressions', () => {
      // AND
      expect(
        rawExprToString({
          BoolExpr: {
            boolop: 0,
            args: [
              { A_Const: { boolval: { boolval: true } } },
              { A_Const: { boolval: { boolval: false } } },
            ],
          },
        })
      ).toBe('true AND false')

      // OR
      expect(
        rawExprToString({
          BoolExpr: {
            boolop: 1,
            args: [
              { A_Const: { boolval: { boolval: true } } },
              { A_Const: { boolval: { boolval: false } } },
            ],
          },
        })
      ).toBe('true OR false')

      // NOT
      expect(
        rawExprToString({
          BoolExpr: {
            boolop: 2,
            args: [{ A_Const: { boolval: { boolval: true } } }],
          },
        })
      ).toBe('NOT (true)')
    })

    it('should handle null tests', () => {
      expect(
        rawExprToString({
          NullTest: {
            arg: { ColumnRef: { fields: [{ String: { sval: 'deleted_at' } }] } },
            nulltesttype: 0,
          },
        })
      ).toBe('deleted_at IS NULL')

      expect(
        rawExprToString({
          NullTest: {
            arg: { ColumnRef: { fields: [{ String: { sval: 'deleted_at' } }] } },
            nulltesttype: 1,
          },
        })
      ).toBe('deleted_at IS NOT NULL')
    })
  })

  describe('interpretCheckCondition', () => {
    it('should handle length checks', () => {
      expect(interpretCheckCondition('length(name) >= 3')).toBe(
        'length of name must be at least 3 characters'
      )
      expect(interpretCheckCondition('length(name) > 3')).toBe(
        'length of name must be greater than 3 characters'
      )
      expect(interpretCheckCondition('length(name) < 3')).toBe(
        'length of name must be less than 3 characters'
      )
      expect(interpretCheckCondition('length(name) <= 3')).toBe(
        'length of name must be at most 3 characters'
      )
      expect(interpretCheckCondition('length(name) = 3')).toBe(
        'length of name must be exactly 3 characters'
      )
    })

    it('should handle IN checks', () => {
      expect(interpretCheckCondition("status IN ('active', 'pending')")).toBe(
        'status must be one of: active, pending'
      )
    })

    it('should handle NOT IN checks', () => {
      expect(interpretCheckCondition("status NOT IN ('deleted')")).toBe(
        'status cannot be any of: deleted'
      )
    })

    it('should handle LIKE checks', () => {
      expect(interpretCheckCondition("email LIKE '%@gmail.com'")).toBe(
        "email must match pattern '%@gmail.com'"
      )
    })

    it('should handle comparison checks', () => {
      expect(interpretCheckCondition('age >= 18')).toBe('age must be at least 18')
      expect(interpretCheckCondition('age > 18')).toBe('age must be greater than 18')
      expect(interpretCheckCondition('age <= 18')).toBe('age must be at most 18')
      expect(interpretCheckCondition('age < 18')).toBe('age must be less than 18')
      expect(interpretCheckCondition('age = 18')).toBe('age must equal 18')
      expect(interpretCheckCondition('age != 18')).toBe('age cannot equal 18')
      expect(interpretCheckCondition('age <> 18')).toBe('age cannot equal 18')
    })

    it('should handle unknown conditions', () => {
      expect(interpretCheckCondition('complex_check(col)')).toBe('Condition: complex_check(col)')
    })

    it('should handle empty input', () => {
      expect(interpretCheckCondition('')).toBe('')
    })
  })

  describe('compilePgAst', () => {
    it('should handle null AST', () => {
      expect(compilePgAst(null)).toEqual({ tables: [], relations: [] })
    })

    it('should handle empty AST', () => {
      expect(compilePgAst({})).toEqual({ tables: [], relations: [] })
    })

    it('should compile a simple table with basic columns', () => {
      const ast = {
        stmts: [
          {
            stmt: {
              CreateStmt: {
                relation: { relname: 'users' },
                tableElts: [
                  {
                    ColumnDef: {
                      colname: 'id',
                      typeName: { names: [{ String: { sval: 'int4' } }] },
                      is_not_null: true,
                      constraints: [
                        {
                          Constraint: {
                            contype: 4, // PRIMARY KEY
                          },
                        },
                      ],
                    },
                  },
                  {
                    ColumnDef: {
                      colname: 'username',
                      typeName: {
                        names: [{ String: { sval: 'varchar' } }],
                        typmods: [{ A_Const: { ival: { ival: 255 } } }],
                      },
                      is_not_null: true,
                      constraints: [
                        {
                          Constraint: {
                            contype: 5, // UNIQUE
                          },
                        },
                      ],
                    },
                  },
                ],
              },
            },
          },
        ],
      }

      const result = compilePgAst(ast)
      expect(result.tables[0].name).toBe('users')
      expect(result.tables[0].columns[0].name).toBe('id')
      expect(result.tables[0].columns[0].isPrimaryKey).toBe(true)
      expect(result.tables[0].columns[1].name).toBe('username')
      expect(result.tables[0].columns[1].type).toBe('varchar(255)')
      expect(result.tables[0].columns[1].isUnique).toBe(true)
    })

    it('should handle composite primary keys and table-level constraints', () => {
      const ast = {
        stmts: [
          {
            stmt: {
              CreateStmt: {
                relation: { relname: 'user_roles' },
                tableElts: [
                  {
                    ColumnDef: {
                      colname: 'user_id',
                      typeName: { names: [{ String: { sval: 'int4' } }] },
                      is_not_null: true,
                    },
                  },
                  {
                    ColumnDef: {
                      colname: 'role_id',
                      typeName: { names: [{ String: { sval: 'int4' } }] },
                      is_not_null: true,
                    },
                  },
                  {
                    Constraint: {
                      contype: 4, // PRIMARY KEY
                      keys: [{ String: { sval: 'user_id' } }, { String: { sval: 'role_id' } }],
                    },
                  },
                ],
              },
            },
          },
        ],
      }

      const result = compilePgAst(ast)
      expect(result.tables[0].columns.find(c => c.name === 'user_id')?.isPrimaryKey).toBe(true)
      expect(result.tables[0].columns.find(c => c.name === 'role_id')?.isPrimaryKey).toBe(true)
    })

    it('should handle table-level check constraints', () => {
      const ast = {
        stmts: [
          {
            stmt: {
              CreateStmt: {
                relation: { relname: 'products' },
                tableElts: [
                  {
                    ColumnDef: {
                      colname: 'price',
                      typeName: { names: [{ String: { sval: 'numeric' } }] },
                    },
                  },
                  {
                    Constraint: {
                      contype: 3, // CHECK
                      raw_expr: {
                        A_Expr: {
                          lexpr: { ColumnRef: { fields: [{ String: { sval: 'price' } }] } },
                          name: [{ String: { sval: '>' } }],
                          rexpr: { A_Const: { ival: { ival: 0 } } },
                          kind: 'AEXPR_OP',
                        },
                      },
                    },
                  },
                ],
              },
            },
          },
        ],
      }

      const result = compilePgAst(ast)
      const priceCol = result.tables[0].columns.find(c => c.name === 'price')
      expect(priceCol?.checkCondition?.raw).toBe('price > 0')
      expect(priceCol?.checkCondition?.humanReadable).toBe('price must be greater than 0')
    })

    it('should handle column-level foreign keys', () => {
      const ast = {
        stmts: [
          {
            stmt: {
              CreateStmt: {
                relation: { relname: 'posts' },
                tableElts: [
                  {
                    ColumnDef: {
                      colname: 'user_id',
                      typeName: { names: [{ String: { sval: 'int4' } }] },
                      constraints: [
                        {
                          Constraint: {
                            contype: 7, // FOREIGN KEY
                            pktable: { relname: 'users' },
                            pk_attrs: [{ String: { sval: 'id' } }],
                          },
                        },
                      ],
                    },
                  },
                ],
              },
            },
          },
        ],
      }

      const result = compilePgAst(ast)
      expect(result.tables[0].columns[0].isForeignKey).toBe(true)
      expect(result.tables[0].columns[0].references).toEqual({ table: 'users', column: 'id' })
      expect(result.relations[0]).toEqual({
        from: 'posts.user_id',
        to: 'users.id',
        fromTable: 'posts',
        fromColumn: 'user_id',
        toTable: 'users',
        toColumn: 'id',
      })
    })

    it('should handle table-level foreign keys', () => {
      const ast = {
        stmts: [
          {
            stmt: {
              CreateStmt: {
                relation: { relname: 'posts' },
                tableElts: [
                  {
                    ColumnDef: {
                      colname: 'user_id',
                      typeName: { names: [{ String: { sval: 'int4' } }] },
                    },
                  },
                  {
                    Constraint: {
                      contype: 7, // FOREIGN KEY
                      pktable: { relname: 'users' },
                      fk_attrs: [{ String: { sval: 'user_id' } }],
                      pk_attrs: [{ String: { sval: 'id' } }],
                    },
                  },
                ],
              },
            },
          },
        ],
      }

      const result = compilePgAst(ast)
      expect(result.tables[0].columns[0].isForeignKey).toBe(true)
      expect(result.relations[0].from).toBe('posts.user_id')
    })

    it('should handle comments on tables and columns', () => {
      const ast = {
        stmts: [
          {
            stmt: {
              CommentStmt: {
                objtype: 'OBJECT_TABLE',
                object: { List: { items: [{ String: { sval: 'users' } }] } },
                comment: 'The users table stores account info',
              },
            },
          },
          {
            stmt: {
              CommentStmt: {
                objtype: 'OBJECT_COLUMN',
                object: {
                  List: { items: [{ String: { sval: 'users' } }, { String: { sval: 'email' } }] },
                },
                comment: 'The primary contact email',
              },
            },
          },
          {
            stmt: {
              CreateStmt: {
                relation: { relname: 'users' },
                tableElts: [
                  {
                    ColumnDef: {
                      colname: 'email',
                      typeName: { names: [{ String: { sval: 'text' } }] },
                    },
                  },
                ],
              },
            },
          },
        ],
      }

      const result = compilePgAst(ast)
      expect(result.tables[0].comment).toBe('The users table stores account info')
      expect(result.tables[0].columns[0].comment).toBe('The primary contact email')
    })

    it('should handle SERIAL types', () => {
      const ast = {
        stmts: [
          {
            stmt: {
              CreateStmt: {
                relation: { relname: 'logs' },
                tableElts: [
                  {
                    ColumnDef: {
                      colname: 'id',
                      typeName: { names: [{ String: { sval: 'serial' } }] },
                    },
                  },
                ],
              },
            },
          },
        ],
      }

      const result = compilePgAst(ast)
      expect(result.tables[0].columns[0].isNullable).toBe(false)
      expect(result.tables[0].columns[0].constraintsList).toContain('NOT NULL')
    })

    it('should handle complex type names with typmods and arrays', () => {
      const ast = {
        stmts: [
          {
            stmt: {
              CreateStmt: {
                relation: { relname: 'test' },
                tableElts: [
                  {
                    ColumnDef: {
                      colname: 'c1',
                      typeName: {
                        names: [{ String: { sval: 'numeric' } }],
                        typmods: [
                          { A_Const: { ival: { ival: 10 } } },
                          { A_Const: { ival: { ival: 2 } } },
                        ],
                      },
                    },
                  },
                  {
                    ColumnDef: {
                      colname: 'c2',
                      typeName: {
                        names: [{ String: { sval: 'text' } }],
                        arrayBounds: [{}],
                      },
                    },
                  },
                ],
              },
            },
          },
        ],
      }

      const result = compilePgAst(ast)
      expect(result.tables[0].columns[0].type).toBe('numeric(10, 2)')
      expect(result.tables[0].columns[1].type).toBe('text[]')
    })
  })
})
