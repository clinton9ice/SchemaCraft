export type ThemeId = 'dark' | 'monokai' | 'dracula' | 'nord' | 'light'

export interface ThemeDefinition {
  id: ThemeId
  name: string
  category: 'light' | 'dark'
  description: string
  bgPreview: string
  accentColor: string
  editorTheme: string
  monacoThemeData?: any
}

export const THEME_LIST: ThemeDefinition[] = [
  {
    id: 'dark',
    name: 'Midnight Slate',
    category: 'dark',
    description: 'Modern deep slate and indigo aesthetic (Default)',
    bgPreview: '#121620',
    accentColor: '#38bdf8',
    editorTheme: 'vs-dark',
  },
  {
    id: 'monokai',
    name: 'Monokai Classic',
    category: 'dark',
    description: 'Iconic dark charcoal with vibrant pink, yellow & green accents',
    bgPreview: '#272822',
    accentColor: '#f92672',
    editorTheme: 'monokai',
    monacoThemeData: {
      base: 'vs-dark',
      inherit: true,
      rules: [
        { token: '', background: '272822', foreground: 'F8F8F2' },
        { token: 'comment', foreground: '75715E', fontStyle: 'italic' },
        { token: 'keyword', foreground: 'F92672', fontStyle: 'bold' },
        { token: 'keyword.sql', foreground: 'F92672', fontStyle: 'bold' },
        { token: 'string', foreground: 'E6DB74' },
        { token: 'string.sql', foreground: 'E6DB74' },
        { token: 'number', foreground: 'AE81FF' },
        { token: 'type', foreground: '66D9EF', fontStyle: 'italic' },
        { token: 'type.sql', foreground: '66D9EF', fontStyle: 'italic' },
        { token: 'identifier', foreground: 'A6E22E' },
        { token: 'delimiter', foreground: 'F8F8F2' },
        { token: 'operator', foreground: 'F92672' },
      ],
      colors: {
        'editor.background': '#272822',
        'editor.foreground': '#F8F8F2',
        'editorCursor.foreground': '#F8F8F0',
        'editor.lineHighlightBackground': '#3E3D32',
        'editorLineNumber.foreground': '#90908A',
        'editorLineNumber.activeForeground': '#C2C2BF',
        'editor.selectionBackground': '#49483E',
      },
    },
  },
  {
    id: 'dracula',
    name: 'Dracula Dark',
    category: 'dark',
    description: 'Famous purple nocturnal aesthetic with cyan & pink syntax',
    bgPreview: '#282a36',
    accentColor: '#bd93f9',
    editorTheme: 'dracula',
    monacoThemeData: {
      base: 'vs-dark',
      inherit: true,
      rules: [
        { token: '', background: '282a36', foreground: 'f8f8f2' },
        { token: 'comment', foreground: '6272a4', fontStyle: 'italic' },
        { token: 'keyword', foreground: 'ff79c6', fontStyle: 'bold' },
        { token: 'string', foreground: 'f1fa8c' },
        { token: 'number', foreground: 'bd93f9' },
        { token: 'type', foreground: '8be9fd', fontStyle: 'italic' },
        { token: 'identifier', foreground: '50fa7b' },
      ],
      colors: {
        'editor.background': '#282a36',
        'editor.foreground': '#f8f8f2',
        'editorCursor.foreground': '#f8f8f0',
        'editor.lineHighlightBackground': '#44475a',
        'editorLineNumber.foreground': '#6272a4',
        'editor.selectionBackground': '#44475a',
      },
    },
  },
  {
    id: 'nord',
    name: 'Nordic Frost',
    category: 'dark',
    description: 'Arctic, north-bluish clean dark palette',
    bgPreview: '#2e3440',
    accentColor: '#88c0d0',
    editorTheme: 'nord',
    monacoThemeData: {
      base: 'vs-dark',
      inherit: true,
      rules: [
        { token: '', background: '2e3440', foreground: 'd8dee9' },
        { token: 'comment', foreground: '616e88', fontStyle: 'italic' },
        { token: 'keyword', foreground: '81a1c1', fontStyle: 'bold' },
        { token: 'string', foreground: 'a3be8c' },
        { token: 'number', foreground: 'b48ead' },
        { token: 'type', foreground: '8fbcbb', fontStyle: 'italic' },
        { token: 'identifier', foreground: '88c0d0' },
      ],
      colors: {
        'editor.background': '#2e3440',
        'editor.foreground': '#d8dee9',
        'editorCursor.foreground': '#d8dee9',
        'editor.lineHighlightBackground': '#3b4252',
        'editorLineNumber.foreground': '#4c566a',
        'editor.selectionBackground': '#434c5e',
      },
    },
  },
  {
    id: 'light',
    name: 'Clean Light',
    category: 'light',
    description: 'Crisp, high-contrast light theme for daytime focus',
    bgPreview: '#f8fafc',
    accentColor: '#2563eb',
    editorTheme: 'vs',
  },
]

const currentTheme = ref<ThemeId>('dark')
const showThemeModal = ref(false)

export function useThemeEngine() {
  const activeThemeDef = computed(() => {
    return THEME_LIST.find((t) => t.id === currentTheme.value) || THEME_LIST[0]
  })

  function setTheme(themeId: ThemeId) {
    const target = THEME_LIST.find((t) => t.id === themeId)
    if (!target) return

    currentTheme.value = themeId

    if (typeof window !== 'undefined') {
      document.documentElement.setAttribute('data-theme', themeId)
      try {
        localStorage.setItem('schemacraft-theme', themeId)
      } catch {}

      try {
        const colorMode = useColorMode()
        if (colorMode) {
          colorMode.preference = target.category
        }
      } catch {}
    }
  }

  function initTheme() {
    if (typeof window !== 'undefined') {
      try {
        const saved = localStorage.getItem('schemacraft-theme') as ThemeId | null
        if (saved && THEME_LIST.some((t) => t.id === saved)) {
          setTheme(saved)
        } else {
          setTheme('dark')
        }
      } catch {
        setTheme('dark')
      }
    }
  }

  return {
    currentTheme,
    showThemeModal,
    activeThemeDef,
    THEME_LIST,
    setTheme,
    initTheme,
  }
}
