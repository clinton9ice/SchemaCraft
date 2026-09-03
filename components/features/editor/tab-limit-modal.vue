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
        <!-- iOS Style Frosted Glass Dialog -->
        <div
          class="w-full max-w-md overflow-hidden rounded-[28px] border border-white/15 bg-neutral-900/90 shadow-2xl backdrop-blur-2xl text-neutral-100 transition-all p-6 text-center"
        >
          <!-- Soft Icon Badge -->
          <div
            class="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-2xl bg-amber-500/15 text-amber-400 border border-amber-500/20"
          >
            <tools-icon
              dir="editor"
              icon="tabs"
              width="28"
              height="28"
              svg-class="text-amber-400"
            />
          </div>

          <!-- Dialog Header -->
          <h3 class="text-lg font-semibold tracking-tight text-white mb-2">
            Tab Limit Reached ({{ tabs.length }}/{{ MAX_WORKSPACE_TABS }})
          </h3>

          <!-- Dialog Body Copy -->
          <p class="text-sm leading-relaxed text-neutral-300/90 mb-6 font-normal px-2">
            You will need to export and save the files you're done with to free up more tabs as
            you're only allowed to open just 10 tabs per task.
          </p>

          <!-- Current Open Tabs Count Summary Pill -->
          <div
            class="mb-6 inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/5 px-3.5 py-1 text-xs text-neutral-400"
          >
            <span class="h-2 w-2 rounded-full bg-amber-400 animate-pulse" />
            <span>Workspace is at full capacity (10 active schemas)</span>
          </div>

          <!-- iOS Dialog Button Actions -->
          <div class="flex flex-col gap-2.5">
            <button
              type="button"
              class="w-full rounded-xl bg-blue-600 px-4 py-3 text-sm font-semibold text-white shadow-lg shadow-blue-600/25 transition-all hover:bg-blue-500 active:scale-[0.98] cursor-pointer flex items-center justify-center gap-2"
              :disabled="isExportingZip"
              @click="handleExportZip"
            >
              <tools-icon
                v-if="isExportingZip"
                dir="editor"
                icon="loading"
                width="16"
                height="16"
                svg-class="animate-spin text-white"
              />
              <tools-icon
                v-else-if="!hasExported"
                dir="editor"
                icon="download"
                width="16"
                height="16"
                svg-class="text-white"
              />
              <span>{{
                hasExported ? 'Downloaded collection.zip!' : 'Export All as collection.zip'
              }}</span>
            </button>

            <button
              type="button"
              class="w-full rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-sm font-medium text-neutral-300 transition-all hover:bg-white/10 hover:text-white active:scale-[0.98] cursor-pointer"
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
