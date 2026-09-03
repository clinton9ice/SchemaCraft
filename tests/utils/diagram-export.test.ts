// @vitest-environment happy-dom
import { describe, it, expect, beforeEach } from 'vitest'
import { createWatermarkElement, useFileSystem } from '../../composables/use-file-system'
import { useSchemaStore } from '../../composables/use-schema-store'

describe('Diagram Export Watermark Structure', () => {
  it('generates a stylish SchemaCraft watermark element with brand identity and positioning', () => {
    const watermark = createWatermarkElement()

    expect(watermark.id).toBe('schemacraft-export-watermark')
    expect(watermark.getAttribute('data-watermark')).toBe('true')
    expect(watermark.textContent).toContain('Schema')
    expect(watermark.textContent).toContain('Craft')
    expect(watermark.textContent).toContain('Visual Database Editor')
    expect(watermark.style.position).toBe('absolute')
    expect(watermark.style.right).toBe('24px')
    expect(watermark.style.bottom).toBe('24px')
    expect(watermark.style.display).toBe('inline-flex')
  })
})

describe('Large Schema Export Warning Guard (>10 Tables)', () => {
  beforeEach(() => {
    const { activeTab } = useSchemaStore()
    if (activeTab.value) {
      activeTab.value.parsedTables = []
    }
    const { isLargeSchemaModalOpen } = useFileSystem()
    isLargeSchemaModalOpen.value = false
  })

  it('triggers large schema warning modal when active schema has more than 10 tables', async () => {
    const { activeTab } = useSchemaStore()
    const { exportDiagramAsImage, isLargeSchemaModalOpen, pendingExportFormat } = useFileSystem()

    // 12 tables in active tab
    if (activeTab.value) {
      activeTab.value.parsedTables = Array.from({ length: 12 }, (_, i) => ({
        name: `table_${i + 1}`,
        columns: [],
      }))
    }

    const result = await exportDiagramAsImage('jpeg')
    expect(result).toBe(false)
    expect(isLargeSchemaModalOpen.value).toBe(true)
    expect(pendingExportFormat.value).toBe('jpeg')
  })

  it('cancels export when cancelLargeSchemaExport is invoked', () => {
    const { isLargeSchemaModalOpen, cancelLargeSchemaExport } = useFileSystem()
    isLargeSchemaModalOpen.value = true

    cancelLargeSchemaExport()
    expect(isLargeSchemaModalOpen.value).toBe(false)
  })
})
