<script lang="ts" setup>
import type { ClassNameValue } from 'tailwind-merge'

const { useIcon = true } = defineProps<{
  description?: string | object | undefined | null
  useIcon?: boolean
}>()
const cls = computed(() => useAttrs().class as ClassNameValue)
defineOptions({
  inheritAttrs: false,
})
</script>

<template>
  <div :class="cn('w-full', cls)">
    <a-tooltip color="white" class="text-gray-800" placement="left" :align="{ autoArrow: false }">
      <div class="inline-flex">
        <slot />
        <sup v-if="useIcon">
          <tools-icon dir="fill" icon="question-info" :height="10" :width="10" />
        </sup>
      </div>
      <template #title>
        <div class="text-xs font-medium text-gray-600">
          <slot name="content" :description>{{ description }}</slot>
        </div>
      </template>
    </a-tooltip>
  </div>
</template>
