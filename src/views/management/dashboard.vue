<template>
  <div>
    <div v-for="item in state.createdList" :key="item.itemId">
      <div>{{ item.itemId }}</div>
      <div>{{ item.tokenId }}</div>
      <div>{{ item.info?.name }}</div>
      <div>{{ item.info?.description }}</div>
      <div>
        <img :src="item.info?.image" />
      </div>
      <div>Status</div>
      <div>{{ item.status }}</div>
      <div>
        <button v-if="item.status == ItemStatus.New" @click="changeStatus(item.itemId)">Sell it!</button>
        <button v-else-if="item.status == ItemStatus.OnAuction" @click="changeStatus(item.itemId)"></button>
      </div>
      <div>
        <button @click="deleteItem(item.itemId)">delete it</button>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { fetchItemsCreated,removeMktItem } from '@/service/EthService/mktService';
import { MarketItem } from '@/types';
import { onMounted, reactive, ref } from 'vue';
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

const deleteItem = async(itemId:string)=>{
  await removeMktItem(itemId)
}
</script>