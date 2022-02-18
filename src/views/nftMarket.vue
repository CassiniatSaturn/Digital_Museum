<template>
  <div>
    <div v-for="item in state.itemList" :key="item.itemId" @click="goToDetail(item.itemId)">
      <div>{{ item.info?.name }}</div>
      <div>{{ item.info?.description }}</div>
      <div>status:{{ item.status }}</div>
      <div>
        <img :src="item.info?.image" />
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { fetchMarketItems, createMarketSale, createBid, endAuction } from '@/service/EthService/mktService';
import { MarketItem } from '@/types';
import { onMounted, reactive, ref } from 'vue';
import { web3 } from '@/Web3/web3';
import { ItemStatus } from '@/types';
import { useRouter } from 'vue-router';
const state = reactive({ itemList: [] as Array<MarketItem> })
const currentAccount = ref('')

onMounted(async () => {
  try {
    const accounts = await web3.eth.getAccounts()
    currentAccount.value = accounts[0]
    console.log(currentAccount.value);
    const list = await fetchMarketItems(currentAccount.value)
    if (list) {
      state.itemList = list
    }
    console.log(state.itemList);
  } catch (error) {
    console.log(error);
  }
})

/* check the detail */
const router = useRouter()
const goToDetail = (itemId: string) => {
  router.push({ name: 'NFTDetail', query: { id: itemId } })
}
</script>