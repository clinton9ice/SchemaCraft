<script setup lang="ts">
const { isTabLimitModalOpen, exportAllTabsAsZip, tabs, MAX_WORKSPACE_TABS } = useSchemaStore()

const isExportingZip = ref(false)
const hasExported = ref(false)

function handleExportZip() {
  isExportingZip.value = true
  try {
    exportAllTabsAsZip('schema-collection.zip')
    hasExported.value = true
    setTimeout(() => {
      hasExported.value = false
    }, 2500)
  } catch (err) {
    console.error('Failed to export collection ZIP:', err)
  } finally {
    isExportingZip.value = false
  }
}

function handleDismiss() {
  isTabLimitModalOpen.value = false
}
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
        v-if="isTabLimitModalOpen"
        class="fixed inset-0 z-50 flex items-center justify-center p-4 select-none bg-black/60 backdrop-blur-md"
        @click.self="handleDismiss"
      >
        <div
          class="w-full max-w-md overflow-hidden rounded-2xl border border-neutral-800 bg-neutral-900 shadow-2xl text-neutral-100 transition-all p-6 text-center"
        >
          <div
            class="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-neutral-800 text-amber-400 border border-neutral-700/60"
          >
            <tools-icon
              dir="editor"
              icon="tabs"
              width="24"
              height="24"
              svg-class="text-amber-400"
            />
          </div>

          <h3 class="text-base font-semibold tracking-tight text-white mb-1.5">
            Tab Limit Reached ({{ tabs.length }}/{{ MAX_WORKSPACE_TABS }})
          </h3>

          <p class="text-xs leading-relaxed text-neutral-400 mb-5 font-normal px-2">
            You've hit the maximum of 10 open tabs. You can save and download all your current tabs
            as a ZIP archive to clear space.
          </p>

          <div class="flex flex-col gap-2">
            <button
              type="button"
              class="w-full rounded-lg bg-blue-600 px-3 py-2 text-xs font-medium text-white transition-colors hover:bg-blue-500 cursor-pointer flex items-center justify-center gap-2 disabled:opacity-50"
              :disabled="isExportingZip"
              @click="handleExportZip"
            >
              <tools-icon
                v-if="isExportingZip"
                dir="editor"
                icon="loading"
                width="14"
                height="14"
                svg-class="animate-spin text-white"
              />
              <tools-icon
                v-else-if="!hasExported"
                dir="editor"
                icon="download"
                width="14"
                height="14"
                svg-class="text-white"
              />
              <span>{{
                hasExported ? 'Downloaded collection.zip!' : 'Export all as collection.zip'
              }}</span>
            </button>

            <button
              type="button"
              class="w-full rounded-lg border border-neutral-700/80 bg-neutral-800 px-3 py-2 text-xs font-medium text-neutral-300 transition-colors hover:bg-neutral-700 hover:text-white cursor-pointer"
              @click="handleDismiss"
            >
              Dismiss
            </button>
          </div>
        </div>
      </div>
    </transition>
  </teleport>
</template>
