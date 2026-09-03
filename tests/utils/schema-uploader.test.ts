// @vitest-environment happy-dom
import { describe, it, expect, beforeEach, vi } from 'vitest'
import { useSchemaUploader } from '../../composables/use-schema-uploader'
import { useSchemaStore } from '../../composables/use-schema-store'

describe('useSchemaUploader Composable', () => {
  beforeEach(() => {
    vi.restoreAllMocks()
    vi.stubGlobal('$fetch', vi.fn().mockResolvedValue({ success: true, tables: [], relations: [] }))
    const { tabs, switchTab } = useSchemaStore()
    while (tabs.value.length > 1) {
      tabs.value.pop()
    }
    switchTab(tabs.value[0].id)
  })

  it('processes standard PostgreSQL file to completed stage and sanitizes data rows', async () => {
    const { startUploadQueue, isUploadModalOpen, stage, completedSchemas, handleVisualise } =
      useSchemaUploader()

    const pgFile = new File(
      [
        'CREATE TABLE users (id SERIAL PRIMARY KEY, name TEXT);\nINSERT INTO users (id, name) VALUES (1, "Test");',
      ],
      'users.sql',
      { type: 'text/plain' }
    )

    await startUploadQueue([pgFile])

    expect(isUploadModalOpen.value).toBe(true)
    expect(stage.value).toBe('completed')
    expect(completedSchemas.value.length).toBe(1)
    expect(completedSchemas.value[0].title).toBe('users.sql')
    expect(completedSchemas.value[0].language).toBe('sql')
    // Data rows should have been stripped to protect heap memory
    expect(completedSchemas.value[0].content).not.toContain('INSERT INTO')

    // Visualise into editor tabs
    const { tabs } = useSchemaStore()
    handleVisualise()

    expect(isUploadModalOpen.value).toBe(false)
    expect(tabs.value.some(t => t.title === 'users.sql' && t.language === 'sql')).toBe(true)
  })

  it('automatically detects .prisma extension and opens in prisma mode without dialect check', async () => {
    const { startUploadQueue, stage, completedSchemas, handleVisualise } = useSchemaUploader()

    const prismaFile = new File(
      ['model User {\n  id Int @id @default(autoincrement())\n  email String @unique\n}'],
      'schema.prisma',
      { type: 'text/plain' }
    )

    await startUploadQueue([prismaFile])

    // Should complete directly without pausing at dialect_prompt
    expect(stage.value).toBe('completed')
    expect(completedSchemas.value.length).toBe(1)
    expect(completedSchemas.value[0].language).toBe('prisma')

    const { tabs } = useSchemaStore()
    handleVisualise()

    const addedTab = tabs.value.find(t => t.title === 'schema.prisma')
    expect(addedTab).toBeDefined()
    expect(addedTab?.language).toBe('prisma')
  })

  it('automatically detects .dbml extension and opens in dbml mode without dialect check', async () => {
    const { startUploadQueue, stage, completedSchemas, handleVisualise } = useSchemaUploader()

    const dbmlFile = new File(
      ['Table users {\n  id integer [pk]\n  username varchar\n}'],
      'database.dbml',
      { type: 'text/plain' }
    )

    await startUploadQueue([dbmlFile])

    expect(stage.value).toBe('completed')
    expect(completedSchemas.value.length).toBe(1)
    expect(completedSchemas.value[0].language).toBe('dbml')

    const { tabs } = useSchemaStore()
    handleVisualise()

    const addedTab = tabs.value.find(t => t.title === 'database.dbml')
    expect(addedTab).toBeDefined()
    expect(addedTab?.language).toBe('dbml')
  })

  it('automatically detects .ts Drizzle/TypeORM extension without dialect check', async () => {
    const { startUploadQueue, stage, completedSchemas, handleVisualise } = useSchemaUploader()

    const drizzleFile = new File(
      [
        "import { pgTable, serial, text } from 'drizzle-orm/pg-core';\nexport const users = pgTable('users', { id: serial('id').primaryKey() });",
      ],
      'schema.ts',
      { type: 'text/plain' }
    )

    await startUploadQueue([drizzleFile])

    expect(stage.value).toBe('completed')
    expect(completedSchemas.value.length).toBe(1)
    expect(completedSchemas.value[0].language).toBe('drizzle')

    const { tabs } = useSchemaStore()
    handleVisualise()

    const addedTab = tabs.value.find(t => t.title === 'schema.ts')
    expect(addedTab).toBeDefined()
    expect(addedTab?.language).toBe('drizzle')
  })

  it('pauses at dialect_prompt for MySQL file and transforms upon proceed', async () => {
    const { startUploadQueue, stage, currentItem, handleUserProceed, completedSchemas } =
      useSchemaUploader()

    const mysqlFile = new File(
      ['CREATE TABLE `product` (`id` int(11) NOT NULL) ENGINE=InnoDB;'],
      'product.sql',
      { type: 'text/plain' }
    )

    // Start queue without waiting for completion (it will pause on dialect_prompt)
    const queuePromise = startUploadQueue([mysqlFile])

    // Wait until queue worker reaches the dialect_prompt stage
    while (stage.value !== 'dialect_prompt') {
      await new Promise(r => setTimeout(r, 30))
    }

    expect(stage.value).toBe('dialect_prompt')
    expect(currentItem.value?.isMysql).toBe(true)

    // User confirms Proceed
    handleUserProceed()
    await queuePromise

    expect(stage.value).toBe('completed')
    expect(completedSchemas.value.length).toBe(1)
    expect(completedSchemas.value[0].content.includes('`')).toBe(false)
  })

  it('skips file when user clicks decline on MySQL prompt', async () => {
    const { startUploadQueue, stage, handleUserDecline, completedSchemas } = useSchemaUploader()

    const mysqlFile = new File(
      ['CREATE TABLE `product` (`id` int(11) NOT NULL) ENGINE=InnoDB;'],
      'product.sql',
      { type: 'text/plain' }
    )

    const queuePromise = startUploadQueue([mysqlFile])
    while (stage.value !== 'dialect_prompt') {
      await new Promise(r => setTimeout(r, 30))
    }

    expect(stage.value).toBe('dialect_prompt')

    // User declines transformation
    handleUserDecline()
    await queuePromise

    expect(stage.value).toBe('completed')
    // File was skipped, so zero schemas added
    expect(completedSchemas.value.length).toBe(0)
  })
})
