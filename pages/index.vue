<script setup lang="ts">
const { sqlCode, parseSchema } = useSchemaStore()
const { saveSqlFile, openSqlFile } = useFileSystem()
const { toggleConsole } = useEditorConsole()
const { validateUploadFiles, setReuploadHandler } = useUploadGuard()
const { startUploadQueue } = useSchemaUploader()
const { splitPercent, isDragging, mobileView, startDragging, resetSplit, toggleMobileView } =
  useSplitPane()

const isDraggingFiles = ref(false)

function handleGlobalKeydown(e: KeyboardEvent) {
  if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 's') {
    e.preventDefault()
    saveSqlFile(false)
  }
  // Cmd + J or Ctrl + J toggles the VS Code style Error / Terminal Console
  if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'j') {
    e.preventDefault()
    toggleConsole()
  }
  // Cmd + K or Ctrl + K opens the canvas table search
  if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k') {
    e.preventDefault()
    if (typeof window !== 'undefined') {
      window.dispatchEvent(new CustomEvent('schemacraft:open-search'))
    }
  }
}

function handleDragOver(e: DragEvent) {
  e.preventDefault()
  if (e.dataTransfer?.types?.includes('Files')) {
    isDraggingFiles.value = true
  }
}

function handleDragLeave(e: DragEvent) {
  if (!e.relatedTarget || (e.relatedTarget as HTMLElement).nodeName === 'HTML') {
    isDraggingFiles.value = false
  }
}

async function handleDrop(e: DragEvent) {
  e.preventDefault()
  isDraggingFiles.value = false
  const fileList = e.dataTransfer?.files ? Array.from(e.dataTransfer.files) : []
  if (fileList.length === 0) return

  setReuploadHandler(() => {
    openSqlFile()
  })

  const validation = validateUploadFiles(fileList)
  if (validation.valid && validation.files.length > 0) {
    await startUploadQueue(validation.files)
  }
}

onMounted(() => {
  window.addEventListener('keydown', handleGlobalKeydown)
  window.addEventListener('dragover', handleDragOver)
  window.addEventListener('dragleave', handleDragLeave)
  window.addEventListener('drop', handleDrop)
  parseSchema(sqlCode.value)
})

onBeforeUnmount(() => {
  window.removeEventListener('keydown', handleGlobalKeydown)
  window.removeEventListener('dragover', handleDragOver)
  window.removeEventListener('dragleave', handleDragLeave)
  window.removeEventListener('drop', handleDrop)
})
</script>

<template>
  <div
    class="h-screen w-screen flex flex-col bg-[var(--app-bg)] text-[var(--text-primary)] overflow-hidden font-sans select-none transition-colors duration-150 relative"
  >
    <div
      v-if="isDraggingFiles"
      class="fixed inset-0 z-50 bg-black/80 backdrop-blur-md flex flex-col items-center justify-center p-6 border-2 border-dashed border-sky-400/60 pointer-events-none transition-all select-none"
    >
      <div class="flex flex-col items-center gap-3 text-center">
        <div
          class="h-16 w-16 rounded-2xl bg-sky-500/20 border border-sky-400/30 flex items-center justify-center text-sky-400"
        >
          <tools-icon
            dir="editor"
            icon="upload"
            width="32"
            height="32"
            svg-class="text-sky-400 animate-bounce"
          />
        </div>
        <h2 class="text-xl font-bold text-white tracking-tight">Drop Schemas Here</h2>
        <p class="text-sm text-neutral-300 max-w-sm">
          Accepts up to 3 files (.sql, .dbml, .prisma, .ts), max 1MB each.
        </p>
      </div>
    </div>
    <shared-header />

    <main
      ref="containerRef"
      class="flex-1 w-full min-h-0 flex overflow-hidden relative"
      :class="{ 'cursor-col-resize select-none': isDragging }"
    >
      <div
        v-if="isDragging"
        class="absolute inset-0 z-50 cursor-col-resize select-none bg-transparent"
      />

      <section
        class="editor-pane h-full flex flex-col min-w-0 overflow-hidden bg-[var(--app-bg)] transition-[width] duration-0"
        :class="[
          'w-full md:w-auto',
          mobileView === 'editor' ? 'flex' : 'hidden md:flex',
          isDragging ? 'pointer-events-none select-none' : '',
        ]"
      >
        <div class="flex-1 w-full h-full min-h-0 relative">
          <features-editor-sql-editor />
        </div>
      </section>

      <div
        class="hidden md:flex w-2 hover:w-2.5 bg-[var(--tab-bar-bg)] hover:bg-blue-500/30 border-x border-[var(--node-border)] cursor-col-resize items-center justify-center relative group select-none shrink-0 transition-all duration-150 z-20"
        :class="{ '!bg-blue-500 !border-blue-400': isDragging }"
        title="Drag to resize panes (Double click to reset to 40%)"
        @mousedown="startDragging"
        @touchstart="startDragging"
        @dblclick="resetSplit"
      >
        <div
          class="flex flex-col gap-1 items-center justify-center opacity-40 group-hover:opacity-100 transition-opacity"
        >
          <span class="w-1 h-1 rounded-full bg-[var(--text-muted)] group-hover:bg-white" />
          <span class="w-1 h-1 rounded-full bg-[var(--text-muted)] group-hover:bg-white" />
          <span class="w-1 h-1 rounded-full bg-[var(--text-muted)] group-hover:bg-white" />
        </div>
      </div>

      <section
        class="canvas-pane h-full flex flex-col min-w-0 overflow-hidden bg-[var(--canvas-bg)] flex-1"
        :class="[
          'w-full md:w-auto',
          mobileView === 'canvas' ? 'flex' : 'hidden md:flex',
          isDragging ? 'pointer-events-none select-none' : '',
        ]"
      >
        <features-canvas-diagram />
      </section>
    </main>

    <div class="fixed bottom-8 sm:bottom-9 right-3 sm:right-4 z-40 md:hidden select-none">
      <button
        type="button"
        class="flex items-center gap-2 px-4 py-2.5 rounded-full shadow-2xl font-bold text-xs text-white transition-all duration-200 active:scale-95 border border-white/25 backdrop-blur-md touch-manipulation cursor-pointer"
        :class="[
          mobileView === 'editor'
            ? 'bg-gradient-to-r from-blue-600 via-indigo-600 to-indigo-700 shadow-blue-500/40 ring-2 ring-blue-400/30'
            : 'bg-gradient-to-r from-emerald-600 via-teal-600 to-cyan-700 shadow-emerald-500/40 ring-2 ring-emerald-400/30',
        ]"
        @click="toggleMobileView"
      >
        <template v-if="mobileView === 'editor'">
          <svg class="w-4 h-4 text-white shrink-0 fill-current" viewBox="0 0 24 24">
            <polygon points="6 4 20 12 6 20 6 4" />
          </svg>
          <span class="tracking-wide font-semibold">Preview Diagram</span>
          <span class="w-2 h-2 rounded-full bg-emerald-400 animate-ping ml-0.5 shrink-0" />
        </template>

        <template v-else>
          <svg
            class="w-4 h-4 text-white shrink-0"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2.5"
          >
            <polyline points="16 18 22 12 16 6" />
            <polyline points="8 6 2 12 8 18" />
          </svg>
          <span class="tracking-wide font-semibold">Edit Schema</span>
        </template>
      </button>
    </div>

    <features-editor-error-console />

    <shared-status-bar />
  </div>
</template>

<style scoped>
@media (min-width: 768px) {
  section.editor-pane {
    width: v-bind('splitPercent + "%"') !important;
    min-width: 220px;
    max-width: calc(100% - 220px);
  }
  section.canvas-pane {
    width: v-bind('(100 - splitPercent) + "%"') !important;
    min-width: 220px;
    max-width: calc(100% - 220px);
  }
}
</style>
