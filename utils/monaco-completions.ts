import type * as monacoType from 'monaco-editor'
import type { CompiledSchema } from '~/utils/sql-compiler'

export interface CompletionProviderContext {
  getSchema?: () => CompiledSchema
}

let disposables: monacoType.IDisposable[] = []

/**
 * Builds standard replacement range based on the word under cursor
 */
export function getWordRange(
  model: monacoType.editor.ITextModel,
  position: monacoType.Position
): monacoType.IRange {
  const word = model.getWordUntilPosition(position)
  return {
    startLineNumber: position.lineNumber,
    endLineNumber: position.lineNumber,
    startColumn: word.startColumn,
    endColumn: word.endColumn,
  }
}

/**
 * SQL Language Completion Provider (PostgreSQL & Standard SQL DDL)
 */
export function getSqlCompletions(
  monaco: typeof monacoType,
  model: monacoType.editor.ITextModel,
  position: monacoType.Position,
  context?: CompletionProviderContext
): monacoType.languages.CompletionItem[] {
  const range = getWordRange(model, position)
  const lineContent = model.getLineContent(position.lineNumber)
  const lineBeforeCursor = lineContent.slice(0, position.column - 1)
  const schema = context?.getSchema ? context.getSchema() : { tables: [], relations: [] }
  const tableNames = schema.tables.map((t) => t.name)

  const items: monacoType.languages.CompletionItem[] = []

  // Contextual Foreign Key / REFERENCES Table suggestions
  const isAfterReferences = /REFERENCES\s+([a-zA-Z0-9_]*)$/i.test(lineBeforeCursor)
  const isInsideReferenceColumns = /REFERENCES\s+([a-zA-Z0-9_]+)\s*\(([^)]*)$/i.test(lineBeforeCursor)

  if (isInsideReferenceColumns) {
    const match = lineBeforeCursor.match(/REFERENCES\s+([a-zA-Z0-9_]+)\s*\(([^)]*)$/i)
    const targetTableName = match ? match[1] : ''
    const targetTable = schema.tables.find(
      (t) => t.name.toLowerCase() === targetTableName.toLowerCase()
    )
    if (targetTable) {
      targetTable.columns.forEach((col) => {
        items.push({
          label: col.name,
          kind: monaco.languages.CompletionItemKind.Field,
          detail: `Column in ${targetTable.name} (${col.type})`,
          insertText: col.name,
          range,
          sortText: `0_${col.name}`,
        })
      })
      return items
    }
  }

  if (isAfterReferences) {
    tableNames.forEach((name) => {
      items.push({
        label: name,
        kind: monaco.languages.CompletionItemKind.Class,
        detail: `Referenced Table: ${name}`,
        insertText: `${name}($0)`,
        insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
        range,
        sortText: `0_${name}`,
      })
    })
    return items
  }

  // SQL DDL Snippets
  items.push(
    {
      label: 'CREATE TABLE',
      kind: monaco.languages.CompletionItemKind.Snippet,
      detail: 'Standard PostgreSQL Table',
      documentation: 'Creates a new relational table with serial primary key and timestamp.',
      insertText: [
        'CREATE TABLE ${1:table_name} (',
        '\tid serial PRIMARY KEY,',
        '\t${2:name} varchar(255) NOT NULL,',
        '\tcreated_at timestamp DEFAULT CURRENT_TIMESTAMP',
        ');$0',
      ].join('\n'),
      insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
      range,
      sortText: '00_create_table',
    },
    {
      label: 'CREATE TABLE (UUID)',
      kind: monaco.languages.CompletionItemKind.Snippet,
      detail: 'UUID-based PostgreSQL Table',
      documentation: 'Creates a table using gen_random_uuid() as the primary key.',
      insertText: [
        'CREATE TABLE ${1:table_name} (',
        '\tid uuid PRIMARY KEY DEFAULT gen_random_uuid(),',
        '\t${2:title} varchar(255) NOT NULL,',
        '\tcreated_at timestamptz DEFAULT now()',
        ');$0',
      ].join('\n'),
      insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
      range,
      sortText: '01_create_table_uuid',
    },
    {
      label: 'FOREIGN KEY',
      kind: monaco.languages.CompletionItemKind.Snippet,
      detail: 'Foreign Key Constraint',
      documentation: 'Defines a named foreign key constraint with cascade options.',
      insertText:
        'CONSTRAINT ${1:fk_name} FOREIGN KEY (${2:column_id}) REFERENCES ${3:target_table} (${4:id}) ON DELETE CASCADE$0',
      insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
      range,
      sortText: '02_foreign_key',
    },
    {
      label: 'ALTER TABLE ADD COLUMN',
      kind: monaco.languages.CompletionItemKind.Snippet,
      detail: 'Add column to existing table',
      insertText: 'ALTER TABLE ${1:table_name} ADD COLUMN ${2:column_name} ${3:varchar(255)};$0',
      insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
      range,
      sortText: '03_alter_table_add_column',
    },
    {
      label: 'CREATE INDEX',
      kind: monaco.languages.CompletionItemKind.Snippet,
      detail: 'Create B-tree Index',
      insertText: 'CREATE INDEX ${1:idx_name} ON ${2:table_name} (${3:column_name});$0',
      insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
      range,
      sortText: '04_create_index',
    },
    {
      label: 'CHECK CONSTRAINT',
      kind: monaco.languages.CompletionItemKind.Snippet,
      detail: 'Column Check Constraint',
      insertText: 'CONSTRAINT ${1:chk_name} CHECK (${2:condition})$0',
      insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
      range,
      sortText: '05_check_constraint',
    }
  )

  // SQL Keywords
  const keywords = [
    'CREATE TABLE',
    'ALTER TABLE',
    'DROP TABLE',
    'PRIMARY KEY',
    'FOREIGN KEY',
    'REFERENCES',
    'CONSTRAINT',
    'NOT NULL',
    'UNIQUE',
    'DEFAULT',
    'CHECK',
    'ON DELETE CASCADE',
    'ON DELETE SET NULL',
    'ON UPDATE CASCADE',
    'SELECT',
    'INSERT INTO',
    'UPDATE',
    'DELETE FROM',
    'WHERE',
    'JOIN',
    'LEFT JOIN',
    'ORDER BY',
    'GROUP BY',
    'INDEX',
  ]
  keywords.forEach((kw) => {
    items.push({
      label: kw,
      kind: monaco.languages.CompletionItemKind.Keyword,
      detail: 'SQL Keyword',
      insertText: kw,
      range,
      sortText: `10_${kw}`,
    })
  })

  // SQL Data Types
  const sqlTypes = [
    'serial',
    'bigserial',
    'integer',
    'bigint',
    'smallint',
    'varchar(255)',
    'text',
    'boolean',
    'timestamp',
    'timestamptz',
    'date',
    'time',
    'numeric(10, 2)',
    'decimal',
    'json',
    'jsonb',
    'uuid',
    'bytea',
  ]
  sqlTypes.forEach((t) => {
    items.push({
      label: t,
      kind: monaco.languages.CompletionItemKind.TypeParameter,
      detail: 'PostgreSQL Type',
      insertText: t,
      range,
      sortText: `20_${t}`,
    })
  })

  // Live Schema Tables in SQL
  tableNames.forEach((name) => {
    items.push({
      label: name,
      kind: monaco.languages.CompletionItemKind.Class,
      detail: `Schema Table: ${name}`,
      insertText: name,
      range,
      sortText: `30_${name}`,
    })
  })

  return items
}

/**
 * DBML Language Completion Provider
 */
export function getDbmlCompletions(
  monaco: typeof monacoType,
  model: monacoType.editor.ITextModel,
  position: monacoType.Position,
  context?: CompletionProviderContext
): monacoType.languages.CompletionItem[] {
  const range = getWordRange(model, position)
  const lineContent = model.getLineContent(position.lineNumber)
  const lineBeforeCursor = lineContent.slice(0, position.column - 1)
  const schema = context?.getSchema ? context.getSchema() : { tables: [], relations: [] }
  const tableNames = schema.tables.map((t) => t.name)

  const items: monacoType.languages.CompletionItem[] = []

  // Check if user is typing inside brackets [ ... ] or after [
  const isInsideBrackets = /\[[^\]]*$/.test(lineBeforeCursor)

  if (isInsideBrackets) {
    const settings = [
      { label: 'pk', detail: 'Primary Key', insertText: 'pk' },
      { label: 'increment', detail: 'Auto-incrementing', insertText: 'increment' },
      { label: 'not null', detail: 'Non-nullable field', insertText: 'not null' },
      { label: 'null', detail: 'Explicitly nullable', insertText: 'null' },
      { label: 'unique', detail: 'Unique constraint', insertText: 'unique' },
      {
        label: 'default',
        detail: 'Default value',
        insertText: "default: '${1:value}'$0",
        isSnippet: true,
      },
      {
        label: 'note',
        detail: 'Field note/documentation',
        insertText: "note: '${1:description}'$0",
        isSnippet: true,
      },
      {
        label: 'ref',
        detail: 'Inline foreign key reference',
        insertText: 'ref: > ${1:table}.${2:id}$0',
        isSnippet: true,
      },
    ]

    settings.forEach((s) => {
      items.push({
        label: s.label,
        kind: monaco.languages.CompletionItemKind.Property,
        detail: s.detail,
        insertText: s.insertText,
        insertTextRules: s.isSnippet
          ? monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet
          : undefined,
        range,
        sortText: `0_${s.label}`,
      })
    })

    return items
  }

  // Check for DBML Ref relations: Ref: table.col > table.col
  const isAfterRef = /Ref:\s*([a-zA-Z0-9_.]*)$/i.test(lineBeforeCursor)
  const isAfterOperator = /[><\-]\s*([a-zA-Z0-9_.]*)$/.test(lineBeforeCursor)

  if (isAfterRef || isAfterOperator) {
    tableNames.forEach((name) => {
      const table = schema.tables.find((t) => t.name === name)
      if (table && table.columns.length > 0) {
        table.columns.forEach((col) => {
          items.push({
            label: `${name}.${col.name}`,
            kind: monaco.languages.CompletionItemKind.Reference,
            detail: `Ref to ${name}.${col.name}`,
            insertText: `${name}.${col.name}`,
            range,
            sortText: `0_${name}_${col.name}`,
          })
        })
      } else {
        items.push({
          label: name,
          kind: monaco.languages.CompletionItemKind.Class,
          detail: `Table: ${name}`,
          insertText: `${name}.id`,
          range,
          sortText: `1_${name}`,
        })
      }
    })
    return items
  }

  // DBML Structure Snippets
  items.push(
    {
      label: 'Table',
      kind: monaco.languages.CompletionItemKind.Snippet,
      detail: 'DBML Table Definition',
      insertText: [
        'Table ${1:table_name} {',
        '  id int [pk, increment]',
        '  ${2:name} varchar',
        '  created_at timestamp [default: `now()`]',
        '  Note: \'${3:Table description}\'',
        '}$0',
      ].join('\n'),
      insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
      range,
      sortText: '00_table',
    },
    {
      label: 'Ref',
      kind: monaco.languages.CompletionItemKind.Snippet,
      detail: 'DBML Relationship Statement',
      insertText: 'Ref: ${1:table1}.${2:col1} > ${3:table2}.${4:col2}$0',
      insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
      range,
      sortText: '01_ref',
    },
    {
      label: 'Enum',
      kind: monaco.languages.CompletionItemKind.Snippet,
      detail: 'DBML Enum Definition',
      insertText: [
        'Enum ${1:status_enum} {',
        '  ${2:active}',
        '  ${3:inactive}',
        '  ${4:pending}',
        '}$0',
      ].join('\n'),
      insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
      range,
      sortText: '02_enum',
    },
    {
      label: 'TableGroup',
      kind: monaco.languages.CompletionItemKind.Snippet,
      detail: 'DBML Table Grouping',
      insertText: [
        'TableGroup ${1:group_name} {',
        '  ${2:table1}',
        '  ${3:table2}',
        '}$0',
      ].join('\n'),
      insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
      range,
      sortText: '03_tablegroup',
    },
    {
      label: 'Project',
      kind: monaco.languages.CompletionItemKind.Snippet,
      detail: 'DBML Project Metadata',
      insertText: [
        'Project ${1:project_name} {',
        '  database_type: \'PostgreSQL\'',
        '  Note: \'${2:Project description}\'',
        '}$0',
      ].join('\n'),
      insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
      range,
      sortText: '04_project',
    },
    {
      label: 'indexes',
      kind: monaco.languages.CompletionItemKind.Snippet,
      detail: 'DBML Table Indexes Block',
      insertText: [
        'indexes {',
        '  ${1:column_name} [unique]',
        '  (${2:col1}, ${3:col2}) [name: \'${4:idx_composite}\']',
        '}$0',
      ].join('\n'),
      insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
      range,
      sortText: '05_indexes',
    }
  )

  // DBML Data Types
  const dbmlTypes = [
    'int',
    'integer',
    'bigint',
    'smallint',
    'varchar',
    'char',
    'text',
    'boolean',
    'date',
    'datetime',
    'timestamp',
    'timestamptz',
    'decimal',
    'numeric',
    'float',
    'json',
    'jsonb',
    'uuid',
    'blob',
  ]
  dbmlTypes.forEach((t) => {
    items.push({
      label: t,
      kind: monaco.languages.CompletionItemKind.TypeParameter,
      detail: 'DBML Field Type',
      insertText: t,
      range,
      sortText: `10_${t}`,
    })
  })

  // Table names
  tableNames.forEach((name) => {
    items.push({
      label: name,
      kind: monaco.languages.CompletionItemKind.Class,
      detail: `Existing Table: ${name}`,
      insertText: name,
      range,
      sortText: `20_${name}`,
    })
  })

  return items
}

/**
 * Prisma Language Completion Provider
 */
export function getPrismaCompletions(
  monaco: typeof monacoType,
  model: monacoType.editor.ITextModel,
  position: monacoType.Position,
  context?: CompletionProviderContext
): monacoType.languages.CompletionItem[] {
  const range = getWordRange(model, position)
  const lineContent = model.getLineContent(position.lineNumber)
  const lineBeforeCursor = lineContent.slice(0, position.column - 1)
  const schema = context?.getSchema ? context.getSchema() : { tables: [], relations: [] }
  const tableNames = schema.tables.map((t) => t.name)

  const items: monacoType.languages.CompletionItem[] = []

  // Check if user is typing an attribute starting with @ or @@
  const isAttribute = /@[a-zA-Z0-9_]*$/.test(lineBeforeCursor)

  if (isAttribute) {
    const attributes = [
      { label: '@id', detail: 'Primary Key', insertText: '@id' },
      { label: '@unique', detail: 'Unique Constraint', insertText: '@unique' },
      {
        label: '@default(autoincrement())',
        detail: 'Auto-increment default',
        insertText: '@default(autoincrement())',
      },
      {
        label: '@default(uuid())',
        detail: 'UUID generator default',
        insertText: '@default(uuid())',
      },
      {
        label: '@default(cuid())',
        detail: 'CUID generator default',
        insertText: '@default(cuid())',
      },
      {
        label: '@default(now())',
        detail: 'Current timestamp default',
        insertText: '@default(now())',
      },
      {
        label: '@default(...)',
        detail: 'Custom default value',
        insertText: '@default(${1:value})$0',
        isSnippet: true,
      },
      {
        label: '@updatedAt',
        detail: 'Auto update timestamp on write',
        insertText: '@updatedAt',
      },
      {
        label: '@relation',
        detail: 'Foreign Key Relation',
        insertText:
          '@relation(fields: [${1:userId}], references: [${2:id}], onDelete: Cascade)$0',
        isSnippet: true,
      },
      {
        label: '@map',
        detail: 'Map column name in database',
        insertText: '@map("${1:db_column_name}")$0',
        isSnippet: true,
      },
      { label: '@ignore', detail: 'Ignore field in client', insertText: '@ignore' },
      {
        label: '@@id',
        detail: 'Composite primary key',
        insertText: '@@id([${1:field1}, ${2:field2}])$0',
        isSnippet: true,
      },
      {
        label: '@@unique',
        detail: 'Composite unique constraint',
        insertText: '@@unique([${1:field1}, ${2:field2}])$0',
        isSnippet: true,
      },
      {
        label: '@@index',
        detail: 'Model index',
        insertText: '@@index([${1:field1}])$0',
        isSnippet: true,
      },
      {
        label: '@@map',
        detail: 'Map table name in database',
        insertText: '@@map("${1:db_table_name}")$0',
        isSnippet: true,
      },
    ]

    attributes.forEach((attr) => {
      // If user has already typed @, strip the leading @ in insertText if word starts with @
      const alreadyHasAt = /@$/.test(lineBeforeCursor)
      const insert = alreadyHasAt && attr.label.startsWith('@') ? attr.label.slice(1) : attr.label

      items.push({
        label: attr.label,
        kind: monaco.languages.CompletionItemKind.Property,
        detail: attr.detail,
        insertText: insert,
        insertTextRules: attr.isSnippet
          ? monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet
          : undefined,
        range,
        sortText: `0_${attr.label}`,
      })
    })

    return items
  }

  // Prisma Model & Top-level Snippets
  items.push(
    {
      label: 'model',
      kind: monaco.languages.CompletionItemKind.Snippet,
      detail: 'Prisma Model Definition',
      insertText: [
        'model ${1:ModelName} {',
        '  id        Int      @id @default(autoincrement())',
        '  ${2:name}      String',
        '  createdAt DateTime @default(now())',
        '  updatedAt DateTime @updatedAt',
        '}$0',
      ].join('\n'),
      insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
      range,
      sortText: '00_model',
    },
    {
      label: 'model (UUID)',
      kind: monaco.languages.CompletionItemKind.Snippet,
      detail: 'Prisma Model with UUID',
      insertText: [
        'model ${1:ModelName} {',
        '  id        String   @id @default(uuid())',
        '  ${2:name}      String',
        '  createdAt DateTime @default(now())',
        '}$0',
      ].join('\n'),
      insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
      range,
      sortText: '01_model_uuid',
    },
    {
      label: 'enum',
      kind: monaco.languages.CompletionItemKind.Snippet,
      detail: 'Prisma Enum Definition',
      insertText: ['enum ${1:Role} {', '  ${2:USER}', '  ${3:ADMIN}', '}$0'].join('\n'),
      insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
      range,
      sortText: '02_enum',
    },
    {
      label: 'datasource',
      kind: monaco.languages.CompletionItemKind.Snippet,
      detail: 'Prisma Datasource Block',
      insertText: [
        'datasource db {',
        '  provider = "postgresql"',
        '  url      = env("DATABASE_URL")',
        '}$0',
      ].join('\n'),
      insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
      range,
      sortText: '03_datasource',
    },
    {
      label: 'generator',
      kind: monaco.languages.CompletionItemKind.Snippet,
      detail: 'Prisma Client Generator',
      insertText: [
        'generator client {',
        '  provider = "prisma-client-js"',
        '}$0',
      ].join('\n'),
      insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
      range,
      sortText: '04_generator',
    }
  )

  // Prisma Field Types
  const prismaTypes = [
    'Int',
    'BigInt',
    'String',
    'Boolean',
    'DateTime',
    'Float',
    'Decimal',
    'Json',
    'Bytes',
  ]
  prismaTypes.forEach((t) => {
    items.push({
      label: t,
      kind: monaco.languages.CompletionItemKind.TypeParameter,
      detail: 'Prisma Scalar Type',
      insertText: t,
      range,
      sortText: `10_${t}`,
    })
  })

  // Suggest existing models as relation types
  tableNames.forEach((name) => {
    items.push({
      label: name,
      kind: monaco.languages.CompletionItemKind.Class,
      detail: `Model Reference: ${name}`,
      insertText: name,
      range,
      sortText: `20_${name}`,
    })
  })

  return items
}

/**
 * TypeScript Language Completion Provider (Drizzle ORM & TypeORM)
 */
export function getTypeScriptCompletions(
  monaco: typeof monacoType,
  model: monacoType.editor.ITextModel,
  position: monacoType.Position,
  context?: CompletionProviderContext
): monacoType.languages.CompletionItem[] {
  const range = getWordRange(model, position)
  const schema = context?.getSchema ? context.getSchema() : { tables: [], relations: [] }
  const tableNames = schema.tables.map((t) => t.name)

  const items: monacoType.languages.CompletionItem[] = []

  // TypeORM Snippets
  items.push(
    {
      label: 'TypeORM @Entity',
      kind: monaco.languages.CompletionItemKind.Snippet,
      detail: 'TypeORM Entity Class',
      insertText: [
        "@Entity('${1:table_name}')",
        'export class ${2:EntityName} {',
        '  @PrimaryGeneratedColumn()',
        '  id: number;',
        '',
        '  @Column()',
        '  ${3:name}: string;',
        '',
        '  @CreateDateColumn()',
        '  createdAt: Date;',
        '}$0',
      ].join('\n'),
      insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
      range,
      sortText: '00_typeorm_entity',
    },
    {
      label: 'TypeORM @ManyToOne',
      kind: monaco.languages.CompletionItemKind.Snippet,
      detail: 'TypeORM ManyToOne Relationship',
      insertText: [
        '@ManyToOne(() => ${1:TargetEntity}, (${2:target}) => ${2:target}.${3:inverseRelation})',
        "@JoinColumn({ name: '${4:target_id}' })",
        '${5:property}: ${1:TargetEntity};$0',
      ].join('\n'),
      insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
      range,
      sortText: '01_typeorm_many_to_one',
    },
    {
      label: 'TypeORM @OneToMany',
      kind: monaco.languages.CompletionItemKind.Snippet,
      detail: 'TypeORM OneToMany Relationship',
      insertText: [
        '@OneToMany(() => ${1:TargetEntity}, (${2:target}) => ${2:target}.${3:inverseRelation})',
        '${4:property}: ${1:TargetEntity}[];$0',
      ].join('\n'),
      insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
      range,
      sortText: '02_typeorm_one_to_many',
    },
    {
      label: 'TypeORM @Column',
      kind: monaco.languages.CompletionItemKind.Snippet,
      detail: 'TypeORM Column Decorator',
      insertText: "@Column({ type: '${1:varchar}', length: ${2:255} })\n${3:column}: string;$0",
      insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
      range,
      sortText: '03_typeorm_column',
    }
  )

  // Drizzle ORM Snippets
  items.push(
    {
      label: 'Drizzle pgTable',
      kind: monaco.languages.CompletionItemKind.Snippet,
      detail: 'Drizzle pgTable Definition',
      insertText: [
        "export const ${1:tableName} = pgTable('${2:table_name}', {",
        "  id: serial('id').primaryKey(),",
        "  ${3:name}: varchar('${3:name}', { length: 255 }).notNull(),",
        "  createdAt: timestamp('created_at').defaultNow().notNull(),",
        '});$0',
      ].join('\n'),
      insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
      range,
      sortText: '04_drizzle_pgtable',
    },
    {
      label: 'Drizzle relations',
      kind: monaco.languages.CompletionItemKind.Snippet,
      detail: 'Drizzle Relations Builder',
      insertText: [
        'export const ${1:table}Relations = relations(${1:table}, ({ one, many }) => ({',
        '  ${2:relationName}: one(${3:targetTable}, {',
        '    fields: [${1:table}.${4:fkColumn}],',
        '    references: [${3:targetTable}.id],',
        '  }),',
        '}));$0',
      ].join('\n'),
      insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
      range,
      sortText: '05_drizzle_relations',
    }
  )

  // Drizzle Column Helpers
  const drizzleColumns = [
    { label: "serial('id').primaryKey()", insertText: "serial('id').primaryKey()" },
    {
      label: "varchar('name', { length: 255 })",
      insertText: "varchar('${1:name}', { length: 255 })",
      isSnippet: true,
    },
    { label: "integer('count')", insertText: "integer('${1:name}')", isSnippet: true },
    { label: "boolean('is_active')", insertText: "boolean('${1:is_active}')", isSnippet: true },
    {
      label: "timestamp('created_at').defaultNow()",
      insertText: "timestamp('created_at').defaultNow()",
    },
    {
      label: "uuid('id').defaultRandom().primaryKey()",
      insertText: "uuid('id').defaultRandom().primaryKey()",
    },
  ]

  drizzleColumns.forEach((col) => {
    items.push({
      label: col.label,
      kind: monaco.languages.CompletionItemKind.Function,
      detail: 'Drizzle Column Definition',
      insertText: col.insertText,
      insertTextRules: col.isSnippet
        ? monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet
        : undefined,
      range,
      sortText: `10_${col.label}`,
    })
  })

  // Table Names
  tableNames.forEach((name) => {
    items.push({
      label: name,
      kind: monaco.languages.CompletionItemKind.Class,
      detail: `Schema Entity: ${name}`,
      insertText: name,
      range,
      sortText: `20_${name}`,
    })
  })

  return items
}

/**
 * Registers completion providers for all supported dialects in Monaco
 */
export function registerAllCompletions(
  monaco: typeof monacoType,
  getSchemaContext?: () => CompiledSchema
): monacoType.IDisposable[] {
  // Dispose existing providers if previously registered
  disposables.forEach((d) => d.dispose())
  disposables = []

  const ctx: CompletionProviderContext = {
    getSchema: getSchemaContext,
  }

  // 1. SQL / Postgres Provider
  const sqlProvider = monaco.languages.registerCompletionItemProvider('sql', {
    triggerCharacters: [' ', '.', '(', ',', '\n'],
    provideCompletionItems(model, position) {
      const suggestions = getSqlCompletions(monaco, model, position, ctx)
      return { suggestions }
    },
  })
  disposables.push(sqlProvider)

  // 2. DBML Provider
  const dbmlProvider = monaco.languages.registerCompletionItemProvider('dbml', {
    triggerCharacters: ['[', '>', '<', '-', ' ', ':', '\n'],
    provideCompletionItems(model, position) {
      const suggestions = getDbmlCompletions(monaco, model, position, ctx)
      return { suggestions }
    },
  })
  disposables.push(dbmlProvider)

  // 3. Prisma Provider
  const prismaProvider = monaco.languages.registerCompletionItemProvider('prisma', {
    triggerCharacters: ['@', ' ', ':', '[', '\n'],
    provideCompletionItems(model, position) {
      const suggestions = getPrismaCompletions(monaco, model, position, ctx)
      return { suggestions }
    },
  })
  disposables.push(prismaProvider)

  // 4. TypeScript Provider (Drizzle & TypeORM)
  const tsProvider = monaco.languages.registerCompletionItemProvider('typescript', {
    triggerCharacters: ['@', '.', '(', ' ', '\n'],
    provideCompletionItems(model, position) {
      const suggestions = getTypeScriptCompletions(monaco, model, position, ctx)
      return { suggestions }
    },
  })
  disposables.push(tsProvider)

  return disposables
}
