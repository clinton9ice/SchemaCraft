import { MAX_FILE_SIZE_BYTES, MAX_UPLOAD_FILES, MAX_WORKSPACE_TABS } from '~/utils/constants'

export interface UploadValidationResult {
  valid: boolean
  files: File[]
  omittedCount: number
  reason?: 'batch_limit' | 'file_oversize' | 'tab_limit'
}

const isOversizeModalOpen = ref(false)
const oversizedFileName = ref('')
const oversizedFileSize = ref(0)
const isBatchLimitModalOpen = ref(false)
const attemptedBatchCount = ref(0)
const onReuploadAction = ref<(() => void) | null>(null)

export function useUploadGuard() {
  const { tabs, isTabLimitModalOpen } = useSchemaStore()

  /**
   * Formats a byte number into a clean human-readable string (e.g. "1.45 MB", "512 KB")
   */
  function formatFileSize(bytes: number): string {
    if (bytes >= 1024 * 1024) {
      return `${(bytes / (1024 * 1024)).toFixed(2)} MB`
    }
    if (bytes >= 1024) {
      return `${(bytes / 1024).toFixed(1)} KB`
    }
    return `${bytes} B`
  }

  /**
   * Validates a batch of files selected for upload.
   * Enforces:
   * 1. Max 3 files in a single batch.
   * 2. Max 1MB per file size limit.
   * 3. Workspace tab cap (up to 10 tabs total).
   */
  function validateUploadFiles(fileList: File[] | FileList): UploadValidationResult {
    const rawFiles = Array.from(fileList)

    // 1. Guard against batch count > MAX_UPLOAD_FILES (3)
    if (rawFiles.length > MAX_UPLOAD_FILES) {
      attemptedBatchCount.value = rawFiles.length
      isBatchLimitModalOpen.value = true
      return {
        valid: false,
        files: [],
        omittedCount: rawFiles.length,
        reason: 'batch_limit',
      }
    }

    // 2. Guard against file size > MAX_FILE_SIZE_BYTES (1MB)
    for (const file of rawFiles) {
      if (file.size > MAX_FILE_SIZE_BYTES) {
        oversizedFileName.value = file.name
        oversizedFileSize.value = file.size
        isOversizeModalOpen.value = true
        return {
          valid: false,
          files: [],
          omittedCount: 1,
          reason: 'file_oversize',
        }
      }
    }

    // 3. Tab ceiling check: allow up to remaining tab slots (capped at 10)
    const currentTabCount = tabs.value.length
    const remainingSlots = Math.max(0, MAX_WORKSPACE_TABS - currentTabCount)

    if (remainingSlots === 0) {
      isTabLimitModalOpen.value = true
      return {
        valid: false,
        files: [],
        omittedCount: rawFiles.length,
        reason: 'tab_limit',
      }
    }

    const acceptedFiles = rawFiles.slice(0, remainingSlots)
    const omittedCount = rawFiles.length - acceptedFiles.length

    if (omittedCount > 0) {
      isTabLimitModalOpen.value = true
    }

    return {
      valid: true,
      files: acceptedFiles,
      omittedCount,
    }
  }

  function setReuploadHandler(handler: () => void) {
    onReuploadAction.value = handler
  }

  function triggerReupload() {
    isOversizeModalOpen.value = false
    if (onReuploadAction.value) {
      onReuploadAction.value()
    }
  }

  return {
    isOversizeModalOpen,
    oversizedFileName,
    oversizedFileSize,
    isBatchLimitModalOpen,
    attemptedBatchCount,
    validateUploadFiles,
    formatFileSize,
    setReuploadHandler,
    triggerReupload,
  }
}
