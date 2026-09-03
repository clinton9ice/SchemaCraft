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
        v-if="isUploadModalOpen"
        class="fixed inset-0 z-50 flex items-center justify-center p-4 select-none bg-black/60 backdrop-blur-sm"
        @click.self="stage === 'completed' || stage === 'idle' ? handleCloseModal() : null"
      >
        <div
          class="relative w-full max-w-md overflow-hidden rounded-2xl border border-neutral-800 bg-neutral-900 shadow-2xl text-neutral-100 p-6 select-none transition-all"
        >
          <button
            v-if="stage === 'completed' || stage === 'idle'"
            type="button"
            class="absolute top-4 right-4 h-7 w-7 rounded-lg flex items-center justify-center text-neutral-400 hover:text-white hover:bg-neutral-800 transition-colors cursor-pointer"
            title="Close"
            @click="handleCloseModal"
          >
            <tools-icon dir="editor" icon="close" width="12" height="12" />
          </button>

          <div class="mb-5">
            <div class="flex items-center gap-2 mb-2">
              <span
                class="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-md bg-neutral-800 border border-neutral-700/60 text-[11px] font-mono text-neutral-300"
              >
                <span
                  v-if="stage !== 'completed'"
                  class="w-1.5 h-1.5 rounded-full bg-blue-400 animate-pulse"
                />
                <span>File {{ currentQueueIndex + 1 }} of {{ totalFilesCount }}</span>
                <span class="text-neutral-500">•</span>
                <span class="truncate max-w-[170px] text-neutral-200">
                  {{ currentItem?.file?.name || 'schema.sql' }}
                </span>
              </span>
            </div>

            <h3 class="text-base font-semibold text-white tracking-tight">
              {{
                stage === 'dialect_prompt'
                  ? 'Convert MySQL to PostgreSQL?'
                  : stage === 'completed'
                    ? 'Ready to Visualize'
                    : 'Processing Schema'
              }}
            </h3>
          </div>

          <div class="space-y-1.5 mb-5">
            <div class="flex items-center justify-between text-xs">
              <span class="text-neutral-300 font-normal truncate pr-2">{{ statusMessage }}</span>
              <span class="font-mono text-neutral-400 shrink-0">{{ uploadProgress }}%</span>
            </div>

            <div class="h-1.5 w-full overflow-hidden rounded-full bg-neutral-800">
              <div
                class="h-full rounded-full bg-blue-600 transition-all duration-200 ease-out"
                :style="{ width: `${uploadProgress}%` }"
              />
            </div>
          </div>

          <div
            v-if="stage === 'dialect_prompt'"
            class="mb-5 rounded-xl border border-neutral-700/70 bg-neutral-800/50 p-4 text-left transition-all space-y-3"
          >
            <div class="space-y-1.5 text-xs">
              <p class="text-neutral-200 leading-relaxed font-normal">
                This file has MySQL-specific syntax (like backticks or MySQL types) that PostgreSQL
                won't parse directly. We can convert it for you so your diagram displays without
                errors.
              </p>

              <div v-if="detectedReasons.length > 0" class="flex flex-wrap gap-1.5 pt-1">
                <span
                  v-for="(reason, idx) in detectedReasons.slice(0, 3)"
                  :key="idx"
                  class="px-2 py-0.5 rounded-md bg-neutral-800 border border-neutral-700 text-neutral-300 font-mono text-[10px]"
                >
                  {{ reason }}
                </span>
              </div>
            </div>

            <div class="pt-1 flex items-center justify-end gap-2">
              <button
                type="button"
                class="px-3 py-1.5 rounded-lg bg-neutral-800 hover:bg-neutral-700 text-neutral-300 text-xs font-medium border border-neutral-700/70 transition-colors cursor-pointer"
                @click="handleUserDecline"
              >
                Skip file
              </button>
              <button
                type="button"
                class="px-3.5 py-1.5 rounded-lg bg-blue-600 hover:bg-blue-500 text-white text-xs font-medium transition-colors cursor-pointer flex items-center gap-1.5"
                @click="handleUserProceed"
              >
                <tools-icon dir="editor" icon="sparkles" width="12" height="12" />
                <span>Convert to PostgreSQL</span>
              </button>
            </div>
          </div>

          <div v-if="stage === 'completed'" class="space-y-3 pt-1">
            <div class="text-xs text-neutral-400">
              <span v-if="transformedCount > 0" class="text-neutral-300">
                {{ transformedCount }} file(s) converted to PostgreSQL DDL.
              </span>
              <span v-else> {{ completedSchemas.length }} file(s) ready to open. </span>
            </div>

            <button
              type="button"
              class="w-full py-2.5 rounded-lg bg-blue-600 hover:bg-blue-500 text-white font-medium text-xs transition-colors cursor-pointer flex items-center justify-center gap-2"
              @click="handleVisualise"
            >
              <tools-icon dir="editor" icon="check" width="14" height="14" />
              <span>Open in Workspace</span>
            </button>
          </div>
        </div>
      </div>
    </transition>
  </teleport>
</template>
