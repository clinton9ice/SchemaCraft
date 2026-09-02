<script setup lang="ts">
import { Handle, Position } from '@vue-flow/core'
import type { CompiledColumn } from '~/utils/sql-compiler'

interface TableNodeData {
  name: string
  columns: CompiledColumn[]
  color?: string
  comment?: string
}

const props = defineProps<{
  id: string
  data: TableNodeData
  selected?: boolean
}>()

// Calculate table stats
const primaryKeysCount = computed(() => {
  return (props.data?.columns || []).filter((c) => c.isPrimaryKey).length
})

const foreignKeysCount = computed(() => {
  return (props.data?.columns || []).filter((c) => c.isForeignKey).length
})

// Check if column has additional metadata / conditions / comments
function hasColumnDetails(col: CompiledColumn): boolean {
  return Boolean(
    col.checkCondition ||
    col.comment ||
    col.defaultValue ||
    (col.constraintsList && col.constraintsList.length > 0)
  )
}

// Hover popover state (Teleported to body for zero clipping)
const hoveredCol = ref<CompiledColumn | null>(null)
const popoverPos = ref<{ x: number; y: number }>({ x: 0, y: 0 })
const showPopover = ref(false)
let hideTimer: ReturnType<typeof setTimeout> | null = null

function onRowMouseEnter(event: MouseEvent, col: CompiledColumn) {
  if (!hasColumnDetails(col)) return

  if (hideTimer) {
    clearTimeout(hideTimer)
    hideTimer = null
  }

  const target = event.currentTarget as HTMLElement
  const rect = target.getBoundingClientRect()

  const cardWidth = 300
  const screenWidth = window.innerWidth
  const spaceOnRight = screenWidth - rect.right

  // Place on right if space permits, otherwise place on left
  let posX = rect.right + 12
  if (spaceOnRight < cardWidth + 20) {
    posX = Math.max(10, rect.left - cardWidth - 12)
  }

  popoverPos.value = {
    x: posX,
    y: Math.max(10, Math.min(rect.top - 10, window.innerHeight - 320)),
  }

  hoveredCol.value = col
  showPopover.value = true
}

function onRowMouseLeave() {
  hideTimer = setTimeout(() => {
    showPopover.value = false
    hoveredCol.value = null
  }, 120)
}
</script>

<template>
  <div
    class="w-72 bg-[var(--node-bg)] rounded-xl border transition-all duration-150 shadow-2xl font-sans text-xs select-none relative group text-[var(--text-primary)]"
    :class="[
      selected
        ? 'border-[var(--accent)] ring-2 ring-[var(--accent)]/30 shadow-2xl'
        : 'border-[var(--node-border)] hover:border-[var(--accent)]/50',
    ]"
  >
    <!-- Table Header (Darker header with icon & badges) -->
    <div
      class="px-3.5 py-2.5 bg-[var(--node-header)] border-b border-[var(--node-border)] rounded-t-xl flex items-center justify-between"
    >
      <div class="flex items-center gap-2 min-w-0">
        <!-- Table Icon -->
        <div
          class="w-5 h-5 rounded bg-blue-500/15 border border-blue-500/30 flex items-center justify-center text-blue-400 shrink-0"
        >
          <svg class="w-3 h-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <rect x="3" y="3" width="18" height="18" rx="2" />
            <path d="M3 9h18" />
            <path d="M9 21V9" />
          </svg>
        </div>

        <!-- Table Name -->
        <span class="font-bold text-[var(--text-primary)] truncate text-[13px] tracking-tight">
          {{ data.name }}
        </span>
      </div>

      <!-- Quick Metrics Pill -->
      <div class="flex items-center gap-1.5 shrink-0">
        <span
          v-if="primaryKeysCount > 0"
          class="px-1.5 py-0.5 rounded text-[9px] font-mono font-semibold bg-amber-500/15 text-amber-300 border border-amber-500/30"
          title="Primary Keys"
        >
          {{ primaryKeysCount }} PK
        </span>
        <span
          class="px-1.5 py-0.5 rounded text-[9px] font-mono bg-black/20 text-[var(--text-muted)] border border-[var(--node-border)]"
        >
          {{ data.columns?.length || 0 }}
        </span>
      </div>
    </div>

    <!-- Column Rows List -->
    <div class="divide-y divide-[var(--node-border)] bg-[var(--node-bg)] rounded-b-xl overflow-visible">
      <div
        v-for="col in data.columns"
        :key="col.name"
        class="relative w-full"
        @mouseenter="onRowMouseEnter($event, col)"
        @mouseleave="onRowMouseLeave"
      >
        <!-- Target Handle (Left anchor for incoming foreign key references) -->
        <Handle
          :id="`${data.name}.${col.name}-target`"
          type="target"
          :position="Position.Left"
          class="!w-2 !h-2 !-left-1 !bg-[var(--accent)] !border !border-[var(--node-header)] z-10"
        />

        <!-- Full Column Row Container -->
        <div
          class="relative px-3 py-1.5 flex items-center justify-between hover:bg-white/5 transition-colors w-full cursor-default group/row"
        >
          <!-- Left Column Info: Icon & Column Name -->
          <div class="flex items-center gap-2 min-w-0 pr-2">
            <!-- Key / Type Indicator Icon -->
            <span v-if="col.isPrimaryKey" class="text-amber-400 shrink-0" title="Primary Key">
              <svg class="w-3 h-3" viewBox="0 0 24 24" fill="currentColor">
                <path
                  d="M7 14A5 5 0 0 0 12 9V2h2v2h2V2h2v2h2v3h-6a5 5 0 1 0-7 7Zm0-2a3 3 0 1 1 0-6 3 3 0 0 1 0 6Z"
                />
              </svg>
            </span>
            <span v-else-if="col.isForeignKey" class="text-sky-400 shrink-0" title="Foreign Key">
              <svg class="w-3 h-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71" />
                <path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71" />
              </svg>
            </span>
            <span v-else class="w-1.5 h-1.5 rounded-full bg-neutral-500 shrink-0" />

            <!-- Column Name -->
            <span
              class="truncate font-medium text-[var(--text-primary)]"
              :class="{
                'text-amber-300 font-semibold': col.isPrimaryKey,
                'text-sky-300': col.isForeignKey,
              }"
            >
              {{ col.name }}
            </span>

            <!-- Constraint Badges (UQ, NN) -->
            <span
              v-if="col.isUnique && !col.isPrimaryKey"
              class="px-1 py-0.2 rounded text-[8px] font-mono bg-purple-950/60 text-purple-300 border border-purple-800/40 shrink-0"
            >
              UQ
            </span>
          </div>

          <!-- Right Column Info: Data Type & Subtle Indicator -->
          <div class="flex items-center gap-1.5 shrink-0">
            <span
              class="font-mono text-[11px] text-[var(--text-muted)] group-hover/row:text-[var(--text-primary)] transition-colors"
            >
              {{ col.type }}
            </span>

            <span
              v-if="!col.isNullable && !col.isPrimaryKey"
              class="text-[9px] font-mono text-[var(--text-muted)]"
              title="NOT NULL"
            >
              *
            </span>

            <!-- Subtle Quiet Indicator Icon (Condition / Comment) -->
            <span
              v-if="hasColumnDetails(col)"
              class="w-3.5 h-3.5 flex items-center justify-center text-[var(--text-muted)] group-hover/row:text-[var(--text-primary)] transition-colors"
            >
              <svg
                v-if="col.checkCondition"
                class="w-2.5 h-2.5 text-amber-400/80"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2.5"
              >
                <circle cx="12" cy="12" r="10" />
                <line x1="12" y1="16" x2="12" y2="12" />
                <line x1="12" y1="8" x2="12.01" y2="8" />
              </svg>
              <svg
                v-else-if="col.comment"
                class="w-2.5 h-2.5 text-neutral-400/80"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
              >
                <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
              </svg>
              <span v-else class="text-[9px] leading-none text-[var(--text-muted)] font-mono">⋯</span>
            </span>
          </div>
        </div>

        <!-- Source Handle (Right anchor for outgoing foreign key references) -->
        <Handle
          :id="`${data.name}.${col.name}-source`"
          type="source"
          :position="Position.Right"
          class="!w-2 !h-2 !-right-1 !bg-[var(--accent)] !border !border-[var(--node-header)] z-10"
        />
      </div>
    </div>

    <!-- Table Footer / Details -->
    <div
      v-if="foreignKeysCount > 0"
      class="px-3 py-1.5 bg-[var(--node-header)] border-t border-[var(--node-border)] rounded-b-xl text-[10px] text-[var(--text-muted)] font-mono flex items-center justify-between"
    >
      <span class="text-[var(--text-muted)]">References</span>
      <span class="text-sky-400">{{ foreignKeysCount }} outbound FK</span>
    </div>

    <!-- TELEPORTED UNCLIPPED HOVER DETAILS POPOVER -->
    <Teleport to="body">
      <Transition
        enter-active-class="transition duration-150 ease-out"
        enter-from-class="opacity-0 translate-y-1 scale-95"
        enter-to-class="opacity-100 translate-y-0 scale-100"
        leave-active-class="transition duration-100 ease-in"
        leave-from-class="opacity-100 scale-100"
        leave-to-class="opacity-0 scale-95"
      >
        <div
          v-if="showPopover && hoveredCol"
          class="fixed z-[99999] w-80 bg-[var(--header-bg)] border border-[var(--node-border)] shadow-2xl rounded-xl p-3.5 text-[var(--text-primary)] text-xs font-sans pointer-events-none ring-1 ring-white/10"
          :style="{
            top: `${popoverPos.y}px`,
            left: `${popoverPos.x}px`,
          }"
        >
          <!-- Header: Table & Column Name & Data Type -->
          <div class="flex items-center justify-between gap-2 border-b border-[var(--node-border)] pb-2 mb-2">
            <div class="flex items-center gap-1.5 min-w-0">
              <span class="text-[var(--text-muted)] font-mono text-[11px]">{{ data.name }}.</span>
              <span class="font-bold text-[var(--text-primary)] text-sm truncate">{{ hoveredCol.name }}</span>
            </div>
            <span class="px-2 py-0.5 rounded text-[10px] font-mono font-semibold bg-sky-950/80 text-sky-300 border border-sky-800/50 shrink-0">
              {{ hoveredCol.type }}
            </span>
          </div>

          <div class="space-y-2.5">
            <!-- SQL Documentation Note / Comment -->
            <div v-if="hoveredCol.comment" class="bg-[var(--app-bg)] border border-[var(--node-border)] rounded-lg p-2 leading-relaxed">
              <div class="text-[10px] font-semibold uppercase tracking-wider text-[var(--text-muted)] mb-0.5 flex items-center gap-1">
                <svg class="w-3 h-3 text-neutral-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
                </svg>
                <span>Documentation Note</span>
              </div>
              <p class="text-[var(--text-primary)] text-[11px]">{{ hoveredCol.comment }}</p>
            </div>

            <!-- Human-Readable CHECK Condition -->
            <div
              v-if="hoveredCol.checkCondition"
              class="bg-amber-950/40 border border-amber-800/50 rounded-lg p-2 leading-relaxed"
            >
              <div class="text-[10px] font-semibold uppercase tracking-wider text-amber-400 mb-0.5 flex items-center gap-1">
                <svg class="w-3 h-3 text-amber-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                  <circle cx="12" cy="12" r="10" />
                  <line x1="12" y1="16" x2="12" y2="12" />
                  <line x1="12" y1="8" x2="12.01" y2="8" />
                </svg>
                <span>Check Condition</span>
              </div>
              <p class="text-amber-200 font-medium text-[11px] mb-1">
                {{ hoveredCol.checkCondition.humanReadable }}
              </p>
              <div class="text-[10px] font-mono text-amber-400/70 bg-amber-950/60 px-1.5 py-0.5 rounded">
                SQL: {{ hoveredCol.checkCondition.raw }}
              </div>
            </div>

            <!-- Default Expression -->
            <div v-if="hoveredCol.defaultValue" class="flex items-center justify-between text-[11px] bg-[var(--app-bg)] border border-[var(--node-border)] rounded-lg px-2.5 py-1.5">
              <span class="text-[var(--text-muted)]">Default Value:</span>
              <span class="font-mono text-[var(--text-primary)] font-semibold">{{ hoveredCol.defaultValue }}</span>
            </div>

            <!-- Active Constraints Badges -->
            <div v-if="hoveredCol.constraintsList?.length" class="pt-1">
              <span class="text-[10px] text-[var(--text-muted)] font-semibold uppercase tracking-wider block mb-1">
                Active Constraints
              </span>
              <div class="flex flex-wrap gap-1.5">
                <span
                  v-for="c in hoveredCol.constraintsList"
                  :key="c"
                  class="px-2 py-0.5 rounded text-[10px] font-mono bg-[var(--app-bg)] text-[var(--text-primary)] border border-[var(--node-border)]"
                >
                  {{ c }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>
  </div>
</template>
