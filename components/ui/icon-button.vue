<script setup lang="ts">
const props = withDefaults(
  defineProps<{
    variant?: 'ghost' | 'primary' | 'secondary' | 'accent' | 'danger'
    size?: 'xs' | 'sm' | 'md'
    disabled?: boolean
    title?: string
    customClass?: string
  }>(),
  {
    variant: 'ghost',
    size: 'sm',
    disabled: false,
    title: '',
    customClass: '',
  }
)

defineEmits<{
  (e: 'click', event: MouseEvent): void
}>()

const sizeClasses = computed(() => {
  switch (props.size) {
    case 'xs':
      return 'px-1.5 py-1 text-[11px]'
    case 'md':
      return 'px-3 py-1.5 text-xs'
    case 'sm':
    default:
      return 'px-2 py-1 text-xs'
  }
})

const variantClasses = computed(() => {
  switch (props.variant) {
    case 'primary':
      return 'bg-blue-600 hover:bg-blue-500 text-white shadow-sm'
    case 'accent':
      return 'bg-emerald-600 hover:bg-emerald-500 text-white shadow-sm'
    case 'secondary':
      return 'bg-[#2d2d30] hover:bg-[#3e3e42] text-neutral-200 border border-[#3e3e42]'
    case 'danger':
      return 'bg-red-600/20 hover:bg-red-600/30 text-red-400 border border-red-500/30'
    case 'ghost':
    default:
      return 'text-neutral-400 hover:text-neutral-100 hover:bg-[#2a2d2e]'
  }
})
</script>

<template>
  <button
    type="button"
    :disabled="disabled"
    :class="[
      'inline-flex items-center justify-center gap-1.5 transition-colors duration-150 rounded text-xs font-medium focus:outline-none focus:ring-1 focus:ring-blue-500/50 disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer',
      sizeClasses,
      variantClasses,
      customClass,
    ]"
    :title="title"
    @click="$emit('click', $event)"
  >
    <slot name="leading" />
    <slot />
    <slot name="trailing" />
  </button>
</template>
