declare module 'pg-query-emscripten' {
  export interface PgParsedResult {
    parse_tree?: Record<string, unknown>[]
    error?: {
      message: string
      cursorpos: number
    }
  }

  export interface PgQueryParser {
    parse: (query: string) => PgParsedResult
    default?: () => Promise<PgQueryParser>
  }

  const pgQuery: PgQueryParser | (() => Promise<PgQueryParser>)
  export default pgQuery
}
