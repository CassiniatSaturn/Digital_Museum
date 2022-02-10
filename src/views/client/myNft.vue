<template>
  <div>
    <div v-for="item in state.nftList" :key="item.itemId">{{ item }}</div>
  </div>
</template>

<script setup lang="ts">
import { fetchMyNFTs } from '@/service/EthService/mktService';
import { MarketItem } from '@/types';
import { onMounted, reactive, ref } from 'vue';
import { web3 } from '@/Web3/web3';

const state = reactive({ nftList: {} as Array<MarketItem> })
let currentAccount = ref('')

onMounted(async () => {
  try {
    const accounts = await web3.eth.getAccounts()
    currentAccount.value = accounts[0]
    console.log(currentAccount.value);
    state.nftList = await fetchMyNFTs(currentAccount.value)
    console.log(state.nftList);

  } catch (error) {
    console.log(error);
  }

})
</script>