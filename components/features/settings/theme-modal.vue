<script setup lang="ts">
import { THEME_LIST, type ThemeId } from '~/composables/use-theme-engine'

const { currentTheme, showThemeModal, activeThemeDef, setTheme } = useThemeEngine()

const selectedCategory = ref<'dark' | 'light'>('dark')

// Filter themes by category
const darkThemes = computed(() => THEME_LIST.filter((t) => t.category === 'dark'))
const lightThemes = computed(() => THEME_LIST.filter((t) => t.category === 'light'))

function selectTheme(themeId: ThemeId) {
  setTheme(themeId)
}
</script>

<template>
  <Teleport to="body">
    <div
      v-if="showThemeModal"
      class="fixed inset-0 z-50 bg-black/70 backdrop-blur-xs flex items-center justify-center p-4 select-none"
      @click.self="showThemeModal = false"
    >
      <div
        class="w-full max-w-xl bg-[var(--header-bg)] border border-[var(--node-border)] rounded-2xl shadow-2xl overflow-hidden flex flex-col max-h-[85vh] animate-in zoom-in-95 duration-150 text-[var(--text-primary)]"
      >
        <!-- Modal Header -->
        <div class="h-14 border-b border-[var(--node-border)] px-5 flex items-center justify-between">
          <div class="flex items-center gap-2.5">
            <div class="w-8 h-8 rounded-lg bg-gradient-to-tr from-pink-500 to-indigo-500 flex items-center justify-center text-white">
              <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="4" />
                <path d="M12 2v2" />
                <path d="M12 20v2" />
                <path d="m4.93 4.93 1.41 1.41" />
                <path d="m17.66 17.66 1.41 1.41" />
                <path d="M2 12h2" />
                <path d="M20 12h2" />
                <path d="m6.34 17.66-1.41 1.41" />
                <path d="m19.07 4.93-1.41 1.41" />
              </svg>
            </div>
            <div>
              <span class="font-bold text-sm block">Theme Settings</span>
              <span class="text-[11px] text-[var(--text-muted)] font-mono">Monaco Editor & UI Color Suite</span>
            </div>
          </div>

          <button
            type="button"
            @click="showThemeModal = false"
            class="w-7 h-7 flex items-center justify-center text-[var(--text-muted)] hover:text-[var(--text-primary)] hover:bg-white/10 rounded-lg transition-colors cursor-pointer"
          >
            ✕
          </button>
        </div>

        <!-- Category Selector (Dark Suite vs Light) -->
        <div class="px-5 pt-4 pb-2 border-b border-[var(--node-border)] flex items-center gap-2 bg-[var(--tab-bar-bg)]">
          <button
            type="button"
            @click="selectedCategory = 'dark'"
            class="px-4 py-1.5 text-xs font-semibold rounded-lg flex items-center gap-2 transition-colors cursor-pointer"
            :class="[
              selectedCategory === 'dark'
                ? 'bg-blue-600 text-white shadow-md'
                : 'bg-white/5 text-[var(--text-muted)] hover:text-white hover:bg-white/10',
            ]"
          >
            <svg class="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z" />
            </svg>
            <span>Dark Theme Suite (4)</span>
          </button>

          <button
            type="button"
            @click="selectedCategory = 'light'"
            class="px-4 py-1.5 text-xs font-semibold rounded-lg flex items-center gap-2 transition-colors cursor-pointer"
            :class="[
              selectedCategory === 'light'
                ? 'bg-blue-600 text-white shadow-md'
                : 'bg-white/5 text-[var(--text-muted)] hover:text-white hover:bg-white/10',
            ]"
          >
            <svg class="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="12" cy="12" r="5" />
              <line x1="12" y1="1" x2="12" y2="3" />
              <line x1="12" y1="21" x2="12" y2="23" />
              <line x1="4.22" y1="4.22" x2="5.64" y2="5.64" />
              <line x1="18.36" y1="18.36" x2="19.78" y2="19.78" />
              <line x1="1" y1="12" x2="3" y2="12" />
              <line x1="21" y1="12" x2="23" y2="12" />
            </svg>
            <span>Light Theme (1)</span>
          </button>
        </div>

        <!-- Theme Grid Choices -->
        <div class="p-5 overflow-y-auto space-y-4 max-h-[60vh]">
          <!-- Dark Theme Options -->
          <div v-if="selectedCategory === 'dark'" class="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
            <div
              v-for="theme in darkThemes"
              :key="theme.id"
              class="relative rounded-xl border p-4 transition-all duration-150 cursor-pointer flex flex-col justify-between group hover:scale-[1.01]"
              :style="{ backgroundColor: theme.bgPreview }"
              :class="[
                currentTheme === theme.id
                  ? 'border-blue-500 ring-2 ring-blue-500/40 shadow-xl'
                  : 'border-[var(--node-border)] hover:border-white/40',
              ]"
              @click="selectTheme(theme.id)"
            >
              <!-- Card Header -->
              <div>
                <div class="flex items-center justify-between mb-1.5">
                  <span class="font-bold text-sm text-white flex items-center gap-2">
                    {{ theme.name }}
                    <span
                      v-if="theme.id === 'monokai'"
                      class="px-1.5 py-0.2 rounded text-[9px] font-mono font-bold bg-pink-500/20 text-pink-400 border border-pink-500/40 uppercase"
                    >
                      Classic
                    </span>
                  </span>

                  <!-- Active Checkmark Indicator -->
                  <span
                    v-if="currentTheme === theme.id"
                    class="w-5 h-5 rounded-full bg-blue-500 text-white flex items-center justify-center text-[10px] font-bold shadow-md"
                  >
                    ✓
                  </span>
                </div>

                <p class="text-[11px] text-neutral-300/80 leading-snug mb-3">
                  {{ theme.description }}
                </p>
              </div>

              <!-- Color Palette Swatches Preview -->
              <div class="flex items-center gap-1.5 pt-2 border-t border-white/10">
                <span class="w-4 h-4 rounded-full border border-black/40" :style="{ backgroundColor: theme.accentColor }" :title="`Accent: ${theme.accentColor}`" />
                <span v-if="theme.id === 'monokai'" class="flex items-center gap-1">
                  <span class="w-3.5 h-3.5 rounded-full bg-[#f92672]" title="Pink" />
                  <span class="w-3.5 h-3.5 rounded-full bg-[#e6db74]" title="Yellow" />
                  <span class="w-3.5 h-3.5 rounded-full bg-[#a6e22e]" title="Green" />
                  <span class="w-3.5 h-3.5 rounded-full bg-[#66d9ef]" title="Cyan" />
                </span>
                <span v-else-if="theme.id === 'dracula'" class="flex items-center gap-1">
                  <span class="w-3.5 h-3.5 rounded-full bg-[#ff79c6]" />
                  <span class="w-3.5 h-3.5 rounded-full bg-[#50fa7b]" />
                  <span class="w-3.5 h-3.5 rounded-full bg-[#8be9fd]" />
                </span>
                <span v-else class="flex items-center gap-1">
                  <span class="w-3.5 h-3.5 rounded-full bg-[#38bdf8]" />
                  <span class="w-3.5 h-3.5 rounded-full bg-[#818cf8]" />
                </span>
              </div>
            </div>
          </div>

          <!-- Light Theme Options -->
          <div v-else class="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
            <div
              v-for="theme in lightThemes"
              :key="theme.id"
              class="relative rounded-xl border p-4 transition-all duration-150 cursor-pointer flex flex-col justify-between group hover:scale-[1.01] bg-white text-neutral-900"
              :class="[
                currentTheme === theme.id
                  ? 'border-blue-600 ring-2 ring-blue-500/40 shadow-xl'
                  : 'border-neutral-300 hover:border-neutral-400',
              ]"
              @click="selectTheme(theme.id)"
            >
              <div>
                <div class="flex items-center justify-between mb-1.5">
                  <span class="font-bold text-sm text-neutral-900">{{ theme.name }}</span>
                  <span
                    v-if="currentTheme === theme.id"
                    class="w-5 h-5 rounded-full bg-blue-600 text-white flex items-center justify-center text-[10px] font-bold shadow-md"
                  >
                    ✓
                  </span>
                </div>
                <p class="text-[11px] text-neutral-600 leading-snug mb-3">
                  {{ theme.description }}
                </p>
              </div>

              <div class="flex items-center gap-1.5 pt-2 border-t border-neutral-200">
                <span class="w-4 h-4 rounded-full bg-blue-600" />
                <span class="w-3.5 h-3.5 rounded-full bg-slate-700" />
                <span class="w-3.5 h-3.5 rounded-full bg-slate-400" />
              </div>
            </div>
          </div>
        </div>

        <!-- Modal Footer -->
        <div class="h-12 border-t border-[var(--node-border)] px-5 flex items-center justify-between bg-[var(--tab-bar-bg)]">
          <span class="text-[11px] text-[var(--text-muted)] font-mono">
            Active Theme: <span class="text-[var(--text-primary)] font-bold">{{ activeThemeDef?.name || 'Midnight Slate' }}</span>
          </span>
          <button
            type="button"
            @click="showThemeModal = false"
            class="px-4 py-1.5 bg-blue-600 hover:bg-blue-500 text-white text-xs font-semibold rounded-lg shadow-sm transition-colors cursor-pointer"
          >
            Apply & Close
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>
