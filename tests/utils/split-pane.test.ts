// @vitest-environment happy-dom
import { describe, it, expect, beforeEach, vi } from 'vitest'
import { useSplitPane } from '../../composables/use-split-pane'

describe('useSplitPane Composable', () => {
  beforeEach(() => {
    localStorage.clear()
    vi.restoreAllMocks()
  })

  it('initializes with default 40% split percent and editor mobile view', () => {
    const { splitPercent, mobileView, isDragging } = useSplitPane()
    expect(splitPercent.value).toBe(40)
    expect(mobileView.value).toBe('editor')
    expect(isDragging.value).toBe(false)
  })

  it('toggles mobileView between editor and canvas and dispatches fit-view on canvas mode', async () => {
    const { mobileView, toggleMobileView } = useSplitPane()
    const dispatchSpy = vi.spyOn(window, 'dispatchEvent')

    toggleMobileView()
    expect(mobileView.value).toBe('canvas')

    await new Promise(resolve => setTimeout(resolve, 60))
    expect(dispatchSpy).toHaveBeenCalled()

    toggleMobileView()
    expect(mobileView.value).toBe('editor')
  })

  it('resets split percentage to 40% and persists to localStorage', () => {
    const { splitPercent, resetSplit } = useSplitPane()
    splitPercent.value = 65
    resetSplit()

    expect(splitPercent.value).toBe(40)
    expect(localStorage.getItem('schemacraft-split')).toBe('40')
  })

  it('restores split percentage from localStorage if within valid bounds', () => {
    localStorage.setItem('schemacraft-split', '55')
    const { splitPercent } = useSplitPane()
    expect(splitPercent.value).toBe(55)
  })

  it('ignores invalid localStorage values outside 15-85 range', () => {
    localStorage.setItem('schemacraft-split', '95')
    const { splitPercent } = useSplitPane()
    expect(splitPercent.value).toBe(40)
  })
})
