<script setup lang="ts">
const { isBatchLimitModalOpen, attemptedBatchCount } = useUploadGuard()

function handleDismiss() {
  isBatchLimitModalOpen.value = false
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
        v-if="isBatchLimitModalOpen"
        class="fixed inset-0 z-50 flex items-center justify-center p-4 select-none bg-black/60 backdrop-blur-md"
        @click.self="handleDismiss"
      >
        <div
          class="w-full max-w-md overflow-hidden rounded-2xl border border-neutral-800 bg-neutral-900 shadow-2xl text-neutral-100 transition-all p-6 text-center"
        >
          <div
            class="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-neutral-800 text-neutral-300 border border-neutral-700/60"
          >
            <tools-icon
              dir="editor"
              icon="files"
              width="24"
              height="24"
              svg-class="text-neutral-300"
            />
          </div>

          <h3 class="text-base font-semibold tracking-tight text-white mb-1.5">
            Too Many Files Selected
          </h3>

          <p class="text-xs leading-relaxed text-neutral-400 mb-5 font-normal px-2">
            You picked <span class="font-medium text-white">{{ attemptedBatchCount }}</span> files.
            You can upload up to 3 files at once.
          </p>

          <button
            type="button"
            class="w-full rounded-lg bg-blue-600 px-3 py-2 text-xs font-medium text-white transition-colors hover:bg-blue-500 cursor-pointer"
            @click="handleDismiss"
          >
            Okay, got it
          </button>
        </div>
      </div>
    </transition>
  </teleport>
</template>
