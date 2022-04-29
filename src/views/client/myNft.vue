<template>
  <div class="flex flex-wrap border border-white rounded-lg w-10/12 mx-auto text-white px-16 py-8 mt-20">
    <div>
      <div v-for="item in state.nftList" :key="item.itemId" class=" w-1/3 px-4">
        <div class=" w-full" @click="$router.push({ name: 'NFTDetail', query: { id: item.itemId } })">
          <img :src="item.info?.image" />
          <div class=" text-center py-4 text-gray-400">{{ item.info?.name }}</div>
        </div>
        <div class=" flex items-center justify-center">{{ item.reservePrice ? item.reservePrice : item.price }}
          <SvgIcon iconClass="eth" class="w-5 h-5"></SvgIcon>
        </div>
      </div>
    </div>
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