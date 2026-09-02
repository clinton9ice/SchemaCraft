<script setup lang="ts">
const { initTheme } = useThemeEngine()

function handleContextMenu(event: MouseEvent) {
  const target = event.target as HTMLElement | null
  // Allow Monaco Editor's context menu to open, while preventing the native browser menu elsewhere
  if (
    target?.closest('.monaco-editor') ||
    target?.closest('.monaco-menu-container') ||
    target?.closest('.context-view') ||
    target?.closest('.monaco-dropdown')
  ) {
    return
  }
  event.preventDefault()
}

onMounted(() => {
  initTheme()
  window.addEventListener('contextmenu', handleContextMenu)
})

onUnmounted(() => {
  window.removeEventListener('contextmenu', handleContextMenu)
})
</script>

<template>
  <div class="h-full w-full bg-[var(--app-bg)] text-[var(--text-primary)]">
    <NuxtPage />
  </div>
</template>
