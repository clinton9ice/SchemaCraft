import type { CompiledTable, CompiledRelation } from '~/utils/sql-compiler'
import { parseDbml, tablesToDbml, dbmlToSql } from '~/utils/dbml-compiler'
import { parsePrisma, tablesToPrisma, prismaToSql } from '~/utils/prisma-compiler'
import { compileTypeORM, tablesToTypeORM, typeormToSql, typeormToDbml, typeormToPrisma } from '~/utils/typeorm-compiler'
import { compileDrizzle, tablesToDrizzle, drizzleToSql } from '~/utils/drizzle-compiler'

export type SupportedLanguage = 'sql' | 'dbml' | 'prisma' | 'typeorm' | 'drizzle'

export interface LanguageOption {
  id: SupportedLanguage
  label: string
  shortLabel: string
  ext: string
  icon: string
  description: string
}

export const LANGUAGE_OPTIONS: LanguageOption[] = [
  {
    id: 'sql',
    label: 'PostgreSQL',
    shortLabel: 'Postgres',
    ext: '.sql',
    icon: '🐘',
    description: 'PostgreSQL DDL & Standard SQL schema statements',
  },
  {
    id: 'drizzle',
    label: 'Drizzle ORM',
    shortLabel: 'Drizzle',
    ext: '.ts',
    icon: '💧',
    description: 'TypeScript Drizzle ORM schema definitions',
  },
  {
    id: 'typeorm',
    label: 'TypeORM Entities',
    shortLabel: 'TypeORM',
    ext: '.ts',
    icon: '📦',
    description: 'TypeScript TypeORM entity definitions',
  },
  {
    id: 'prisma',
    label: 'Prisma Schema',
    shortLabel: 'Prisma',
    ext: '.prisma',
    icon: '💎',
    description: 'Prisma Schema ORM model definitions',
  },
  {
    id: 'dbml',
    label: 'DBML',
    shortLabel: 'DBML',
    ext: '.dbml',
    icon: '📋',
    description: 'Database Markup Language schema format',
  },
]

export interface SchemaTab {
  id: string
  title: string
  sqlCode: string
  lastSavedCode: string
  fileName: string
  language: SupportedLanguage
  fileHandle?: FileSystemFileHandle
  cursorPosition: { line: number; column: number }
  parsedTables: CompiledTable[]
  parsedRelations: CompiledRelation[]
  createdAt: number
}

export function detectLanguageFromCode(code: string): SupportedLanguage {
  if (!code || !code.trim()) return 'sql'
  const trimmed = code.trim()

  if (/\b(?:pgTable|mysqlTable|sqliteTable)\s*\(|from\s+['"]drizzle-orm/im.test(trimmed)) {
    return 'drizzle'
  }

  if (/@Entity\b|from\s+['"]typeorm['"]|@PrimaryGeneratedColumn|@PrimaryColumn|@Column\b/im.test(trimmed)) {
    return 'typeorm'
  }

  if (/^\s*(?:model\s+[a-zA-Z0-9_]+\s*\{|datasource\s+\w+\s*\{|generator\s+\w+\s*\{)/im.test(trimmed)) {
    return 'prisma'
  }

  if (/^\s*(?:Table\s+[\w"]+|Ref(?:\s+[\w_]+)?\s*:|Enum\s+[\w"]+|TableGroup\s+[\w"]+)/im.test(trimmed)) {
    return 'dbml'
  }

  return 'sql'
}

const DEFAULT_SQL_SCHEMA = `-- Database Diagram Visual Editor Schema
-- Type your DDL SQL commands below to visualize tables, constraints & relations

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    role VARCHAR(20) DEFAULT 'member' CHECK (role IN ('admin', 'editor', 'member', 'guest')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    slug VARCHAR(60) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(30),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    author_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL CHECK (length(title) >= 5),
    slug VARCHAR(280) NOT NULL UNIQUE,
    content TEXT NOT NULL,
    summary VARCHAR(500),
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
    view_count INTEGER DEFAULT 0 CHECK (view_count >= 0),
    published_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE comments (
    id SERIAL PRIMARY KEY,
    post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    parent_id INTEGER REFERENCES comments(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_approved BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tags (
    id SERIAL PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE post_tags (
    post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    tag_id INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (post_id, tag_id)
);

COMMENT ON COLUMN users.role IS 'User access level permission in organization';
COMMENT ON COLUMN posts.view_count IS 'Total lifetime page views metrics';
COMMENT ON COLUMN posts.status IS 'Publication workflow lifecycle state';
COMMENT ON COLUMN posts.title IS 'Main article headline';
`

// Initial tab with auto-detected language
const initialTab: SchemaTab = {
  id: 'tab-default',
  title: 'schema.sql',
  fileName: 'schema.sql',
  language: detectLanguageFromCode(DEFAULT_SQL_SCHEMA),
  sqlCode: DEFAULT_SQL_SCHEMA,
  lastSavedCode: DEFAULT_SQL_SCHEMA,
  cursorPosition: { line: 1, column: 1 },
  parsedTables: [],
  parsedRelations: [],
  createdAt: Date.now(),
}

// Global state
const tabs = ref<SchemaTab[]>([initialTab])
const activeTabId = ref<string>('tab-default')
const isSaving = ref(false)
const lastSaveTimestamp = ref<Date | null>(new Date())
const isParsing = ref(false)
const availablePresets = ref<
  Array<{ id: string; label: string; description: string; sql: string; language?: SupportedLanguage }>
>([])

export function useSchemaStore() {
  // Currently active tab
  const activeTab = computed(() => {
    return tabs.value.find((t) => t.id === activeTabId.value) || tabs.value[0]
  })

  // Current language (auto-detected fallback if undefined)
  const activeLanguage = computed<SupportedLanguage>({
    get: () => activeTab.value?.language || detectLanguageFromCode(activeTab.value?.sqlCode || ''),
    set: (lang: SupportedLanguage) => {
      setLanguage(lang, false)
    },
  })

  // Reactive properties proxying activeTab
  const sqlCode = computed({
    get: () => activeTab.value?.sqlCode ?? '',
    set: (val: string) => {
      if (activeTab.value) {
        activeTab.value.sqlCode = val
      }
    },
  })

  const fileName = computed({
    get: () => activeTab.value?.fileName ?? 'schema.sql',
    set: (val: string) => {
      if (activeTab.value) {
        activeTab.value.fileName = val
        activeTab.value.title = val
      }
    },
  })

  const lastSavedCode = computed({
    get: () => activeTab.value?.lastSavedCode ?? '',
    set: (val: string) => {
      if (activeTab.value) {
        activeTab.value.lastSavedCode = val
      }
    },
  })

  const isDirty = computed(() => {
    return sqlCode.value !== lastSavedCode.value
  })

  const cursorPosition = computed({
    get: () => activeTab.value?.cursorPosition ?? { line: 1, column: 1 },
    set: (pos: { line: number; column: number }) => {
      if (activeTab.value) {
        activeTab.value.cursorPosition = pos
      }
    },
  })

  const detectedTablesCount = computed(() => {
    return activeTab.value?.parsedTables?.length || 0
  })

  const parsedTables = computed(() => {
    return activeTab.value?.parsedTables || []
  })

  const parsedRelations = computed(() => {
    return activeTab.value?.parsedRelations || []
  })

  // Tab management methods
  function addNewTab(title?: string, initialContent?: string, language?: SupportedLanguage) {
    const isExplicitContent = typeof initialContent === 'string'
    const defaultNewTabSql = `-- SQL Schema\n\nCREATE TABLE new_table (\n    id INT PRIMARY KEY,\n    name VARCHAR(100) NOT NULL,\n    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP\n);\n`
    
    const content = isExplicitContent ? initialContent : defaultNewTabSql
    const lang = language || detectLanguageFromCode(content)
    const ext = lang === 'dbml' ? '.dbml' : lang === 'prisma' ? '.prisma' : '.sql'
    const newIndex = tabs.value.length + 1
    const tabTitle = title || `untitled-${newIndex}${ext}`

    const newTab: SchemaTab = {
      id: `tab-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`,
      title: tabTitle,
      fileName: tabTitle,
      language: lang,
      sqlCode: content,
      lastSavedCode: isExplicitContent ? content : '',
      cursorPosition: { line: 1, column: 1 },
      parsedTables: [],
      parsedRelations: [],
      createdAt: Date.now(),
    }

    tabs.value.push(newTab)
    activeTabId.value = newTab.id
    parseSchema(newTab.sqlCode, lang)
  }

  function closeTab(tabId: string) {
    if (tabs.value.length <= 1) {
      return
    }

    const index = tabs.value.findIndex((t) => t.id === tabId)
    if (index === -1) return

    tabs.value.splice(index, 1)

    if (activeTabId.value === tabId) {
      const nextIndex = Math.max(0, index - 1)
      activeTabId.value = tabs.value[nextIndex].id
    }
  }

  function switchTab(tabId: string) {
    const exists = tabs.value.some((t) => t.id === tabId)
    if (exists) {
      activeTabId.value = tabId
    }
  }

  function renameTab(tabId: string, newTitle: string) {
    const tab = tabs.value.find((t) => t.id === tabId)
    if (tab) {
      tab.title = newTitle
      tab.fileName = newTitle
      if (newTitle.endsWith('.dbml')) {
        tab.language = 'dbml'
      } else if (newTitle.endsWith('.prisma')) {
        tab.language = 'prisma'
      } else if (newTitle.endsWith('.sql')) {
        tab.language = 'sql'
      }
    }
  }

  // Language management & translation utility
  function setLanguage(targetLang: SupportedLanguage, convertCode = false) {
    if (!activeTab.value) return

    const oldLang = activeTab.value.language || 'sql'
    activeTab.value.language = targetLang

    // Adjust file extension
    const currentName = activeTab.value.fileName
    const baseName = currentName.replace(/\.(sql|ddl|pgsql|dbml|prisma|ts)$/i, '')
    const targetExt = targetLang === 'dbml' ? '.dbml' : targetLang === 'prisma' ? '.prisma' : (targetLang === 'typeorm' || targetLang === 'drizzle') ? '.ts' : '.sql'
    activeTab.value.fileName = `${baseName}${targetExt}`
    activeTab.value.title = `${baseName}${targetExt}`

    if (convertCode && oldLang !== targetLang) {
      convertCurrentSchema(targetLang)
    } else {
      parseSchema(activeTab.value.sqlCode, targetLang)
    }
  }

  /**
   * Converts code from one database definition language to another
   */
  function convertSchemaCode(
    currentCode: string,
    fromLang: SupportedLanguage,
    toLang: SupportedLanguage,
    existingTables?: CompiledTable[],
    existingRelations?: CompiledRelation[]
  ): string {
    const detected = detectLanguageFromCode(currentCode)
    const effectiveFrom = fromLang === 'sql' && detected !== 'sql' ? detected : fromLang

    if (effectiveFrom === toLang) return currentCode

    let tables: CompiledTable[] = existingTables && existingTables.length > 0 ? existingTables : []
    let relations: CompiledRelation[] = existingRelations || []

    if (tables.length === 0) {
      if (effectiveFrom === 'dbml') {
        const parsed = parseDbml(currentCode)
        tables = parsed.tables
        relations = parsed.relations
      } else if (effectiveFrom === 'prisma') {
        const parsed = parsePrisma(currentCode)
        tables = parsed.tables
        relations = parsed.relations
      } else if (effectiveFrom === 'typeorm') {
        const parsed = compileTypeORM(currentCode)
        tables = parsed.tables
        relations = parsed.relations
      } else if (effectiveFrom === 'drizzle') {
        const parsed = compileDrizzle(currentCode)
        tables = parsed.tables
        relations = parsed.relations
      }
    }

    if (toLang === 'drizzle') {
      return tablesToDrizzle(tables, relations)
    }

    if (toLang === 'typeorm') {
      return tablesToTypeORM(tables, relations)
    }

    if (toLang === 'dbml') {
      return tablesToDbml(tables, relations)
    }

    if (toLang === 'prisma') {
      return tablesToPrisma(tables, relations)
    }

    if (toLang === 'sql') {
      if (effectiveFrom === 'dbml') {
        return dbmlToSql(currentCode)
      }
      if (effectiveFrom === 'prisma') {
        return prismaToSql(currentCode)
      }
      if (effectiveFrom === 'typeorm') {
        return typeormToSql(currentCode)
      }
      if (effectiveFrom === 'drizzle') {
        return drizzleToSql(currentCode)
      }
      return tables.length > 0 ? dbmlToSql(tablesToDbml(tables, relations)) : currentCode
    }

    return currentCode
  }

  /**
   * The 'Convert-to-Tab' workflow: creates a new workspace tab with converted schema
   * without overwriting the current tab.
   */
  function convertSchemaToNewTab(targetLang: SupportedLanguage) {
    if (!activeTab.value) return

    try {
      const sourceTab = activeTab.value
      const sourceLang = sourceTab.language || detectLanguageFromCode(sourceTab.sqlCode) || 'sql'
      const sourceCode = sourceTab.sqlCode

      const convertedCode = convertSchemaCode(
        sourceCode,
        sourceLang,
        targetLang,
        sourceTab.parsedTables,
        sourceTab.parsedRelations
      )

      const baseName = (sourceTab.fileName || 'schema').replace(/\.(sql|ddl|pgsql|dbml|prisma|ts)$/i, '')
      const targetExt = targetLang === 'dbml' ? '.dbml' : targetLang === 'prisma' ? '.prisma' : (targetLang === 'typeorm' || targetLang === 'drizzle') ? '.ts' : '.sql'

      let targetTitle = `${baseName}${targetExt}`
      if (tabs.value.some((t) => t.title === targetTitle || t.fileName === targetTitle)) {
        let counter = 1
        while (tabs.value.some((t) => t.title === `${baseName}-${counter}${targetExt}` || t.fileName === `${baseName}-${counter}${targetExt}`)) {
          counter++
        }
        targetTitle = `${baseName}-${counter}${targetExt}`
      }

      addNewTab(targetTitle, convertedCode, targetLang)
    } catch (err) {
      console.error('Failed to convert schema to new tab:', err)
    }
  }

  function convertCurrentSchema(targetLang: SupportedLanguage) {
    if (!activeTab.value) return

    const currentCode = activeTab.value.sqlCode
    const oldLang = activeTab.value.language || 'sql'

    const converted = convertSchemaCode(
      currentCode,
      oldLang,
      targetLang,
      activeTab.value.parsedTables,
      activeTab.value.parsedRelations
    )

    if (converted.trim()) {
      activeTab.value.sqlCode = converted
    }
    activeTab.value.language = targetLang
    activeTab.value.lastSavedCode = activeTab.value.sqlCode
    parseSchema(activeTab.value.sqlCode, targetLang)
  }

  // Fetch sample presets from server
  async function fetchPresets() {
    try {
      const presets = await $fetch<
        Array<{ id: string; label: string; description: string; sql: string; language?: SupportedLanguage }>
      >('/api/schema/samples')
      if (presets && presets.length) {
        availablePresets.value = presets
      }
    } catch (err) {
      console.warn('Could not fetch presets from Nitro backend:', err)
    }
  }

  // Parse SQL, DBML or Prisma into structured AST table/relation graph on Nitro
  async function parseSchema(code: string, langOverride?: SupportedLanguage) {
    if (!activeTab.value) return

    const targetTabId = activeTabId.value
    const targetTab = tabs.value.find((t) => t.id === targetTabId)
    if (!targetTab) return

    const language = langOverride || targetTab.language || detectLanguageFromCode(code)

    if (!code || !code.trim()) {
      targetTab.parsedTables = []
      targetTab.parsedRelations = []
      return
    }

    isParsing.value = true
    try {
      const res = await $fetch<{
        success: boolean
        tables: CompiledTable[]
        relations: CompiledRelation[]
      }>('/api/schema/parse', {
        method: 'POST',
        body: { sql: code, language },
      })
      if (res && res.success) {
        targetTab.parsedTables = res.tables || []
        targetTab.parsedRelations = res.relations || []
      }
    } catch (err) {
      console.warn('Schema parse error:', err)
    } finally {
      isParsing.value = false
    }
  }

  function setSqlCode(newCode: string) {
    if (activeTab.value) {
      activeTab.value.sqlCode = newCode
    }
  }

  function setCursorPosition(line: number, column: number) {
    if (activeTab.value) {
      activeTab.value.cursorPosition = { line, column }
    }
  }

  function saveSchema() {
    isSaving.value = true
    setTimeout(async () => {
      if (activeTab.value) {
        activeTab.value.lastSavedCode = activeTab.value.sqlCode
        lastSaveTimestamp.value = new Date()
        await parseSchema(activeTab.value.sqlCode, activeTab.value.language)
      }
      isSaving.value = false
    }, 150)
  }

  function loadSample(sampleId: string) {
    const found = availablePresets.value.find((p) => p.id === sampleId)
    if (found) {
      if (activeTab.value) {
        const lang: SupportedLanguage =
          found.language ||
          (found.id === 'prisma-saas' || found.id.includes('prisma')
            ? 'prisma'
            : found.id === 'dbml-social' || found.id.includes('dbml')
            ? 'dbml'
            : 'sql')
        const ext = lang === 'dbml' ? '.dbml' : lang === 'prisma' ? '.prisma' : '.sql'
        activeTab.value.title = `${found.id}${ext}`
        activeTab.value.fileName = `${found.id}${ext}`
        activeTab.value.language = lang
        activeTab.value.sqlCode = found.sql
        activeTab.value.lastSavedCode = found.sql
        parseSchema(found.sql, lang)
      }
    }
  }

  async function exportSchema(
    format: 'typescript' | 'prisma' | 'dbml' | 'json',
  ) {
    try {
      const res = await $fetch<{
        success: boolean
        content: string
        format: string
      }>('/api/schema/export', {
        method: 'POST',
        body: {
          format,
          tables: parsedTables.value,
        },
      })
      return res
    } catch (err) {
      console.error('Export error:', err)
      return null
    }
  }

  function formatSql() {
    if (activeTab.value) {
      const lines = activeTab.value.sqlCode.split('\n')
      activeTab.value.sqlCode = lines.join('\n')
    }
  }

  return {
    tabs,
    activeTabId,
    activeTab,
    activeLanguage,
    addNewTab,
    closeTab,
    switchTab,
    renameTab,
    setLanguage,
    convertCurrentSchema,
    convertSchemaToNewTab,
    convertSchemaCode,
    detectLanguageFromCode,
    sqlCode,
    isDirty,
    isSaving,
    lastSaveTimestamp,
    lastSavedCode,
    cursorPosition,
    fileName,
    detectedTablesCount,
    parsedTables,
    parsedRelations,
    isParsing,
    availablePresets,
    fetchPresets,
    parseSchema,
    parseSchemaOnServer: parseSchema,
    setSqlCode,
    setCursorPosition,
    saveSchema,
    loadSample,
    exportSchema,
    formatSql,
  }
}
