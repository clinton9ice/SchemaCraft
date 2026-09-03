/**
 * Strips comments and empty lines from TypeScript code (Drizzle ORM & TypeORM).
 * Protects memory, improves AST parsing speed, and keeps schemas focused on structure.
 */

function stripLineComment(line: string): string {
  let inSingle = false
  let inDouble = false
  let inBacktick = false

  for (let i = 0; i < line.length; i++) {
    const ch = line[i]
    const prev = i > 0 ? line[i - 1] : ''

    if (ch === "'" && !inDouble && !inBacktick && prev !== '\\') {
      inSingle = !inSingle
    } else if (ch === '"' && !inSingle && !inBacktick && prev !== '\\') {
      inDouble = !inDouble
    } else if (ch === '`' && !inSingle && !inDouble && prev !== '\\') {
      inBacktick = !inBacktick
    } else if (!inSingle && !inDouble && !inBacktick) {
      if (ch === '/' && line[i + 1] === '/') {
        return line.slice(0, i)
      }
    }
  }

  return line
}

/**
 * Strips block comments, single-line comments, and blank lines from TypeScript schemas.
 */
export function sanitizeTypeScript(rawTs: string): string {
  if (!rawTs || !rawTs.trim()) return ''

  // 1. Strip multi-line block comments /* ... */
  const noBlock = rawTs.replace(/\/\*[\s\S]*?\*\//g, ' ')

  // 2. Strip single-line comments // (preserving string literals) and blank lines
  return noBlock
    .split('\n')
    .map(line => stripLineComment(line))
    .filter(line => line.trim().length > 0)
    .join('\n')
    .trim()
}

/**
 * Sanitizes Drizzle ORM schema code.
 */
export function sanitizeDrizzle(rawDrizzle: string): string {
  return sanitizeTypeScript(rawDrizzle)
}

/**
 * Sanitizes TypeORM entity schema code.
 */
export function sanitizeTypeORM(rawTypeOrm: string): string {
  return sanitizeTypeScript(rawTypeOrm)
}
