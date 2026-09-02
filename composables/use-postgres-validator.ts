import type * as MonacoType from 'monaco-editor'
import { validateDbmlCode } from '~/utils/dbml-compiler'
import { validatePrismaCode } from '~/utils/prisma-compiler'

export interface ValidationError {
  message: string
  cursorpos?: number
  lineNumber: number
  column: number
  endLineNumber: number
  endColumn: number
}

const validationError = ref<ValidationError | null>(null)
const isValidating = ref(false)

export function usePostgresValidator() {
  let debounceTimer: ReturnType<typeof setTimeout> | null = null

  async function validateSql(
    code: string,
    monacoInstance: typeof MonacoType,
    model: MonacoType.editor.ITextModel,
    langOverride?: string
  ) {
    if (!code || !code.trim()) {
      validationError.value = null
      monacoInstance.editor.setModelMarkers(model, 'schema-validator', [])
      return
    }

    const { activeLanguage } = useSchemaStore()
    const currentLang = (langOverride || activeLanguage.value || 'sql').toLowerCase()

    // 1. Handle DBML Validation
    if (currentLang === 'dbml') {
      const res = validateDbmlCode(code)
      if (!res.valid && res.error) {
        const formattedError: ValidationError = {
          message: res.error.message,
          lineNumber: res.error.lineNumber,
          column: res.error.column,
          endLineNumber: res.error.endLineNumber,
          endColumn: res.error.endColumn,
        }
        validationError.value = formattedError

        monacoInstance.editor.setModelMarkers(model, 'schema-validator', [
          {
            severity: monacoInstance.MarkerSeverity.Error,
            message: `DBML Error: ${formattedError.message}`,
            startLineNumber: formattedError.lineNumber,
            startColumn: formattedError.column,
            endLineNumber: formattedError.endLineNumber,
            endColumn: formattedError.endColumn,
            source: 'DBML Parser',
          },
        ])
      } else {
        validationError.value = null
        monacoInstance.editor.setModelMarkers(model, 'schema-validator', [])
      }
      return
    }

    // 2. Handle Prisma Schema Validation
    if (currentLang === 'prisma') {
      const res = validatePrismaCode(code)
      if (!res.valid && res.error) {
        const formattedError: ValidationError = {
          message: res.error.message,
          lineNumber: res.error.lineNumber,
          column: res.error.column,
          endLineNumber: res.error.endLineNumber,
          endColumn: res.error.endColumn,
        }
        validationError.value = formattedError

        monacoInstance.editor.setModelMarkers(model, 'schema-validator', [
          {
            severity: monacoInstance.MarkerSeverity.Error,
            message: `Prisma Error: ${formattedError.message}`,
            startLineNumber: formattedError.lineNumber,
            startColumn: formattedError.column,
            endLineNumber: formattedError.endLineNumber,
            endColumn: formattedError.endColumn,
            source: 'Prisma Validator',
          },
        ])
      } else {
        validationError.value = null
        monacoInstance.editor.setModelMarkers(model, 'schema-validator', [])
      }
      return
    }

    // 3. Handle SQL / PostgreSQL Validation
    // If in SQL mode but user pasted DBML/Prisma snippet, skip throwing raw SQL error
    if (/^\s*(?:Table\s+[\w"]+|Ref(?:\s+[\w_]+)?\s*:|model\s+[a-zA-Z0-9_]+\s*\{)/im.test(code)) {
      validationError.value = null
      monacoInstance.editor.setModelMarkers(model, 'schema-validator', [])
      return
    }

    isValidating.value = true

    try {
      // Validate and parse through Nitro backend parser
      const res = await $fetch<{
        success: boolean
        tables: CompiledTable[]
        relations: CompiledRelation[]
        error: { message?: string; cursorpos?: number } | null
      }>('/api/schema/parse', {
        method: 'POST',
        body: { sql: code, language: 'sql' },
      })

      if (res && !res.success && res.error) {
        const err = res.error
        const cursorpos = typeof err.cursorpos === 'number' ? err.cursorpos : 1

        // Convert 1-based character offset to line and column in Monaco model
        const offset = Math.max(0, cursorpos - 1)
        const pos = model.getPositionAt(offset)

        const word = model.getWordAtPosition(pos)
        let startColumn = pos.column
        let endColumn = pos.column + 1

        if (word) {
          startColumn = word.startColumn
          endColumn = word.endColumn
        } else {
          const lineMax = model.getLineMaxColumn(pos.lineNumber)
          endColumn = Math.min(pos.column + 6, lineMax)
          if (endColumn <= startColumn) {
            endColumn = startColumn + 1
          }
        }

        const formattedError: ValidationError = {
          message: err.message || 'SQL syntax error',
          cursorpos: err.cursorpos,
          lineNumber: pos.lineNumber,
          column: startColumn,
          endLineNumber: pos.lineNumber,
          endColumn: endColumn,
        }

        validationError.value = formattedError

        // Apply Monaco markers (red squiggly line + hover tooltip)
        monacoInstance.editor.setModelMarkers(model, 'schema-validator', [
          {
            severity: monacoInstance.MarkerSeverity.Error,
            message: `SQL Error: ${formattedError.message}`,
            startLineNumber: formattedError.lineNumber,
            startColumn: formattedError.column,
            endLineNumber: formattedError.endLineNumber,
            endColumn: formattedError.endColumn,
            source: 'SQL Parser',
          },
        ])
      } else if (res && res.success) {
        // Valid SQL: clear all markers
        validationError.value = null
        monacoInstance.editor.setModelMarkers(model, 'schema-validator', [])
      }
    } catch (err: unknown) {
      console.warn('SQL validator network exception:', err)
    } finally {
      isValidating.value = false
    }
  }

  function debouncedValidate(
    code: string,
    monacoInstance: typeof MonacoType,
    model: MonacoType.editor.ITextModel,
    delay = 300,
    langOverride?: string
  ) {
    if (debounceTimer) {
      clearTimeout(debounceTimer)
    }
    debounceTimer = setTimeout(() => {
      validateSql(code, monacoInstance, model, langOverride)
    }, delay)
  }

  function clearValidation(monacoInstance: typeof MonacoType, model: MonacoType.editor.ITextModel) {
    if (debounceTimer) {
      clearTimeout(debounceTimer)
      debounceTimer = null
    }
    validationError.value = null
    monacoInstance.editor.setModelMarkers(model, 'schema-validator', [])
  }

  return {
    validationError,
    isValidating,
    validateSql,
    debouncedValidate,
    clearValidation,
  }
}
