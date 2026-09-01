import type * as monacoType from 'monaco-editor'

/**
 * Registers Prisma Schema language syntax highlighting in Monaco Editor
 */
export function registerPrismaLanguage(monaco: typeof monacoType) {
  if (monaco.languages.getLanguages().some((l) => l.id === 'prisma')) {
    return
  }

  monaco.languages.register({ id: 'prisma' })

  monaco.languages.setMonarchTokensProvider('prisma', {
    keywords: [
      'datasource',
      'generator',
      'model',
      'enum',
      'type',
      'view',
    ],

    typeKeywords: [
      'Int',
      'BigInt',
      'Float',
      'Decimal',
      'String',
      'Boolean',
      'DateTime',
      'Json',
      'Bytes',
      'Unsupported',
    ],

    attributeKeywords: [
      '@id',
      '@unique',
      '@default',
      '@relation',
      '@map',
      '@updatedAt',
      '@ignore',
      '@@id',
      '@@unique',
      '@@index',
      '@@map',
      '@@ignore',
      '@@schema',
    ],

    brackets: [
      { open: '{', close: '}', token: 'delimiter.curly' },
      { open: '[', close: ']', token: 'delimiter.bracket' },
      { open: '(', close: ')', token: 'delimiter.parenthesis' },
    ],

    tokenizer: {
      root: [
        // Comments
        [/\/\/\/.*$/, 'comment.doc'],
        [/\/\/.*$/, 'comment'],

        // Strings
        [/"([^"\\]|\\.)*"/, 'string'],
        [/'([^'\\]|\\.)*'/, 'string'],

        // Decorators / Attributes (@id, @@map, etc.)
        [/@@?[a-zA-Z_]\w*/, 'annotation'],

        // Function calls inside attributes (autoincrement(), now(), uuid(), env())
        [/\b(?:autoincrement|now|uuid|cuid|dbgenerated|env)\b/, 'keyword.flow'],

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
        [/[{}()\[\]]/, '@brackets'],
        [/[=?:,]/, 'delimiter'],
        [/\d+/, 'number'],
      ],
    },
  })

  monaco.languages.setLanguageConfiguration('prisma', {
    comments: {
      lineComment: '//',
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
      { open: '"', close: '"', notIn: ['string'] },
      { open: "'", close: "'", notIn: ['string', 'comment'] },
    ],
    surroundingPairs: [
      { open: '{', close: '}' },
      { open: '[', close: ']' },
      { open: '(', close: ')' },
      { open: '"', close: '"' },
      { open: "'", close: "'" },
    ],
  })
}
