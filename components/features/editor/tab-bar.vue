<script setup lang="ts">
const { fileName, isDirty, formatSql } = useSchemaStore()
const { validationError } = usePostgresValidator()
</script>

<template>
  <div
    class="h-9 bg-[#1e1e1e] border-b border-[#2d2d30] flex items-center justify-between px-2 shrink-0 select-none"
  >
    <!-- Left: Tabs -->
    <div class="flex items-center h-full">
      <div
        class="flex items-center gap-2 px-3 h-full bg-[#18181b] border-t-2 text-neutral-100 text-xs font-medium border-r border-[#2d2d30]"
        :class="validationError ? 'border-t-red-500' : 'border-t-blue-500'"
      >
        <!-- SQL Icon -->
        <span class="text-sky-400 font-mono text-[11px] font-bold">SQL</span>
        <span
          :class="validationError ? 'text-red-300' : 'text-neutral-100'"
          class="font-mono text-xs"
          >{{ fileName }}</span
        >

        <!-- Error / Dirty indicator circle -->
        <span
          v-if="validationError"
          class="w-2 h-2 rounded-full bg-red-500"
          :title="`Error: ${validationError.message}`"
        />
        <span
          v-else-if="isDirty"
          class="w-2 h-2 rounded-full bg-amber-400"
          title="Unsaved changes"
        />
      </div>
    </div>

    <!-- Right: Tab actions -->
    <div class="flex items-center gap-1">
      <button
        type="button"
        class="p-1 text-neutral-400 hover:text-white hover:bg-[#2d2d30] rounded transition-colors cursor-pointer"
        title="Format SQL Document (Shift+Alt+F)"
        @click="formatSql"
      >
        <svg
          class="w-3.5 h-3.5"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
        >
          <line x1="21" y1="10" x2="3" y2="10" />
          <line x1="21" y1="6" x2="3" y2="6" />
          <line x1="21" y1="14" x2="3" y2="14" />
          <line x1="21" y1="18" x2="3" y2="18" />
        </svg>
      </button>

      <div class="h-3.5 w-px bg-neutral-700 mx-0.5" />

      <span class="text-[10px] text-neutral-400 font-mono px-1">40% width</span>
    </div>
  </div>
</template>
