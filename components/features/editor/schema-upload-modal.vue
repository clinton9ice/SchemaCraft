<script setup lang="ts">
import { useSchemaUploader } from '~/composables/use-schema-uploader'

const {
  isUploadModalOpen,
  currentItem,
  currentQueueIndex,
  totalFilesCount,
  uploadProgress,
  statusMessage,
  stage,
  detectedReasons,
  transformedCount,
  completedSchemas,
  handleUserProceed,
  handleUserDecline,
  handleVisualise,
  handleCloseModal,
} = useSchemaUploader()
</script>

<template>
  <u-modal
    v-model="isUploadModalOpen"
    :ui="{
      wrapper: 'z-50',
      inner: 'inset-0 flex items-center justify-center p-4',
      container: 'w-full max-w-md',
      base: 'overflow-hidden',
      background: 'bg-transparent',
      shadow: 'shadow-2xl',
    }"
    :prevent-close="stage !== 'completed' && stage !== 'idle'"
  >
    <div
      class="relative overflow-hidden rounded-3xl border border-white/10 bg-neutral-900/90 p-6 sm:p-7 backdrop-blur-2xl shadow-2xl text-white select-none transition-all"
    >
      <!-- Subtle top decorative ambient light -->
      <div
        class="absolute -top-24 left-1/2 -translate-x-1/2 w-60 h-24 bg-sky-500/20 rounded-full blur-3xl pointer-events-none"
      />

      <!-- Close button (available when completed or idle) -->
      <button
        v-if="stage === 'completed' || stage === 'idle'"
        type="button"
        class="absolute top-4 right-4 h-8 w-8 rounded-full flex items-center justify-center text-neutral-400 hover:text-white hover:bg-white/10 transition-colors cursor-pointer"
        @click="handleCloseModal"
      >
        <tools-icon dir="editor" icon="close" width="14" height="14" />
      </button>

      <!-- Badge Icon based on Stage -->
      <div
        class="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-2xl transition-all"
      >
        <template v-if="stage === 'reading' || stage === 'analyzing'">
          <div
            class="flex h-14 w-14 items-center justify-center rounded-2xl bg-sky-500/15 border border-sky-500/20 text-sky-400 animate-pulse"
          >
            <tools-icon
              dir="editor"
              icon="upload"
              width="28"
              height="28"
              svg-class="text-sky-400"
            />
          </div>
        </template>

        <template v-else-if="stage === 'dialect_prompt'">
          <div
            class="flex h-14 w-14 items-center justify-center rounded-2xl bg-amber-500/15 border border-amber-500/20 text-amber-400"
          >
            <tools-icon
              dir="editor"
              icon="sparkles"
              width="28"
              height="28"
              svg-class="text-amber-400"
            />
          </div>
        </template>

        <template v-else-if="stage === 'transforming'">
          <div
            class="flex h-14 w-14 items-center justify-center rounded-2xl bg-indigo-500/15 border border-indigo-500/20 text-indigo-400"
          >
            <tools-icon
              dir="editor"
              icon="loading"
              width="28"
              height="28"
              svg-class="text-indigo-400 animate-spin"
            />
          </div>
        </template>

        <template v-else-if="stage === 'completed'">
          <div
            class="flex h-14 w-14 items-center justify-center rounded-2xl bg-emerald-500/15 border border-emerald-500/20 text-emerald-400"
          >
            <tools-icon
              dir="editor"
              icon="check"
              width="28"
              height="28"
              svg-class="text-emerald-400"
            />
          </div>
        </template>
      </div>

      <!-- Queue Header Indicator -->
      <div class="text-center mb-5">
        <div
          class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-white/5 border border-white/10 text-xs text-neutral-400 mb-2"
        >
          <span
            v-if="stage !== 'completed'"
            class="w-1.5 h-1.5 rounded-full bg-sky-400 animate-ping"
          />
          <span class="font-medium text-neutral-300"
            >File {{ currentQueueIndex + 1 }} of {{ totalFilesCount }}</span
          >
          <span class="text-neutral-500">•</span>
          <span class="truncate max-w-[180px] text-white font-mono">{{
            currentItem?.file?.name || 'Schema File'
          }}</span>
        </div>

        <h3 class="text-lg font-semibold tracking-tight text-white">
          {{
            stage === 'dialect_prompt'
              ? 'Convert MySQL Schema?'
              : stage === 'completed'
                ? 'Processing Complete'
                : 'Processing Schema'
          }}
        </h3>
      </div>

      <!-- Progress Track & Percentage -->
      <div class="space-y-1.5 mb-5">
        <div class="flex items-center justify-between text-xs text-neutral-400">
          <span class="font-medium truncate pr-2 text-neutral-300">{{ statusMessage }}</span>
          <span class="font-mono text-neutral-400 shrink-0">{{ uploadProgress }}%</span>
        </div>
        <div class="h-2 w-full overflow-hidden rounded-full bg-white/10">
          <div
            class="h-full rounded-full bg-gradient-to-r from-sky-500 via-indigo-500 to-emerald-400 transition-all duration-300 ease-out"
            :style="{ width: `${uploadProgress}%` }"
          />
        </div>
      </div>

      <!-- Dialect Prompt Card (Option B: Per-File Decision) -->
      <div
        v-if="stage === 'dialect_prompt'"
        class="mb-6 rounded-2xl border border-amber-500/20 bg-amber-500/5 p-4 text-left transition-all"
      >
        <div class="flex items-start gap-2.5">
          <tools-icon
            dir="editor"
            icon="alert"
            width="18"
            height="18"
            svg-class="text-amber-400 shrink-0 mt-0.5"
          />
          <div class="space-y-2 text-xs">
            <p class="text-neutral-200 leading-relaxed">
              This file contains MySQL / MariaDB syntax which is not directly compatible with the
              PostgreSQL diagram engine.
            </p>
            <div v-if="detectedReasons.length > 0" class="flex flex-wrap gap-1.5 pt-1">
              <span
                v-for="(reason, idx) in detectedReasons.slice(0, 3)"
                :key="idx"
                class="px-2 py-0.5 rounded-md bg-amber-500/10 border border-amber-500/20 text-amber-300 font-mono text-[10px]"
              >
                {{ reason }}
              </span>
            </div>
            <p class="text-neutral-400 text-[11px]">
              Would you like to automatically transform it to clean PostgreSQL DDL?
            </p>
          </div>
        </div>

        <!-- Decision Buttons -->
        <div class="mt-4 flex items-center justify-end gap-2.5">
          <button
            type="button"
            class="px-3.5 py-2 rounded-xl bg-white/5 hover:bg-white/10 text-neutral-300 text-xs font-medium border border-white/10 transition-colors cursor-pointer active:scale-95"
            @click="handleUserDecline"
          >
            Decline
          </button>
          <button
            type="button"
            class="px-4 py-2 rounded-xl bg-gradient-to-r from-sky-500 to-indigo-600 hover:from-sky-400 hover:to-indigo-500 text-white text-xs font-semibold shadow-md shadow-sky-500/20 transition-all cursor-pointer active:scale-95 flex items-center gap-1.5"
            @click="handleUserProceed"
          >
            <tools-icon dir="editor" icon="sparkles" width="13" height="13" />
            <span>Proceed</span>
          </button>
        </div>
      </div>

      <!-- Completed State Actions -->
      <div v-if="stage === 'completed'" class="space-y-3 pt-2">
        <div class="text-center text-xs text-neutral-400">
          <span v-if="transformedCount > 0" class="text-sky-300 font-medium">
            {{ transformedCount }} file(s) converted to PostgreSQL DDL.
          </span>
          <span v-else> {{ completedSchemas.length }} file(s) ready to render. </span>
        </div>

        <button
          type="button"
          class="w-full py-3 rounded-2xl bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-400 hover:to-teal-500 text-white font-semibold text-sm shadow-lg shadow-emerald-500/20 transition-all cursor-pointer active:scale-[0.98] flex items-center justify-center gap-2"
          @click="handleVisualise"
        >
          <tools-icon dir="editor" icon="check" width="16" height="16" />
          <span>Visualise</span>
        </button>
      </div>
    </div>
  </u-modal>
</template>
