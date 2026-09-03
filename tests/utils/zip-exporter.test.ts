// @vitest-environment happy-dom
import { describe, it, expect, vi } from 'vitest'
import { unzipSync, strFromU8 } from 'fflate'
import { createZipArchive, downloadZipArchive, type ZipFileEntry } from '../../utils/zip-exporter'

describe('zip-exporter utility', () => {
  it('creates a valid ZIP archive containing provided files', () => {
    const files: ZipFileEntry[] = [
      { name: 'users.sql', content: 'CREATE TABLE users (id SERIAL PRIMARY KEY);' },
      { name: 'posts.sql', content: 'CREATE TABLE posts (id SERIAL PRIMARY KEY);' },
    ]

    const zipBytes = createZipArchive(files)

    expect(zipBytes).toBeInstanceOf(Uint8Array)
    expect(zipBytes.length).toBeGreaterThan(0)

    // Standard ZIP local file header signature: PK\x03\x04
    expect(zipBytes[0]).toBe(0x50) // 'P'
    expect(zipBytes[1]).toBe(0x4b) // 'K'
    expect(zipBytes[2]).toBe(0x03)
    expect(zipBytes[3]).toBe(0x04)

    // Verify roundtrip extraction using fflate unzipSync
    const unzipped = unzipSync(zipBytes)
    expect(Object.keys(unzipped)).toContain('users.sql')
    expect(Object.keys(unzipped)).toContain('posts.sql')

    expect(strFromU8(unzipped['users.sql'])).toBe('CREATE TABLE users (id SERIAL PRIMARY KEY);')
    expect(strFromU8(unzipped['posts.sql'])).toBe('CREATE TABLE posts (id SERIAL PRIMARY KEY);')
  })

  it('triggers browser DOM download element when downloadZipArchive is called', () => {
    const appendChildSpy = vi.spyOn(document.body, 'appendChild')
    const removeChildSpy = vi.spyOn(document.body, 'removeChild')

    // Mock URL object methods
    const originalCreateObjectURL = window.URL.createObjectURL
    const originalRevokeObjectURL = window.URL.revokeObjectURL
    window.URL.createObjectURL = vi.fn().mockReturnValue('blob:test-download-url')
    window.URL.revokeObjectURL = vi.fn()

    const files: ZipFileEntry[] = [{ name: 'schema.sql', content: 'CREATE TABLE dummy (id INT);' }]

    downloadZipArchive(files, 'test-collection.zip')

    expect(appendChildSpy).toHaveBeenCalled()
    expect(removeChildSpy).toHaveBeenCalled()
    expect(window.URL.createObjectURL).toHaveBeenCalled()

    // Restore mocks
    window.URL.createObjectURL = originalCreateObjectURL
    window.URL.revokeObjectURL = originalRevokeObjectURL
    appendChildSpy.mockRestore()
    removeChildSpy.mockRestore()
  })
})
