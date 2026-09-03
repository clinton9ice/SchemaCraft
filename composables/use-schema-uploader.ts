import { detectSqlDialect } from '~/utils/sql-dialect-detector'
import { transformMysqlToPostgres } from '~/utils/mysql-to-postgres-transformer'
import { sanitizeSqlDdl } from '~/utils/sql-sanitizer'
import { sanitizeDbml } from '~/utils/dbml-compiler'
import { sanitizeDrizzle, sanitizeTypeORM } from '~/utils/ts-sanitizer'
import { sanitizePrisma } from '~/utils/prisma-compiler'
import { detectLanguageFromCode, type SupportedLanguage } from '~/composables/use-schema-store'

export type UploadStage =
  'idle' | 'reading' | 'analyzing' | 'dialect_prompt' | 'transforming' | 'completed'

export interface UploadQueueItem {
  file: File
  rawText?: string
  detectedDialect?: 'mysql' | 'postgres' | 'unknown'
  isMysql?: boolean
  reasons?: string[]
  status: 'pending' | 'processing' | 'needs_transform' | 'transformed' | 'skipped' | 'ready'
}

export interface ReadySchema {
  title: string
  content: string
  language: SupportedLanguage
}

const isUploadModalOpen = ref(false)
const uploadQueue = ref<UploadQueueItem[]>([])
const currentQueueIndex = ref(0)
const uploadProgress = ref(0)
const statusMessage = ref('')
const stage = ref<UploadStage>('idle')
const detectedReasons = ref<string[]>([])
const transformedCount = ref(0)
const completedSchemas = ref<ReadySchema[]>([])

// Resolver promise callback for user prompt (Decline vs. Proceed)
let promptResolver: ((action: 'proceed' | 'decline') => void) | null = null

export function useSchemaUploader() {
  const { tabs, addNewTab, switchTab, isTabLimitModalOpen, canAddTabs } = useSchemaStore()

  const currentItem = computed<UploadQueueItem | null>(() => {
    return uploadQueue.value[currentQueueIndex.value] || null
  })

  const totalFilesCount = computed(() => uploadQueue.value.length)

  /**
   * Smoothly animates progress from current value to target value over a duration
   */
  async function animateProgress(target: number, durationMs = 350): Promise<void> {
    if (typeof window === 'undefined' || typeof requestAnimationFrame === 'undefined') {
      uploadProgress.value = target
      return
    }

    const start = uploadProgress.value
    const diff = target - start
    const startTime = performance.now()

    return new Promise(resolve => {
      function step(currentTime: number) {
        const elapsed = currentTime - startTime
        const progressRatio = Math.min(1, elapsed / durationMs)
        uploadProgress.value = Math.round(start + diff * progressRatio)

        if (progressRatio < 1) {
          requestAnimationFrame(step)
        } else {
          uploadProgress.value = target
          resolve()
        }
      }
      requestAnimationFrame(step)
    })
  }

  /**
   * Initializes the upload queue with selected files and begins processing
   */
  async function startUploadQueue(files: File[]) {
    if (!files || files.length === 0) return

    // Verify remaining tab space
    if (!canAddTabs(1)) {
      isTabLimitModalOpen.value = true
      return
    }

    uploadQueue.value = files.map(file => ({
      file,
      status: 'pending',
    }))

    currentQueueIndex.value = 0
    uploadProgress.value = 0
    transformedCount.value = 0
    completedSchemas.value = []
    detectedReasons.value = []
    isUploadModalOpen.value = true

    await processNextQueueItem()
  }

  /**
   * Sequential queue worker processing each uploaded file
   */
  async function processNextQueueItem() {
    if (currentQueueIndex.value >= uploadQueue.value.length) {
      // All files in queue have finished
      stage.value = 'completed'
      await animateProgress(100, 200)
      statusMessage.value = 'All files processed and ready for visualization!'
      return
    }

    const item = uploadQueue.value[currentQueueIndex.value]
    item.status = 'processing'
    stage.value = 'reading'

    // Stage 1: Uploading / Reading file
    statusMessage.value = 'Uploading file...'
    await animateProgress(25, 250)

    const text = await item.file.text()
    item.rawText = text

    statusMessage.value = 'Reading schema definitions...'
    await animateProgress(60, 200)

    // Check file extension: if it's an extension we currently support natively, open in that extension directly!
    const lowerName = item.file.name.toLowerCase()
    const isPrismaExt = lowerName.endsWith('.prisma')
    const isDbmlExt = lowerName.endsWith('.dbml')
    const isTsExt = lowerName.endsWith('.ts') || lowerName.endsWith('.js')
    const isPostgresExt = lowerName.endsWith('.pgsql') || lowerName.endsWith('.psql')

    if (isPrismaExt) {
      // 1. Prisma Schema: open directly in prisma mode
      stage.value = 'completed'
      statusMessage.value = 'Prisma schema ready'
      await animateProgress(100, 150)

      item.status = 'ready'
      completedSchemas.value.push({
        title: item.file.name,
        content: sanitizePrisma(text),
        language: 'prisma',
      })
    } else if (isDbmlExt) {
      // 2. DBML Schema: open directly in dbml mode
      stage.value = 'completed'
      statusMessage.value = 'DBML schema ready'
      await animateProgress(100, 150)

      item.status = 'ready'
      completedSchemas.value.push({
        title: item.file.name,
        content: sanitizeDbml(text),
        language: 'dbml',
      })
    } else if (isTsExt) {
      // 3. TypeScript Schema (Drizzle ORM / TypeORM): detect entity structure
      const tsLang: SupportedLanguage = /@Entity\b/.test(text) ? 'typeorm' : 'drizzle'
      stage.value = 'completed'
      statusMessage.value = tsLang === 'typeorm' ? 'TypeORM entities ready' : 'Drizzle schema ready'
      await animateProgress(100, 150)

      const sanitizedText = tsLang === 'typeorm' ? sanitizeTypeORM(text) : sanitizeDrizzle(text)
      item.status = 'ready'
      completedSchemas.value.push({
        title: item.file.name,
        content: sanitizedText,
        language: tsLang,
      })
    } else if (isPostgresExt) {
      // 4. Native PostgreSQL extension: sanitize data rows to prevent heap exhaustion
      const sanitized = sanitizeSqlDdl(text)
      stage.value = 'completed'
      statusMessage.value = 'PostgreSQL DDL ready'
      await animateProgress(100, 150)

      item.status = 'ready'
      completedSchemas.value.push({
        title: item.file.name,
        content: sanitized,
        language: 'sql',
      })
    } else {
      // 5. Extension is .sql, .ddl, .dump, or generic: run MySQL dialect detection!
      stage.value = 'analyzing'
      statusMessage.value = 'Checking dialect compatibility...'
      await animateProgress(85, 250)

      const detection = detectSqlDialect(text)
      item.detectedDialect = detection.dialect
      item.isMysql = detection.isMysql
      item.reasons = detection.reasons

      if (detection.isMysql) {
        // Pause queue on this specific file and prompt user for decision
        item.status = 'needs_transform'
        detectedReasons.value = detection.reasons
        stage.value = 'dialect_prompt'
        statusMessage.value = 'MySQL syntax found'

        const userChoice = await waitForUserDecision()

        if (userChoice === 'decline') {
          // User declined: Skip this file and advance queue
          item.status = 'skipped'
          currentQueueIndex.value++
          await processNextQueueItem()
          return
        }

        // User chose to proceed: Transform DDL and strip data/directives
        stage.value = 'transforming'
        statusMessage.value = 'Converting to PostgreSQL...'
        await animateProgress(95, 250)

        const transformed = transformMysqlToPostgres(text)
        item.status = 'transformed'
        transformedCount.value++

        completedSchemas.value.push({
          title: item.file.name,
          content: sanitizeSqlDdl(transformed.sql),
          language: 'sql',
        })
      } else {
        // Not MySQL: Check if content happens to be DBML/Prisma or clean SQL DDL
        const detectedLang = detectLanguageFromCode(text)
        // Sanitize comments and bulk data rows to protect parser memory
        let finalContent = text
        if (detectedLang === 'sql') {
          finalContent = sanitizeSqlDdl(text)
        } else if (detectedLang === 'dbml') {
          finalContent = sanitizeDbml(text)
        } else if (detectedLang === 'drizzle') {
          finalContent = sanitizeDrizzle(text)
        } else if (detectedLang === 'typeorm') {
          finalContent = sanitizeTypeORM(text)
        } else if (detectedLang === 'prisma') {
          finalContent = sanitizePrisma(text)
        }

        item.status = 'ready'
        completedSchemas.value.push({
          title: item.file.name,
          content: finalContent,
          language: detectedLang,
        })
      }
    }

    await animateProgress(100, 150)
    currentQueueIndex.value++
    await processNextQueueItem()
  }

  /**
   * Prompts the user to Proceed or Decline transformation for current file
   */
  function waitForUserDecision(): Promise<'proceed' | 'decline'> {
    return new Promise(resolve => {
      promptResolver = resolve
    })
  }

  function handleUserProceed() {
    if (promptResolver) {
      const resolver = promptResolver
      promptResolver = null
      resolver('proceed')
    }
  }

  function handleUserDecline() {
    if (promptResolver) {
      const resolver = promptResolver
      promptResolver = null
      resolver('decline')
    }
  }

  /**
   * Visualises the completed schemas in the editor tabs and closes modal
   */
  function handleVisualise() {
    if (completedSchemas.value.length === 0) {
      isUploadModalOpen.value = false
      return
    }

    let firstNewTabId: string | null = null
    for (const schema of completedSchemas.value) {
      const existingTab = tabs.value.find(t => t.title.toLowerCase() === schema.title.toLowerCase())
      if (existingTab) {
        if (!firstNewTabId) {
          firstNewTabId = existingTab.id
        }
      } else {
        const newTab = addNewTab(schema.title, schema.content, schema.language)
        if (newTab && !firstNewTabId) {
          firstNewTabId = newTab.id
        }
      }
    }

    if (firstNewTabId) {
      switchTab(firstNewTabId)
    }

    isUploadModalOpen.value = false
    stage.value = 'idle'
  }

  function handleCloseModal() {
    if (promptResolver) {
      promptResolver('decline')
      promptResolver = null
    }
    isUploadModalOpen.value = false
    stage.value = 'idle'
  }

  return {
    isUploadModalOpen,
    uploadQueue,
    currentItem,
    currentQueueIndex,
    totalFilesCount,
    uploadProgress,
    statusMessage,
    stage,
    detectedReasons,
    transformedCount,
    completedSchemas,
    startUploadQueue,
    handleUserProceed,
    handleUserDecline,
    handleVisualise,
    handleCloseModal,
  }
}
