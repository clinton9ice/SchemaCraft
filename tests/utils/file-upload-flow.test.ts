// @vitest-environment happy-dom
import { describe, it, expect, beforeEach, vi } from 'vitest'
import { useUploadGuard } from '../../composables/use-upload-guard'
import { useSchemaUploader } from '../../composables/use-schema-uploader'
import { useSchemaStore } from '../../composables/use-schema-store'

describe('File Upload & Multi-Tab Pipeline Integration', () => {
  beforeEach(() => {
    vi.restoreAllMocks()
    vi.stubGlobal('$fetch', vi.fn().mockResolvedValue({ success: true, tables: [], relations: [] }))
    const { tabs, switchTab } = useSchemaStore()
    while (tabs.value.length > 1) {
      tabs.value.pop()
    }
    switchTab(tabs.value[0].id)
  })

  it('validates and executes upload queue for multiple files, transforming MySQL and populating tabs', async () => {
    const { validateUploadFiles } = useUploadGuard()
    const { startUploadQueue, stage, handleUserProceed, completedSchemas, handleVisualise } =
      useSchemaUploader()
    const { tabs, exportAllTabsAsZip } = useSchemaStore()

    const pgFile = new File(
      ['CREATE TABLE authors (id SERIAL PRIMARY KEY, name TEXT);'],
      'authors.sql',
      { type: 'text/plain' }
    )

    const mysqlFile = new File(
      [
        'CREATE TABLE `books` (`id` int(11) NOT NULL, `title` varchar(255) NOT NULL) ENGINE=InnoDB;',
      ],
      'books.sql',
      { type: 'text/plain' }
    )

    // Validate batch
    const validation = validateUploadFiles([pgFile, mysqlFile])
    expect(validation.valid).toBe(true)
    expect(validation.files.length).toBe(2)

    // Process queue
    const queuePromise = startUploadQueue(validation.files)

    // Wait until the MySQL file triggers dialect_prompt
    while (stage.value !== 'dialect_prompt') {
      await new Promise(r => setTimeout(r, 30))
    }

    expect(stage.value).toBe('dialect_prompt')

    // Confirm Proceed with MySQL conversion
    handleUserProceed()
    await queuePromise

    expect(stage.value).toBe('completed')
    expect(completedSchemas.value.length).toBe(2)

    // Click Visualise
    handleVisualise()

    expect(tabs.value.some(t => t.title === 'authors.sql')).toBe(true)
    expect(tabs.value.some(t => t.title === 'books.sql')).toBe(true)

    // Verify collection.zip export includes all tabs
    const appendChildSpy = vi.spyOn(document.body, 'appendChild')
    const originalCreateObjectURL = window.URL.createObjectURL
    window.URL.createObjectURL = vi.fn().mockReturnValue('blob:mock-collection-zip')

    await exportAllTabsAsZip('collection.zip')
    expect(appendChildSpy).toHaveBeenCalled()

    window.URL.createObjectURL = originalCreateObjectURL
    appendChildSpy.mockRestore()
  })
})
