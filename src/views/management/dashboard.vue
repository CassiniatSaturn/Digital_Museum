<template>
  <div class=" w-10/12 mx-auto border border-white rounded-3xl my-20 px-10">
    <table class=" text-white text-center w-full py-6 border-separate" style="border-spacing: 1rem;">
      <tr>
        <th>NFT</th>
        <th>NFT Token ID</th>
        <th>状态</th>
        <th>操作</th>
      </tr>
      <tr v-for="item in state.createdList" :key="item.itemId">
        <th>{{ item.info?.name }}</th>
        <th>{{ item.tokenId }}</th>
        <th>{{ filteredStatus(+item.status) }}</th>
        <th>
          <button @click="router.push({ name: 'NFTDetail', query: { id: item.itemId } })">详情</button>
          <button v-if="item.status == ItemStatus.New" @click="changeStatus(item.itemId)"><span
              class=" px-4">|</span>上市</button>
          <button v-if="item.status != ItemStatus.OnAuction" @click="deleteItem(item.itemId)">
            <span class=" px-4">|</span>
            删除
          </button>
          <button v-if="item.status == ItemStatus.OnAuction" @click="cancelAuc(item.itemId)">
            <span class=" px-4">|</span>
            取消拍卖
          </button>
        </th>
      </tr>
    </table>
  </div>
</template>

<script lang="ts" setup>
import { cancelAuction, fetchItemsCreated, removeMktItem } from '@/service/EthService/mktService';
import { MarketItem } from '@/types';
import { computed, onMounted, reactive, ref } from 'vue';
import { ItemStatus } from '@/types';
import { useRoute, useRouter } from 'vue-router';

const state = reactive({ createdList: {} as Array<MarketItem> })

onMounted(async () => {
  state.createdList = await fetchItemsCreated()
  console.log(state.createdList);
})

const router = useRouter()
const changeStatus = (id: string) => {
  router.push({ name: 'SetItemStatus', query: { id: id } });
}

const deleteItem = async (itemId: string) => {
  await removeMktItem(itemId)
  state.createdList = await fetchItemsCreated()
}

const filteredStatus = computed(() => {
  return (status: number) => {
    let result
    switch (status) {
      case ItemStatus.BuyNow:
        result = "以固定价格出售中"
        break;
      case ItemStatus.New:
        result = "未上架"
        break;
      case ItemStatus.OnAuction:
        result = "拍卖中"
        break; case ItemStatus.Sold:
        result = "已出售"
        break;
    }
    return result
  }
})

/* cancel auction */
const cancelAuc = async (id: string) => {
  await cancelAuction(id)
  state.createdList = await fetchItemsCreated()
}
</script>