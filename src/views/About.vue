<template>
  <div>
    {{balance}}
  </div>
</template>

<script setup lang="ts">
import {reactive, ref} from 'vue'
import web3 from 'web3'

let currentProvider = reactive({})
currentProvider = web3.givenProvider? web3.givenProvider:'http://127.0.0.1:7545'


const balance = ref(0)


</script>

<style scoped>

</style>