import type { CompiledTable, CompiledRelation } from '~/utils/sql-compiler'
import { parseDbml, tablesToDbml, dbmlToSql, sanitizeDbml } from '~/utils/dbml-compiler'
import { parsePrisma, tablesToPrisma, prismaToSql, sanitizePrisma } from '~/utils/prisma-compiler'
import { compileTypeORM, tablesToTypeORM, typeormToSql } from '~/utils/typeorm-compiler'
import { compileDrizzle, tablesToDrizzle, drizzleToSql } from '~/utils/drizzle-compiler'
import { sanitizeDrizzle, sanitizeTypeORM } from '~/utils/ts-sanitizer'
import { MAX_WORKSPACE_TABS, MAX_DDL_BYTES } from '~/utils/constants'
import { sanitizeSqlDdl } from '~/utils/sql-sanitizer'
import { downloadZipArchive, type ZipFileEntry } from '~/utils/zip-exporter'

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

  if (
    /@Entity\b|from\s+['"]typeorm['"]|@PrimaryGeneratedColumn|@PrimaryColumn|@Column\b/im.test(
      trimmed
    )
  ) {
    return 'typeorm'
  }

  if (
    /^\s*(?:model\s+[a-zA-Z0-9_]+\s*\{|datasource\s+\w+\s*\{|generator\s+\w+\s*\{)/im.test(trimmed)
  ) {
    return 'prisma'
  }

  if (
    /^\s*(?:Table\s+[\w"]+|Ref(?:\s+[\w_]+)?\s*:|Enum\s+[\w"]+|TableGroup\s+[\w"]+)/im.test(trimmed)
  ) {
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

// ---------------------------------------------------------------------------
// Parse result cache — keyed by `${tabId}::${language}::${code}` hash
// Avoids re-hitting the WASM parser for identical content (e.g. tab switches,
// diagram panel toggles, or rapid keystroke debounce hits).
// ---------------------------------------------------------------------------
interface ParseCacheEntry {
  tables: CompiledTable[]
  relations: CompiledRelation[]
  cachedAt: number
}

/** Simple djb2 hash — fast, no crypto dependency, good enough for cache keys */
function hashString(str: string): string {
  let h = 5381
  for (let i = 0; i < str.length; i++) {
    h = (h * 33) ^ str.charCodeAt(i)
  }
  return (h >>> 0).toString(36)
}

const PARSE_CACHE_MAX = 10
const parseCache = new Map<string, ParseCacheEntry>()

function getCached(tabId: string, language: string, code: string): ParseCacheEntry | null {
  const key = hashString(`${tabId}::${language}::${code}`)
  return parseCache.get(key) ?? null
}

function setCached(tabId: string, language: string, code: string, entry: ParseCacheEntry) {
  const key = hashString(`${tabId}::${language}::${code}`)
  // Evict oldest entry when at capacity
  if (parseCache.size >= PARSE_CACHE_MAX && !parseCache.has(key)) {
    const oldest = parseCache.keys().next().value
    if (oldest) parseCache.delete(oldest)
  }
  parseCache.set(key, entry)
}

// Global state
const tabs = ref<SchemaTab[]>([initialTab])
const activeTabId = ref<string>('tab-default')
const isSaving = ref(false)
const lastSaveTimestamp = ref<Date | null>(new Date())
const isParsing = ref(false)
const isTabLimitModalOpen = ref(false)
/** Soft warning shown when sanitized DDL exceeds MAX_DDL_BYTES and parsing is skipped */
const parseWarning = ref<string | null>(null)
const availablePresets = ref<
  Array<{
    id: string
    label: string
    description: string
    sql: string
    language?: SupportedLanguage
  }>
>([])

export interface SampleFileInfo {
  fileName: string
  baseName: string
  ext: string
  language: SupportedLanguage
  content: string
}

export interface ParseResponse {
  success: boolean
  tables?: CompiledTable[]
  relations?: CompiledRelation[]
  error?: { message?: string; cursorpos?: number; isMysql?: boolean } | null
}

const sampleFiles = ref<SampleFileInfo[]>([])
const inFlightParseRequests = new Map<string, Promise<ParseResponse>>()

export function useSchemaStore() {
  // Currently active tab
  const activeTab = computed(() => {
    return tabs.value.find(t => t.id === activeTabId.value) || tabs.value[0]
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
    if (tabs.value.length >= MAX_WORKSPACE_TABS) {
      isTabLimitModalOpen.value = true
      return null
    }

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
    return newTab
  }

  function closeTab(tabId: string) {
    if (tabs.value.length <= 1) {
      return
    }

    const index = tabs.value.findIndex(t => t.id === tabId)
    if (index === -1) return

    tabs.value.splice(index, 1)

    if (activeTabId.value === tabId) {
      const nextIndex = Math.max(0, index - 1)
      activeTabId.value = tabs.value[nextIndex].id
    }
  }

  function switchTab(tabId: string) {
    const exists = tabs.value.some(t => t.id === tabId)
    if (exists) {
      activeTabId.value = tabId
    }
  }

  function renameTab(tabId: string, newTitle: string) {
    const tab = tabs.value.find(t => t.id === tabId)
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
    const targetExt =
      targetLang === 'dbml'
        ? '.dbml'
        : targetLang === 'prisma'
          ? '.prisma'
          : targetLang === 'typeorm' || targetLang === 'drizzle'
            ? '.ts'
            : '.sql'
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

      const baseName = (sourceTab.fileName || 'schema').replace(
        /\.(sql|ddl|pgsql|dbml|prisma|ts)$/i,
        ''
      )
      const targetExt =
        targetLang === 'dbml'
          ? '.dbml'
          : targetLang === 'prisma'
            ? '.prisma'
            : targetLang === 'typeorm' || targetLang === 'drizzle'
              ? '.ts'
              : '.sql'

      let targetTitle = `${baseName}${targetExt}`
      if (tabs.value.some(t => t.title === targetTitle || t.fileName === targetTitle)) {
        let counter = 1
        while (
          tabs.value.some(
            t =>
              t.title === `${baseName}-${counter}${targetExt}` ||
              t.fileName === `${baseName}-${counter}${targetExt}`
          )
        ) {
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
        Array<{
          id: string
          label: string
          description: string
          sql: string
          language?: SupportedLanguage
        }>
      >('/api/schema/samples')
      if (presets && presets.length) {
        availablePresets.value = presets
      }
    } catch (err) {
      console.warn('Could not fetch presets from Nitro backend:', err)
    }
  }

  async function fetchSampleFiles() {
    try {
      const files = await $fetch<SampleFileInfo[]>('/api/sample-files')
      if (Array.isArray(files) && files.length > 0) {
        sampleFiles.value = files
        return
      }
    } catch (apiErr) {
      console.warn('[sample-files:api-fallback] Fetching from static public CDN...', apiErr)
    }

    try {
      const staticFiles = await $fetch<SampleFileInfo[]>('/sample-db-files/manifest.json')
      if (Array.isArray(staticFiles) && staticFiles.length > 0) {
        sampleFiles.value = staticFiles
      }
    } catch (staticErr) {
      console.warn('Could not fetch sample files from static public manifest:', staticErr)
    }
  }

  // Parse SQL, DBML or Prisma into structured AST table/relation graph on Nitro
  async function parseSchema(
    code: string,
    langOverride?: SupportedLanguage
  ): Promise<ParseResponse> {
    if (!activeTab.value) return { success: true, tables: [], relations: [], error: null }

    const targetTabId = activeTabId.value
    const targetTab = tabs.value.find(t => t.id === targetTabId)
    if (!targetTab) return { success: true, tables: [], relations: [], error: null }

    const language = langOverride || targetTab.language || detectLanguageFromCode(code)

    if (!code || !code.trim()) {
      targetTab.parsedTables = []
      targetTab.parsedRelations = []
      parseWarning.value = null
      return { success: true, tables: [], relations: [], error: null }
    }

    // ---------------------------------------------------------------------------
    // 1. Universal pre-parse sanitization for all schema languages:
    //    Strip comments, blank lines, and non-structural payload so only
    //    clean definitions reach the parser and memory is protected.
    // ---------------------------------------------------------------------------
    let codeToSend = code
    if (language === 'sql') {
      codeToSend = sanitizeSqlDdl(code)
    } else if (language === 'dbml') {
      codeToSend = sanitizeDbml(code)
    } else if (language === 'drizzle') {
      codeToSend = sanitizeDrizzle(code)
    } else if (language === 'typeorm') {
      codeToSend = sanitizeTypeORM(code)
    } else if (language === 'prisma') {
      codeToSend = sanitizePrisma(code)
    }

    // ---------------------------------------------------------------------------
    // 2. Byte-size guard — skip parsing if sanitized DDL is still too large.
    //    Surface a soft warning instead of crashing the WASM parser.
    // ---------------------------------------------------------------------------
    const byteSize = new TextEncoder().encode(codeToSend).length
    if (language === 'sql' && byteSize > MAX_DDL_BYTES) {
      parseWarning.value =
        `Schema DDL is ${Math.round(byteSize / 1024)}KB after sanitizing — ` +
        `exceeds the ${Math.round(MAX_DDL_BYTES / 1024)}KB parser limit. ` +
        `Diagram may not render. Try removing extra comments or splitting the file.`
      isParsing.value = false
      return {
        success: false,
        tables: targetTab.parsedTables,
        relations: targetTab.parsedRelations,
        error: { message: parseWarning.value },
      }
    }

    parseWarning.value = null

    // ---------------------------------------------------------------------------
    // 3. Cache lookup — return immediately if this exact code was parsed before.
    // ---------------------------------------------------------------------------
    const cached = getCached(targetTabId, language, codeToSend)
    if (cached) {
      targetTab.parsedTables = cached.tables
      targetTab.parsedRelations = cached.relations
      return {
        success: true,
        tables: cached.tables,
        relations: cached.relations,
        error: null,
      }
    }

    // ---------------------------------------------------------------------------
    // 4. In-flight request deduplication — reuse pending request if already in progress
    // ---------------------------------------------------------------------------
    const reqKey = `${targetTabId}::${language}::${codeToSend}`
    if (inFlightParseRequests.has(reqKey)) {
      return await inFlightParseRequests.get(reqKey)!
    }

    // ---------------------------------------------------------------------------
    // 5. Fetch from Nitro / WASM parser, then cache the result.
    // ---------------------------------------------------------------------------
    isParsing.value = true
    const parsePromise = (async (): Promise<ParseResponse> => {
      try {
        const res = await $fetch<ParseResponse>('/api/schema/parse', {
          method: 'POST',
          body: { sql: codeToSend, language },
        })
        if (res && res.success) {
          const entry: ParseCacheEntry = {
            tables: res.tables || [],
            relations: res.relations || [],
            cachedAt: Date.now(),
          }
          targetTab.parsedTables = entry.tables
          targetTab.parsedRelations = entry.relations
          setCached(targetTabId, language, codeToSend, entry)
        }
        return res || { success: true, tables: [], relations: [], error: null }
      } catch (err: unknown) {
        console.warn('Schema parse error:', err)
        return {
          success: false,
          tables: [],
          relations: [],
          error: { message: err instanceof Error ? err.message : String(err) },
        }
      } finally {
        isParsing.value = false
        inFlightParseRequests.delete(reqKey)
      }
    })()

    inFlightParseRequests.set(reqKey, parsePromise)
    return await parsePromise
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
    const found = availablePresets.value.find(p => p.id === sampleId)
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

  function loadSampleFile(file: SampleFileInfo) {
    // If the file is already open in the tab, do not open or duplicate it
    const existing = tabs.value.find(
      t =>
        t.title.toLowerCase() === file.fileName.toLowerCase() ||
        t.title.toLowerCase() === file.baseName.toLowerCase()
    )
    if (existing) {
      switchTab(existing.id)
      return
    }

    if (tabs.value.length >= MAX_WORKSPACE_TABS) {
      isTabLimitModalOpen.value = true
      return
    }

    addNewTab(file.fileName, file.content, file.language)
  }

  async function exportSchema(format: 'typescript' | 'prisma' | 'dbml' | 'json') {
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
      console.error('Export failed:', err)
      return { success: false, content: '', format }
    }
  }

  function formatSql() {
    // Basic SQL formatting
    if (!activeTab.value?.sqlCode) return
    const formatted = activeTab.value.sqlCode
      .replace(/\s+/g, ' ')
      .replace(/,\s*/g, ',\n  ')
      .replace(/\s*;\s*/g, ';\n\n')
      .replace(/CREATE TABLE/gi, '\nCREATE TABLE')
      .trim()
    activeTab.value.sqlCode = formatted
  }

  function canAddTabs(count = 1): boolean {
    return tabs.value.length + count <= MAX_WORKSPACE_TABS
  }

  function exportAllTabsAsZip(zipName = 'collection.zip') {
    const fileEntries: ZipFileEntry[] = tabs.value.map(tab => ({
      name: tab.fileName || `${tab.title || 'schema'}.sql`,
      content: tab.sqlCode || '',
    }))
    downloadZipArchive(fileEntries, zipName)
  }

  return {
    tabs,
    activeTab,
    activeTabId,
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
    sampleFiles,
    fetchSampleFiles,
    loadSampleFile,
    parseSchema,
    parseSchemaOnServer: parseSchema,
    setSqlCode,
    setCursorPosition,
    saveSchema,
    loadSample,
    exportSchema,
    formatSql,
    isTabLimitModalOpen,
    parseWarning,
    MAX_WORKSPACE_TABS,
    canAddTabs,
    exportAllTabsAsZip,
  }
}
