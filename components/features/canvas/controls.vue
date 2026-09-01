<script setup lang="ts">
const { zoomLevel, showGrid, zoomIn, zoomOut, resetZoom, toggleGrid } = useCanvasViewport()
</script>

<template>
  <div class="absolute top-4 right-4 z-20 flex items-center gap-1 bg-[#18181b]/90 backdrop-blur-md p-1 rounded-lg border border-[#2d2d30] shadow-xl text-neutral-300">
    <!-- Zoom Out -->
    <ui-icon-button
      size="sm"
      variant="ghost"
      title="Zoom Out (-10%)"
      @click="zoomOut()"
    >
      <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <line x1="5" y1="12" x2="19" y2="12"/>
      </svg>
    </ui-icon-button>

    <!-- Zoom Percentage Display / Reset -->
    <button
      type="button"
      @click="resetZoom()"
      class="px-2 py-1 text-xs font-mono font-medium hover:bg-[#2d2d30] rounded text-neutral-200 transition-colors"
      title="Reset Zoom to 100%"
    >
      {{ zoomLevel }}%
    </button>

    <!-- Zoom In -->
    <ui-icon-button
      size="sm"
      variant="ghost"
      title="Zoom In (+10%)"
      @click="zoomIn()"
    >
      <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <line x1="12" y1="5" x2="12" y2="19"/>
        <line x1="5" y1="12" x2="19" y2="12"/>
      </svg>
    </ui-icon-button>

    <div class="h-4 w-px bg-neutral-700 mx-0.5" />

    <!-- Toggle Grid -->
    <ui-icon-button
      size="sm"
      :variant="showGrid ? 'secondary' : 'ghost'"
      title="Toggle Canvas Grid"
      @click="toggleGrid()"
    >
      <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <rect x="3" y="3" width="18" height="18" rx="2"/>
        <line x1="3" y1="9" x2="21" y2="9"/>
        <line x1="3" y1="15" x2="21" y2="15"/>
        <line x1="9" y1="3" x2="9" y2="21"/>
        <line x1="15" y1="3" x2="15" y2="21"/>
      </svg>
    </ui-icon-button>
  </div>
</template>
