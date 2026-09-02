<script setup lang="ts">
const { tabs, activeTabId, addNewTab, closeTab, switchTab, renameTab } = useSchemaStore()

const editingTabId = ref<string | null>(null)
const editingTitle = ref('')
const editInputRef = ref<HTMLInputElement | null>(null)

function startRenaming(tab: { id: string; title: string }) {
  editingTabId.value = tab.id
  editingTitle.value = tab.title
  nextTick(() => {
    editInputRef.value?.focus()
    editInputRef.value?.select()
  })
}

function finishRenaming(tabId: string) {
  if (editingTabId.value === tabId && editingTitle.value.trim()) {
    let finalTitle = editingTitle.value.trim()
    if (!finalTitle.includes('.')) {
      finalTitle += '.sql'
    }
    renameTab(tabId, finalTitle)
  }
  editingTabId.value = null
  editingTitle.value = ''
}

function cancelRenaming() {
  editingTabId.value = null
  editingTitle.value = ''
}
</script>

<template>
  <div
    class="h-9 bg-[var(--tab-bar-bg)] border-b border-[var(--node-border)] flex items-center justify-between select-none overflow-hidden shrink-0 transition-colors duration-150"
  >
    <!-- Tabs Scroll Area -->
    <div class="flex items-center h-full overflow-x-auto no-scrollbar min-w-0 flex-1">
      <div
        v-for="tab in tabs"
        :key="tab.id"
        class="group relative h-full flex items-center gap-2 px-3 border-r border-[var(--node-border)] border-t-2 text-xs font-mono transition-colors cursor-pointer shrink-0 max-w-[200px]"
        :class="[
          activeTabId === tab.id
            ? 'bg-[var(--tab-active-bg)] text-[var(--text-primary)] font-medium shadow-inner'
            : 'bg-[var(--tab-bar-bg)] text-[var(--text-muted)] hover:bg-white/5 hover:text-white',
        ]"
        :style="{
          borderTopColor: activeTabId === tab.id ? 'var(--tab-active-accent)' : 'transparent',
        }"
        @click="switchTab(tab.id)"
        @dblclick="startRenaming(tab)"
      >
        <!-- File Icon / Language Badge -->
        <span
          class="shrink-0 text-[10px] font-sans font-bold px-1 py-0.2 rounded"
          :class="[
            tab.language === 'prisma'
              ? 'bg-emerald-500/20 text-emerald-300'
              : tab.language === 'dbml'
              ? 'bg-amber-500/20 text-amber-300'
              : tab.language === 'drizzle'
              ? 'bg-cyan-500/20 text-cyan-300'
              : tab.language === 'typeorm'
              ? 'bg-purple-500/20 text-purple-300'
              : 'bg-blue-500/20 text-blue-300',
          ]"
        >
          {{
            tab.language === 'prisma'
              ? 'PRISMA'
              : tab.language === 'dbml'
              ? 'DBML'
              : tab.language === 'drizzle'
              ? 'DRIZZLE'
              : tab.language === 'typeorm'
              ? 'TYPEORM'
              : 'SQL'
          }}
        </span>

        <!-- Tab Title (or Inline Rename Input) -->
        <div v-if="editingTabId === tab.id" class="min-w-0 flex-1">
          <input
            ref="editInputRef"
            v-model="editingTitle"
            type="text"
            class="w-full bg-[var(--app-bg)] text-[var(--text-primary)] px-1.5 py-0.5 rounded text-xs outline-none border border-[var(--accent)] font-mono"
            @blur="finishRenaming(tab.id)"
            @keydown.enter="finishRenaming(tab.id)"
            @keydown.esc="cancelRenaming"
            @click.stop
          />
        </div>
        <span
          v-else
          class="truncate min-w-0 flex-1"
          :title="tab.title + ' (Double click to rename)'"
        >
          {{ tab.title }}
        </span>

        <!-- Dirty Indicator (when modified) or Close Button -->
        <div class="flex items-center shrink-0 w-4 h-4 justify-center">
          <!-- Dirty dot (shows if modified and not hovered) -->
          <span
            v-if="tab.sqlCode !== tab.lastSavedCode"
            class="w-2 h-2 rounded-full bg-amber-400 group-hover:hidden"
            title="Unsaved changes"
          />

          <!-- Close Tab Button (X) -->
          <button
            type="button"
            class="w-4 h-4 rounded flex items-center justify-center text-[var(--text-muted)] hover:text-white hover:bg-white/10 transition-colors"
            :class="[
              tab.sqlCode !== tab.lastSavedCode
                ? 'hidden group-hover:flex'
                : 'opacity-0 group-hover:opacity-100',
            ]"
            title="Close tab"
            @click.stop="closeTab(tab.id)"
          >
            <svg class="w-3 h-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
              <line x1="18" y1="6" x2="6" y2="18" />
              <line x1="6" y1="6" x2="18" y2="18" />
            </svg>
          </button>
        </div>
      </div>
    </div>

    <!-- Add New Tab Button with Language Selection Dropdown -->
    <div class="px-2 flex items-center gap-1 shrink-0 relative new-tab-container">
      <UTooltip text="Add New Tab (SQL / DBML / Prisma)" :popper="{ placement: 'bottom' }">
        <button
          type="button"
          class="w-6 h-6 rounded flex items-center justify-center text-[var(--text-muted)] hover:text-white hover:bg-white/10 transition-colors cursor-pointer"
          @click="addNewTab()"
        >
          <svg class="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <line x1="12" y1="5" x2="12" y2="19" />
            <line x1="5" y1="12" x2="19" y2="12" />
          </svg>
        </button>
      </UTooltip>
    </div>
  </div>
</template>
