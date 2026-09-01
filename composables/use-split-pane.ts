export function useSplitPane() {
  const splitPercent = ref(40)
  const isDragging = ref(false)
  const mobileView = ref<'editor' | 'canvas'>('editor')
  const containerRef = ref<HTMLElement | null>(null)

  function startDragging(event: MouseEvent | TouchEvent) {
    event.preventDefault()
    isDragging.value = true

    if (typeof window !== 'undefined') {
      window.addEventListener('mousemove', onDrag)
      window.addEventListener('touchmove', onDrag, { passive: false })
      window.addEventListener('mouseup', stopDragging)
      window.addEventListener('touchend', stopDragging)
      document.body.style.cursor = 'col-resize'
      document.body.style.userSelect = 'none'
    }
  }

  function onDrag(event: MouseEvent | TouchEvent) {
    if (!isDragging.value || !containerRef.value) return

    const clientX = 'touches' in event ? event.touches[0].clientX : event.clientX
    const rect = containerRef.value.getBoundingClientRect()
    const containerWidth = rect.width

    if (containerWidth <= 0) return

    const offset = clientX - rect.left
    const minWidthPx = 200

    // Calculate percentage bounds for min 200px
    const minPercent = (minWidthPx / containerWidth) * 100
    const maxPercent = 100 - minPercent

    const rawPercent = (offset / containerWidth) * 100
    const clampedPercent = Math.max(minPercent, Math.min(maxPercent, rawPercent))

    splitPercent.value = Number(clampedPercent.toFixed(2))

    // Trigger window resize event so Monaco and Vue Flow smoothly adapt viewport
    window.dispatchEvent(new Event('resize'))
  }

  function stopDragging() {
    if (!isDragging.value) return
    isDragging.value = false

    if (typeof window !== 'undefined') {
      window.removeEventListener('mousemove', onDrag)
      window.removeEventListener('touchmove', onDrag)
      window.removeEventListener('mouseup', stopDragging)
      window.removeEventListener('touchend', stopDragging)
      document.body.style.cursor = ''
      document.body.style.userSelect = ''
    }

    // Final resize trigger to ensure pixel-perfect canvas/editor fitting
    window.dispatchEvent(new Event('resize'))
  }

  function resetSplit() {
    splitPercent.value = 40
    window.dispatchEvent(new Event('resize'))
  }

  function toggleMobileView() {
    mobileView.value = mobileView.value === 'editor' ? 'canvas' : 'editor'
    nextTick(() => {
      window.dispatchEvent(new Event('resize'))
    })
  }

  return {
    splitPercent,
    isDragging,
    mobileView,
    containerRef,
    startDragging,
    resetSplit,
    toggleMobileView,
  }
}
