<script setup lang="ts">
import { VueFlow, useVueFlow } from '@vue-flow/core'
import { Background } from '@vue-flow/background'
import { layoutWithElk } from '~/utils/elk-layout'
import TableNode from './table-node.vue'

const { parsedTables, parsedRelations, isParsing, lastSaveTimestamp, activeTabId } = useSchemaStore()
const { exportDiagramAsImage, isExportingImage } = useFileSystem()

const nodes = ref<any[]>([])
const edges = ref<any[]>([])
const isLayouting = ref(false)

const {
  fitView,
  zoomIn,
  zoomOut,
  setViewport,
  getViewport,
} = useVueFlow()

const showGrid = ref(true)
const gridVariant = ref<'dots' | 'lines'>('dots')
const edgeRoutingType = ref<'smoothstep' | 'step'>('smoothstep')
const currentZoomPercent = ref(100)

function updateZoomState() {
  try {
    const vp = getViewport()
    if (vp && typeof vp.zoom === 'number') {
      currentZoomPercent.value = Math.round(vp.zoom * 100)
    }
  } catch {}
}

function buildVueFlowNodes(tables: typeof parsedTables.value) {
  if (!Array.isArray(tables)) return []

  return tables
    .filter((t) => Boolean(t && t.name && typeof t.name === 'string'))
    .map((t, index) => {
      const tableName = String(t.name).trim()
      const rowCount = Array.isArray(t.columns) ? t.columns.length : 1
      const calculatedHeight = Math.max(80, 44 + rowCount * 30 + 16)

      return {
        id: tableName,
        type: 'table',
        label: tableName,
        position: {
          x: (index % 3) * 360 + 50,
          y: Math.floor(index / 3) * 380 + 50,
        },
        dimensions: {
          width: 288,
          height: calculatedHeight,
        },
        data: {
          name: tableName,
          columns: Array.isArray(t.columns) ? t.columns : [],
          comment: t.comment,
        },
      }
    })
}

function buildVueFlowEdges(relations: typeof parsedRelations.value, validNodeIds: Set<string>) {
  if (!Array.isArray(relations)) return []

  return relations
    .map((rel, index) => {
      if (!rel) return null

      let fromTable = ''
      let fromCol = ''
      let toTable = ''
      let toCol = ''

      if (rel.fromTable && rel.toTable) {
        fromTable = String(rel.fromTable).trim()
        fromCol = String(rel.fromColumn || 'id').trim()
        toTable = String(rel.toTable).trim()
        toCol = String(rel.toColumn || 'id').trim()
      } else if (rel.from && rel.to) {
        const fromParts = String(rel.from).split('.')
        const toParts = String(rel.to).split('.')
        fromTable = (fromParts[0] || '').trim()
        fromCol = (fromParts[1] || 'id').trim()
        toTable = (toParts[0] || '').trim()
        toCol = (toParts[1] || 'id').trim()
      }

      if (!fromTable || !toTable || !validNodeIds.has(fromTable) || !validNodeIds.has(toTable)) {
        return null
      }

      const edgeId = `edge_${fromTable}_${fromCol}_to_${toTable}_${toCol}_${index}`

      return {
        id: edgeId,
        source: fromTable,
        target: toTable,
        sourceHandle: `${fromTable}.${fromCol}-source`,
        targetHandle: `${toTable}.${toCol}-target`,
        type: edgeRoutingType.value,
        animated: false,
        label: `${fromCol} → ${toCol}`,
        labelBgPadding: [4, 2] as [number, number],
        labelBgBorderRadius: 4,
        labelBgStyle: { fill: '#141822', fillOpacity: 0.9, stroke: '#2e384d', strokeWidth: 1 },
        labelStyle: { fill: '#94a3b8', fontSize: 10, fontFamily: 'monospace', fontWeight: '500' },
        style: { stroke: '#38bdf8', strokeWidth: 2 },
      }
    })
    .filter((e): e is NonNullable<typeof e> => e !== null)
}

async function applyElkLayout(shouldFitView = false) {
  const rawNodes = buildVueFlowNodes(parsedTables.value)
  const validNodeIds = new Set(rawNodes.map((n) => n.id))
  const rawEdges = buildVueFlowEdges(parsedRelations.value, validNodeIds)

  if (rawNodes.length === 0) {
    nodes.value = []
    edges.value = []
    return
  }

  isLayouting.value = true

  try {
    const { positions } = await layoutWithElk(parsedTables.value, parsedRelations.value)

    nodes.value = rawNodes.map((n) => ({
      ...n,
      position: positions[n.id] || n.position,
    }))
    edges.value = rawEdges

    if (shouldFitView) {
      nextTick(() => {
        setTimeout(() => {
          fitView({ padding: 0.15, duration: 400 })
          updateZoomState()
        }, 100)
      })
    }
  } catch (error) {
    console.error('ELK Layout calculation failed:', error)
    nodes.value = rawNodes
    edges.value = rawEdges
  } finally {
    isLayouting.value = false
  }
}

function handleFitView() {
  fitView({ padding: 0.15, duration: 300 })
  updateZoomState()
}

function handleResetZoom() {
  setViewport({ x: 0, y: 0, zoom: 1 }, { duration: 250 })
  updateZoomState()
}

function toggleGridPattern() {
  if (!showGrid.value) {
    showGrid.value = true
    gridVariant.value = 'dots'
  } else if (gridVariant.value === 'dots') {
    gridVariant.value = 'lines'
  } else {
    showGrid.value = false
  }
}

function toggleEdgeRouting() {
  const newType = edgeRoutingType.value === 'smoothstep' ? 'step' : 'smoothstep'
  edgeRoutingType.value = newType
  edges.value.forEach((e) => {
    e.type = newType
  })
}

// Watch for manual 'Save' event or schema update -> auto-rearrange diagram with ELK
watch(lastSaveTimestamp, () => {
  applyElkLayout(true)
})

// Watch schema store tables & relations
watch(
  [parsedTables, parsedRelations],
  () => {
    applyElkLayout(false)
  },
  { deep: true, immediate: true }
)

// Watch active tab switch to re-layout and fit view to the active tab's schema
watch(activeTabId, () => {
  applyElkLayout(true)
})

onMounted(() => {
  applyElkLayout(true)
})
</script>

<template>
  <div class="relative w-full h-full overflow-hidden flex flex-col bg-[var(--canvas-bg)] select-none transition-colors duration-150">
    <!-- Canvas Top Header / Info bar (Responsive on Mobile) -->
    <div
      class="h-9 bg-[var(--header-bg)] backdrop-blur-md border-b border-[var(--node-border)] flex items-center justify-between px-3 z-10 shrink-0 select-none transition-colors duration-150"
    >
      <div class="flex items-center gap-1.5 sm:gap-2 text-xs text-[var(--text-primary)] font-medium min-w-0">
        <!-- Canvas Table Icon -->
        <div
          class="w-4 h-4 rounded bg-blue-500/20 border border-blue-500/30 flex items-center justify-center text-blue-400 shrink-0"
        >
          <svg class="w-2.5 h-2.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
            <rect x="3" y="3" width="18" height="18" rx="2" />
            <path d="M3 9h18" />
            <path d="M9 21V9" />
          </svg>
        </div>

        <!-- Title: Visible on desktop, hidden on small screens -->
        <span class="hidden sm:inline font-semibold">Schema Diagram Canvas</span>

        <!-- Compact Metrics Pill (Full on desktop, compact on mobile) -->
        <span
          v-if="nodes.length"
          class="px-1.5 py-0.2 rounded text-[9px] sm:text-[10px] font-mono bg-blue-950/60 text-blue-300 border border-blue-800/50 truncate"
        >
          <span class="hidden sm:inline">{{ nodes.length }} tables • {{ edges.length }} links</span>
          <span class="sm:hidden">{{ nodes.length }}T • {{ edges.length }}L</span>
        </span>
      </div>

      <!-- Right status: Hidden on mobile (< 640px) to prevent overflowing -->
      <div class="hidden sm:flex items-center gap-3 text-[11px] text-[var(--text-muted)] font-mono shrink-0">
        <span v-if="isParsing || isLayouting" class="text-blue-400 flex items-center gap-1">
          <svg class="w-3 h-3 animate-spin" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M21 12a9 9 0 1 1-6.219-8.56" />
          </svg>
          {{ isLayouting ? 'arranging ELK layout...' : 'syncing...' }}
        </span>
        <span v-else class="text-[var(--text-muted)] flex items-center gap-1.5">
          <span class="w-1.5 h-1.5 rounded-full bg-emerald-400" />
          ELK Layered Layout Active
        </span>
      </div>
    </div>

    <!-- Floating Canvas Controls Toolbar (Responsive) -->
    <div
      class="absolute top-11 sm:top-12 right-2 sm:right-4 z-20 flex items-center gap-0.5 sm:gap-1 bg-[var(--header-bg)]/90 backdrop-blur-md p-1 rounded-xl border border-[var(--node-border)] shadow-2xl text-[var(--text-primary)]"
    >
      <!-- Zoom Out -->
      <button
        type="button"
        title="Zoom Out"
        class="w-6 h-6 sm:w-7 sm:h-7 flex items-center justify-center rounded-lg hover:bg-white/10 hover:text-white transition-colors cursor-pointer"
        @click="zoomOut()"
      >
        <svg class="w-3 h-3 sm:w-3.5 sm:h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="5" y1="12" x2="19" y2="12" />
        </svg>
      </button>

      <!-- Zoom Percentage / Reset -->
      <button
        type="button"
        title="Reset Zoom to 100%"
        class="px-1.5 sm:px-2 py-0.5 sm:py-1 text-[10px] sm:text-[11px] font-mono font-medium hover:bg-white/10 rounded-lg text-[var(--text-primary)] transition-colors cursor-pointer"
        @click="handleResetZoom()"
      >
        {{ currentZoomPercent }}%
      </button>

      <!-- Zoom In -->
      <button
        type="button"
        title="Zoom In"
        class="w-6 h-6 sm:w-7 sm:h-7 flex items-center justify-center rounded-lg hover:bg-white/10 hover:text-white transition-colors cursor-pointer"
        @click="zoomIn()"
      >
        <svg class="w-3 h-3 sm:w-3.5 sm:h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="12" y1="5" x2="12" y2="19" />
          <line x1="5" y1="12" x2="19" y2="12" />
        </svg>
      </button>

      <div class="h-3.5 sm:h-4 w-px bg-[var(--node-border)] mx-0.5" />

      <!-- Fit View -->
      <button
        type="button"
        title="Fit All Tables to Screen"
        class="w-6 h-6 sm:w-7 sm:h-7 flex items-center justify-center rounded-lg hover:bg-white/10 hover:text-white transition-colors cursor-pointer"
        @click="handleFitView()"
      >
        <svg class="w-3 h-3 sm:w-3.5 sm:h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7" />
        </svg>
      </button>

      <!-- Auto Layout (ELK) -->
      <button
        type="button"
        title="Rearrange Diagram with ELK"
        class="px-1.5 sm:px-2 py-0.5 sm:py-1 text-[10px] sm:text-[11px] font-medium flex items-center gap-1 rounded-lg hover:bg-blue-600/20 text-blue-300 border border-blue-500/30 transition-colors cursor-pointer"
        @click="applyElkLayout(true)"
      >
        <svg class="w-3 h-3 sm:w-3.5 sm:h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <rect x="3" y="3" width="7" height="7" />
          <rect x="14" y="3" width="7" height="7" />
          <rect x="14" y="14" width="7" height="7" />
          <rect x="3" y="14" width="7" height="7" />
        </svg>
        <span class="hidden sm:inline">Auto-Layout</span>
      </button>

      <!-- Line Style Toggle (smoothstep vs step) -->
      <button
        type="button"
        :title="`Line Style: ${edgeRoutingType}`"
        class="w-6 h-6 sm:w-7 sm:h-7 flex items-center justify-center rounded-lg hover:bg-white/10 text-[var(--text-primary)] font-mono text-[10px] transition-colors cursor-pointer"
        @click="toggleEdgeRouting()"
      >
        {{ edgeRoutingType === 'smoothstep' ? '∼' : '⌐' }}
      </button>

      <!-- Quick Export Image Button -->
      <button
        type="button"
        title="Export Diagram as PNG"
        class="w-6 h-6 sm:w-7 sm:h-7 flex items-center justify-center rounded-lg hover:bg-white/10 text-[var(--text-primary)] hover:text-blue-300 transition-colors cursor-pointer"
        @click="exportDiagramAsImage('png')"
      >
        <svg v-if="!isExportingImage" class="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <rect x="3" y="3" width="18" height="18" rx="2" />
          <circle cx="8.5" cy="8.5" r="1.5" />
          <polyline points="21 15 16 10 5 21" />
        </svg>
        <svg v-else class="w-3.5 h-3.5 animate-spin text-blue-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M21 12a9 9 0 1 1-6.219-8.56" />
        </svg>
      </button>

      <!-- Toggle Grid Background (Dots -> Lines -> Off) -->
      <button
        type="button"
        :title="`Grid Pattern: ${showGrid ? gridVariant : 'off'} (Click to cycle Dots / Lines / Off)`"
        class="w-6 h-6 sm:w-7 sm:h-7 flex items-center justify-center rounded-lg hover:bg-white/10 transition-colors cursor-pointer"
        :class="showGrid ? 'text-blue-400' : 'text-neutral-500'"
        @click="toggleGridPattern"
      >
        <svg class="w-3 h-3 sm:w-3.5 sm:h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <rect x="3" y="3" width="7" height="7" />
          <rect x="14" y="3" width="7" height="7" />
          <rect x="14" y="14" width="7" height="7" />
          <rect x="3" y="14" width="7" height="7" />
        </svg>
      </button>
    </div>

    <!-- Main Vue Flow Canvas Area -->
    <div class="flex-1 w-full h-full min-h-0 relative">
      <VueFlow
        :nodes="nodes"
        :edges="edges"
        :default-viewport="{ zoom: 1, x: 50, y: 50 }"
        :min-zoom="0.15"
        :max-zoom="3"
        :fit-view-on-init="true"
        :elevate-edges-on-select="true"
        :snap-to-grid="true"
        :snap-grid="[15, 15]"
        class="w-full h-full schemacraft-canvas"
        @pane-scroll="updateZoomState"
        @viewport-change="updateZoomState"
      >
        <!-- Custom Database Table Node -->
        <template #node-table="nodeProps">
          <TableNode :id="nodeProps.id" :data="nodeProps.data" :selected="nodeProps.selected" />
        </template>

        <!-- Dynamic Multi-Pattern Canvas Grid Background -->
        <Background
          v-if="showGrid"
          :pattern-color="gridVariant === 'dots' ? 'rgba(148, 163, 184, 0.15)' : 'rgba(148, 163, 184, 0.07)'"
          :gap="gridVariant === 'dots' ? 20 : 28"
          :size="gridVariant === 'dots' ? 1.5 : 1"
          :variant="gridVariant"
        />
      </VueFlow>

      <!-- Empty State Viewport Indicator -->
      <div
        v-if="nodes.length === 0"
        class="absolute inset-0 flex flex-col items-center justify-center text-center p-6 pointer-events-none select-none z-10"
      >
        <div class="w-16 h-16 rounded-2xl bg-blue-500/10 border border-blue-500/20 flex items-center justify-center text-blue-400 mb-3">
          <svg class="w-8 h-8 opacity-60" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
            <ellipse cx="12" cy="5" rx="9" ry="3" />
            <path d="M3 5V19A9 3 0 0 0 21 19V5" />
            <path d="M3 12A9 3 0 0 0 21 12" />
          </svg>
        </div>
        <h3 class="font-bold text-sm text-white mb-1">No Tables Detected in Current Schema</h3>
        <p class="text-xs text-neutral-400 max-w-sm leading-relaxed">
          Type PostgreSQL <code class="text-blue-300 font-mono">CREATE TABLE</code> statements in the left editor, load a preset from the top bar, or open a <code class="text-blue-300 font-mono">.sql</code> file.
        </p>
      </div>
    </div>
  </div>
</template>
