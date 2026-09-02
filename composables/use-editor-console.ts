import { ref } from 'vue'

export interface ConsoleLogEntry {
  id: string
  type: 'error' | 'warning' | 'info' | 'success'
  message: string
  timestamp: string
  source?: string
  lineNumber?: number
  column?: number
}

type JumpHandler = (line: number, column: number) => void

const isEditorConsoleOpen = ref(false)
const activeConsoleTab = ref<'problems' | 'output'>('problems')
const consoleLogs = ref<ConsoleLogEntry[]>([])
let registeredJumpHandler: JumpHandler | null = null

export function setEditorJumpHandler(handler: JumpHandler | null) {
  registeredJumpHandler = handler
}

export function jumpToEditorPosition(line: number, column: number) {
  if (registeredJumpHandler) {
    registeredJumpHandler(line, column)
  }
}

export function useEditorConsole() {
  function toggleConsole(force?: boolean) {
    if (typeof force === 'boolean') {
      isEditorConsoleOpen.value = force
    } else {
      isEditorConsoleOpen.value = !isEditorConsoleOpen.value
    }
  }

  function openConsole(tab: 'problems' | 'output' = 'problems') {
    activeConsoleTab.value = tab
    isEditorConsoleOpen.value = true
  }

  function closeConsole() {
    isEditorConsoleOpen.value = false
  }

  function addLog(entry: Omit<ConsoleLogEntry, 'id' | 'timestamp'>) {
    const newEntry: ConsoleLogEntry = {
      ...entry,
      id: `${Date.now()}-${Math.random().toString(36).substring(2, 9)}`,
      timestamp: new Date().toLocaleTimeString(),
    }
    consoleLogs.value.unshift(newEntry)
    if (consoleLogs.value.length > 100) {
      consoleLogs.value.pop()
    }
  }

  function clearLogs() {
    consoleLogs.value = []
  }

  return {
    isEditorConsoleOpen,
    activeConsoleTab,
    consoleLogs,
    toggleConsole,
    openConsole,
    closeConsole,
    addLog,
    clearLogs,
    jumpToEditorPosition,
    setEditorJumpHandler,
  }
}
