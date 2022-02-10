<template>
  <div>
    <div v-for="item in state.createdList" :key="item.itemId">{{ item }}</div>
  </div>
</template>

<script lang="ts" setup>
import { fetchItemsCreated } from '@/service/EthService/mktService';
import { onMounted, reactive } from 'vue';
import { MarketItem } from '@/types';

const state = reactive({ createdList: {} as Array<MarketItem> })

onMounted(async () => {
  state.createdList = await fetchItemsCreated()

})
</script>