<template>
  <div class=" w-10/12 mx-auto mt-16 text-white">
    <div class=" text-2xl font-bold text-center border-b pb-5 border-gray-400 mb-16">探索数字藏品NFT</div>
    <div class=" flex flex-wrap">
      <div v-for="item in state.itemList" :key="item.itemId" @click="goToDetail(item.itemId)" class=" px-4 w-1/3">
        <div class="border border-white rounded-lg">
          <div class=" rounded-t-lg w-full overflow-hidden">
            <img :src="item.info?.image" />
          </div>
          <div class=" text-gray-500 text-center pt-3">{{ item.info?.name }}</div>
          <div class=" flex items-center justify-center py-2">
            {{ item.status == ItemStatus.BuyNow ? item.price : item.reservePrice }}
            <SvgIcon iconClass="eth" class=" w-5 h-5"></SvgIcon>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { fetchMarketItems, createMarketSale, createBid, endAuction, fetchMarketItemDetail, fetchAuction } from '@/service/EthService/mktService';
import { MarketItem } from '@/types';
import { onMounted, reactive, ref } from 'vue';
import { web3 } from '@/Web3/web3';
import { ItemStatus } from '@/types';
import { useRouter } from 'vue-router';
import { List } from 'ant-design-vue';
const state = reactive({ itemList: [] as Array<MarketItem> })
const currentAccount = ref('')

onMounted(async () => {
  try {
    const accounts = await web3.eth.getAccounts()
    currentAccount.value = accounts[0]
    const list = await fetchMarketItems(currentAccount.value)
    state.itemList = await Promise.all(list.map(async (i) => {
      if (i.status == ItemStatus.OnAuction) {
        return (
          async () => {
            const rp = (await fetchAuction(i.itemId, currentAccount.value)).reservePrice
            return {
              reservePrice: rp,
              ...i
            }
          }
        )()
      } else {
        return i
      }
    }))
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