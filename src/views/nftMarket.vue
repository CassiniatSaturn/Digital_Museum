<template>
  <div>
    <div v-for="item in state.itemList" :key="item.itemId">
      <div>{{ item }}</div>
      <div>
        <button type="button" @click="purchaseNFT(item.itemId!,item.price)">purchase</button>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { fetchMarketItems, createMarketSale } from '@/service/EthService/mktService';
import { MarketItem } from '@/types';
import { onMounted, reactive, ref } from 'vue';
import { web3 } from '@/Web3/web3';

const state = reactive({ itemList: [] as Array<MarketItem> })
const currentAccount = ref('')

onMounted(async () => {
  try {
    web3.eth.getAccounts().then((accounts) => {
      currentAccount.value = accounts[0]
    })
  } catch (error) {
    console.log(error);
  }
  state.itemList = await fetchMarketItems()
  console.log(state.itemList);
})

/* Buys NFT */

const purchaseNFT = async (itemId: string, price: string) => {
  await createMarketSale(itemId, currentAccount.value, price)
}
</script>