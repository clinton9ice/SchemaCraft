import { describe, it, expect, beforeEach, vi } from 'vitest'
import { useSchemaStore } from '../../composables/use-schema-store'
import { MAX_WORKSPACE_TABS } from '../../utils/constants'

describe('Tab Ceiling & Limit Enforcement', () => {
  beforeEach(() => {
    vi.restoreAllMocks()
    vi.stubGlobal('$fetch', vi.fn().mockResolvedValue({ success: true, tables: [], relations: [] }))
    const { tabs, isTabLimitModalOpen, switchTab } = useSchemaStore()
    // Reset tabs back to 1 initial tab for isolated test runs
    while (tabs.value.length > 1) {
      tabs.value.pop()
    }
    isTabLimitModalOpen.value = false
    switchTab(tabs.value[0].id)
  })

  it('allows adding tabs up to the MAX_WORKSPACE_TABS limit', () => {
    const { tabs, addNewTab, isTabLimitModalOpen, canAddTabs } = useSchemaStore()

    expect(tabs.value.length).toBe(1)
    expect(MAX_WORKSPACE_TABS).toBe(10)

    // Add 9 more tabs to reach 10
    for (let i = 2; i <= MAX_WORKSPACE_TABS; i++) {
      const added = addNewTab(`tab-${i}.sql`, 'CREATE TABLE t (id INT);', 'sql')
      expect(added).not.toBeNull()
      expect(tabs.value.length).toBe(i)
    }

    expect(tabs.value.length).toBe(10)
    expect(isTabLimitModalOpen.value).toBe(false)
    expect(canAddTabs(1)).toBe(false)
  })

  it('blocks adding the 11th tab and triggers isTabLimitModalOpen', () => {
    const { tabs, addNewTab, isTabLimitModalOpen, canAddTabs } = useSchemaStore()

    // Fill up to 10
    for (let i = tabs.value.length + 1; i <= MAX_WORKSPACE_TABS; i++) {
      addNewTab(`tab-${i}.sql`, 'CREATE TABLE t (id INT);', 'sql')
    }
    expect(tabs.value.length).toBe(10)
    expect(isTabLimitModalOpen.value).toBe(false)

    // Attempt to add the 11th tab
    const overflowTab = addNewTab('tab-overflow.sql', 'CREATE TABLE overflow (id INT);', 'sql')

    expect(overflowTab).toBeNull()
    expect(tabs.value.length).toBe(10)
    expect(isTabLimitModalOpen.value).toBe(true)
    expect(canAddTabs(1)).toBe(false)
  })
})
