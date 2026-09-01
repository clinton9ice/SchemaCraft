const zoomLevel = ref(100)
const panPosition = ref({ x: 0, y: 0 })
const showGrid = ref(true)
const gridStyle = ref<'dots' | 'lines' | 'dense'>('dots')

export function useCanvasViewport() {
  const zoomFactor = computed(() => zoomLevel.value / 100)

  function zoomIn(step = 10) {
    zoomLevel.value = Math.min(200, zoomLevel.value + step)
  }

  function zoomOut(step = 10) {
    zoomLevel.value = Math.max(25, zoomLevel.value - step)
  }

  function resetZoom() {
    zoomLevel.value = 100
    panPosition.value = { x: 0, y: 0 }
  }

  function toggleGrid() {
    showGrid.value = !showGrid.value
  }

  function setGridStyle(style: 'dots' | 'lines' | 'dense') {
    gridStyle.value = style
  }

  function setPan(x: number, y: number) {
    panPosition.value = { x, y }
  }

  return {
    zoomLevel,
    zoomFactor,
    panPosition,
    showGrid,
    gridStyle,
    zoomIn,
    zoomOut,
    resetZoom,
    toggleGrid,
    setGridStyle,
    setPan,
  }
}
