import type * as monacoType from 'monaco-editor'

/**
 * Registers DBML (Database Markup Language) language syntax highlighting in Monaco Editor
 */
export function registerDbmlLanguage(monaco: typeof monacoType) {
  if (monaco.languages.getLanguages().some(l => l.id === 'dbml')) {
    return
  }

  monaco.languages.register({ id: 'dbml' })

  monaco.languages.setMonarchTokensProvider('dbml', {
    keywords: [
      'Table',
      'table',
      'TableGroup',
      'Enum',
      'enum',
      'Ref',
      'ref',
      'indexes',
      'Note',
      'note',
      'Project',
      'as',
    ],

    typeKeywords: [
      'int',
      'integer',
      'bigint',
      'smallint',
      'serial',
      'bigserial',
      'varchar',
      'char',
      'text',
      'boolean',
      'bool',
      'date',
      'datetime',
      'timestamp',
      'timestamptz',
      'time',
      'timetz',
      'decimal',
      'numeric',
      'float',
      'double',
      'real',
      'json',
      'jsonb',
      'uuid',
      'bytea',
      'blob',
    ],

    operators: ['>', '<', '-', ':'],

    brackets: [
      { open: '{', close: '}', token: 'delimiter.curly' },
      { open: '[', close: ']', token: 'delimiter.bracket' },
      { open: '(', close: ')', token: 'delimiter.parenthesis' },
    ],

    tokenizer: {
      root: [
        // Comments
        [/\/\/.*$/, 'comment'],
        [/\/\*/, 'comment', '@comment'],

        // Strings
        [/'([^'\\]|\\.)*'/, 'string'],
        [/"([^"\\]|\\.)*"/, 'string'],
        [/`([^`\\]|\\.)*`/, 'string'],

        // Settings keywords inside brackets
        [/pk|primary\s+key/i, 'keyword'],
        [/not\s+null|null/i, 'keyword'],
        [/unique/i, 'keyword'],
        [/increment|auto_increment/i, 'keyword'],
        [/default\s*:/i, 'type.identifier'],
        [/note\s*:/i, 'type.identifier'],
        [/ref\s*:/i, 'keyword.flow'],

        // Identifiers and keywords
        [
          /[a-zA-Z_]\w*/,
          {
            cases: {
              '@keywords': 'keyword',
              '@typeKeywords': 'type',
              '@default': 'identifier',
            },
          },
        ],

        // Delimiters & operators
        [/[{}[\]()]/, '@brackets'],
        [/[><:-]/, 'operator'],
        [/\d+/, 'number'],
      ],

      comment: [
        [/[^/*]+/, 'comment'],
        [/\/\*/, 'comment', '@push'],
        ['\\*/', 'comment', '@pop'],
        [/[/*]/, 'comment'],
      ],
    },
  })

  monaco.languages.setLanguageConfiguration('dbml', {
    comments: {
      lineComment: '//',
      blockComment: ['/*', '*/'],
    },
    brackets: [
      ['{', '}'],
      ['[', ']'],
      ['(', ')'],
    ],
    autoClosingPairs: [
      { open: '{', close: '}' },
      { open: '[', close: ']' },
      { open: '(', close: ')' },
      { open: "'", close: "'", notIn: ['string', 'comment'] },
      { open: '"', close: '"', notIn: ['string'] },
      { open: '`', close: '`', notIn: ['string'] },
    ],
    surroundingPairs: [
      { open: '{', close: '}' },
      { open: '[', close: ']' },
      { open: '(', close: ')' },
      { open: "'", close: "'" },
      { open: '"', close: '"' },
      { open: '`', close: '`' },
    ],
  })
}
