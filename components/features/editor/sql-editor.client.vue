<script setup lang="ts">
import * as monaco from 'monaco-editor'
import { THEME_LIST } from '~/composables/use-theme-engine'
import { registerDbmlLanguage } from '~/utils/monaco-dbml'
import { registerPrismaLanguage } from '~/utils/monaco-prisma'
import { LANGUAGE_OPTIONS, type SupportedLanguage } from '~/composables/use-schema-store'

const {
  sqlCode,
  fileName,
  activeTabId,
  activeTab,
  activeLanguage,
  cursorPosition,
  detectedTablesCount,
  setSqlCode,
  setCursorPosition,
  setLanguage,
  convertCurrentSchema,
  convertSchemaToNewTab,
  parseSchemaOnServer,
} = useSchemaStore()

const { validationError, isValidating, validateSql, debouncedValidate, clearValidation } = usePostgresValidator()
const { saveSqlFile } = useFileSystem()
const { currentTheme, activeThemeDef } = useThemeEngine()

const editorContainer = ref<HTMLElement | null>(null)
const isLoading = ref(true)
const isLanguageDropdownOpen = ref(false)

let editorInstance: monaco.editor.IStandaloneCodeEditor | null = null
let resizeObserver: ResizeObserver | null = null

const currentLanguageDef = computed(() => {
  return LANGUAGE_OPTIONS.find((l) => l.id === activeLanguage.value) || LANGUAGE_OPTIONS[0]
})

// Setup Monaco Worker Environment fallback for browser Vite
if (typeof window !== 'undefined' && !(window as any).MonacoEnvironment) {
  ;(window as any).MonacoEnvironment = {
    getWorker() {
      const blob = new Blob([`self.onmessage = function () {};`], {
        type: 'application/javascript',
      })
      return new Worker(URL.createObjectURL(blob))
    },
  }
}

// Register custom themes, DBML and Prisma languages in Monaco editor
function registerMonacoAddons() {
  THEME_LIST.forEach((theme) => {
    if (theme.monacoThemeData) {
      monaco.editor.defineTheme(theme.id, theme.monacoThemeData)
    }
  })
  registerDbmlLanguage(monaco)
  registerPrismaLanguage(monaco)
}

function getMonacoLanguageId(lang: SupportedLanguage): string {
  if (lang === 'dbml') return 'dbml'
  if (lang === 'prisma') return 'prisma'
  return 'sql'
}

function updateMonacoLanguage() {
  if (!editorInstance) return
  const model = editorInstance.getModel()
  if (!model) return

  const targetLang = getMonacoLanguageId(activeLanguage.value)
  monaco.editor.setModelLanguage(model, targetLang)
  debouncedValidate(editorInstance.getValue(), monaco, model, 100, targetLang)
}

async function initMonaco() {
  await nextTick()
  if (!editorContainer.value) {
    await new Promise((resolve) => requestAnimationFrame(resolve))
    if (!editorContainer.value) {
      isLoading.value = false
      return
    }
  }

  try {
    if (editorInstance) {
      editorInstance.dispose()
      editorInstance = null
    }

    registerMonacoAddons()
    const monacoTheme = activeThemeDef.value.editorTheme || 'vs-dark'
    const initialMonacoLang = getMonacoLanguageId(activeLanguage.value)

    // Configure Monaco Editor Options
    editorInstance = monaco.editor.create(editorContainer.value, {
      value: sqlCode.value,
      language: initialMonacoLang,
      theme: monacoTheme,
      fontSize: 13,
      fontFamily: "'JetBrains Mono', 'Fira Code', Menlo, Monaco, Consolas, monospace",
      fontLigatures: true,
      lineHeight: 20,
      automaticLayout: true,
      tabSize: 4,
      insertSpaces: true,
      minimap: {
        enabled: false,
        maxColumn: 60,
        renderCharacters: false,
      },
      scrollBeyondLastLine: false,
      roundedSelection: true,
      renderLineHighlight: 'all',
      bracketPairColorization: {
        enabled: true,
      },
      cursorBlinking: 'smooth',
      cursorSmoothCaretAnimation: 'on',
      padding: {
        top: 12,
        bottom: 12,
      },
      glyphMargin: true,
      quickSuggestions: true,
      hover: {
        enabled: true,
        delay: 200,
      },
    })

    const model = editorInstance.getModel()
    if (model) {
      validateSql(sqlCode.value, monaco, model, activeLanguage.value)
    }

    // Track Cursor Position
    editorInstance.onDidChangeCursorPosition((e) => {
      setCursorPosition(e.position.lineNumber, e.position.column)
    })

    // Track Content Changes with Real-time 300ms Debounced Validation
    editorInstance.onDidChangeModelContent(() => {
      if (editorInstance) {
        const val = editorInstance.getValue()
        if (val !== sqlCode.value) {
          setSqlCode(val)
        }
        const currentModel = editorInstance.getModel()
        if (currentModel) {
          debouncedValidate(val, monaco, currentModel, 300, activeLanguage.value)
        }
      }
    })

    // Keyboard shortcut: Cmd+S / Ctrl+S (triggers File System save)
    editorInstance.addCommand(monaco.KeyMod.CtrlCmd | monaco.KeyCode.KeyS, () => {
      saveSqlFile(false)
    })

    // Watch for tab switching: switch editor value and language cleanly
    watch(
      () => activeTabId.value,
      () => {
        if (editorInstance) {
          const currentVal = editorInstance.getValue()
          const targetVal = sqlCode.value
          if (currentVal !== targetVal) {
            editorInstance.setValue(targetVal)
            const targetPos = activeTab.value?.cursorPosition || { line: 1, column: 1 }
            editorInstance.setPosition({ lineNumber: targetPos.line, column: targetPos.column })
          }
          updateMonacoLanguage()
          const currentModel = editorInstance.getModel()
          if (currentModel) {
            debouncedValidate(targetVal, monaco, currentModel, 100, activeLanguage.value)
          }
        }
      }
    )

    // Watch for external code changes (e.g. file open, preset select, convert)
    watch(sqlCode, (newVal) => {
      if (editorInstance && editorInstance.getValue() !== newVal) {
        const position = editorInstance.getPosition()
        editorInstance.setValue(newVal)
        if (position) {
          editorInstance.setPosition(position)
        }
        const currentModel = editorInstance.getModel()
        if (currentModel) {
          debouncedValidate(newVal, monaco, currentModel, 300, activeLanguage.value)
        }
      }
    })

    // Watch activeLanguage for Monaco syntax mode & validator
    watch(
      () => activeLanguage.value,
      (newLang) => {
        updateMonacoLanguage()
      }
    )

    // Watch theme engine for dynamic Monaco theme changes
    watch(
      () => currentTheme.value,
      () => {
        const targetTheme = activeThemeDef.value.editorTheme || 'vs-dark'
        monaco.editor.setTheme(targetTheme)
      }
    )

    // Layout on resize
    if (typeof ResizeObserver !== 'undefined') {
      resizeObserver = new ResizeObserver(() => {
        editorInstance?.layout()
      })
      resizeObserver.observe(editorContainer.value)
    }
  } catch (err) {
    console.error('Error mounting Monaco editor:', err)
  } finally {
    isLoading.value = false
  }
}

// Switch current tab view mode
function handleSwitchViewMode(targetLang: SupportedLanguage) {
  isLanguageDropdownOpen.value = false
  setLanguage(targetLang, false)
}

// The 'Convert-to-Tab' Workflow: Translates schema and opens in a NEW workspace tab
function handleConvertToNewTab(targetLang: SupportedLanguage) {
  isLanguageDropdownOpen.value = false
  convertSchemaToNewTab(targetLang)
}

function triggerNextConversion() {
  const rotation: Record<SupportedLanguage, SupportedLanguage> = {
    sql: 'dbml',
    dbml: 'prisma',
    prisma: 'sql',
  }
  const next = rotation[activeLanguage.value] || 'sql'
  handleConvertToNewTab(next)
}

// Click outside handler for dropdown
function handleClickOutside(e: MouseEvent) {
  const target = e.target as HTMLElement
  if (!target.closest('.language-selector-container')) {
    isLanguageDropdownOpen.value = false
  }
}

onMounted(() => {
  initMonaco()
  window.addEventListener('click', handleClickOutside)
})

onBeforeUnmount(() => {
  window.removeEventListener('click', handleClickOutside)
  if (resizeObserver) {
    resizeObserver.disconnect()
    resizeObserver = null
  }
  if (editorInstance) {
    editorInstance.dispose()
    editorInstance = null
  }
})
</script>

<template>
  <div class="w-full h-full flex flex-col relative bg-[var(--app-bg)] overflow-hidden">
    <!-- Tab Bar for Multi-Schema Management -->
    <features-editor-tabs />

    <!-- Breadcrumb Sub-Header & Diagnostic Status -->
    <div
      class="h-7 px-3 bg-[var(--header-bg)] border-b border-[var(--node-border)] flex items-center justify-between text-xs text-[var(--text-muted)] font-mono select-none shrink-0 transition-colors duration-150"
    >
      <div class="flex items-center gap-1.5 min-w-0">
        <span class="hidden sm:inline">workspace</span>
        <span class="text-neutral-600 hidden sm:inline">›</span>
        <span>schema</span>
        <span class="text-neutral-600">›</span>
        <span class="text-[var(--text-primary)] font-medium truncate">{{ fileName }}</span>
      </div>

      <!-- Diagnostic Status Indicator with real-time cross-language error feedback -->
      <div class="flex items-center gap-2 text-[10px] shrink-0">
        <span v-if="isValidating" class="text-blue-400 flex items-center gap-1">
          <svg class="w-2.5 h-2.5 animate-spin" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M21 12a9 9 0 1 1-6.219-8.56" />
          </svg>
          validating...
        </span>
        <span v-else-if="validationError" class="text-rose-400 font-sans flex items-center gap-1 truncate max-w-[240px]">
          <span class="w-1.5 h-1.5 rounded-full bg-rose-500 animate-ping shrink-0" />
          <span class="truncate font-mono">Ln {{ validationError.lineNumber }}, Col {{ validationError.column }}: {{ validationError.message }}</span>
        </span>
        <span v-else-if="activeLanguage === 'prisma'" class="text-emerald-400 font-sans flex items-center gap-1">
          <span class="w-1.5 h-1.5 rounded-full bg-emerald-500" />
          Valid Prisma Schema
        </span>
        <span v-else-if="activeLanguage === 'dbml'" class="text-emerald-400 font-sans flex items-center gap-1">
          <span class="w-1.5 h-1.5 rounded-full bg-emerald-500" />
          Valid DBML Schema
        </span>
        <span v-else class="text-emerald-400 font-sans flex items-center gap-1">
          <span class="w-1.5 h-1.5 rounded-full bg-emerald-500" />
          Valid SQL Schema
        </span>
      </div>
    </div>

    <!-- Monaco Container -->
    <div ref="editorContainer" class="flex-1 w-full h-full relative" />

    <!-- VS Code Style Status Bar (Bottom of Editor) with Language Selector & Convert-to-Tab -->
    <div
      class="h-6 px-3 bg-[var(--header-bg)] border-t border-[var(--node-border)] flex items-center justify-between text-[11px] text-[var(--text-muted)] font-mono select-none shrink-0 z-20 transition-colors duration-150"
    >
      <!-- Left: Line / Column Info & Table Count -->
      <div class="flex items-center gap-3">
        <span>Ln {{ cursorPosition.line }}, Col {{ cursorPosition.column }}</span>
        <span class="text-[var(--node-border)]">|</span>
        <span class="text-[var(--text-muted)]">{{ detectedTablesCount }} tables</span>
      </div>

      <!-- Right: Quick Convert & Professional Dropdown Selector -->
      <div class="flex items-center gap-2 relative language-selector-container">
        <!-- Quick Convert Button -->
        <button
          type="button"
          title="Convert current schema to next format in a new tab"
          class="hidden sm:flex items-center gap-1 px-2 py-0.5 rounded text-[10px] font-sans font-medium text-blue-400 hover:text-blue-300 hover:bg-blue-500/10 border border-blue-500/20 transition-colors cursor-pointer"
          @click="triggerNextConversion"
        >
          <span>⚡</span>
          <span>Convert to Tab</span>
        </button>

        <span class="text-[var(--node-border)] hidden sm:inline">|</span>

        <!-- Language Selector Dropdown Trigger -->
        <div class="relative">
          <button
            type="button"
            title="Switch Language or Convert to New Tab"
            class="flex items-center gap-1.5 px-2 py-0.5 rounded hover:bg-white/10 text-[var(--text-primary)] hover:text-white transition-colors cursor-pointer border border-transparent hover:border-[var(--node-border)]"
            @click.stop="isLanguageDropdownOpen = !isLanguageDropdownOpen"
          >
            <span>{{ currentLanguageDef.icon }}</span>
            <span class="font-medium font-sans">{{ currentLanguageDef.shortLabel }}</span>
            <svg class="w-3 h-3 text-[var(--text-muted)] transition-transform" :class="{ 'rotate-180': isLanguageDropdownOpen }" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polyline points="6 9 12 15 18 9" />
            </svg>
          </button>

          <!-- Language Selection Popover Menu -->
          <div
            v-if="isLanguageDropdownOpen"
            class="absolute bottom-full right-0 mb-1 w-72 p-2 rounded-xl bg-[var(--header-bg)]/95 backdrop-blur-xl border border-[var(--node-border)] shadow-2xl z-50 animate-in fade-in zoom-in-95 duration-100 divide-y divide-[var(--node-border)]"
            @click.stop
          >
            <!-- SECTION 1: Convert to New Tab (Recommended Workflow) -->
            <div class="pb-2">
              <div class="px-2 py-1 flex items-center justify-between text-[10px] uppercase font-bold tracking-wider text-blue-400">
                <span class="flex items-center gap-1">
                  <span>⚡</span>
                  <span>Convert to New Tab</span>
                </span>
                <span class="text-[9px] font-normal lowercase opacity-75">spawns new tab</span>
              </div>

              <div class="space-y-0.5 mt-1">
                <button
                  v-for="lang in LANGUAGE_OPTIONS"
                  :key="'convert-' + lang.id"
                  type="button"
                  class="w-full px-2.5 py-1.5 rounded-lg flex items-center justify-between text-left transition-colors cursor-pointer hover:bg-blue-600/15 group text-[var(--text-primary)]"
                  @click="handleConvertToNewTab(lang.id)"
                >
                  <div class="flex items-center gap-2">
                    <span class="text-sm">{{ lang.icon }}</span>
                    <div>
                      <div class="font-medium text-xs text-[var(--text-primary)] group-hover:text-blue-300 flex items-center gap-1.5">
                        Convert to {{ lang.shortLabel }}
                        <span class="text-[9px] font-mono text-neutral-400 group-hover:text-blue-400">({{ lang.ext }})</span>
                      </div>
                    </div>
                  </div>
                  <span class="text-[10px] text-blue-400 opacity-0 group-hover:opacity-100 font-sans font-medium">
                    + Tab ↗
                  </span>
                </button>
              </div>
            </div>

            <!-- SECTION 2: Switch View Mode on Current Tab -->
            <div class="pt-2">
              <div class="px-2 py-1 text-[10px] uppercase font-bold tracking-wider text-[var(--text-muted)]">
                Switch View Mode (Current Tab)
              </div>

              <div class="space-y-0.5 mt-1">
                <button
                  v-for="lang in LANGUAGE_OPTIONS"
                  :key="'switch-' + lang.id"
                  type="button"
                  class="w-full px-2.5 py-1.5 rounded-lg flex items-center justify-between text-left transition-colors cursor-pointer group"
                  :class="activeLanguage === lang.id ? 'bg-white/10 text-white font-medium' : 'hover:bg-white/5 text-[var(--text-muted)] hover:text-white'"
                  @click="handleSwitchViewMode(lang.id)"
                >
                  <div class="flex items-center gap-2">
                    <span class="text-sm opacity-80">{{ lang.icon }}</span>
                    <div>
                      <div class="text-xs">
                        {{ lang.label }}
                      </div>
                    </div>
                  </div>

                  <span v-if="activeLanguage === lang.id" class="w-1.5 h-1.5 rounded-full bg-blue-400" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading Fallback -->
    <div
      v-if="isLoading"
      class="absolute inset-0 bg-[var(--app-bg)] flex flex-col items-center justify-center gap-2 text-[var(--text-muted)] z-10"
    >
      <div class="w-6 h-6 border-2 border-blue-500 border-t-transparent rounded-full animate-spin" />
      <span class="text-xs font-mono">Initializing Monaco Editor & Language Engine...</span>
    </div>
  </div>
</template>
