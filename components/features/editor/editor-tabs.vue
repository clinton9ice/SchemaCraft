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

        <div class="flex items-center shrink-0 w-4 h-4 justify-center">
          <span
            v-if="tab.sqlCode !== tab.lastSavedCode"
            class="w-2 h-2 rounded-full bg-amber-400 group-hover:hidden"
            title="Unsaved changes"
          />

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
            <tools-icon dir="editor" icon="close" width="12" height="12" />
          </button>
        </div>
      </div>
    </div>

    <div class="px-2 flex items-center gap-1.5 shrink-0 relative new-tab-container">
      <span
        v-if="tabs.length >= 8"
        class="text-[10px] font-mono px-1.5 py-0.5 rounded"
        :class="
          tabs.length >= 10
            ? 'bg-amber-500/20 text-amber-300 font-semibold'
            : 'text-neutral-400 bg-white/5'
        "
        :title="`${tabs.length} of 10 maximum tabs open`"
      >
        {{ tabs.length }}/10
      </span>
      <u-tooltip
        :text="
          tabs.length >= 10 ? 'Tab limit reached (10/10)' : 'Add New Tab (SQL / DBML / Prisma)'
        "
        :popper="{ placement: 'bottom' }"
      >
        <button
          type="button"
          class="w-6 h-6 rounded flex items-center justify-center text-[var(--text-muted)] hover:text-white hover:bg-white/10 transition-colors cursor-pointer"
          @click="addNewTab()"
        >
          <tools-icon dir="editor" icon="plus" width="14" height="14" />
        </button>
      </u-tooltip>
    </div>
  </div>
</template>
