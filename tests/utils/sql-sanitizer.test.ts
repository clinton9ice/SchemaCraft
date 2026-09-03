import { describe, it, expect } from 'vitest'
import { sanitizeSqlDdl } from '../../utils/sql-sanitizer'

describe('sanitizeSqlDdl Utility', () => {
  it('strips single-line and multiline INSERT INTO statements', () => {
    const rawSql = `
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL
);

INSERT INTO users (id, username) VALUES (1, 'Alice');
INSERT INTO users (id, username) VALUES
(2, 'Bob'),
(3, 'Charlie');

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id)
);
`
    const sanitized = sanitizeSqlDdl(rawSql)
    expect(sanitized).not.toContain('INSERT INTO')
    expect(sanitized).not.toContain('Alice')
    expect(sanitized).not.toContain('Bob')
    expect(sanitized).toContain('CREATE TABLE users')
    expect(sanitized).toContain('CREATE TABLE orders')
  })

  it('strictly preserves ON DELETE SET NULL and table setup clauses intact', () => {
    const rawSql = `
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL
);
`
    const sanitized = sanitizeSqlDdl(rawSql)
    expect(sanitized).toContain('ON DELETE SET NULL')
    expect(sanitized).toContain('CREATE TABLE categories')
    expect(sanitized).toContain('CREATE TABLE posts')
  })
})
