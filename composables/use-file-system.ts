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

export function useFileSystem() {
  const {
    sqlCode,
    fileName,
    lastSavedCode,
    lastSaveTimestamp,
    activeTab,
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

  // Export diagram viewport as high-res PNG / SVG / JPEG with active theme background
  async function exportDiagramAsImage(
    format: 'png' | 'svg' | 'jpeg' = 'png',
    options: { quality?: number; scale?: number } = {}
  ) {
    const { quality = 0.95, scale = 2 } = options
    isExportingImage.value = true

    try {
      const targetElement =
        (document.querySelector('.vue-flow__viewport') as HTMLElement) ||
        (document.querySelector('.vue-flow') as HTMLElement)

      if (!targetElement) {
        throw new Error('Diagram canvas container not found')
      }

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
      isExportingImage.value = false
    }
  }

  return {
    openSqlFile,
    saveSqlFile,
    exportDiagramAsImage,
    detectLanguageForFile,
    isExportingImage,
    isSavingFile,
  }
}
