<script setup lang="ts">
import type { SampleFileInfo } from '~/composables/use-schema-store'

const {
  fileName,
  isDirty,
  isSaving,
  tabs,
  sampleFiles,
  fetchSampleFiles,
  loadSampleFile,
  exportSchema,
  exportAllTabsAsZip,
} = useSchemaStore()

const { openSqlFile, saveSqlFile, exportDiagramAsImage, isExportingImage, isSavingFile } =
  useFileSystem()

const { showThemeModal, activeThemeDef, initTheme } = useThemeEngine()

const showExportModal = ref(false)
const selectedExportFormat = ref<'typescript' | 'prisma' | 'dbml' | 'json'>('typescript')
const exportResult = ref('')
const isExporting = ref(false)
const isExportingZip = ref(false)
const copied = ref(false)
const showImageExportMenu = ref(false)
const showSettingsMenu = ref(false)
const showMobileDrawer = ref(false)
const isSampleDropdownOpen = ref(false)
const sampleDropdownRef = ref<HTMLElement | null>(null)

function onDocumentClick(e: MouseEvent) {
  if (sampleDropdownRef.value && !sampleDropdownRef.value.contains(e.target as Node)) {
    isSampleDropdownOpen.value = false
  }
}

async function handleExportZip() {
  showExportModal.value = false
  showMobileDrawer.value = false
  isExportingZip.value = true
  try {
    await exportAllTabsAsZip('collection.zip')
  } finally {
    isExportingZip.value = false
  }
}

onMounted(async () => {
  initTheme()
  await fetchSampleFiles()
  if (typeof document !== 'undefined') {
    document.addEventListener('click', onDocumentClick)
  }
})

onUnmounted(() => {
  if (typeof document !== 'undefined') {
    document.removeEventListener('click', onDocumentClick)
  }
})

async function handleOpenExport() {
  showExportModal.value = true
  showMobileDrawer.value = false
  await runExport()
}

async function runExport() {
  isExporting.value = true
  const res = await exportSchema(selectedExportFormat.value)
  if (res && res.content) {
    exportResult.value = res.content
  }
  isExporting.value = false
}

function handleFormatChange(fmt: 'typescript' | 'prisma' | 'dbml' | 'json') {
  selectedExportFormat.value = fmt
  runExport()
}

function copyExportResult() {
  navigator.clipboard.writeText(exportResult.value)
  copied.value = true
  setTimeout(() => {
    copied.value = false
  }, 1500)
}

async function handleExportImage(format: 'png' | 'svg' | 'jpeg') {
  showImageExportMenu.value = false
  showMobileDrawer.value = false
  await exportDiagramAsImage(format)
}

function openThemeModal() {
  showSettingsMenu.value = false
  showMobileDrawer.value = false
  showThemeModal.value = true
}

function handleMobileOpenSql() {
  showMobileDrawer.value = false
  openSqlFile()
}

function isTabOpen(targetFileName: string): boolean {
  const base = targetFileName.replace(/\.[^/.]+$/, '')
  return tabs.value.some(
    t =>
      t.title.toLowerCase() === targetFileName.toLowerCase() ||
      t.title.toLowerCase() === base.toLowerCase()
  )
}

function getExtensionBadgeClass(ext: string): string {
  const lower = ext.toLowerCase()
  if (lower === 'sql') return 'text-blue-400 bg-blue-500/15 border-blue-500/30'
  if (lower === 'dbml') return 'text-amber-400 bg-amber-500/15 border-amber-500/30'
  if (lower === 'ts' || lower === 'js') return 'text-cyan-400 bg-cyan-500/15 border-cyan-500/30'
  if (lower === 'prisma') return 'text-emerald-400 bg-emerald-500/15 border-emerald-500/30'
  return 'text-neutral-400 bg-neutral-800 border-neutral-700'
}

function handleSelectSample(file: SampleFileInfo) {
  loadSampleFile(file)
  isSampleDropdownOpen.value = false
  showMobileDrawer.value = false
}
</script>

<template>
  <header
    class="h-12 border-b border-[var(--node-border)] bg-[var(--header-bg)] text-[var(--text-primary)] px-3 sm:px-4 flex items-center justify-between shrink-0 select-none z-30 relative transition-colors duration-150"
  >
    <div class="flex items-center gap-2.5 sm:gap-3 min-w-0">
      <div class="flex items-center gap-2 sm:gap-2.5 shrink-0">
        <div
          class="w-7 h-7 rounded-lg bg-gradient-to-tr from-blue-600 to-indigo-500 flex items-center justify-center shadow-md shadow-blue-500/20 text-white font-bold text-sm"
        >
          <svg
            class="w-4 h-4"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
          >
            <ellipse cx="12" cy="5" rx="9" ry="3" />
            <path d="M3 5V19A9 3 0 0 0 21 19V5" />
            <path d="M3 12A9 3 0 0 0 21 12" />
          </svg>
        </div>
        <div class="flex flex-col">
          <span class="font-bold text-xs tracking-tight text-white flex items-center gap-1.5">
            SchemaCraft
            <span
              class="text-[9px] font-semibold uppercase px-1 py-0.2 bg-blue-500/20 text-blue-400 border border-blue-500/30 rounded hidden min-[400px]:inline"
            >
              Nitro
            </span>
          </span>
          <span class="text-[10px] text-[var(--text-muted)] font-mono hidden min-[400px]:block"
            >DB Visual Editor</span
          >
        </div>
      </div>

      <div class="h-4 w-px bg-neutral-700/60 mx-1 hidden md:block" />

      <div
        class="hidden md:flex items-center gap-1.5 text-xs text-[var(--text-muted)] font-mono truncate"
      >
        <span class="hover:text-neutral-200 cursor-pointer">database</span>
        <span class="text-neutral-600">/</span>
        <span class="flex items-center gap-1.5 text-[var(--text-primary)] font-medium truncate">
          <span
            class="w-2 h-2 rounded-full shrink-0"
            :class="isDirty ? 'bg-amber-400' : 'bg-emerald-400'"
          />
          {{ fileName }}
        </span>
      </div>
    </div>

    <div ref="sampleDropdownRef" class="relative hidden sm:block">
      <button
        type="button"
        class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-[var(--tab-bar-bg)] hover:bg-white/10 text-xs font-medium text-[var(--text-primary)] border border-[var(--node-border)] transition-colors cursor-pointer"
        :title="`Open sample database schema (${sampleFiles.length} available)`"
        @click.stop="isSampleDropdownOpen = !isSampleDropdownOpen"
      >
        <tools-icon dir="editor" icon="database" width="13" height="13" svg-class="text-blue-400" />
        <span class="font-medium font-mono text-xs">sample-file</span>
        <svg
          class="w-3.5 h-3.5 text-[var(--text-muted)] transition-transform duration-200"
          :class="{ 'rotate-180': isSampleDropdownOpen }"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
        >
          <polyline points="6 9 12 15 18 9" />
        </svg>
      </button>

      <div
        v-if="isSampleDropdownOpen"
        class="absolute top-full mt-1.5 left-1/2 -translate-x-1/2 w-80 p-1.5 rounded-xl bg-[var(--header-bg)]/95 backdrop-blur-xl border border-[var(--node-border)] shadow-2xl z-50 animate-in fade-in zoom-in-95 duration-150"
      >
        <div
          class="px-2.5 py-1.5 border-b border-[var(--node-border)] mb-1 flex items-center justify-between"
        >
          <span
            class="text-[10px] font-mono uppercase tracking-wider text-[var(--text-muted)] font-semibold"
          >
            Sample DB Files
          </span>
          <span class="text-[10px] font-mono text-[var(--text-muted)]">
            {{ sampleFiles.length }} available
          </span>
        </div>
        <div class="space-y-0.5 max-h-72 overflow-y-auto">
          <button
            v-for="file in sampleFiles"
            :key="file.fileName"
            type="button"
            class="w-full px-2.5 py-2 rounded-lg flex items-center justify-between text-left transition-colors cursor-pointer hover:bg-white/10 group text-[var(--text-primary)]"
            @click="handleSelectSample(file)"
          >
            <span
              class="text-xs font-mono truncate text-[var(--text-primary)] group-hover:text-white"
            >
              {{ file.baseName }}
              <sup
                class="ml-1 px-1 py-0.2 rounded text-[9px] font-mono font-semibold border"
                :class="getExtensionBadgeClass(file.ext)"
              >
                .{{ file.ext }}
              </sup>
            </span>
            <span
              v-if="isTabOpen(file.fileName)"
              class="text-[10px] font-medium text-emerald-400 shrink-0 ml-2 bg-emerald-500/10 px-1.5 py-0.5 rounded border border-emerald-500/20"
            >
              open
            </span>
            <span
              v-else
              class="text-[10px] text-blue-400 opacity-0 group-hover:opacity-100 font-medium shrink-0 ml-2"
            >
              open ↗
            </span>
          </button>
        </div>
      </div>
    </div>

    <div class="flex items-center gap-1.5 sm:gap-2">
      <div class="hidden min-[520px]:flex items-center gap-2">
        <button
          type="button"
          class="inline-flex items-center gap-1.5 px-2.5 py-1.5 bg-white/5 hover:bg-white/10 text-[var(--text-primary)] text-xs font-medium rounded-md border border-[var(--node-border)] transition-colors cursor-pointer"
          title="Open .sql file from computer (File System Access API)"
          @click="openSqlFile"
        >
          <svg
            class="w-3.5 h-3.5 text-neutral-400"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
          >
            <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z" />
          </svg>
          <span class="hidden sm:inline">Open</span>
        </button>

        <div class="relative">
          <button
            type="button"
            class="inline-flex items-center gap-1.5 px-2.5 py-1.5 bg-white/5 hover:bg-white/10 text-[var(--text-primary)] text-xs font-medium rounded-md border border-[var(--node-border)] transition-colors cursor-pointer"
            title="Export diagram as image (PNG / SVG)"
            @click="showImageExportMenu = !showImageExportMenu"
          >
            <svg
              v-if="!isExportingImage"
              class="w-3.5 h-3.5 text-blue-400"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
            >
              <rect x="3" y="3" width="18" height="18" rx="2" />
              <circle cx="8.5" cy="8.5" r="1.5" />
              <polyline points="21 15 16 10 5 21" />
            </svg>
            <svg
              v-else
              class="w-3.5 h-3.5 animate-spin text-blue-400"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
            >
              <path d="M21 12a9 9 0 1 1-6.219-8.56" />
            </svg>
            <span class="hidden sm:inline">Image</span>
            <svg
              class="w-3 h-3 text-neutral-400"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
            >
              <path d="m6 9 6 6 6-6" />
            </svg>
          </button>

          <div
            v-if="showImageExportMenu"
            class="absolute right-0 mt-1 w-44 bg-[var(--header-bg)] border border-[var(--node-border)] rounded-lg shadow-2xl py-1 z-50 text-xs font-sans"
          >
            <button
              type="button"
              class="w-full px-3 py-2 text-left text-[var(--text-primary)] hover:bg-blue-600/20 hover:text-blue-300 flex items-center justify-between"
              @click="handleExportImage('png')"
            >
              <span>Export as PNG</span>
              <span class="text-[10px] font-mono text-[var(--text-muted)]">High-Res</span>
            </button>
            <button
              type="button"
              class="w-full px-3 py-2 text-left text-[var(--text-primary)] hover:bg-blue-600/20 hover:text-blue-300 flex items-center justify-between border-t border-[var(--node-border)]"
              @click="handleExportImage('svg')"
            >
              <span>Export as SVG</span>
              <span class="text-[10px] font-mono text-[var(--text-muted)]">Vector</span>
            </button>
            <button
              type="button"
              class="w-full px-3 py-2 text-left text-[var(--text-primary)] hover:bg-blue-600/20 hover:text-blue-300 flex items-center justify-between border-t border-[var(--node-border)]"
              @click="handleExportImage('jpeg')"
            >
              <span>Export as JPEG</span>
              <span class="text-[10px] font-mono text-[var(--text-muted)]">Compressed</span>
            </button>
          </div>
        </div>

        <button
          type="button"
          class="inline-flex items-center gap-1.5 px-2.5 py-1.5 bg-white/5 hover:bg-white/10 text-[var(--text-primary)] text-xs font-medium rounded-md border border-[var(--node-border)] transition-colors cursor-pointer"
          title="Export schema via Nitro (TypeScript, Prisma, DBML, JSON)"
          @click="handleOpenExport"
        >
          <svg
            class="w-3.5 h-3.5 text-indigo-400"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
          >
            <polyline points="16 18 22 12 16 6" />
            <polyline points="8 6 2 12 8 18" />
          </svg>
          <span class="hidden sm:inline">Code</span>
        </button>

        <button
          type="button"
          :disabled="isExportingZip"
          class="inline-flex items-center gap-1.5 px-2.5 py-1.5 bg-white/5 hover:bg-white/10 text-[var(--text-primary)] text-xs font-medium rounded-md border border-[var(--node-border)] transition-colors cursor-pointer disabled:opacity-50"
          title="Save and download all tabs as collection.zip"
          @click="handleExportZip"
        >
          <tools-icon
            dir="editor"
            :icon="isExportingZip ? 'loading' : 'download'"
            width="14"
            height="14"
            :svg-class="isExportingZip ? 'text-amber-400 animate-spin' : 'text-amber-400'"
          />
          <span class="hidden sm:inline">Collection.zip</span>
        </button>

        <div class="relative">
          <button
            type="button"
            class="p-1.5 text-[var(--text-muted)] hover:text-white hover:bg-white/10 rounded-md transition-colors cursor-pointer"
            title="Settings & Documentation"
            @click="showSettingsMenu = !showSettingsMenu"
          >
            <svg
              class="w-4 h-4"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
            >
              <circle cx="12" cy="12" r="3" />
              <path
                d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"
              />
            </svg>
          </button>

          <div
            v-if="showSettingsMenu"
            class="absolute right-0 mt-1 w-48 bg-[var(--header-bg)] border border-[var(--node-border)] rounded-xl shadow-2xl py-1.5 z-50 text-xs font-sans divide-y divide-[var(--node-border)]"
          >
            <div class="py-1">
              <a
                href="/docs"
                target="_blank"
                rel="noopener noreferrer"
                class="w-full px-3.5 py-2 text-left text-[var(--text-primary)] hover:bg-blue-600/20 hover:text-blue-300 flex items-center justify-between group transition-colors"
                @click="showSettingsMenu = false"
              >
                <div class="flex items-center gap-2">
                  <svg
                    class="w-4 h-4 text-blue-400"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="2"
                  >
                    <path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1-2.5-2.5Z" />
                    <path d="M6 6h10" />
                    <path d="M6 10h10" />
                  </svg>
                  <span>Documentation</span>
                </div>
                <svg
                  class="w-3 h-3 text-[var(--text-muted)] group-hover:text-blue-300"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2"
                >
                  <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6" />
                  <polyline points="15 3 21 3 21 9" />
                  <line x1="10" y1="14" x2="21" y2="3" />
                </svg>
              </a>

              <button
                type="button"
                class="w-full px-3.5 py-2 text-left text-[var(--text-primary)] hover:bg-blue-600/20 hover:text-blue-300 flex items-center justify-between transition-colors cursor-pointer"
                @click="openThemeModal"
              >
                <div class="flex items-center gap-2">
                  <svg
                    class="w-4 h-4 text-pink-400"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="2"
                  >
                    <circle cx="12" cy="12" r="4" />
                    <path d="M12 2v2" />
                    <path d="M12 20v2" />
                    <path d="m4.93 4.93 1.41 1.41" />
                    <path d="m17.66 17.66 1.41 1.41" />
                    <path d="M2 12h2" />
                    <path d="M20 12h2" />
                    <path d="m6.34 17.66-1.41 1.41" />
                    <path d="m19.07 4.93-1.41 1.41" />
                  </svg>
                  <span>Theme Settings</span>
                </div>
                <span
                  class="text-[9px] font-mono font-bold px-1.5 py-0.2 rounded bg-white/10 text-[var(--text-muted)]"
                >
                  {{ activeThemeDef?.name?.split(' ')[0] || 'Dark' }}
                </span>
              </button>
            </div>
          </div>
        </div>
      </div>

      <button
        type="button"
        :disabled="isSaving || isSavingFile"
        class="inline-flex items-center gap-1.5 sm:gap-2 px-3 sm:px-3.5 py-1.5 bg-blue-600 hover:bg-blue-500 active:bg-blue-700 text-white text-xs font-semibold rounded-md shadow-sm transition-all duration-150 cursor-pointer focus:outline-none focus:ring-2 focus:ring-blue-500/40 disabled:opacity-50"
        title="Save Schema to disk (Cmd+S / Ctrl+S)"
        @click="saveSqlFile(false)"
      >
        <svg
          v-if="!isSaving && !isSavingFile"
          class="w-3.5 h-3.5"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
        >
          <path
            d="M15.2 3a2 2 0 0 1 1.4.6l3.8 3.8a2 2 0 0 1 .6 1.4V19a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2z"
          />
          <path d="M17 21v-7a1 1 0 0 0-1-1H8a1 1 0 0 0-1 1v7" />
          <path d="M7 3v4a1 1 0 0 0 1 1h7" />
        </svg>
        <svg
          v-else
          class="w-3.5 h-3.5 animate-spin"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
        >
          <path d="M21 12a9 9 0 1 1-6.219-8.56" />
        </svg>
        <span>{{ isSaving || isSavingFile ? 'Saving...' : 'Save' }}</span>
        <ui-keyboard-shortcut class="hidden sm:inline-flex">⌘S</ui-keyboard-shortcut>
      </button>

      <button
        type="button"
        class="flex min-[520px]:hidden p-1.5 text-[var(--text-muted)] hover:text-white hover:bg-white/10 rounded-md transition-colors cursor-pointer border border-[var(--node-border)]"
        title="Open menu"
        @click="showMobileDrawer = true"
      >
        <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="3" y1="12" x2="21" y2="12" />
          <line x1="3" y1="6" x2="21" y2="6" />
          <line x1="3" y1="18" x2="21" y2="18" />
        </svg>
      </button>
    </div>

    <teleport to="body">
      <div v-if="showMobileDrawer" class="fixed inset-0 z-50 flex select-none md:hidden">
        <div
          class="fixed inset-0 bg-black/60 backdrop-blur-xs transition-opacity"
          @click="showMobileDrawer = false"
        />

        <div
          class="relative ml-auto w-4/5 max-w-xs bg-[var(--header-bg)] border-l border-[var(--node-border)] h-full flex flex-col z-10 shadow-2xl animate-in slide-in-from-right duration-200"
        >
          <div
            class="h-14 border-b border-[var(--node-border)] px-4 flex items-center justify-between"
          >
            <div class="flex items-center gap-2">
              <div
                class="w-6 h-6 rounded bg-gradient-to-tr from-blue-600 to-indigo-500 flex items-center justify-center text-white font-bold text-xs"
              >
                SC
              </div>
              <span class="font-bold text-sm text-[var(--text-primary)]">SchemaCraft Menu</span>
            </div>
            <button
              type="button"
              class="w-7 h-7 flex items-center justify-center rounded-lg hover:bg-white/10 text-[var(--text-muted)] hover:text-white"
              @click="showMobileDrawer = false"
            >
              ✕
            </button>
          </div>

          <div class="flex-1 overflow-y-auto p-4 space-y-5 text-xs">
            <div class="space-y-1.5">
              <span
                class="text-[10px] font-semibold font-mono uppercase tracking-wider text-[var(--text-muted)] block px-1"
              >
                Schema Operations
              </span>
              <button
                type="button"
                class="w-full px-3 py-2.5 rounded-lg bg-white/5 hover:bg-white/10 text-left flex items-center gap-2.5 text-[var(--text-primary)] font-medium cursor-pointer"
                @click="handleMobileOpenSql"
              >
                <svg
                  class="w-4 h-4 text-blue-400"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2"
                >
                  <path
                    d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"
                  />
                </svg>
                <span>Open Schema File</span>
              </button>
            </div>

            <div class="space-y-1.5">
              <span
                class="text-[10px] font-semibold font-mono uppercase tracking-wider text-[var(--text-muted)] block px-1"
              >
                Export Options
              </span>
              <div class="grid grid-cols-2 gap-1.5">
                <button
                  type="button"
                  class="p-2 rounded-lg bg-white/5 hover:bg-blue-600/20 text-left flex flex-col gap-0.5 border border-[var(--node-border)]"
                  @click="handleExportImage('png')"
                >
                  <span class="font-semibold text-[11px] text-blue-400">PNG Image</span>
                  <span class="text-[9px] text-[var(--text-muted)]">High-Res</span>
                </button>
                <button
                  type="button"
                  class="p-2 rounded-lg bg-white/5 hover:bg-blue-600/20 text-left flex flex-col gap-0.5 border border-[var(--node-border)]"
                  @click="handleExportImage('svg')"
                >
                  <span class="font-semibold text-[11px] text-blue-400">SVG Vector</span>
                  <span class="text-[9px] text-[var(--text-muted)]">Vector format</span>
                </button>
              </div>
              <button
                type="button"
                class="w-full px-3 py-2.5 rounded-lg bg-white/5 hover:bg-white/10 text-left flex items-center justify-between text-[var(--text-primary)] font-medium mt-1"
                @click="handleOpenExport"
              >
                <div class="flex items-center gap-2.5">
                  <svg
                    class="w-4 h-4 text-indigo-400"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="2"
                  >
                    <polyline points="16 18 22 12 16 6" />
                    <polyline points="8 6 2 12 8 18" />
                  </svg>
                  <span>Export Code (Nitro)</span>
                </div>
                <span class="text-[9px] font-mono text-[var(--text-muted)]">TS/Prisma</span>
              </button>

              <button
                type="button"
                :disabled="isExportingZip"
                class="w-full px-3 py-2.5 rounded-lg bg-white/5 hover:bg-white/10 text-left flex items-center justify-between text-[var(--text-primary)] font-medium mt-1.5 cursor-pointer disabled:opacity-50"
                @click="handleExportZip"
              >
                <div class="flex items-center gap-2.5">
                  <tools-icon
                    dir="editor"
                    :icon="isExportingZip ? 'loading' : 'download'"
                    width="16"
                    height="16"
                    :svg-class="isExportingZip ? 'text-amber-400 animate-spin' : 'text-amber-400'"
                  />
                  <span>Download Collection (.zip)</span>
                </div>
                <span class="text-[9px] font-mono text-amber-300">All Tabs</span>
              </button>
            </div>

            <div class="space-y-1.5">
              <div class="flex items-center justify-between px-1">
                <span
                  class="text-[10px] font-semibold font-mono uppercase tracking-wider text-[var(--text-muted)] block"
                >
                  sample-file
                </span>
                <span class="text-[10px] font-mono text-[var(--text-muted)]">
                  {{ sampleFiles.length }} files
                </span>
              </div>
              <div class="space-y-1 max-h-48 overflow-y-auto">
                <button
                  v-for="file in sampleFiles"
                  :key="file.fileName"
                  type="button"
                  class="w-full p-2 rounded-lg bg-white/5 hover:bg-white/10 flex items-center justify-between text-left text-[11px] font-medium text-[var(--text-muted)] hover:text-white truncate border border-[var(--node-border)] cursor-pointer"
                  @click="handleSelectSample(file)"
                >
                  <span class="font-mono truncate">
                    {{ file.baseName }}
                    <sup
                      class="ml-1 px-1 py-0.2 rounded text-[9px] font-mono font-semibold border"
                      :class="getExtensionBadgeClass(file.ext)"
                    >
                      .{{ file.ext }}
                    </sup>
                  </span>
                  <span
                    v-if="isTabOpen(file.fileName)"
                    class="text-[9px] text-emerald-400 font-mono ml-2 shrink-0 bg-emerald-500/10 px-1 py-0.5 rounded border border-emerald-500/20"
                  >
                    open
                  </span>
                </button>
              </div>
            </div>

            <div class="space-y-1.5 pt-1">
              <span
                class="text-[10px] font-semibold font-mono uppercase tracking-wider text-[var(--text-muted)] block px-1"
              >
                Settings & Guides
              </span>
              <a
                href="/docs"
                target="_blank"
                rel="noopener noreferrer"
                class="w-full px-3 py-2.5 rounded-lg bg-white/5 hover:bg-white/10 text-left flex items-center justify-between text-[var(--text-primary)] font-medium"
              >
                <div class="flex items-center gap-2.5">
                  <svg
                    class="w-4 h-4 text-blue-400"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="2"
                  >
                    <path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1-2.5-2.5Z" />
                    <path d="M6 6h10" />
                    <path d="M6 10h10" />
                  </svg>
                  <span>Documentation</span>
                </div>
                <span class="text-[10px] text-[var(--text-muted)]">↗</span>
              </a>

              <button
                type="button"
                class="w-full px-3 py-2.5 rounded-lg bg-white/5 hover:bg-white/10 text-left flex items-center justify-between text-[var(--text-primary)] font-medium cursor-pointer"
                @click="openThemeModal"
              >
                <div class="flex items-center gap-2.5">
                  <svg
                    class="w-4 h-4 text-pink-400"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="2"
                  >
                    <circle cx="12" cy="12" r="4" />
                    <path d="M12 2v2" />
                    <path d="M12 20v2" />
                  </svg>
                  <span>Theme Settings</span>
                </div>
                <span
                  class="text-[9px] font-mono font-bold px-1.5 py-0.5 rounded bg-white/10 text-pink-300"
                >
                  {{ activeThemeDef?.name?.split(' ')[0] || 'Dark' }}
                </span>
              </button>
            </div>
          </div>

          <div
            class="p-4 border-t border-[var(--node-border)] bg-[var(--tab-bar-bg)] flex items-center justify-between text-[11px] text-[var(--text-muted)]"
          >
            <span>SchemaCraft Studio</span>
            <span class="font-mono text-[10px]">v1.0.0</span>
          </div>
        </div>
      </div>
    </teleport>

    <teleport to="body">
      <div
        v-if="showExportModal"
        class="fixed inset-0 z-50 bg-black/70 backdrop-blur-xs flex items-center justify-center p-4 select-none"
        @click.self="showExportModal = false"
      >
        <div
          class="w-full max-w-2xl bg-[var(--header-bg)] border border-[var(--node-border)] rounded-xl shadow-2xl overflow-hidden flex flex-col max-h-[85vh] animate-in zoom-in-95 duration-150"
        >
          <div
            class="h-12 border-b border-[var(--node-border)] px-4 flex items-center justify-between"
          >
            <div class="flex items-center gap-2">
              <span class="font-bold text-sm text-white">Export Schema</span>
              <span
                class="text-[10px] uppercase font-mono px-1.5 py-0.5 bg-blue-500/20 text-blue-400 rounded"
              >
                Nitro Generator
              </span>
            </div>
            <button
              type="button"
              class="p-1 text-neutral-400 hover:text-white hover:bg-white/10 rounded transition-colors"
              @click="showExportModal = false"
            >
              ✕
            </button>
          </div>

          <div
            class="p-4 bg-[var(--tab-bar-bg)] border-b border-[var(--node-border)] flex items-center gap-2"
          >
            <button
              v-for="fmt in ['typescript', 'prisma', 'dbml', 'json'] as const"
              :key="fmt"
              type="button"
              class="px-3 py-1.5 text-xs rounded-md font-medium capitalize transition-colors cursor-pointer"
              :class="
                selectedExportFormat === fmt
                  ? 'bg-blue-600 text-white'
                  : 'bg-white/5 text-neutral-400 hover:text-white'
              "
              @click="handleFormatChange(fmt)"
            >
              {{ fmt }}
            </button>
          </div>

          <div
            class="p-4 flex-1 overflow-auto bg-[var(--app-bg)] font-mono text-xs text-[var(--text-primary)]"
          >
            <div v-if="isExporting" class="flex items-center justify-center py-12 text-neutral-400">
              <svg
                class="w-5 h-5 animate-spin mr-2"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
              >
                <path d="M21 12a9 9 0 1 1-6.219-8.56" />
              </svg>
              Generating {{ selectedExportFormat }} schema...
            </div>
            <pre v-else class="whitespace-pre-wrap leading-relaxed">{{ exportResult }}</pre>
          </div>

          <div
            class="h-12 border-t border-[var(--node-border)] px-4 flex items-center justify-between bg-[var(--tab-bar-bg)]"
          >
            <span class="text-[11px] text-[var(--text-muted)]"
              >Processed server-side via Nitro endpoint</span
            >
            <div class="flex items-center gap-2">
              <button
                type="button"
                :disabled="isExportingZip"
                class="px-2.5 py-1.5 rounded-md bg-white/5 hover:bg-white/10 text-neutral-300 text-xs font-medium border border-white/10 transition-colors cursor-pointer flex items-center gap-1.5 disabled:opacity-50"
                @click="handleExportZip"
              >
                <tools-icon
                  dir="editor"
                  :icon="isExportingZip ? 'loading' : 'download'"
                  width="12"
                  height="12"
                  :svg-class="isExportingZip ? 'text-amber-400 animate-spin' : 'text-amber-400'"
                />
                <span>Download All (.zip)</span>
              </button>
              <ui-icon-button variant="primary" size="sm" @click="copyExportResult">
                {{ copied ? 'Copied to Clipboard!' : 'Copy Code' }}
              </ui-icon-button>
            </div>
          </div>
        </div>
      </div>
    </teleport>

    <features-settings-theme-modal />
  </header>
</template>
