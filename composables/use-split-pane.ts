export function useSplitPane() {
  const splitPercent = ref(40)
  const isDragging = ref(false)
  const mobileView = ref<'editor' | 'canvas'>('editor')
  const containerRef = ref<HTMLElement | null>(null)
  let rafId: number | null = null

  if (typeof window !== 'undefined') {
    try {
      const saved = localStorage.getItem('schemacraft-split')
      if (saved) {
        const parsed = parseFloat(saved)
        if (!isNaN(parsed) && parsed >= 15 && parsed <= 85) {
          splitPercent.value = parsed
        }
      }
    } catch {}
  }

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
    const minWidthPx = 220

    // Calculate percentage bounds for min 220px
    const minPercent = (minWidthPx / containerWidth) * 100
    const maxPercent = 100 - minPercent

    const rawPercent = (offset / containerWidth) * 100
    const clampedPercent = Math.max(minPercent, Math.min(maxPercent, rawPercent))

    splitPercent.value = Number(clampedPercent.toFixed(2))

    // RAF throttling prevents layout thrashing across Monaco and Vue Flow
    if (!rafId && typeof window !== 'undefined') {
      rafId = window.requestAnimationFrame(() => {
        window.dispatchEvent(new Event('resize'))
        rafId = null
      })
    }
  }

  function stopDragging() {
    if (!isDragging.value) return
    isDragging.value = false

    if (rafId && typeof window !== 'undefined') {
      window.cancelAnimationFrame(rafId)
      rafId = null
    }

    if (typeof window !== 'undefined') {
      window.removeEventListener('mousemove', onDrag)
      window.removeEventListener('touchmove', onDrag)
      window.removeEventListener('mouseup', stopDragging)
      window.removeEventListener('touchend', stopDragging)
      document.body.style.cursor = ''
      document.body.style.userSelect = ''

      try {
        localStorage.setItem('schemacraft-split', String(splitPercent.value))
      } catch {}
    }

    // Final resize trigger to ensure pixel-perfect canvas/editor fitting
    window.dispatchEvent(new Event('resize'))
  }

  function resetSplit() {
    splitPercent.value = 40
    if (typeof window !== 'undefined') {
      try {
        localStorage.setItem('schemacraft-split', '40')
      } catch {}
      window.dispatchEvent(new Event('resize'))
    }
  }

  function toggleMobileView() {
    mobileView.value = mobileView.value === 'editor' ? 'canvas' : 'editor'
    if (typeof window !== 'undefined') {
      nextTick(() => {
        window.dispatchEvent(new Event('resize'))
        if (mobileView.value === 'canvas') {
          window.dispatchEvent(new CustomEvent('schemacraft:fit-view'))
        }
      })
    }
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
