<script setup lang="ts">
const {
  isLargeSchemaModalOpen,
  pendingExportFormat,
  cancelLargeSchemaExport,
  continueLargeSchemaExport,
} = useFileSystem()

const { parsedTables, activeTab } = useSchemaStore()

const currentTableCount = computed(() => {
  return parsedTables.value?.length || activeTab.value?.parsedTables?.length || 0
})
</script>

<template>
  <teleport to="body">
    <transition
      enter-active-class="transition duration-200 ease-out"
      enter-from-class="opacity-0 scale-95"
      enter-to-class="opacity-100 scale-100"
      leave-active-class="transition duration-150 ease-in"
      leave-from-class="opacity-100 scale-100"
      leave-to-class="opacity-0 scale-95"
    >
      <div
        v-if="isLargeSchemaModalOpen"
        class="fixed inset-0 z-50 flex items-center justify-center p-4 select-none bg-black/60 backdrop-blur-md"
        @click.self="cancelLargeSchemaExport"
      >
        <div
          class="w-full max-w-md overflow-hidden rounded-2xl border border-neutral-800 bg-neutral-900 shadow-2xl text-neutral-100 transition-all p-6 text-center"
        >
          <div
            class="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-amber-500/10 text-amber-400 border border-amber-500/20"
          >
            <tools-icon
              dir="editor"
              icon="alert"
              width="24"
              height="24"
              svg-class="text-amber-400"
            />
          </div>

          <h3 class="text-base font-semibold tracking-tight text-white mb-2">Heads Up</h3>

          <p class="text-xs leading-relaxed text-neutral-400 mb-6 font-normal px-2">
            Files that have more than 10 tables, the picture might be hard to view as it sometimes
            can be pixelated, just wanted you to know.
          </p>

          <!-- Table count detail pill -->
          <div
            class="mb-6 inline-flex items-center gap-2 rounded-full border border-neutral-800 bg-neutral-950/60 px-3 py-1 text-[11px] text-neutral-400"
          >
            <span class="h-1.5 w-1.5 rounded-full bg-amber-400" />
            <span>Current schema has {{ currentTableCount }} tables</span>
            <span class="text-neutral-600">•</span>
            <span class="font-mono uppercase text-neutral-300">{{ pendingExportFormat }}</span>
          </div>

          <div class="flex items-center gap-3">
            <button
              type="button"
              class="flex-1 rounded-lg border border-neutral-700/80 bg-neutral-800 px-3 py-2 text-xs font-medium text-neutral-300 transition-colors hover:bg-neutral-700 hover:text-white cursor-pointer"
              @click="cancelLargeSchemaExport"
            >
              Cancel
            </button>

            <button
              type="button"
              class="flex-1 rounded-lg bg-blue-600 px-3 py-2 text-xs font-medium text-white transition-colors hover:bg-blue-500 cursor-pointer shadow-lg shadow-blue-600/20"
              @click="continueLargeSchemaExport"
            >
              Continue anyway
            </button>
          </div>
        </div>
      </div>
    </transition>
  </teleport>
</template>
