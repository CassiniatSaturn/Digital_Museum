<template>
  <div>
    <div>Item Details</div>
    <div>{{ state.nft.info?.name }}</div>
    <div>{{ state.nft.info?.description }}</div>
    <div>
      <img :src="state.nft.info?.image" />
    </div>
    <div>Set NFT Status! Now:{{state.nft.status}}</div>
    <div>
      <button @click="changeStatus(state.nft.itemId!, ItemStatus.BuyNow)">Sell in Fixed Price</button>
      <button @click="changeStatus(state.nft.itemId!, ItemStatus.OnAuction)">Sell on Auction</button>
    </div>
    <div v-if="setStatus == ItemStatus.BuyNow">
      <input type="text" v-model="price" />
    </div>
    <div v-else>
      <div>duration</div>
      <input type="text" v-model="duration">
      <div>reservePrice</div>
      <input type="text" v-model="reservePrice">
    </div>
  </div>
</template>


<script lang="ts" setup>
import { MarketItem } from '@/types';
import { computed, onMounted, reactive, ref } from 'vue';
import { useRoute } from 'vue-router';
import { ItemStatus } from '@/types';
import { setFixedPrice, createAuction,fetchMarketItemDetail } from '@/service/EthService/mktService'
import { web3 } from '@/Web3/web3';

const route = useRoute()
const currenItemId = computed((): string => {
  const id = JSON.parse(route.query.id as unknown as string)
  return id
})
const currentAccount = ref('')
let state = reactive({nft:{} as MarketItem})

onMounted(async()=>{
  try {
    currentAccount.value = (await web3.eth.getAccounts())[0]
    console.log(currentAccount.value);
    state.nft = await fetchMarketItemDetail(currenItemId.value, currentAccount.value)
    console.log(state.nft);
  } catch (error) {
    console.log(error);
  }
})
const setStatus = ref(ItemStatus.BuyNow)
const price = ref(0)
const duration = ref(0)
const reservePrice = ref(0)

const changeStatus = async (itemId: string, status: ItemStatus) => {
  setStatus.value = status
  if (status == ItemStatus.BuyNow) {
    /* call buy now */
    if(price.value){
      await setFixedPrice(itemId,price.value)
    }
  }
  else if (status == ItemStatus.OnAuction) {
    if(!duration.value || !reservePrice.value) return
    /* call on auction */
    await createAuction(itemId,duration.value,reservePrice.value)
  }
}
</script>