<template>
  <svg :class="svgClass" class=" fill-current overflow-hidden" aria-hidden="true" :="$attrs" @click="$emit('clickSvg')">
    <use :xlink:href="iconName" />
  </svg>
</template>

<script lang="ts" setup>
import { withDefaults, defineProps, computed,defineEmits } from 'vue';
const props = withDefaults(defineProps<{
  iconClass: string,
  className?: string
}>(), { className: '' })

const iconName = computed(() => {
  return `#icon-${props.iconClass}`
})

const svgClass = computed(() => {
  if (props.className) {
    return 'svg-icon ' + props.className
  } else {
    return 'svg-icon'
  }
})

const emits = defineEmits(['clickSvg'])
</script>
 