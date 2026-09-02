import { ref } from 'vue'
import type { CompiledSchema, CompiledTable, CompiledRelation } from '~/utils/sql-compiler'

export const useSqlParser = () => {
  const schema = ref<CompiledSchema>({ tables: [], relations: [] })
  const error = ref<string | null>(null)
  const isParsing = ref(false)

  const parseSql = async (sql: string) => {
    isParsing.value = true
    error.value = null

    try {
      const res = await $fetch<{
        success: boolean
        tables: CompiledTable[]
        relations: CompiledRelation[]
        error?: { message?: string }
      }>('/api/schema/parse', {
        method: 'POST',
        body: { sql, language: 'sql' },
      })

      if (!res.success && res.error) {
        error.value = res.error.message || 'Error parsing SQL'
        return
      }

      schema.value = {
        tables: res.tables || [],
        relations: res.relations || [],
      }
    } catch (e: unknown) {
      const err = e as { message?: string }
      error.value = err.message || 'An unexpected error occurred while parsing SQL'
    } finally {
      isParsing.value = false
    }
  }

  return {
    schema,
    error,
    isParsing,
    parseSql,
  }
}
