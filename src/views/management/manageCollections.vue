<template>
  <div>
    <div>Collections</div>
    <div v-for="item in state.createdCollections" :key="item.id">
      <div>name:{{ item.cName }}</div>
      <div>id:{{ item.id }}</div>
      <button type="button" @click="deleteCollection(item.id)">delete it</button>
      <button type="button" @click="checkDetail(item.id)">see detail</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Collection } from '@/types';
import { onMounted, reactive, ref } from 'vue';
import { getCollections,removeCollection,fetchColletionDetail } from '@/service/EthService/museumService'
import { digitalMuseum } from '@/Web3/web3';

const state = reactive({ createdCollections: {} as Array<Collection> })

onMounted(async () => {
  state.createdCollections = await getCollections()
  console.log(state.createdCollections);

})

const deleteCollection = async(itemID:string)=>{
  await removeCollection(itemID)
  const list = await getCollections()
  console.log(list);
}

const checkDetail = async(itemId:string)=>{
  const item = await fetchColletionDetail(itemId,digitalMuseum.from)
  console.log(item);
  
}
</script>