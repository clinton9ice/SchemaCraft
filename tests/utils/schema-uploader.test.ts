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

  it('processes standard PostgreSQL file to completed stage', async () => {
    const { startUploadQueue, isUploadModalOpen, stage, completedSchemas, handleVisualise } =
      useSchemaUploader()

    const pgFile = new File(
      ['CREATE TABLE users (id SERIAL PRIMARY KEY, name TEXT);'],
      'users.sql',
      { type: 'text/plain' }
    )

    await startUploadQueue([pgFile])

    expect(isUploadModalOpen.value).toBe(true)
    expect(stage.value).toBe('completed')
    expect(completedSchemas.value.length).toBe(1)
    expect(completedSchemas.value[0].title).toBe('users.sql')

    // Visualise into editor tabs
    const { tabs } = useSchemaStore()
    handleVisualise()

    expect(isUploadModalOpen.value).toBe(false)
    expect(tabs.value.some(t => t.title === 'users.sql')).toBe(true)
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
