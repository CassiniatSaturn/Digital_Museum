<template>
  <div>
    <div v-for="item in state.createdList" :key="item.itemId">
      <div>{{ item.info?.name }}</div>
      <div>{{ item.info?.description }}</div>
      <div>
        <img :src="item.info?.image" />
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { fetchItemsCreated } from '@/service/EthService/mktService';
import { MarketItem } from '@/types';
import { onMounted, reactive, ref } from 'vue';

const state = reactive({ createdList: {} as Array<MarketItem> })

onMounted(async () => {
  state.createdList = await fetchItemsCreated()
  console.log(state.createdList);

})
</script>