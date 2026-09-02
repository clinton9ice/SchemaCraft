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
        <!-- iOS Style Frosted Glass Dialog -->
        <div
          class="w-full max-w-md overflow-hidden rounded-[28px] border border-white/15 bg-neutral-900/90 shadow-2xl backdrop-blur-2xl text-neutral-100 transition-all p-6 text-center"
        >
          <!-- Soft Warning Badge -->
          <div
            class="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-2xl bg-rose-500/15 text-rose-400 border border-rose-500/20"
          >
            <svg
              class="h-7 w-7"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
            >
              <path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z" />
              <polyline points="14 2 14 8 20 8" />
              <line x1="12" y1="18" x2="12" y2="12" />
              <line x1="12" y1="9" x2="12.01" y2="9" />
            </svg>
          </div>

          <!-- Dialog Header -->
          <h3 class="text-lg font-semibold tracking-tight text-white mb-2">
            File Exceeds 1MB Limit
          </h3>

          <!-- Dialog Body Copy -->
          <p class="text-sm leading-relaxed text-neutral-300/90 mb-5 font-normal px-1">
            This board can only accept files less than or equal to 1MB in size. Please consider
            splitting your queries for easy execution.
          </p>

          <!-- Oversized File Details Pill -->
          <div
            v-if="oversizedFileName"
            class="mb-6 flex items-center justify-between gap-3 rounded-xl border border-white/10 bg-white/5 px-4 py-2.5 text-xs text-neutral-300"
          >
            <div class="flex items-center gap-2 truncate text-left">
              <span class="text-neutral-400">📄</span>
              <span class="truncate font-mono text-neutral-200">{{ oversizedFileName }}</span>
            </div>
            <span
              class="shrink-0 rounded bg-rose-500/20 px-2 py-0.5 font-mono text-[11px] font-medium text-rose-300"
            >
              {{ formatFileSize(oversizedFileSize) }}
            </span>
          </div>

          <!-- iOS Dialog Button Actions -->
          <div class="grid grid-cols-2 gap-3">
            <button
              type="button"
              class="w-full rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-sm font-medium text-neutral-300 transition-all hover:bg-white/10 hover:text-white active:scale-[0.98] cursor-pointer"
              @click="handleDismiss"
            >
              Dismiss
            </button>

            <button
              type="button"
              class="w-full rounded-xl bg-blue-600 px-4 py-3 text-sm font-semibold text-white shadow-lg shadow-blue-600/25 transition-all hover:bg-blue-500 active:scale-[0.98] cursor-pointer"
              @click="handleReupload"
            >
              Reupload
            </button>
          </div>
        </div>
      </div>
    </transition>
  </teleport>
</template>
