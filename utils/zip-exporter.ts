import { zipSync, strToU8 } from 'fflate'

export interface ZipFileEntry {
  name: string
  content: string
}

/**
 * Creates a standard compressed ZIP archive from an array of file entries using fflate.
 *
 * @param files - Array of file entries with file name and text content
 * @returns Uint8Array containing binary ZIP data
 */
export function createZipArchive(files: ZipFileEntry[]): Uint8Array {
  const archiveFiles: Record<string, Uint8Array> = {}

  for (const file of files) {
    archiveFiles[file.name] = strToU8(file.content)
  }

  return zipSync(archiveFiles)
}

/**
 * Triggers a browser download of the bundled files as a ZIP archive.
 *
 * @param files - Array of file entries to include in the archive
 * @param zipName - Suggested download name, defaults to 'collection.zip'
 */
export function downloadZipArchive(files: ZipFileEntry[], zipName = 'collection.zip'): void {
  if (typeof window === 'undefined') return

  const zipBytes = createZipArchive(files)
  const blob = new Blob([zipBytes.buffer as ArrayBuffer], { type: 'application/zip' })
  const downloadUrl = URL.createObjectURL(blob)

  const anchor = document.createElement('a')
  anchor.href = downloadUrl
  anchor.download = zipName
  document.body.appendChild(anchor)
  anchor.click()
  document.body.removeChild(anchor)

  setTimeout(() => {
    URL.revokeObjectURL(downloadUrl)
  }, 1000)
}
