<template>
  <div class="  bg-mainBg min-w-body min-h-screen">
    <NavBar></NavBar>
    <div class=" mx-auto w-bodySet pb-10">
      <slot></slot>
    </div>
  </div>
</template>


<script lang="ts" setup>
import NavBar from './NavBar.vue';

</script>