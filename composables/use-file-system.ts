import { toPng, toSvg, toJpeg } from 'html-to-image'
import type { SupportedLanguage } from '~/composables/use-schema-store'

export interface FilePickerTypeFilter {
  description?: string
  accept: Record<string, string[]>
}

export interface FilePickerOpenOptions {
  types?: FilePickerTypeFilter[]
  multiple?: boolean
}

export interface FilePickerSaveOptions {
  suggestedName?: string
  types?: FilePickerTypeFilter[]
}

interface WindowWithFileSystemApi extends Window {
  showOpenFilePicker?: (options?: FilePickerOpenOptions) => Promise<FileSystemFileHandle[]>
  showSaveFilePicker?: (options?: FilePickerSaveOptions) => Promise<FileSystemFileHandle>
}

export function createWatermarkElement(): HTMLDivElement {
  const watermark = document.createElement('div')
  watermark.setAttribute('id', 'schemacraft-export-watermark')
  watermark.setAttribute('data-watermark', 'true')

  watermark.style.cssText = [
    'position: absolute',
    'right: 24px',
    'bottom: 24px',
    'z-index: 99999',
    'display: inline-flex',
    'align-items: center',
    'gap: 10px',
    'padding: 8px 16px',
    'background: rgba(15, 23, 42, 0.88)',
    'border-radius: 9999px',
    'font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
    'pointer-events: none',
    'user-select: none',
    'line-height: 1',
    'opacity: 0.6',
  ].join('; ')

  watermark.innerHTML = `
    <div style="display: flex; align-items: center; justify-content: center; width: 22px; height: 22px; border-radius: 6px; background: linear-gradient(135deg, #3b82f6 0%, #6366f1 100%); box-shadow: 0 2px 8px rgba(59, 130, 246, 0.4);">
      <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#ffffff" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <ellipse cx="12" cy="5" rx="9" ry="3"></ellipse>
        <path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5"></path>
        <path d="M3 12c0 1.66 4 3 9 3s9-1.34 9-3"></path>
      </svg>
    </div>
    <div style="display: flex; flex-direction: column; gap: 2px;">
      <div style="font-size: 12px; font-weight: 800; color: #f8fafc; letter-spacing: -0.02em; display: flex; align-items: center; gap: 1px;">
        <span>Schema</span><span style="color: #60a5fa;">Craft</span>
      </div>
      <div style="font-size: 8px; font-weight: 600; color: #94a3b8; letter-spacing: 0.05em; text-transform: uppercase;">
        Visual Database Editor
      </div>
    </div>
  `

  return watermark
}

const isLargeSchemaModalOpen = ref(false)
const pendingExportFormat = ref<'png' | 'svg' | 'jpeg'>('png')
const pendingExportOptions = ref<{ quality?: number; scale?: number }>({})

export function useFileSystem() {
  const {
    sqlCode,
    fileName,
    lastSavedCode,
    lastSaveTimestamp,
    activeTab,
    parsedTables,
    parseSchema,
    detectLanguageFromCode,
  } = useSchemaStore()

  const { validateUploadFiles, setReuploadHandler } = useUploadGuard()
  const { startUploadQueue } = useSchemaUploader()

  const isExportingImage = ref(false)
  const isSavingFile = ref(false)

  function detectLanguageForFile(targetFileName: string, text: string): SupportedLanguage {
    const lower = targetFileName.toLowerCase()
    if (lower.endsWith('.dbml')) return 'dbml'
    if (lower.endsWith('.prisma')) return 'prisma'
    if (lower.endsWith('.ts') || lower.endsWith('.js')) {
      const detected = detectLanguageFromCode(text)
      return detected === 'typeorm' || detected === 'drizzle' ? detected : 'drizzle'
    }
    return detectLanguageFromCode(text)
  }

  // Open .sql, .dbml, .prisma, or .ts (Drizzle/TypeORM) using File System Access API
  async function openSqlFile() {
    try {
      const win = typeof window !== 'undefined' ? (window as WindowWithFileSystemApi) : null
      if (win && typeof win.showOpenFilePicker === 'function') {
        const handles = await win.showOpenFilePicker({
          types: [
            {
              description: 'All Supported Schemas (*.sql, *.dbml, *.prisma, *.ts, *.ddl)',
              accept: {
                'text/plain': ['.sql', '.dbml', '.prisma', '.ts', '.ddl', '.pgsql', '.txt'],
              },
            },
            {
              description: 'SQL Database Files (*.sql, *.ddl, *.pgsql)',
              accept: {
                'text/plain': ['.sql', '.ddl', '.pgsql'],
              },
            },
            {
              description: 'Prisma Schema Files (*.prisma)',
              accept: {
                'text/plain': ['.prisma'],
              },
            },
            {
              description: 'DBML Files (*.dbml)',
              accept: {
                'text/plain': ['.dbml'],
              },
            },
            {
              description: 'TypeScript ORM Schemas (*.ts)',
              accept: {
                'text/plain': ['.ts'],
              },
            },
          ],
          multiple: true,
        })

        if (!handles || handles.length === 0) return

        const files = await Promise.all(handles.map(h => h.getFile()))
        setReuploadHandler(() => {
          openSqlFile()
        })

        const validation = validateUploadFiles(files)
        if (validation.valid && validation.files.length > 0) {
          await startUploadQueue(validation.files)
        }
      } else {
        // Fallback for browsers without File System Access API
        const input = document.createElement('input')
        input.type = 'file'
        input.multiple = true
        input.accept = '.sql,.dbml,.prisma,.ts,.ddl,.pgsql,.txt,text/plain'
        input.onchange = async (e: Event) => {
          const target = e.target as HTMLInputElement | null
          const fileList = target?.files ? Array.from(target.files) : []
          if (fileList.length === 0) return

          setReuploadHandler(() => {
            openSqlFile()
          })

          const validation = validateUploadFiles(fileList)
          if (validation.valid && validation.files.length > 0) {
            await startUploadQueue(validation.files)
          }
        }
        input.click()
      }
    } catch (err: unknown) {
      if (err instanceof Error && err.name !== 'AbortError') {
        console.error('Failed to open schema file:', err)
      }
    }
  }

  // Save current content to disk with language-aware extension
  async function saveSqlFile(forceSaveAs = false) {
    isSavingFile.value = true
    try {
      const currentLang = activeTab.value?.language || 'sql'
      let targetExt = '.sql'
      if (currentLang === 'dbml') targetExt = '.dbml'
      else if (currentLang === 'prisma') targetExt = '.prisma'
      else if (currentLang === 'drizzle' || currentLang === 'typeorm') targetExt = '.ts'

      const baseName = (fileName.value || 'schema').replace(
        /\.(sql|dbml|prisma|ddl|pgsql|ts|txt)$/i,
        ''
      )
      const suggestedFileName = `${baseName}${targetExt}`

      const win = typeof window !== 'undefined' ? (window as WindowWithFileSystemApi) : null
      if (win && typeof win.showSaveFilePicker === 'function') {
        let handle = activeTab.value?.fileHandle
        if (!handle || forceSaveAs) {
          const typeFilters: FilePickerTypeFilter[] = []
          if (currentLang === 'prisma') {
            typeFilters.push({
              description: 'Prisma Schema File (*.prisma)',
              accept: { 'text/plain': ['.prisma'] },
            })
          } else if (currentLang === 'dbml') {
            typeFilters.push({
              description: 'Database Markup Language (*.dbml)',
              accept: { 'text/plain': ['.dbml'] },
            })
          } else if (currentLang === 'drizzle') {
            typeFilters.push({
              description: 'Drizzle ORM Schema (*.ts)',
              accept: { 'text/plain': ['.ts'] },
            })
          } else if (currentLang === 'typeorm') {
            typeFilters.push({
              description: 'TypeORM Entity File (*.ts)',
              accept: { 'text/plain': ['.ts'] },
            })
          } else {
            typeFilters.push({
              description: 'SQL Database File (*.sql)',
              accept: { 'text/plain': ['.sql', '.ddl', '.pgsql'] },
            })
          }

          handle = await win.showSaveFilePicker({
            suggestedName: suggestedFileName,
            types: typeFilters,
          })

          if (activeTab.value && handle) {
            activeTab.value.fileHandle = handle
          }
        }

        if (handle) {
          const writable = await handle.createWritable()
          await writable.write(sqlCode.value)
          await writable.close()

          const file = await handle.getFile()
          fileName.value = file.name || suggestedFileName
          lastSavedCode.value = sqlCode.value
          lastSaveTimestamp.value = new Date()
          await parseSchema(sqlCode.value, currentLang)
        }
      } else {
        // Fallback Blob Download
        const blob = new Blob([sqlCode.value], { type: 'text/plain;charset=utf-8' })
        const url = URL.createObjectURL(blob)
        const a = document.createElement('a')
        a.href = url
        a.download = suggestedFileName
        a.click()
        URL.revokeObjectURL(url)

        lastSavedCode.value = sqlCode.value
        lastSaveTimestamp.value = new Date()
        await parseSchema(sqlCode.value, currentLang)
      }
    } catch (err: unknown) {
      if (err instanceof Error && err.name !== 'AbortError') {
        console.error('Failed to save file:', err)
      }
    } finally {
      isSavingFile.value = false
    }
  }

  // Export diagram viewport as high-res PNG / SVG / JPEG with active theme background and stylish SchemaCraft watermark
  async function exportDiagramAsImage(
    format: 'png' | 'svg' | 'jpeg' = 'png',
    options: { quality?: number; scale?: number } = {},
    skipWarning = false
  ) {
    const tableCount = parsedTables.value?.length || activeTab.value?.parsedTables?.length || 0
    if (tableCount > 10 && !skipWarning) {
      pendingExportFormat.value = format
      pendingExportOptions.value = options
      isLargeSchemaModalOpen.value = true
      return false
    }

    const { quality = 0.95, scale = 2 } = options
    isExportingImage.value = true

    let watermarkEl: HTMLElement | null = null

    try {
      const targetElement =
        (document.querySelector('.vue-flow') as HTMLElement) ||
        (document.querySelector('.vue-flow__viewport') as HTMLElement)

      if (!targetElement) {
        throw new Error('Diagram canvas container not found')
      }

      // Inject stylish SchemaCraft watermark badge at bottom-right corner for export
      watermarkEl = createWatermarkElement()
      targetElement.appendChild(watermarkEl)

      const timestamp = new Date().toISOString().slice(0, 10)
      const baseFileName = (fileName.value || 'schema').replace(/\.[^/.]+$/, '')
      const exportName = `${baseFileName}-diagram-${timestamp}.${format}`

      const activeBg =
        typeof window !== 'undefined'
          ? getComputedStyle(document.documentElement).getPropertyValue('--canvas-bg').trim() ||
            '#1e1f1c'
          : '#1e1f1c'

      let dataUrl = ''
      const config = {
        backgroundColor: activeBg,
        pixelRatio: scale,
        quality: format === 'jpeg' ? quality : undefined,
        style: {
          transform: 'none',
        },
        filter: (node: HTMLElement) => {
          if (
            node?.classList &&
            (node.classList.contains('schemacraft-canvas-controls') ||
              node.classList.contains('vue-flow__controls'))
          ) {
            return false
          }
          return true
        },
      }

      if (format === 'svg') {
        dataUrl = await toSvg(targetElement, config)
      } else if (format === 'jpeg') {
        dataUrl = await toJpeg(targetElement, config)
      } else {
        dataUrl = await toPng(targetElement, config)
      }

      // Download file
      const link = document.createElement('a')
      link.download = exportName
      link.href = dataUrl
      link.click()

      return true
    } catch (err: unknown) {
      console.error('Exporting diagram image failed:', err)
      return false
    } finally {
      if (watermarkEl && watermarkEl.parentNode) {
        watermarkEl.parentNode.removeChild(watermarkEl)
      }
      isExportingImage.value = false
    }
  }

  function cancelLargeSchemaExport() {
    isLargeSchemaModalOpen.value = false
  }

  async function continueLargeSchemaExport() {
    isLargeSchemaModalOpen.value = false
    await exportDiagramAsImage(pendingExportFormat.value, pendingExportOptions.value, true)
  }

  return {
    openSqlFile,
    saveSqlFile,
    exportDiagramAsImage,
    detectLanguageForFile,
    createWatermarkElement,
    isLargeSchemaModalOpen,
    pendingExportFormat,
    cancelLargeSchemaExport,
    continueLargeSchemaExport,
    isExportingImage,
    isSavingFile,
  }
}
