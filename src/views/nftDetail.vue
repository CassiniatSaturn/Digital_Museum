<template>
  <div>
    <div>information</div>
    <div>name:{{ state.nft.info?.name }}</div>
    <div>des:{{ state.nft.info?.description }}</div>
    <div>
      <img :src="state.nft.info?.image" />
    </div>
    <div>status:{{ state.nft.status }}</div>
    <!-- buy now -->
    <div v-if="state.nft.status == ItemStatus.BuyNow">
      <div>price:{{ state.nft.price }}</div>
      <button
        type="button"
        @click="purchaseNFT(state.nft.status, state.nft.itemId!, state.nft.price!)"
      >purchase</button>
    </div>
    <!-- bid -->
    <div v-else-if="state.nft.status == ItemStatus.OnAuction">
      <div>amount{{ state.auction.amount }}</div>
      <div>bidder{{ state.auction.bidder }}</div>
      <div>endsTime{{ endsTime }}</div>
      <div>reservePrice{{ state.auction.reservePrice }}</div>
      <div>firstBidTime{{ state.auction.firstBidTime }}</div>
      <button type="button" @click="purchaseNFT(state.nft.status, state.nft.itemId)">bid for it</button>
      <br/>
      <button @click="clickToEnd(state.nft.itemId!)">endAuction</button>
    </div>
    <a-modal title="Title" :visible="visible" @ok="offBid(bidItemId)" @cancel="visible = false">
      <input v-model="bid" />
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue';
import { useRoute } from 'vue-router';
import { web3 } from '@/Web3/web3';
import { MarketItem, ItemStatus, Auction } from '@/types'
import { fetchMarketItemDetail, fetchAuction } from "@/service/EthService/mktService"
import { fetchMarketItems, createMarketSale, createBid, endAuction,auctionEnds } from '@/service/EthService/mktService';

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
      endsTime.value = await auctionEnds(currenItemId.value,currentAccount.value)
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

const purchaseNFT = async (status: ItemStatus, itemId: string, price?: string) => {
  if (status == ItemStatus.BuyNow) {
    await createMarketSale(itemId, currentAccount.value, price!)
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
</script>
