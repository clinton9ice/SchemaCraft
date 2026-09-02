<script setup lang="ts">
import { useEditorConsole } from '~/composables/use-editor-console'

const {
  isEditorConsoleOpen,
  activeConsoleTab,
  consoleLogs,
  closeConsole,
  clearLogs,
  jumpToEditorPosition,
} = useEditorConsole()

const { validationError } = usePostgresValidator()
const { fileName, activeLanguage } = useSchemaStore()
const { mobileView } = useSplitPane()

function handleJumpToError() {
  if (!validationError.value) return
  if (mobileView.value === 'canvas') {
    mobileView.value = 'editor'
  }
  jumpToEditorPosition(validationError.value.lineNumber, validationError.value.column)
}
</script>

<template>
  <div
    v-if="isEditorConsoleOpen"
    class="w-full bg-[var(--header-bg)] border-t-2 border-[var(--node-border)] flex flex-col z-40 shrink-0 text-xs select-none transition-all duration-200 shadow-2xl"
    :class="[
      validationError ? 'border-t-rose-500/80' : 'border-t-blue-500/80',
      'h-52 sm:h-56 max-h-[40vh]',
    ]"
  >
    <!-- Terminal Header / Tab Navigation -->
    <div
      class="h-8 px-3 bg-[var(--app-bg)]/90 border-b border-[var(--node-border)] flex items-center justify-between shrink-0"
    >
      <div class="flex items-center gap-1 font-mono">
        <!-- Problems Tab -->
        <button
          type="button"
          class="flex items-center gap-1.5 px-3 py-1 text-[11px] font-semibold border-b-2 transition-colors cursor-pointer"
          :class="
            activeConsoleTab === 'problems'
              ? 'border-blue-500 text-[var(--text-primary)]'
              : 'border-transparent text-[var(--text-muted)] hover:text-[var(--text-primary)]'
          "
          @click="activeConsoleTab = 'problems'"
        >
          <span>PROBLEMS</span>
          <span
            class="px-1.5 py-0.2 rounded-full text-[9px] font-mono"
            :class="
              validationError
                ? 'bg-rose-500 text-white font-bold animate-pulse'
                : 'bg-white/10 text-white/70'
            "
          >
            {{ validationError ? '1' : '0' }}
          </span>
        </button>

        <!-- Output Tab -->
        <button
          type="button"
          class="flex items-center gap-1.5 px-3 py-1 text-[11px] font-semibold border-b-2 transition-colors cursor-pointer"
          :class="
            activeConsoleTab === 'output'
              ? 'border-blue-500 text-[var(--text-primary)]'
              : 'border-transparent text-[var(--text-muted)] hover:text-[var(--text-primary)]'
          "
          @click="activeConsoleTab = 'output'"
        >
          <span>OUTPUT</span>
          <span
            v-if="consoleLogs.length > 0"
            class="px-1.5 py-0.2 rounded-full text-[9px] bg-white/10 text-white/70 font-mono"
          >
            {{ consoleLogs.length }}
          </span>
        </button>
      </div>

      <!-- Right Header Actions -->
      <div class="flex items-center gap-2 text-[var(--text-muted)]">
        <span class="hidden sm:inline text-[10px] text-white/40 font-mono">
          Toggle: ⌘J / Ctrl+J
        </span>

        <!-- Clear Logs -->
        <button
          v-if="activeConsoleTab === 'output'"
          type="button"
          title="Clear Output Logs"
          class="p-1 rounded hover:bg-white/10 text-[var(--text-muted)] hover:text-white cursor-pointer transition-colors"
          @click="clearLogs"
        >
          <svg
            class="w-3.5 h-3.5"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
          >
            <circle cx="12" cy="12" r="10" />
            <line x1="4.93" y1="4.93" x2="19.07" y2="19.07" />
          </svg>
        </button>

        <!-- Close Console -->
        <button
          type="button"
          title="Close Console (Cmd+J / Ctrl+J)"
          class="p-1 rounded hover:bg-white/10 text-[var(--text-muted)] hover:text-white cursor-pointer transition-colors"
          @click="closeConsole"
        >
          <svg
            class="w-3.5 h-3.5"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
          >
            <line x1="18" y1="6" x2="6" y2="18" />
            <line x1="6" y1="6" x2="18" y2="18" />
          </svg>
        </button>
      </div>
    </div>

    <!-- Terminal Content Area -->
    <div class="flex-1 min-h-0 overflow-y-auto font-mono text-[11px] p-2 bg-[var(--header-bg)]">
      <!-- PROBLEMS TAB -->
      <div v-if="activeConsoleTab === 'problems'" class="space-y-2">
        <!-- Error Item Card -->
        <div
          v-if="validationError"
          class="flex items-start gap-3 p-3 rounded bg-rose-500/10 hover:bg-rose-500/15 border border-rose-500/30 text-rose-200 cursor-pointer transition-colors group shadow-sm"
          title="Click to jump directly to this error in the code editor"
          @click="handleJumpToError"
        >
          <!-- Error Badge Icon -->
          <div class="shrink-0 mt-0.5">
            <svg
              class="w-4 h-4 text-rose-400"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2.5"
            >
              <circle cx="12" cy="12" r="10" />
              <line x1="12" y1="8" x2="12" y2="12" />
              <line x1="12" y1="16" x2="12.01" y2="16" />
            </svg>
          </div>

          <!-- Error Details -->
          <div class="flex-1 min-w-0">
            <div class="flex items-center gap-2 flex-wrap">
              <span class="font-bold text-rose-300 text-xs">Syntax Error:</span>
              <span class="text-white font-medium break-words">{{ validationError.message }}</span>
            </div>

            <div class="text-[10px] text-white/60 mt-1.5 flex items-center gap-2 flex-wrap">
              <span class="text-[var(--text-primary)] font-semibold">{{ fileName }}</span>
              <span>•</span>
              <span class="bg-rose-500/25 text-rose-200 px-1.5 py-0.5 rounded font-mono font-bold">
                Line {{ validationError.lineNumber }}, Column
                {{ validationError.column }}
              </span>
              <span>•</span>
              <span class="uppercase text-white/40 font-mono">{{ activeLanguage }}</span>
              <span
                class="text-blue-400 group-hover:underline font-sans font-semibold ml-auto flex items-center gap-1"
              >
                Jump to line {{ validationError.lineNumber }} ›
              </span>
            </div>
          </div>
        </div>

        <!-- No Problems State -->
        <div
          v-else
          class="h-full flex flex-col items-center justify-center text-[var(--text-muted)] gap-1.5 py-8"
        >
          <svg
            class="w-7 h-7 text-emerald-500"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
          >
            <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
            <polyline points="22 4 12 14.01 9 11.01" />
          </svg>
          <span class="text-xs font-sans text-emerald-400 font-semibold">
            No problems have been detected in the workspace.
          </span>
          <span class="text-[10px] text-white/40 font-mono">
            All tables and syntax are verified and valid.
          </span>
        </div>
      </div>

      <!-- OUTPUT TAB -->
      <div v-else class="space-y-1">
        <div v-if="consoleLogs.length === 0" class="text-white/40 italic p-3 text-[11px]">
          [Console]: Schema compiler initialized. Real-time compilation and AST diagnostics will
          stream here.
        </div>
        <div
          v-for="log in consoleLogs"
          :key="log.id"
          class="flex items-start gap-2.5 px-2 py-1 rounded text-[11px] font-mono leading-relaxed"
          :class="{
            'text-rose-300 bg-rose-500/10 border border-rose-500/20': log.type === 'error',
            'text-amber-300 bg-amber-500/10 border border-amber-500/20': log.type === 'warning',
            'text-emerald-300 bg-emerald-500/10 border border-emerald-500/20':
              log.type === 'success',
            'text-white/80 hover:bg-white/5': log.type === 'info',
          }"
        >
          <span class="text-white/35 text-[10px] shrink-0 mt-0.5"> [{{ log.timestamp }}] </span>
          <span class="break-all flex-1">{{ log.message }}</span>
        </div>
      </div>
    </div>
  </div>
</template>
