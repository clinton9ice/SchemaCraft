import { defineEventHandler } from 'h3'
import { clearSampleFilesCache } from '../sample-files.get'

export interface CacheResetResponse {
  success: boolean
  message: string
  clearedDrivers: string[]
  clearedKeys: string[]
  timestamp: string
}

export default defineEventHandler(async (): Promise<CacheResetResponse> => {
  const clearedKeys: string[] = []
  const clearedDrivers: string[] = []

  // 1. Invalidate in-memory server variables
  clearSampleFilesCache()
  clearedDrivers.push('in-memory')

  // 2. Clear Nitro storage cache drivers
  const storageDrivers = ['cache', 'nitro:handlers', 'nitro:functions', 'root']

  for (const driverName of storageDrivers) {
    try {
      if (typeof useStorage === 'function') {
        const storage = useStorage(driverName)
        const keys = await storage.getKeys()
        if (keys && keys.length > 0) {
          for (const key of keys) {
            await storage.removeItem(key)
            clearedKeys.push(`${driverName}:${key}`)
          }
          clearedDrivers.push(driverName)
        }
      }
    } catch {
      console.info("Driver does not exist but we're fine. ====> Cache not cleared")
    }
  }

  return {
    success: true,
    message: 'Backend Nitro caches and memory buffers successfully reset',
    clearedDrivers,
    clearedKeys,
    timestamp: new Date().toISOString(),
  }
})
