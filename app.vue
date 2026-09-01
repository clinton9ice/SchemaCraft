<script setup lang="ts">
const { initTheme } = useThemeEngine()

onMounted(() => {
  initTheme()
})
</script>

<template>
  <div class="h-full w-full bg-[var(--app-bg)] text-[var(--text-primary)]">
    <NuxtPage />
  </div>
</template>
