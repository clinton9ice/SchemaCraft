/**
 * SQL Dialect Detector for Postgres Visual Architect
 * Detects whether an uploaded SQL script uses MySQL/MariaDB specific syntax
 * that is incompatible with the PostgreSQL parser.
 */

export interface DialectDetectionResult {
  isMysql: boolean
  confidence: number
  dialect: 'mysql' | 'postgres' | 'unknown'
  reasons: string[]
}

export function detectSqlDialect(sql: string): DialectDetectionResult {
  if (!sql || !sql.trim()) {
    return {
      isMysql: false,
      confidence: 0,
      dialect: 'unknown',
      reasons: [],
    }
  }

  const reasons: string[] = []
  let mysqlScore = 0

  // 1. Backtick-quoted identifiers (e.g. `users`, `id`)
  const backtickMatches = sql.match(/`[a-zA-Z0-9_]+`/g)
  if (backtickMatches && backtickMatches.length > 0) {
    mysqlScore += Math.min(40, backtickMatches.length * 10)
    reasons.push(`Backtick-quoted identifiers (${backtickMatches.length} detected)`)
  }

  // 2. MySQL / MariaDB USE statement (e.g. USE vestnan1_db;)
  if (/\bUSE\s+[`"]?[a-zA-Z0-9_]+[`"]?\s*;/i.test(sql)) {
    mysqlScore += 30
    reasons.push('MySQL "USE <database>" statement')
  }

  // 3. Table storage engines and character set specifications
  if (/\bENGINE\s*=\s*[a-zA-Z0-9_]+/i.test(sql)) {
    mysqlScore += 35
    reasons.push('MySQL table options (ENGINE=InnoDB/MyISAM)')
  }
  if (/\b(?:DEFAULT\s+)?CHARSET\s*=\s*[a-zA-Z0-9_]+/i.test(sql)) {
    mysqlScore += 25
    reasons.push('MySQL CHARSET definition')
  }
  if (/\bCOLLATE\s*=\s*[a-zA-Z0-9_]+/i.test(sql)) {
    mysqlScore += 20
    reasons.push('MySQL COLLATE definition')
  }

  // 4. AUTO_INCREMENT keyword
  if (/\bAUTO_INCREMENT\b/i.test(sql)) {
    mysqlScore += 30
    reasons.push('MySQL AUTO_INCREMENT modifier')
  }

  // 5. MySQL-specific data types: int(11), longtext, mediumtext, tinyint, datetime
  if (/\bint\s*\(\s*\d+\s*\)/i.test(sql)) {
    mysqlScore += 25
    reasons.push('MySQL integer display width (e.g., int(11))')
  }
  if (/\b(?:longtext|mediumtext|tinytext)\b/i.test(sql)) {
    mysqlScore += 20
    reasons.push('MySQL-specific text types (LONGTEXT/MEDIUMTEXT)')
  }
  if (/\bdatetime\b/i.test(sql)) {
    mysqlScore += 15
    reasons.push('MySQL DATETIME type')
  }

  // 6. phpMyAdmin / MariaDB dump headers and conditional comments
  if (/\/\*!\d{5}\b/i.test(sql)) {
    mysqlScore += 30
    reasons.push('MySQL version-specific conditional comments (/*!40101 ... */)')
  }
  if (
    /\b(?:phpMyAdmin\s+SQL\s+Dump|Server\s+version:.*?MariaDB|Server\s+version:.*?MySQL)\b/i.test(
      sql
    )
  ) {
    mysqlScore += 40
    reasons.push('MySQL / MariaDB / phpMyAdmin dump header')
  }

  // 7. MySQL-specific DDL: MODIFY column
  if (/\bALTER\s+TABLE\s+[`"]?[a-zA-Z0-9_]+[`"]?\s+MODIFY\b/i.test(sql)) {
    mysqlScore += 25
    reasons.push('MySQL ALTER TABLE ... MODIFY syntax')
  }

  // 8. MySQL CLI commands: DESCRIBE table
  if (/\bDESCRIBE\s+[`"]?[a-zA-Z0-9_]+[`"]?\s*;/i.test(sql)) {
    mysqlScore += 20
    reasons.push('MySQL DESCRIBE command')
  }

  const confidence = Math.min(1, mysqlScore / 100)
  const isMysql = mysqlScore >= 30

  return {
    isMysql,
    confidence,
    dialect: isMysql ? 'mysql' : 'postgres',
    reasons,
  }
}
