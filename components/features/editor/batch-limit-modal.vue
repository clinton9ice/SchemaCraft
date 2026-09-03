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
        <!-- iOS Style Frosted Glass Dialog -->
        <div
          class="w-full max-w-md overflow-hidden rounded-[28px] border border-white/15 bg-neutral-900/90 shadow-2xl backdrop-blur-2xl text-neutral-100 transition-all p-6 text-center"
        >
          <!-- Soft Badge -->
          <div
            class="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-2xl bg-indigo-500/15 text-indigo-400 border border-indigo-500/20"
          >
            <tools-icon
              dir="editor"
              icon="files"
              width="28"
              height="28"
              svg-class="text-indigo-400"
            />
          </div>

          <!-- Dialog Header -->
          <h3 class="text-lg font-semibold tracking-tight text-white mb-2">
            Maximum 3 Files Allowed
          </h3>

          <!-- Dialog Body Copy -->
          <p class="text-sm leading-relaxed text-neutral-300/90 mb-5 font-normal px-2">
            You selected
            <span class="font-semibold text-white">{{ attemptedBatchCount }}</span> files. The
            visual editor only allows uploading up to 3 files at a time to ensure optimal
            performance.
          </p>

          <!-- Pill Notice -->
          <div
            class="mb-6 inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/5 px-4 py-1 text-xs text-neutral-400"
          >
            <span>Please select between 1 and 3 files per upload</span>
          </div>

          <!-- iOS Dialog Button Actions -->
          <button
            type="button"
            class="w-full rounded-xl bg-blue-600 px-4 py-3 text-sm font-semibold text-white shadow-lg shadow-blue-600/25 transition-all hover:bg-blue-500 active:scale-[0.98] cursor-pointer"
            @click="handleDismiss"
          >
            Got It
          </button>
        </div>
      </div>
    </transition>
  </teleport>
</template>
