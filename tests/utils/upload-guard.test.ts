import { describe, it, expect, beforeEach, vi } from 'vitest'
import { useUploadGuard } from '../../composables/use-upload-guard'
import { useSchemaStore } from '../../composables/use-schema-store'
import { MAX_FILE_SIZE_BYTES } from '../../utils/constants'

describe('Upload Guards Composable', () => {
  beforeEach(() => {
    vi.restoreAllMocks()
    const { isOversizeModalOpen, isBatchLimitModalOpen } = useUploadGuard()
    const { tabs, isTabLimitModalOpen } = useSchemaStore()

    isOversizeModalOpen.value = false
    isBatchLimitModalOpen.value = false
    isTabLimitModalOpen.value = false

    // Reset to 1 tab
    while (tabs.value.length > 1) {
      tabs.value.pop()
    }
  })

  it('rejects upload when more than 3 files are selected', () => {
    const { validateUploadFiles, isBatchLimitModalOpen, attemptedBatchCount } = useUploadGuard()

    const files = [
      new File(['test 1'], 'file1.sql', { type: 'text/plain' }),
      new File(['test 2'], 'file2.sql', { type: 'text/plain' }),
      new File(['test 3'], 'file3.sql', { type: 'text/plain' }),
      new File(['test 4'], 'file4.sql', { type: 'text/plain' }),
    ]

    const result = validateUploadFiles(files)

    expect(result.valid).toBe(false)
    expect(result.reason).toBe('batch_limit')
    expect(isBatchLimitModalOpen.value).toBe(true)
    expect(attemptedBatchCount.value).toBe(4)
  })

  it('rejects upload when any file exceeds the 1MB limit', () => {
    const { validateUploadFiles, isOversizeModalOpen, oversizedFileName, oversizedFileSize } =
      useUploadGuard()

    // 1MB + 10 bytes
    const largeContent = new Uint8Array(MAX_FILE_SIZE_BYTES + 10)
    const largeFile = new File([largeContent], 'heavy-dump.sql', { type: 'text/plain' })

    const result = validateUploadFiles([largeFile])

    expect(result.valid).toBe(false)
    expect(result.reason).toBe('file_oversize')
    expect(isOversizeModalOpen.value).toBe(true)
    expect(oversizedFileName.value).toBe('heavy-dump.sql')
    expect(oversizedFileSize.value).toBe(MAX_FILE_SIZE_BYTES + 10)
  })

  it('accepts files within the 3-file and 1MB size criteria', () => {
    const { validateUploadFiles, isOversizeModalOpen, isBatchLimitModalOpen } = useUploadGuard()

    const files = [
      new File(['CREATE TABLE a (id INT);'], 'a.sql', { type: 'text/plain' }),
      new File(['CREATE TABLE b (id INT);'], 'b.sql', { type: 'text/plain' }),
    ]

    const result = validateUploadFiles(files)

    expect(result.valid).toBe(true)
    expect(result.files.length).toBe(2)
    expect(isOversizeModalOpen.value).toBe(false)
    expect(isBatchLimitModalOpen.value).toBe(false)
  })

  it('correctly formats file sizes into human-readable strings', () => {
    const { formatFileSize } = useUploadGuard()

    expect(formatFileSize(500)).toBe('500 B')
    expect(formatFileSize(2048)).toBe('2.0 KB')
    expect(formatFileSize(1048576)).toBe('1.00 MB')
    expect(formatFileSize(2097152)).toBe('2.00 MB')
  })
})
