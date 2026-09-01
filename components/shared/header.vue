<script setup lang="ts">
const {
  fileName,
  isDirty,
  isSaving,
  isParsing,
  availablePresets,
  fetchPresets,
  loadSample,
  exportSchema,
} = useSchemaStore()

const {
  openSqlFile,
  saveSqlFile,
  exportDiagramAsImage,
  isExportingImage,
} = useFileSystem()

const { currentTheme, showThemeModal, activeThemeDef, setTheme, initTheme } = useThemeEngine()

const showExportModal = ref(false)
const selectedExportFormat = ref<'typescript' | 'prisma' | 'dbml' | 'json'>('typescript')
const exportResult = ref('')
const isExporting = ref(false)
const copied = ref(false)
const showImageExportMenu = ref(false)
const showSettingsMenu = ref(false)
const showMobileDrawer = ref(false)

onMounted(async () => {
  initTheme()
  await fetchPresets()
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

function handleMobilePreset(id: string) {
  showMobileDrawer.value = false
  loadSample(id)
}
</script>

<template>
  <header
    class="h-12 border-b border-[var(--node-border)] bg-[var(--header-bg)] text-[var(--text-primary)] px-3 sm:px-4 flex items-center justify-between shrink-0 select-none z-30 relative transition-colors duration-150"
  >
    <!-- Left: Branding and File Breadcrumb -->
    <div class="flex items-center gap-2.5 sm:gap-3 min-w-0">
      <div class="flex items-center gap-2 sm:gap-2.5 shrink-0">
        <div
          class="w-7 h-7 rounded-lg bg-gradient-to-tr from-blue-600 to-indigo-500 flex items-center justify-center shadow-md shadow-blue-500/20 text-white font-bold text-sm"
        >
          <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <ellipse cx="12" cy="5" rx="9" ry="3" />
            <path d="M3 5V19A9 3 0 0 0 21 19V5" />
            <path d="M3 12A9 3 0 0 0 21 12" />
          </svg>
        </div>
        <div class="flex flex-col">
          <span class="font-bold text-xs tracking-tight text-white flex items-center gap-1.5">
            SchemaCraft
            <span class="text-[9px] font-semibold uppercase px-1 py-0.2 bg-blue-500/20 text-blue-400 border border-blue-500/30 rounded hidden min-[400px]:inline">
              Nitro
            </span>
          </span>
          <span class="text-[10px] text-[var(--text-muted)] font-mono hidden min-[400px]:block">DB Visual Editor</span>
        </div>
      </div>

      <div class="h-4 w-px bg-neutral-700/60 mx-1 hidden md:block" />

      <!-- Breadcrumbs & Dirty Indicator -->
      <div class="hidden md:flex items-center gap-1.5 text-xs text-[var(--text-muted)] font-mono truncate">
        <span class="hover:text-neutral-200 cursor-pointer">database</span>
        <span class="text-neutral-600">/</span>
        <span class="flex items-center gap-1.5 text-[var(--text-primary)] font-medium truncate">
          <span class="w-2 h-2 rounded-full shrink-0" :class="isDirty ? 'bg-amber-400' : 'bg-emerald-400'" />
          {{ fileName }}
        </span>
      </div>
    </div>

    <!-- Center: Preset Schemas Quick Select (Desktop only: lg:flex) -->
    <div class="hidden lg:flex items-center gap-1 bg-[var(--tab-bar-bg)] p-1 rounded-lg border border-[var(--node-border)]">
      <span class="text-[11px] text-[var(--text-muted)] px-2 font-medium">Presets:</span>
      <button
        v-for="sample in availablePresets"
        :key="sample.id"
        type="button"
        @click="loadSample(sample.id)"
        class="px-2.5 py-1 text-xs rounded font-medium text-[var(--text-muted)] hover:text-white hover:bg-white/10 transition-colors cursor-pointer"
        :title="sample.description"
      >
        {{ sample.label }}
      </button>
    </div>

    <!-- Right: Actions -->
    <div class="flex items-center gap-1.5 sm:gap-2">
      <!-- DESKTOP / TABLET ONLY (Hidden on screens < 520px) -->
      <div class="hidden min-[520px]:flex items-center gap-2">
        <!-- Open File Button -->
        <button
          type="button"
          @click="openSqlFile"
          class="inline-flex items-center gap-1.5 px-2.5 py-1.5 bg-white/5 hover:bg-white/10 text-[var(--text-primary)] text-xs font-medium rounded-md border border-[var(--node-border)] transition-colors cursor-pointer"
          title="Open .sql file from computer (File System Access API)"
        >
          <svg class="w-3.5 h-3.5 text-neutral-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z" />
          </svg>
          <span class="hidden sm:inline">Open</span>
        </button>

        <!-- Export as Image Dropdown -->
        <div class="relative">
          <button
            type="button"
            @click="showImageExportMenu = !showImageExportMenu"
            class="inline-flex items-center gap-1.5 px-2.5 py-1.5 bg-white/5 hover:bg-white/10 text-[var(--text-primary)] text-xs font-medium rounded-md border border-[var(--node-border)] transition-colors cursor-pointer"
            title="Export diagram as image (PNG / SVG)"
          >
            <svg v-if="!isExportingImage" class="w-3.5 h-3.5 text-blue-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <rect x="3" y="3" width="18" height="18" rx="2" />
              <circle cx="8.5" cy="8.5" r="1.5" />
              <polyline points="21 15 16 10 5 21" />
            </svg>
            <svg v-else class="w-3.5 h-3.5 animate-spin text-blue-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M21 12a9 9 0 1 1-6.219-8.56" />
            </svg>
            <span class="hidden sm:inline">Image</span>
            <svg class="w-3 h-3 text-neutral-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="m6 9 6 6 6-6" />
            </svg>
          </button>

          <!-- Image Menu Popup -->
          <div
            v-if="showImageExportMenu"
            class="absolute right-0 mt-1 w-44 bg-[var(--header-bg)] border border-[var(--node-border)] rounded-lg shadow-2xl py-1 z-50 text-xs font-sans"
          >
            <button
              type="button"
              @click="handleExportImage('png')"
              class="w-full px-3 py-2 text-left text-[var(--text-primary)] hover:bg-blue-600/20 hover:text-blue-300 flex items-center justify-between"
            >
              <span>Export as PNG</span>
              <span class="text-[10px] font-mono text-[var(--text-muted)]">High-Res</span>
            </button>
            <button
              type="button"
              @click="handleExportImage('svg')"
              class="w-full px-3 py-2 text-left text-[var(--text-primary)] hover:bg-blue-600/20 hover:text-blue-300 flex items-center justify-between border-t border-[var(--node-border)]"
            >
              <span>Export as SVG</span>
              <span class="text-[10px] font-mono text-[var(--text-muted)]">Vector</span>
            </button>
            <button
              type="button"
              @click="handleExportImage('jpeg')"
              class="w-full px-3 py-2 text-left text-[var(--text-primary)] hover:bg-blue-600/20 hover:text-blue-300 flex items-center justify-between border-t border-[var(--node-border)]"
            >
              <span>Export as JPEG</span>
              <span class="text-[10px] font-mono text-[var(--text-muted)]">Compressed</span>
            </button>
          </div>
        </div>

        <!-- Export Schema Code Button -->
        <button
          type="button"
          @click="handleOpenExport"
          class="inline-flex items-center gap-1.5 px-2.5 py-1.5 bg-white/5 hover:bg-white/10 text-[var(--text-primary)] text-xs font-medium rounded-md border border-[var(--node-border)] transition-colors cursor-pointer"
          title="Export schema via Nitro (TypeScript, Prisma, DBML, JSON)"
        >
          <svg class="w-3.5 h-3.5 text-indigo-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <polyline points="16 18 22 12 16 6" />
            <polyline points="8 6 2 12 8 18" />
          </svg>
          <span class="hidden sm:inline">Code</span>
        </button>

        <!-- Settings Cog Dropdown Menu -->
        <div class="relative">
          <button
            type="button"
            @click="showSettingsMenu = !showSettingsMenu"
            class="p-1.5 text-[var(--text-muted)] hover:text-white hover:bg-white/10 rounded-md transition-colors cursor-pointer"
            title="Settings & Documentation"
          >
            <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="12" cy="12" r="3" />
              <path
                d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"
              />
            </svg>
          </button>

          <!-- Dropdown Popup -->
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
                  <svg class="w-4 h-4 text-blue-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1-2.5-2.5Z" />
                    <path d="M6 6h10" />
                    <path d="M6 10h10" />
                  </svg>
                  <span>Documentation</span>
                </div>
                <svg class="w-3 h-3 text-[var(--text-muted)] group-hover:text-blue-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
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
                  <svg class="w-4 h-4 text-pink-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
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
                <span class="text-[9px] font-mono font-bold px-1.5 py-0.2 rounded bg-white/10 text-[var(--text-muted)]">
                  {{ activeThemeDef?.name?.split(' ')[0] || 'Dark' }}
                </span>
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Save Button (Always visible on all screen sizes) -->
      <button
        type="button"
        @click="saveSqlFile(false)"
        :disabled="isSaving"
        class="inline-flex items-center gap-1.5 sm:gap-2 px-3 sm:px-3.5 py-1.5 bg-blue-600 hover:bg-blue-500 active:bg-blue-700 text-white text-xs font-semibold rounded-md shadow-sm transition-all duration-150 cursor-pointer focus:outline-none focus:ring-2 focus:ring-blue-500/40 disabled:opacity-50"
        title="Save SQL Schema to disk (Cmd+S / Ctrl+S)"
      >
        <svg v-if="!isSaving" class="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M15.2 3a2 2 0 0 1 1.4.6l3.8 3.8a2 2 0 0 1 .6 1.4V19a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2z" />
          <path d="M17 21v-7a1 1 0 0 0-1-1H8a1 1 0 0 0-1 1v7" />
          <path d="M7 3v4a1 1 0 0 0 1 1h7" />
        </svg>
        <svg v-else class="w-3.5 h-3.5 animate-spin" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M21 12a9 9 0 1 1-6.219-8.56" />
        </svg>
        <span>{{ isSaving ? 'Saving...' : 'Save' }}</span>
        <ui-keyboard-shortcut class="hidden sm:inline-flex">⌘S</ui-keyboard-shortcut>
      </button>

      <!-- MOBILE HAMBURGER MENU BUTTON (Visible only on screens < 520px) -->
      <button
        type="button"
        @click="showMobileDrawer = true"
        class="flex min-[520px]:hidden p-1.5 text-[var(--text-muted)] hover:text-white hover:bg-white/10 rounded-md transition-colors cursor-pointer border border-[var(--node-border)]"
        title="Open menu"
      >
        <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="3" y1="12" x2="21" y2="12" />
          <line x1="3" y1="6" x2="21" y2="6" />
          <line x1="3" y1="18" x2="21" y2="18" />
        </svg>
      </button>
    </div>

    <!-- MOBILE SLIDEOVER DRAWER (< 520px) -->
    <Teleport to="body">
      <div v-if="showMobileDrawer" class="fixed inset-0 z-50 overflow-hidden select-none">
        <!-- Backdrop Blur overlay -->
        <div
          class="absolute inset-0 bg-black/70 backdrop-blur-xs transition-opacity duration-300"
          @click="showMobileDrawer = false"
        />

        <!-- Slide Drawer Panel (from right) -->
        <div class="fixed inset-y-0 right-0 max-w-full flex pl-10">
          <div
            class="w-screen max-w-xs bg-[var(--header-bg)] border-l border-[var(--node-border)] shadow-2xl flex flex-col justify-between overflow-y-auto animate-in slide-in-from-right duration-200 text-[var(--text-primary)]"
          >
            <!-- Drawer Header -->
            <div class="p-4 border-b border-[var(--node-border)] flex items-center justify-between bg-[var(--tab-bar-bg)]">
              <div class="flex items-center gap-2">
                <div class="w-6 h-6 rounded bg-blue-600 flex items-center justify-center text-white text-xs font-bold">
                  S
                </div>
                <div class="flex flex-col">
                  <span class="font-bold text-xs">SchemaCraft Menu</span>
                  <span class="text-[10px] text-[var(--text-muted)] font-mono flex items-center gap-1">
                    <span class="w-1.5 h-1.5 rounded-full" :class="isDirty ? 'bg-amber-400' : 'bg-emerald-400'" />
                    {{ fileName }}
                  </span>
                </div>
              </div>

              <button
                type="button"
                @click="showMobileDrawer = false"
                class="w-7 h-7 flex items-center justify-center rounded-md text-[var(--text-muted)] hover:text-white hover:bg-white/10"
              >
                ✕
              </button>
            </div>

            <!-- Drawer Body Items -->
            <div class="p-4 space-y-5 flex-1 text-xs">
              <!-- File Actions Section -->
              <div class="space-y-1.5">
                <span class="text-[10px] font-semibold font-mono uppercase tracking-wider text-[var(--text-muted)] block px-1">
                  File & Workspace
                </span>
                <button
                  type="button"
                  @click="handleMobileOpenSql"
                  class="w-full px-3 py-2.5 rounded-lg bg-white/5 hover:bg-white/10 text-left flex items-center gap-2.5 text-[var(--text-primary)] font-medium"
                >
                  <svg class="w-4 h-4 text-blue-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z" />
                  </svg>
                  <span>Open .SQL File</span>
                </button>
              </div>

              <!-- Export Options Section -->
              <div class="space-y-1.5">
                <span class="text-[10px] font-semibold font-mono uppercase tracking-wider text-[var(--text-muted)] block px-1">
                  Export Options
                </span>
                <div class="grid grid-cols-2 gap-1.5">
                  <button
                    type="button"
                    @click="handleExportImage('png')"
                    class="p-2 rounded-lg bg-white/5 hover:bg-blue-600/20 text-left flex flex-col gap-0.5 border border-[var(--node-border)]"
                  >
                    <span class="font-semibold text-[11px] text-blue-400">PNG Image</span>
                    <span class="text-[9px] text-[var(--text-muted)]">High-Res</span>
                  </button>
                  <button
                    type="button"
                    @click="handleExportImage('svg')"
                    class="p-2 rounded-lg bg-white/5 hover:bg-blue-600/20 text-left flex flex-col gap-0.5 border border-[var(--node-border)]"
                  >
                    <span class="font-semibold text-[11px] text-blue-400">SVG Vector</span>
                    <span class="text-[9px] text-[var(--text-muted)]">Vector format</span>
                  </button>
                </div>
                <button
                  type="button"
                  @click="handleOpenExport"
                  class="w-full px-3 py-2.5 rounded-lg bg-white/5 hover:bg-white/10 text-left flex items-center justify-between text-[var(--text-primary)] font-medium mt-1"
                >
                  <div class="flex items-center gap-2.5">
                    <svg class="w-4 h-4 text-indigo-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                      <polyline points="16 18 22 12 16 6" />
                      <polyline points="8 6 2 12 8 18" />
                    </svg>
                    <span>Export Code (Nitro)</span>
                  </div>
                  <span class="text-[9px] font-mono text-[var(--text-muted)]">TS/Prisma</span>
                </button>
              </div>

              <!-- Presets Section -->
              <div class="space-y-1.5">
                <span class="text-[10px] font-semibold font-mono uppercase tracking-wider text-[var(--text-muted)] block px-1">
                  Preset Schemas
                </span>
                <div class="grid grid-cols-2 gap-1.5">
                  <button
                    v-for="sample in availablePresets"
                    :key="sample.id"
                    type="button"
                    @click="handleMobilePreset(sample.id)"
                    class="p-2 rounded-lg bg-white/5 hover:bg-white/10 text-left text-[11px] font-medium text-[var(--text-muted)] hover:text-white truncate border border-[var(--node-border)]"
                  >
                    {{ sample.label }}
                  </button>
                </div>
              </div>

              <!-- Settings & Documentation Section -->
              <div class="space-y-1.5 pt-1">
                <span class="text-[10px] font-semibold font-mono uppercase tracking-wider text-[var(--text-muted)] block px-1">
                  Settings & Guides
                </span>
                <a
                  href="/docs"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="w-full px-3 py-2.5 rounded-lg bg-white/5 hover:bg-white/10 text-left flex items-center justify-between text-[var(--text-primary)] font-medium"
                >
                  <div class="flex items-center gap-2.5">
                    <svg class="w-4 h-4 text-blue-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
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
                  @click="openThemeModal"
                  class="w-full px-3 py-2.5 rounded-lg bg-white/5 hover:bg-white/10 text-left flex items-center justify-between text-[var(--text-primary)] font-medium cursor-pointer"
                >
                  <div class="flex items-center gap-2.5">
                    <svg class="w-4 h-4 text-pink-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                      <circle cx="12" cy="12" r="4" />
                      <path d="M12 2v2" />
                      <path d="M12 20v2" />
                    </svg>
                    <span>Theme Settings</span>
                  </div>
                  <span class="text-[9px] font-mono font-bold px-1.5 py-0.5 rounded bg-white/10 text-pink-300">
                    {{ activeThemeDef?.name?.split(' ')[0] || 'Dark' }}
                  </span>
                </button>
              </div>
            </div>

            <!-- Drawer Footer -->
            <div class="p-4 border-t border-[var(--node-border)] bg-[var(--tab-bar-bg)] flex items-center justify-between text-[11px] text-[var(--text-muted)]">
              <span>SchemaCraft Studio</span>
              <span class="font-mono text-[10px]">v1.0.0</span>
            </div>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- Nitro Export Modal -->
    <Teleport to="body">
      <div
        v-if="showExportModal"
        class="fixed inset-0 z-50 bg-black/70 backdrop-blur-xs flex items-center justify-center p-4 select-none"
        @click.self="showExportModal = false"
      >
        <div
          class="w-full max-w-2xl bg-[var(--header-bg)] border border-[var(--node-border)] rounded-xl shadow-2xl overflow-hidden flex flex-col max-h-[85vh] animate-in zoom-in-95 duration-150"
        >
          <!-- Modal Header -->
          <div class="h-12 border-b border-[var(--node-border)] px-4 flex items-center justify-between">
            <div class="flex items-center gap-2">
              <span class="font-bold text-sm text-white">Export Schema</span>
              <span class="text-[10px] uppercase font-mono px-1.5 py-0.5 bg-blue-500/20 text-blue-400 rounded">
                Nitro Generator
              </span>
            </div>
            <button
              type="button"
              @click="showExportModal = false"
              class="p-1 text-neutral-400 hover:text-white hover:bg-white/10 rounded transition-colors"
            >
              ✕
            </button>
          </div>

          <!-- Format Tabs -->
          <div class="p-4 bg-[var(--tab-bar-bg)] border-b border-[var(--node-border)] flex items-center gap-2">
            <button
              v-for="fmt in (['typescript', 'prisma', 'dbml', 'json'] as const)"
              :key="fmt"
              type="button"
              @click="handleFormatChange(fmt)"
              class="px-3 py-1.5 text-xs rounded-md font-medium capitalize transition-colors cursor-pointer"
              :class="selectedExportFormat === fmt ? 'bg-blue-600 text-white' : 'bg-white/5 text-neutral-400 hover:text-white'"
            >
              {{ fmt }}
            </button>
          </div>

          <!-- Code Output Window -->
          <div class="p-4 flex-1 overflow-auto bg-[var(--app-bg)] font-mono text-xs text-[var(--text-primary)]">
            <div v-if="isExporting" class="flex items-center justify-center py-12 text-neutral-400">
              <svg class="w-5 h-5 animate-spin mr-2" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M21 12a9 9 0 1 1-6.219-8.56" />
              </svg>
              Generating {{ selectedExportFormat }} schema...
            </div>
            <pre v-else class="whitespace-pre-wrap leading-relaxed">{{ exportResult }}</pre>
          </div>

          <!-- Modal Footer -->
          <div class="h-12 border-t border-[var(--node-border)] px-4 flex items-center justify-between bg-[var(--tab-bar-bg)]">
            <span class="text-[11px] text-[var(--text-muted)]">Processed server-side via Nitro endpoint</span>
            <div class="flex items-center gap-2">
              <ui-icon-button variant="primary" size="sm" @click="copyExportResult">
                {{ copied ? 'Copied to Clipboard!' : 'Copy Code' }}
              </ui-icon-button>
            </div>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- Theme Settings Modal -->
    <features-settings-theme-modal />
  </header>
</template>
