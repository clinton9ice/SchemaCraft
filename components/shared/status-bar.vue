<script setup lang="ts">
const { cursorPosition, activeLanguage, detectedTablesCount } = useSchemaStore()
const { zoomLevel } = useCanvasViewport()
const { validationError } = usePostgresValidator()
</script>

<template>
  <footer
    class="h-6 px-3 flex items-center justify-between text-[11px] font-sans shrink-0 select-none z-10 transition-colors duration-150 border-t border-[var(--node-border)]"
    :class="validationError ? 'bg-red-700 text-white' : 'bg-[var(--status-bar-bg)] text-white/90'"
  >
    <!-- Left Section: Status & Diagnostics -->
    <div class="flex items-center gap-3">
      <!-- Error indicator -->
      <div
        class="flex items-center gap-1.5 px-1.5 py-0.5 rounded transition-colors"
        :class="validationError ? 'bg-black/20 text-white font-medium' : 'hover:bg-white/10 text-white/90'"
        :title="validationError ? validationError.message : 'No PostgreSQL syntax errors'"
      >
        <svg class="w-3 h-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="12" cy="12" r="10"/>
          <line x1="12" y1="8" x2="12" y2="12"/>
          <line x1="12" y1="16" x2="12.01" y2="16"/>
        </svg>
        <span>{{ validationError ? '1 Error' : '0 Errors' }}</span>
      </div>

      <!-- Warning indicator -->
      <div class="flex items-center gap-1.5 hover:bg-white/10 px-1.5 py-0.5 rounded cursor-pointer transition-colors text-white/90">
        <svg class="w-3 h-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <polygon points="12 2 2 22 22 22"/>
          <line x1="12" y1="9" x2="12" y2="13"/>
          <line x1="12" y1="17" x2="12.01" y2="17"/>
        </svg>
        <span>0 Warnings</span>
      </div>

      <div class="h-3 w-px bg-white/20" />

      <!-- Tables Count -->
      <div class="flex items-center gap-1 text-white/90">
        <span>Tables: <strong>{{ detectedTablesCount }}</strong></span>
      </div>

      <!-- Error Message Snip (if present) -->
      <div v-if="validationError" class="hidden md:flex items-center gap-1 text-white/95 font-mono text-[10px] truncate max-w-sm">
        <span class="opacity-80">|</span>
        <span class="truncate">{{ validationError.message }}</span>
      </div>
    </div>

    <!-- Right Section: Editor & Canvas Stats -->
    <div class="flex items-center gap-3 font-mono">
      <div class="hover:bg-white/10 px-1.5 py-0.5 rounded cursor-pointer transition-colors">
        Ln {{ cursorPosition.line }}, Col {{ cursorPosition.column }}
      </div>

      <div class="hover:bg-white/10 px-1.5 py-0.5 rounded cursor-pointer transition-colors">
        Spaces: 4
      </div>

      <div class="hover:bg-white/10 px-1.5 py-0.5 rounded cursor-pointer transition-colors uppercase">
        UTF-8
      </div>

      <div class="hover:bg-white/10 px-1.5 py-0.5 rounded cursor-pointer transition-colors font-sans uppercase font-semibold">
        {{ activeLanguage }}
      </div>

      <div class="h-3 w-px bg-white/20" />

      <div class="hover:bg-white/10 px-1.5 py-0.5 rounded cursor-pointer transition-colors">
        Zoom: {{ zoomLevel }}%
      </div>
    </div>
  </footer>
</template>
