<script setup lang="ts">
export interface SearchDropdownItem {
  id: string
  label: string
  sublabel?: string
  badge?: string
  count?: number
}

const props = withDefaults(
  defineProps<{
    modelValue?: string
    items?: SearchDropdownItem[]
    isOpen?: boolean
    placeholder?: string
    emptyText?: string
    autoFocus?: boolean
  }>(),
  {
    modelValue: '',
    items: () => [],
    isOpen: false,
    placeholder: 'Search tables...',
    emptyText: 'No matching tables found',
    autoFocus: true,
  }
)

const emit = defineEmits<{
  (e: 'update:modelValue', val: string): void
  (e: 'update:isOpen', val: boolean): void
  (e: 'select', item: SearchDropdownItem): void
  (e: 'close'): void
}>()

const inputRef = ref<HTMLInputElement | null>(null)
const focusedIndex = ref(0)
const dropdownRef = ref<HTMLElement | null>(null)

// Focus input when opened
watch(
  () => props.isOpen,
  open => {
    if (open) {
      focusedIndex.value = 0
      nextTick(() => {
        if (props.autoFocus && inputRef.value) {
          inputRef.value.focus()
        }
      })
    }
  }
)

// Reset focused index on item change
watch(
  () => props.items,
  () => {
    focusedIndex.value = 0
  }
)

function handleInput(e: Event) {
  const target = e.target as HTMLInputElement
  emit('update:modelValue', target.value)
}

function handleClear() {
  emit('update:modelValue', '')
  if (inputRef.value) {
    inputRef.value.focus()
  }
}

function handleSelect(item: SearchDropdownItem) {
  emit('select', item)
  emit('update:isOpen', false)
}

function handleKeyDown(e: KeyboardEvent) {
  if (!props.isOpen) return

  if (e.key === 'ArrowDown') {
    e.preventDefault()
    if (props.items.length > 0) {
      focusedIndex.value = (focusedIndex.value + 1) % props.items.length
      scrollToFocused()
    }
  } else if (e.key === 'ArrowUp') {
    e.preventDefault()
    if (props.items.length > 0) {
      focusedIndex.value = (focusedIndex.value - 1 + props.items.length) % props.items.length
      scrollToFocused()
    }
  } else if (e.key === 'Enter') {
    e.preventDefault()
    if (props.items.length > 0 && props.items[focusedIndex.value]) {
      handleSelect(props.items[focusedIndex.value])
    }
  } else if (e.key === 'Escape') {
    e.preventDefault()
    emit('update:isOpen', false)
    emit('close')
  }
}

function scrollToFocused() {
  nextTick(() => {
    const listEl = dropdownRef.value?.querySelector('[role="listbox"]')
    const itemEl = listEl?.querySelector(`[data-index="${focusedIndex.value}"]`) as HTMLElement
    if (itemEl && listEl) {
      itemEl.scrollIntoView({ block: 'nearest' })
    }
  })
}

function handleOutsideClick(e: MouseEvent) {
  if (dropdownRef.value && !dropdownRef.value.contains(e.target as Node)) {
    emit('update:isOpen', false)
    emit('close')
  }
}

onMounted(() => {
  document.addEventListener('pointerdown', handleOutsideClick)
})

onBeforeUnmount(() => {
  document.removeEventListener('pointerdown', handleOutsideClick)
})
</script>

<template>
  <div ref="dropdownRef" class="relative inline-block text-left" @keydown="handleKeyDown">
    <!-- Trigger Slot -->
    <slot name="trigger" />

    <!-- Dropdown Content Container -->
    <transition
      enter-active-class="transition duration-150 ease-out"
      enter-from-class="opacity-0 translate-y-1 scale-98"
      enter-to-class="opacity-100 translate-y-0 scale-100"
      leave-active-class="transition duration-100 ease-in"
      leave-from-class="opacity-100 translate-y-0 scale-100"
      leave-to-class="opacity-0 translate-y-1 scale-98"
    >
      <div
        v-if="isOpen"
        class="absolute right-0 top-full mt-2 w-72 sm:w-80 rounded-xl border border-[var(--node-border)] bg-[var(--header-bg)] backdrop-blur-xl shadow-2xl p-2 z-50 overflow-hidden"
        role="dialog"
        aria-label="Search Dropdown"
      >
        <!-- Search Input Bar -->
        <div
          class="relative flex items-center rounded-lg bg-[var(--app-bg)]/80 border border-[var(--node-border)] px-2.5 py-1.5 focus-within:border-blue-500 focus-within:ring-1 focus-within:ring-blue-500/30 transition-all"
        >
          <tools-icon
            dir="editor"
            icon="search"
            width="14"
            height="14"
            svg-class="text-[var(--text-muted)] shrink-0 mr-2"
          />
          <input
            ref="inputRef"
            type="text"
            role="combobox"
            aria-autocomplete="list"
            :aria-expanded="isOpen"
            :placeholder="placeholder"
            :value="modelValue"
            class="w-full bg-transparent text-xs text-[var(--text-primary)] placeholder-[var(--text-muted)] focus:outline-none font-sans"
            @input="handleInput"
          />
          <button
            v-if="modelValue"
            type="button"
            title="Clear search"
            class="p-0.5 rounded hover:bg-white/10 text-[var(--text-muted)] hover:text-[var(--text-primary)] transition-colors cursor-pointer"
            @click="handleClear"
          >
            <tools-icon dir="editor" icon="close" width="12" height="12" />
          </button>
        </div>

        <!-- Items List -->
        <ul
          role="listbox"
          aria-label="Search results"
          class="mt-2 max-h-56 overflow-y-auto overflow-x-hidden space-y-0.5 pr-0.5 custom-scrollbar"
        >
          <li
            v-for="(item, index) in items"
            :id="`search-item-${item.id}`"
            :key="item.id"
            :data-index="index"
            role="option"
            :aria-selected="focusedIndex === index"
            class="flex items-center justify-between gap-2 px-2.5 py-1.5 rounded-lg text-xs cursor-pointer transition-colors select-none"
            :class="[
              focusedIndex === index
                ? 'bg-blue-600/20 text-blue-300 border border-blue-500/30 font-medium'
                : 'text-[var(--text-primary)] hover:bg-white/5 hover:text-white border border-transparent',
            ]"
            @mouseenter="focusedIndex = index"
            @click="handleSelect(item)"
          >
            <div class="flex items-center gap-2 min-w-0">
              <div
                class="w-5 h-5 rounded-md flex items-center justify-center shrink-0"
                :class="
                  focusedIndex === index
                    ? 'bg-blue-500/20 text-blue-400'
                    : 'bg-white/5 text-[var(--text-muted)]'
                "
              >
                <tools-icon dir="editor" icon="database" width="12" height="12" />
              </div>
              <span class="truncate font-mono font-medium">{{ item.label }}</span>
            </div>

            <div class="flex items-center gap-1.5 shrink-0">
              <span
                v-if="item.sublabel"
                class="text-[10px] text-[var(--text-muted)] font-mono font-normal"
              >
                {{ item.sublabel }}
              </span>
              <span
                v-if="item.badge"
                class="px-1.5 py-0.5 rounded text-[9px] font-medium bg-blue-500/10 text-blue-400 border border-blue-500/20"
              >
                {{ item.badge }}
              </span>
            </div>
          </li>

          <!-- Empty State -->
          <li
            v-if="items.length === 0"
            class="py-5 text-center text-xs text-[var(--text-muted)] select-none font-normal"
          >
            {{ emptyText }}
          </li>
        </ul>
      </div>
    </transition>
  </div>
</template>

<style scoped>
.custom-scrollbar::-webkit-scrollbar {
  width: 4px;
}
.custom-scrollbar::-webkit-scrollbar-track {
  background: transparent;
}
.custom-scrollbar::-webkit-scrollbar-thumb {
  background: rgba(148, 163, 184, 0.2);
  border-radius: 9999px;
}
.custom-scrollbar::-webkit-scrollbar-thumb:hover {
  background: rgba(148, 163, 184, 0.4);
}
</style>
