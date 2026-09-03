import { describe, it, expect, vi, beforeEach } from 'vitest'
import sampleFilesHandler from '../../server/api/sample-files/index.get'
import { useSchemaStore, type SampleFileInfo } from '../../composables/use-schema-store'

describe('Sample Files API & Deduplication', () => {
  beforeEach(() => {
    vi.stubGlobal('$fetch', vi.fn().mockResolvedValue({ success: true, tables: [], relations: [] }))
  })
  it('reads and sanitizes files from sample-db-files directory', () => {
    // Call handler with mock event
    const files: SampleFileInfo[] = sampleFilesHandler({} as never)
    expect(files.length).toBeGreaterThanOrEqual(4)

    const extensions = files.map(f => f.ext)
    expect(extensions).toContain('dbml')
    expect(extensions).toContain('ts')
    expect(extensions).toContain('sql')

    for (const f of files) {
      expect(f.fileName).toBeTruthy()
      expect(f.baseName).toBeTruthy()
      expect(f.ext).toBeTruthy()
      expect(f.language).toBeTruthy()
      expect(f.content).toBeTruthy()
      // Comments stripped
      expect(f.content).not.toContain('/*')
    }
  })

  it('deduplicates sample file loading when tab is already open', () => {
    const { tabs, loadSampleFile } = useSchemaStore()

    const initialTabCount = tabs.value.length

    const sampleFile: SampleFileInfo = {
      fileName: 'test_sample_1.sql',
      baseName: 'test_sample_1',
      ext: 'sql',
      language: 'sql',
      content: 'CREATE TABLE sample_orders (id INT PRIMARY KEY);',
    }

    // First load -> creates tab
    loadSampleFile(sampleFile)
    expect(tabs.value.length).toBe(initialTabCount + 1)
    const openedTab = tabs.value.find(t => t.title === 'test_sample_1.sql')
    expect(openedTab).toBeTruthy()

    // Second load -> should NOT create new tab, should reuse existing tab
    loadSampleFile(sampleFile)
    expect(tabs.value.length).toBe(initialTabCount + 1)
  })

  it('matches existing tab by baseName or fileName case-insensitively', () => {
    const { tabs, loadSampleFile, activeTabId } = useSchemaStore()

    const countBefore = tabs.value.length
    const sampleFile: SampleFileInfo = {
      fileName: 'TEST_SAMPLE_1.SQL',
      baseName: 'TEST_SAMPLE_1',
      ext: 'sql',
      language: 'sql',
      content: 'CREATE TABLE sample_orders (id INT PRIMARY KEY);',
    }

    loadSampleFile(sampleFile)
    expect(tabs.value.length).toBe(countBefore)
    const existing = tabs.value.find(t => t.title.toLowerCase() === 'test_sample_1.sql')
    expect(activeTabId.value).toBe(existing?.id)
  })
})
