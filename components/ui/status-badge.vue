<script setup lang="ts">
const props = withDefaults(
  defineProps<{
    variant?: 'neutral' | 'success' | 'warning' | 'info' | 'error'
    showDot?: boolean
  }>(),
  {
    variant: 'neutral',
    showDot: true,
  }
)

const typeClasses = computed(() => {
  switch (props.variant) {
    case 'success':
      return 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20'
    case 'warning':
      return 'bg-amber-500/10 text-amber-400 border-amber-500/20'
    case 'error':
      return 'bg-rose-500/10 text-rose-400 border-rose-500/20'
    case 'info':
      return 'bg-sky-500/10 text-sky-400 border-sky-500/20'
    case 'neutral':
    default:
      return 'bg-neutral-800/80 text-neutral-300 border-neutral-700/60'
  }
})

const dotClasses = computed(() => {
  switch (props.variant) {
    case 'success':
      return 'bg-emerald-400 animate-pulse'
    case 'warning':
      return 'bg-amber-400'
    case 'error':
      return 'bg-rose-400'
    case 'info':
      return 'bg-sky-400'
    case 'neutral':
    default:
      return 'bg-neutral-400'
  }
})
</script>

<template>
  <span
    :class="[
      'inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-[11px] font-medium tracking-tight border',
      typeClasses
    ]"
  >
    <span
      v-if="showDot"
      :class="['w-1.5 h-1.5 rounded-full', dotClasses]"
    />
    <slot />
  </span>
</template>
