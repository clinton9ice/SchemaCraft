<script setup lang="ts">
const {
  isOversizeModalOpen,
  oversizedFileName,
  oversizedFileSize,
  formatFileSize,
  triggerReupload,
} = useUploadGuard()

function handleDismiss() {
  isOversizeModalOpen.value = false
}

function handleReupload() {
  triggerReupload()
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
        v-if="isOversizeModalOpen"
        class="fixed inset-0 z-50 flex items-center justify-center p-4 select-none bg-black/60 backdrop-blur-md"
        @click.self="handleDismiss"
      >
        <div
          class="w-full max-w-md overflow-hidden rounded-2xl border border-neutral-800 bg-neutral-900 shadow-2xl text-neutral-100 transition-all p-6 text-center"
        >
          <div
            class="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-neutral-800 text-rose-400 border border-neutral-700/60"
          >
            <tools-icon
              dir="editor"
              icon="alert"
              width="24"
              height="24"
              svg-class="text-rose-400"
            />
          </div>

          <h3 class="text-base font-semibold tracking-tight text-white mb-1.5">
            File Exceeds 1MB Limit
          </h3>

          <p class="text-xs leading-relaxed text-neutral-400 mb-4 font-normal px-1">
            This workspace accepts files up to 1MB. Consider splitting large queries or dumping
            schema structure only without data.
          </p>

          <div
            v-if="oversizedFileName"
            class="mb-5 flex items-center justify-between gap-3 rounded-xl border border-neutral-800 bg-neutral-800/50 px-3.5 py-2 text-xs text-neutral-300"
          >
            <div class="flex items-center gap-2 truncate text-left">
              <span class="truncate font-mono text-neutral-200">{{ oversizedFileName }}</span>
            </div>
            <span
              class="shrink-0 rounded-md bg-rose-500/10 border border-rose-500/20 px-2 py-0.5 font-mono text-[11px] font-medium text-rose-300"
            >
              {{ formatFileSize(oversizedFileSize) }}
            </span>
          </div>

          <div class="grid grid-cols-2 gap-2.5">
            <button
              type="button"
              class="w-full rounded-lg border border-neutral-700/80 bg-neutral-800 px-3 py-2 text-xs font-medium text-neutral-300 transition-colors hover:bg-neutral-700 hover:text-white cursor-pointer"
              @click="handleDismiss"
            >
              Dismiss
            </button>

            <button
              type="button"
              class="w-full rounded-lg bg-blue-600 px-3 py-2 text-xs font-medium text-white transition-colors hover:bg-blue-500 cursor-pointer"
              @click="handleReupload"
            >
              Choose another file
            </button>
          </div>
        </div>
      </div>
    </transition>
  </teleport>
</template>
