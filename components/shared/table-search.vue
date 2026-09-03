<script setup lang="ts">
import type { SearchDropdownItem } from '~/components/ui/search-dropdown.vue'

const emit = defineEmits<{
  (e: 'select-table', tableName: string): void
}>()

const { parsedTables, activeTab } = useSchemaStore()

const isOpen = ref(false)
const searchQuery = ref('')

const currentTables = computed(() => {
  return parsedTables.value || activeTab.value?.parsedTables || []
})

const filteredTableItems = computed<SearchDropdownItem[]>(() => {
  const query = searchQuery.value.trim().toLowerCase()
  const tables = currentTables.value

  if (!query) {
    return tables.map(t => ({
      id: t.name,
      label: t.name,
      sublabel: `${t.columns?.length || 0} columns`,
      count: t.columns?.length || 0,
    }))
  }

  return tables
    .filter(t => {
      const nameMatch = t.name.toLowerCase().includes(query)
      const columnMatch = t.columns?.some(c => c.name.toLowerCase().includes(query))
      return nameMatch || columnMatch
    })
    .map(t => {
      const colMatch = t.columns?.find(c => c.name.toLowerCase().includes(query))
      const matchNote =
        colMatch && !t.name.toLowerCase().includes(query)
          ? `matches col "${colMatch.name}"`
          : `${t.columns?.length || 0} columns`

      return {
        id: t.name,
        label: t.name,
        sublabel: matchNote,
        count: t.columns?.length || 0,
      }
    })
})

function handleSelectTable(item: SearchDropdownItem) {
  emit('select-table', item.id)
  if (typeof window !== 'undefined') {
    window.dispatchEvent(
      new CustomEvent('schemacraft:focus-table', {
        detail: { tableName: item.id },
      })
    )
  }
  searchQuery.value = ''
  isOpen.value = false
}

function toggleDropdown() {
  isOpen.value = !isOpen.value
}

function handleGlobalKeydown(e: KeyboardEvent) {
  if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k') {
    e.preventDefault()
    isOpen.value = true
  }
}

function handleOpenSearchEvent() {
  isOpen.value = true
}

onMounted(() => {
  if (typeof window !== 'undefined') {
    window.addEventListener('keydown', handleGlobalKeydown)
    window.addEventListener('schemacraft:open-search', handleOpenSearchEvent)
  }
})

onBeforeUnmount(() => {
  if (typeof window !== 'undefined') {
    window.removeEventListener('keydown', handleGlobalKeydown)
    window.removeEventListener('schemacraft:open-search', handleOpenSearchEvent)
  }
})
</script>

<template>
  <ui-search-dropdown
    v-model="searchQuery"
    v-model:is-open="isOpen"
    :items="filteredTableItems"
    placeholder="Find table in diagram..."
    empty-text="No matching tables in current schema"
    @select="handleSelectTable"
    @close="searchQuery = ''"
  >
    <template #trigger>
      <button
        type="button"
        title="Find Table in Diagram (⌘K / Ctrl+K)"
        class="w-6 h-6 sm:w-7 sm:h-7 flex items-center justify-center rounded-lg hover:bg-white/10 text-[var(--text-primary)] transition-colors cursor-pointer"
        :class="{ 'bg-blue-600/20 text-blue-400 border border-blue-500/30': isOpen }"
        @click="toggleDropdown"
      >
        <tools-icon dir="editor" icon="search" width="14" height="14" />
      </button>
    </template>
  </ui-search-dropdown>
</template>
