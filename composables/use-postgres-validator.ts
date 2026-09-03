import type * as MonacoType from 'monaco-editor'
import { validateDbmlCode, sanitizeDbml } from '~/utils/dbml-compiler'
import { validatePrismaCode, sanitizePrisma } from '~/utils/prisma-compiler'
import { compileDrizzle } from '~/utils/drizzle-compiler'
import { compileTypeORM } from '~/utils/typeorm-compiler'
import { sanitizeDrizzle, sanitizeTypeORM } from '~/utils/ts-sanitizer'
import { transformMysqlToPostgres } from '~/utils/mysql-to-postgres-transformer'
import { detectSqlDialect } from '~/utils/sql-dialect-detector'
import { sanitizeSqlDdl } from '~/utils/sql-sanitizer'
import { MAX_DDL_BYTES } from '~/utils/constants'
import type { SupportedLanguage } from '~/composables/use-schema-store'

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
    langOverride?: SupportedLanguage | string
  ) {
    if (!code || !code.trim()) {
      validationError.value = null
      monacoInstance.editor.setModelMarkers(model, 'schema-validator', [])
      const { parseSchema } = useSchemaStore()
      await parseSchema(code, langOverride as SupportedLanguage)
      return
    }

    const { activeLanguage, parseSchema } = useSchemaStore()
    const currentLang = (langOverride || activeLanguage.value || 'sql').toLowerCase()

    // 1. Handle DBML Validation
    if (
      currentLang === 'dbml' ||
      /^\s*(?:Table\s+[\w"]+|Ref(?:\s+[\w_]+)?\s*:|Enum\s+[\w"]+|TableGroup\s+[\w"]+)/im.test(code)
    ) {
      const sanitized = sanitizeDbml(code)
      const res = validateDbmlCode(sanitized)
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
        await parseSchema(code, 'dbml')
      }
      return
    }

    // 2. Handle Prisma Schema Validation
    if (
      currentLang === 'prisma' ||
      /^\s*(?:model\s+[a-zA-Z0-9_]+\s*\{|datasource\s+\w+\s*\{|generator\s+\w+\s*\{)/im.test(code)
    ) {
      const sanitized = sanitizePrisma(code)
      const res = validatePrismaCode(sanitized)
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
        await parseSchema(code, 'prisma')
      }
      return
    }

    // 3. Handle Drizzle ORM Schema Validation
    if (
      currentLang === 'drizzle' ||
      /\b(?:pgTable|mysqlTable|sqliteTable)\s*\(|from\s+['"]drizzle-orm/im.test(code)
    ) {
      try {
        const sanitized = sanitizeDrizzle(code)
        compileDrizzle(sanitized)
        validationError.value = null
        monacoInstance.editor.setModelMarkers(model, 'schema-validator', [])
        await parseSchema(code, 'drizzle')
      } catch (err: unknown) {
        const msg = err instanceof Error ? err.message : 'Drizzle validation error'
        validationError.value = {
          message: msg,
          lineNumber: 1,
          column: 1,
          endLineNumber: 1,
          endColumn: 1,
        }
        monacoInstance.editor.setModelMarkers(model, 'schema-validator', [
          {
            severity: monacoInstance.MarkerSeverity.Error,
            message: `Drizzle Error: ${msg}`,
            startLineNumber: 1,
            startColumn: 1,
            endLineNumber: 1,
            endColumn: 1,
            source: 'Drizzle Validator',
          },
        ])
      }
      return
    }

    // 4. Handle TypeORM Entity Validation
    if (
      currentLang === 'typeorm' ||
      /\b(?:@Entity|@Column|@PrimaryGeneratedColumn)\s*\(|from\s+['"]typeorm/im.test(code)
    ) {
      try {
        const sanitized = sanitizeTypeORM(code)
        compileTypeORM(sanitized)
        validationError.value = null
        monacoInstance.editor.setModelMarkers(model, 'schema-validator', [])
        await parseSchema(code, 'typeorm')
      } catch (err: unknown) {
        const msg = err instanceof Error ? err.message : 'TypeORM validation error'
        validationError.value = {
          message: msg,
          lineNumber: 1,
          column: 1,
          endLineNumber: 1,
          endColumn: 1,
        }
        monacoInstance.editor.setModelMarkers(model, 'schema-validator', [
          {
            severity: monacoInstance.MarkerSeverity.Error,
            message: `TypeORM Error: ${msg}`,
            startLineNumber: 1,
            startColumn: 1,
            endLineNumber: 1,
            endColumn: 1,
            source: 'TypeORM Validator',
          },
        ])
      }
      return
    }

    // 5. Handle SQL / PostgreSQL / MySQL Validation
    isValidating.value = true

    const isMysql = currentLang === 'mysql' || detectSqlDialect(code).isMysql
    const codeToValidate = isMysql
      ? sanitizeSqlDdl(transformMysqlToPostgres(code).sql)
      : sanitizeSqlDdl(code)

    // Guard: if sanitized DDL still exceeds WASM safe limit, skip network call
    const byteSize = new TextEncoder().encode(codeToValidate).length
    if (byteSize > MAX_DDL_BYTES) {
      const warnMsg =
        `Schema is ${Math.round(byteSize / 1024)}KB after sanitizing — ` +
        `exceeds ${Math.round(MAX_DDL_BYTES / 1024)}KB parser limit. ` +
        `Try splitting into smaller files.`
      validationError.value = {
        message: warnMsg,
        lineNumber: 1,
        column: 1,
        endLineNumber: 1,
        endColumn: 1,
      }
      monacoInstance.editor.setModelMarkers(model, 'schema-validator', [
        {
          severity: monacoInstance.MarkerSeverity.Warning,
          message: `SQL Warning: ${warnMsg}`,
          startLineNumber: 1,
          startColumn: 1,
          endLineNumber: 1,
          endColumn: 1,
          source: 'SQL Parser',
        },
      ])
      isValidating.value = false
      return
    }

    try {
      // Delegate to parseSchema: single request that updates both diagram AST and validation markers
      const res = await parseSchema(
        isMysql ? transformMysqlToPostgres(code).sql : code,
        currentLang as SupportedLanguage
      )

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

        const errorMsg = formattedError.message.includes('offset is out of bounds')
          ? 'Query exceeds WebAssembly memory limit. Try removing large INSERT data rows and keep only DDL statements.'
          : formattedError.message

        // Apply Monaco markers (red squiggly line + hover tooltip)
        monacoInstance.editor.setModelMarkers(model, 'schema-validator', [
          {
            severity: monacoInstance.MarkerSeverity.Error,
            message: `SQL Error: ${errorMsg}`,
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

  /**
   * Cancels any pending debounce timer and clears all Monaco markers.
   * Use when unmounting the editor or programmatically resetting state.
   */
  function clearValidation(monacoInstance: typeof MonacoType, model: MonacoType.editor.ITextModel) {
    if (debounceTimer) {
      clearTimeout(debounceTimer)
      debounceTimer = null
    }
    validationError.value = null
    monacoInstance.editor.setModelMarkers(model, 'schema-validator', [])
  }

  /**
   * Immediately clears Monaco editor markers without waiting for the
   * async validator round-trip. Call this on tab switch so stale errors
   * from the previous tab don't bleed into the new tab's view.
   */
  function clearValidationMarkers(
    monacoInstance: typeof MonacoType,
    model: MonacoType.editor.ITextModel
  ) {
    validationError.value = null
    monacoInstance.editor.setModelMarkers(model, 'schema-validator', [])
  }

  return {
    validationError,
    isValidating,
    validateSql,
    debouncedValidate,
    clearValidation,
    clearValidationMarkers,
  }
}
