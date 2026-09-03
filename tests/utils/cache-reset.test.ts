import { describe, it, expect } from 'vitest'
import type { H3Event } from 'h3'
import resetCacheHandler from '../../server/api/cache/reset'
import { clearSampleFilesCache } from '../../server/api/sample-files.get'

describe('Cache Reset Endpoint (/api/cache/reset)', () => {
  it('resets in-memory caches and returns success payload', async () => {
    const mockEvent = {} as unknown as H3Event
    const result = await resetCacheHandler(mockEvent)

    expect(result).toBeDefined()
    expect(result.success).toBe(true)
    expect(result.message).toContain('successfully reset')
    expect(Array.isArray(result.clearedDrivers)).toBe(true)
    expect(result.clearedDrivers).toContain('in-memory')
    expect(typeof result.timestamp).toBe('string')
  })

  it('exports clearSampleFilesCache and executes cleanly without throwing', () => {
    expect(() => clearSampleFilesCache()).not.toThrow()
  })
})
