<template>
  <div class=" w-10/12 mx-auto border border-white rounded-lg py-10 mt-10">
    <div class=" border-b border-gray-300 text-gray-400 pb-6 text-xl mx-8">{{ state.nft.info?.name }}</div>
    <div class=" flex px-10 pt-10 items-stretch">
      <!-- display info -->
      <img :src="state.nft.info?.image" class=" w-2/5" />
      <div class=" w-1/2  pl-20 text-white flex flex-col justify-between">
        <div>
          <div> tokenID : {{ state.nft.tokenId }}</div>
          <div class=" pt-3">NFT : {{ state.nft.info?.name }}</div>
          <div class=" pt-3" v-if="state.nft.owner != '0x0000000000000000000000000000000000000000'">
            所有者 : {{ state.nft.owner }}</div>
          <div v-if="state.nft.status == ItemStatus.BuyNow" class=" flex pt-3">
            价格 : {{ state.nft.price }}
            <SvgIcon iconClass="eth" class=" w-6 h-6"></SvgIcon>
          </div>
          <div class=" pt-3" v-if="state.nft.status == ItemStatus.OnAuction">
            保留价格 : {{ state.auction.reservePrice }}
            <SvgIcon iconClass="eth" class=" w-6 h-6 inline-block"></SvgIcon>
            <div class=" pt-3" v-if="+state.auction.firstBidTime">
              <a-statistic-countdown title="距离拍卖结束时间还有 :" :value="+endsTime" format="D 天 H 时 m 分 s 秒" />
            </div>
          </div>
          <div class=" text-justify pt-3">NFT描述 : {{ state.nft.info?.description }}</div>
        </div>
        <!-- action -->
        <div v-if="state.nft.status != ItemStatus.Sold" class=" h-10">
          <!-- buy now -->
          <button type="button" v-if="state.nft.status == ItemStatus.BuyNow"
            class=" bg-purple-600 px-10 py-2  rounded-3xl w-full"
            @click="purchaseNFT(state.nft.status, state.nft.itemId!, state.nft.price!)">立即购买</button>
          <!-- auction -->
          <div v-else-if="state.nft.status == ItemStatus.OnAuction">
            <button type="button" class=" bg-purple-600 px-10 py-2  rounded-3xl w-1/3 mr-5"
              @click="purchaseNFT(state.nft.status, state.nft.itemId)">出价</button>
            <button v-if="isEnd" class=" bg-purple-600 px-10 py-2  rounded-3xl w-1/3"
              @click="clickToEnd(state.nft.itemId!)">结束拍卖</button>
          </div>
        </div>
      </div>
    </div>
    <div v-if="state.nft.status == ItemStatus.OnAuction" class=" w-full border-t border-white text-white mt-16">
      <p class=" border-b border-white px-10 py-4">报价情况</p>
      <p v-if="state.auction.firstBidTime == '0'" class=" text-center">暂无报价!</p>
      <table v-else class=" w-full text-left px-10 border-separate py-5 table-fixed" style="border-spacing: 1rem;">
        <tr>
          <th class=" w-1/2">账户</th>
          <th class=" w-1/4">出价时间</th>
          <th class=" w-1/4">价格</th>
        </tr>
        <tr v-for="(bid, index) in state.bidHistory" :key="index">
          <th>{{ bid.sender }}</th>
          <th>{{ filteredDate(bid.timestamp) }}</th>
          <th class=" flex items-center">
            {{ bid.value }}
            <SvgIcon iconClass="eth" class=" w-6 h-6"></SvgIcon>
          </th>
        </tr>
      </table>
    </div>

    <a-modal wrapClassName="full-modal" :visible="visible" @ok="offBid(bidItemId)" cancelText="取消" okText="确认出价"
      @cancel="visible = false">
      <div class=" pt-10">
        <q-input label-color="deep-purple-10" color="deep-purple-10" label="请输入竞价" rounded outlined type="text"
          v-model="bid" />
      </div>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { useRoute, useRouter } from 'vue-router';
import { computed, onMounted, reactive, ref } from 'vue';
import { web3 } from '@/Web3/web3';
import { MarketItem, ItemStatus, Auction, BidHistory } from '@/types'
import { fetchMarketItemDetail, fetchAuction } from "@/service/EthService/mktService"
import { fetchMarketItems, createMarketSale, createBid, endAuction, auctionEnds, cancelAuction, verifyAuction } from '@/service/EthService/mktService';
import moment from 'moment';
/* fetch info of NFT */
const state = reactive({ nft: {} as MarketItem, auction: {} as Auction, bidHistory: [] as Array<BidHistory> })
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
      endsTime.value = (await auctionEnds(currenItemId.value, currentAccount.value)) + '000'
      await verifyMyBid()
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
    visible.value = false
    state.auction = await fetchAuction(currenItemId.value, currentAccount.value)
    endsTime.value = (await auctionEnds(currenItemId.value, currentAccount.value)) + '000'
    await verifyMyBid()
  }
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

/* get Bid History */

const verifyMyBid = async () => {
  state.bidHistory = await verifyAuction(+state.nft.tokenId)
}


/* claim nft */
const isEnd = computed(() => {
  let isEnd = false
  /* the defult of endsTime is '180' */
  if (state.auction.firstBidTime != '0') {
    if (+endsTime.value <= new Date().getTime())
      isEnd = true
  }
  return isEnd
})

const clickToEnd = async (itemId: string) => {
  await endAuction(itemId, currentAccount.value)
  state.nft = await fetchMarketItemDetail(currenItemId.value, currentAccount.value)
}

/* cancel auction */
const clickToCancle = async (itemId: string) => {
  await cancelAuction(itemId)
}

/* filteredMoment */
const filteredDate = computed(() => {
  return (timeStamp: string) => {
    return moment(+timeStamp).fromNow()
  }
})
</script>

<style>
.full-modal .ant-modal .ant-btn-primary {
  background: #1E0338;
}

.ant-statistic-title {
  color: #FFFFFF;
}

.ant-statistic-content {
  color: #FFFFFF;
}
</style>

