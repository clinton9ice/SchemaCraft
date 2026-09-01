import { toPng, toSvg, toJpeg } from 'html-to-image'

let activeFileHandle: any = null

export function useFileSystem() {
  const {
    sqlCode,
    fileName,
    lastSavedCode,
    lastSaveTimestamp,
    activeTab,
    isDirty,
    addNewTab,
    setSqlCode,
    parseSchemaOnServer,
    detectLanguageFromCode,
  } = useSchemaStore()

  const isExportingImage = ref(false)
  const isSavingFile = ref(false)

  // Open .sql, .dbml, or .prisma file using File System Access API
  async function openSqlFile() {
    try {
      if (typeof window !== 'undefined' && 'showOpenFilePicker' in window) {
        const [handle] = await (window as any).showOpenFilePicker({
          types: [
            {
              description: 'Database Schema Files (*.sql, *.dbml, *.prisma, *.ddl)',
              accept: {
                'text/plain': ['.sql', '.dbml', '.prisma', '.ddl', '.pgsql', '.txt'],
              },
            },
          ],
          multiple: false,
        })

        if (!handle) return

        activeFileHandle = handle
        const file = await handle.getFile()
        const text = await file.text()
        const targetFileName = file.name || 'schema.sql'
        const detectedLang = targetFileName.endsWith('.dbml')
          ? 'dbml'
          : targetFileName.endsWith('.prisma')
          ? 'prisma'
          : detectLanguageFromCode(text)

        if (isDirty.value) {
          // If current tab has unsaved changes, open in a new tab
          addNewTab(targetFileName, text, detectedLang)
        } else {
          fileName.value = targetFileName
          if (activeTab.value) {
            activeTab.value.language = detectedLang
          }
          setSqlCode(text)
          lastSavedCode.value = text
          lastSaveTimestamp.value = new Date()
          await parseSchemaOnServer(text, detectedLang)
        }
      } else {
        // Fallback for browsers without File System Access API
        const input = document.createElement('input')
        input.type = 'file'
        input.accept = '.sql,.dbml,.prisma,.ddl,.pgsql,.txt,text/plain'
        input.onchange = async (e: any) => {
          const file = e.target.files?.[0]
          if (!file) return

          const text = await file.text()
          const targetFileName = file.name || 'schema.sql'
          const detectedLang = targetFileName.endsWith('.dbml')
            ? 'dbml'
            : targetFileName.endsWith('.prisma')
            ? 'prisma'
            : detectLanguageFromCode(text)

          if (isDirty.value) {
            addNewTab(targetFileName, text, detectedLang)
          } else {
            fileName.value = targetFileName
            if (activeTab.value) {
              activeTab.value.language = detectedLang
            }
            setSqlCode(text)
            lastSavedCode.value = text
            lastSaveTimestamp.value = new Date()
            await parseSchemaOnServer(text, detectedLang)
          }
        }
        input.click()
      }
    } catch (err: any) {
      if (err.name !== 'AbortError') {
        console.error('Failed to open schema file:', err)
      }
    }
  }

  // Save current content to disk with language-aware extension
  async function saveSqlFile(forceSaveAs = false) {
    isSavingFile.value = true
    try {
      const currentLang = activeTab.value?.language || 'sql'
      const targetExt = currentLang === 'dbml' ? '.dbml' : currentLang === 'prisma' ? '.prisma' : '.sql'
      const baseName = (fileName.value || 'schema').replace(/\.(sql|dbml|prisma|ddl|pgsql)$/i, '')
      const suggestedFileName = `${baseName}${targetExt}`

      if (typeof window !== 'undefined' && 'showSaveFilePicker' in window) {
        if (!activeFileHandle || forceSaveAs) {
          activeFileHandle = await (window as any).showSaveFilePicker({
            suggestedName: suggestedFileName,
            types: [
              currentLang === 'prisma'
                ? {
                    description: 'Prisma Schema File (*.prisma)',
                    accept: { 'text/plain': ['.prisma'] },
                  }
                : currentLang === 'dbml'
                ? {
                    description: 'Database Markup Language (*.dbml)',
                    accept: { 'text/plain': ['.dbml'] },
                  }
                : {
                    description: 'SQL Database File (*.sql)',
                    accept: { 'text/plain': ['.sql', '.ddl'] },
                  },
            ],
          })
        }

        if (activeFileHandle) {
          const writable = await activeFileHandle.createWritable()
          await writable.write(sqlCode.value)
          await writable.close()

          const file = await activeFileHandle.getFile()
          fileName.value = file.name || suggestedFileName
          lastSavedCode.value = sqlCode.value
          lastSaveTimestamp.value = new Date()
          await parseSchemaOnServer(sqlCode.value, currentLang)
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
        await parseSchemaOnServer(sqlCode.value, currentLang)
      }
    } catch (err: any) {
      if (err.name !== 'AbortError') {
        console.error('Failed to save file:', err)
      }
    } finally {
      isSavingFile.value = false
    }
  }

  // Export diagram viewport as high-res PNG / SVG / JPEG
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

      let dataUrl = ''
      const config = {
        backgroundColor: '#0b0f17',
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
    } catch (err) {
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
    isExportingImage,
    isSavingFile,
  }
}
