<template>
  <div class=" w-10/12 mx-auto border border-white rounded-lg mt-10 text-white px-16 py-4">
    <div class=" text-xl font-bold">设置交易规则</div>
    <div class=" w-1/3 mx-auto">
      <img :src="state.nft.info?.image" class=" w-full h-80 py-5 mx-auto" />
      <div class=" pt-3">tokenID:{{ state.nft.tokenId }}</div>
      <div class=" pt-3">NFT:{{ state.nft.info?.name }}</div>
      <div class=" text-justify pt-3">{{ state.nft.info?.description }}</div>
      <p class=" pt-3">交易方式</p>
      <q-radio dark v-model="setStatus" :val="ItemStatus.BuyNow" label="以固定价格出售" color="gray-1" />
      <span class=" pr-4"></span>
      <q-radio dark v-model="setStatus" :val="ItemStatus.OnAuction" label="最高价拍卖" color="gray-1" />
      <div v-if="setStatus == ItemStatus.BuyNow">
        <p class=" pb-3">价格</p>
        <q-input dark label-color="grey-1" color="gray-1" label="请输入数字藏品NFT的价格（单位为ether）" rounded outlined type="text"
          v-model="price" />
      </div>
      <div v-else>
        <div class=" py-3">拍卖持续时间</div>
        <q-input dark label-color="grey-1" color="gray-1" label="请输入拍卖持续时间（单位为秒）" rounded outlined type="text"
          v-model="duration" />
        <div class=" py-3">保留价格</div>
        <q-input dark label-color="grey-1" color="gray-1" label="请输入保留价格" rounded outlined type="text" v-model="reservePrice" />
      </div>
    </div>
    <button class=" bg-purple-700 mt-14 px-10 py-2  rounded-3xl block mx-auto mb-10"
      @click="changeStatus(state.nft.itemId)">设置并上市</button>
  </div>
</template>


<script lang="ts" setup>
import { MarketItem } from '@/types';
import { computed, onMounted, reactive, ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { ItemStatus } from '@/types';
import { setFixedPrice, createAuction, fetchMarketItemDetail } from '@/service/EthService/mktService'
import { web3 } from '@/Web3/web3';


const route = useRoute()
const currenItemId = computed((): string => {
  const id = JSON.parse(route.query.id as unknown as string)
  return id
})
const currentAccount = ref('')
let state = reactive({ nft: {} as MarketItem })

onMounted(async () => {
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
const price = ref()
const duration = ref()
const reservePrice = ref()
const router = useRouter()

const changeStatus = async (itemId: string) => {
  const status = setStatus.value
  if (status == ItemStatus.BuyNow) {
    /* call buy now */
    if (!price.value) return
    await setFixedPrice(itemId, price.value)
    router.push({name:'Dashboard'})
  }
  else if (status == ItemStatus.OnAuction) {
    if (!duration.value || !reservePrice.value) return
    /* call on auction */
    await createAuction(itemId, duration.value, reservePrice.value)
    router.push({name:'Dashboard'})
  }
}
</script>