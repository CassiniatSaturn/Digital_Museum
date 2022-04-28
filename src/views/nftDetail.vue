<template>
  <div class=" w-10/12 mx-auto border border-white rounded-lg py-10 mt-10">
    <div class=" border-b border-gray-300 text-gray-400 pb-6 text-xl mx-8">{{ state.nft.info?.name }}</div>
    <div class=" flex px-10 pt-10 items-start">
      <!-- display info -->
      <img :src="state.nft.info?.image" class=" w-2/5" />
      <div class=" w-1/2  pl-20 text-white flex flex-col justify-between">
        <div>
          <div> tokenID : {{ state.nft.tokenId }}</div>
          <div class=" pt-3">NFT : {{ state.nft.info?.name }}</div>
          <div v-if="state.nft.status == ItemStatus.BuyNow">
            价格 : {{ state.nft.price }}
            <SvgIcon iconClass="eth" class=" w-6 h-6"></SvgIcon>
          </div>
          <div class=" pt-3" v-if="state.nft.status == ItemStatus.OnAuction">
            保留价格 : {{ state.auction.reservePrice }}
            <SvgIcon iconClass="eth" class=" w-6 h-6 inline-block"></SvgIcon>
            <div class=" pt-3">
              距离拍卖结束时间还有 :
              <a-statistic-countdown title="Million Seconds" :value="dueTime" format="HH:mm:ss:SSS"
                style="margin-right: 50px" />
              <p class=" text-xl text-white font-semibold py-6">{{ dueTime }}</p>
            </div>
          </div>
          <div class=" text-justify pt-3">NFT描述 : {{ state.nft.info?.description }}</div>
        </div>
        <!-- action -->

        <!-- buy now -->
        <button type="button" v-if="state.nft.status == ItemStatus.BuyNow"
          class=" bg-purple-600 mt-14 px-10 py-2  rounded-3xl w-full mb-10"
          @click="purchaseNFT(state.nft.status, state.nft.itemId!, state.nft.price!)">立即购买</button>
        <!-- auction -->
        <div v-else-if="state.nft.status == ItemStatus.OnAuction" class=" pt-6">
          <!-- <div>amount{{ state.auction.amount }}</div>
            <div>bidder{{ state.auction.bidder }}</div>
            <div>firstBidTime{{ state.auction.firstBidTime }}</div>
            <button v-if="state.auction.firstBidTime === '0'" type="button"
              @click="clickToCancle(state.nft.itemId)">cancel
              auction</button>
            <br> -->
          <button type="button" class=" bg-purple-600 px-10 py-2  rounded-3xl w-1/3 mr-5"
            @click="purchaseNFT(state.nft.status, state.nft.itemId)">出价</button>
          <button class=" bg-purple-600 px-10 py-2  rounded-3xl w-1/3"
            @click="clickToEnd(state.nft.itemId!)">结束拍卖</button>
        </div>
      </div>
      <!-- bid -->
      <!-- <div>
        <button type="button" @click="verifyMyBid">check my bid</button>
        </div> -->
    </div>
    <div class=" w-full border-t border-white text-white">
      <p class=" border-b border-white px-10 py-4">报价情况</p>
      <p v-if="state.auction.firstBidTime == '0'" class=" text-center">暂无报价!</p>
      <p v-else>{{ state.auction.firstBidTime }}</p>
    </div>

    <a-modal title="Title" :visible="visible" @ok="offBid(bidItemId)" @cancel="visible = false">
      <input v-model="bid" />
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { useRoute, useRouter } from 'vue-router';
import { computed, onMounted, reactive, ref } from 'vue';
import { web3 } from '@/Web3/web3';
import { MarketItem, ItemStatus, Auction } from '@/types'
import { fetchMarketItemDetail, fetchAuction } from "@/service/EthService/mktService"
import { fetchMarketItems, createMarketSale, createBid, endAuction, auctionEnds, cancelAuction, verifyAuction } from '@/service/EthService/mktService';
import moment from 'moment';
/* fetch info of NFT */
const state = reactive({ nft: {} as MarketItem, auction: {} as Auction })
const route = useRoute()
const currenItemId = computed(() => {
  return route.query.id as unknown as string
})
const currentAccount = ref('')
const endsTime = ref('')
onMounted(async () => {
  try {
    currentAccount.value = (await web3.eth.getAccounts())[0]
    console.log(currentAccount.value);
    state.nft = await fetchMarketItemDetail(currenItemId.value, currentAccount.value)
    console.log(state.nft);
    if (state.nft.status == ItemStatus.OnAuction) {
      state.auction = await fetchAuction(currenItemId.value, currentAccount.value)
      console.log(state.auction);
      endsTime.value = await auctionEnds(currenItemId.value, currentAccount.value)
      console.log(endsTime.value);

    }
  } catch (error) {
    console.log(error);
  }

})


/* Buys NFT */
const visible = ref(false)
const bidItemId = ref('')
const bid = ref('')

const offBid = async (itemId: string) => {
  if (bid.value) {
    await createBid(itemId, bid.value, currentAccount.value)
  }
}

const verifyMyBid = async () => {
  await verifyAuction(currentAccount.value)
}

const router = useRouter()
const purchaseNFT = async (status: ItemStatus, itemId: string, price?: string) => {
  if (status == ItemStatus.BuyNow) {
    await createMarketSale(itemId, currentAccount.value, price!)
    router.push('/myNft')
  }
  else if (status == ItemStatus.OnAuction) {
    visible.value = true
    bidItemId.value = itemId
  }
}

/* claim nft */
const clickToEnd = async (itemId: string) => {
  await endAuction(itemId, currentAccount.value)
}

/* cancel auction */
const clickToCancle = async (itemId: string) => {
  await cancelAuction(itemId)
}

const dueTime = computed(() => {
  return moment(parseInt(endsTime.value) * 1000).format("dddd, MMMM Do YYYY, h:mm:ss a")
})
</script>
