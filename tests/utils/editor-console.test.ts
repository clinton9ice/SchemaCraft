import { describe, it, expect, beforeEach } from 'vitest'
import { useEditorConsole } from '~/composables/use-editor-console'

describe('useEditorConsole', () => {
  const {
    isEditorConsoleOpen,
    activeConsoleTab,
    consoleLogs,
    toggleConsole,
    openConsole,
    closeConsole,
    addLog,
    clearLogs,
  } = useEditorConsole()

  beforeEach(() => {
    closeConsole()
    clearLogs()
  })

  it('toggles console open and close', () => {
    expect(isEditorConsoleOpen.value).toBe(false)
    toggleConsole()
    expect(isEditorConsoleOpen.value).toBe(true)
    toggleConsole()
    expect(isEditorConsoleOpen.value).toBe(false)
  })

  it('opens console to specific tab', () => {
    openConsole('output')
    expect(isEditorConsoleOpen.value).toBe(true)
    expect(activeConsoleTab.value).toBe('output')

    openConsole('problems')
    expect(isEditorConsoleOpen.value).toBe(true)
    expect(activeConsoleTab.value).toBe('problems')
  })

  it('closes console', () => {
    openConsole()
    expect(isEditorConsoleOpen.value).toBe(true)
    closeConsole()
    expect(isEditorConsoleOpen.value).toBe(false)
  })

  it('adds and clears console log entries', () => {
    addLog({
      type: 'error',
      message: 'Syntax error at line 5',
      lineNumber: 5,
      column: 12,
    })

    expect(consoleLogs.value).toHaveLength(1)
    expect(consoleLogs.value[0].message).toBe('Syntax error at line 5')
    expect(consoleLogs.value[0].type).toBe('error')

    clearLogs()
    expect(consoleLogs.value).toHaveLength(0)
  })

  it('delegates jumpToEditorPosition to registered jump handler', () => {
    let jumpedLine = 0
    let jumpedCol = 0

    const { setEditorJumpHandler, jumpToEditorPosition } = useEditorConsole()
    setEditorJumpHandler((line, col) => {
      jumpedLine = line
      jumpedCol = col
    })

    jumpToEditorPosition(14, 5)
    expect(jumpedLine).toBe(14)
    expect(jumpedCol).toBe(5)

    setEditorJumpHandler(null)
  })
})
