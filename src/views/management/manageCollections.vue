<template>
  <div class=" w-10/12 mx-auto border border-white rounded-3xl my-20 px-10">
    <table class=" text-white text-center w-full py-6 border-separate" style="border-spacing: 1rem;">
      <tr>
        <th>藏品编号</th>
        <th>藏品名称</th>
        <th>数据编目日期</th>
        <th>数据编目人员</th>
        <th>藏品级别</th>
        <th>操作</th>
      </tr>
      <tr v-for="item in state.createdCollections" :key="item.id">
        <th>{{ item.id }}</th>
        <th>{{ item.cName }}</th>
        <th>{{ item.meta.date }}</th>
        <th>{{ item.meta.recorder }}</th>
        <th>{{ item.meta.level }}</th>
        <th>
          <button type="button" @click="deleteCollection(item.id)">删除</button>
          <span class=" px-2">|</span>
          <button type="button" @click="checkDetail(item.id)"> 查看详情</button>
        </th>
      </tr>
    </table>
  </div>
</template>

<script setup lang="ts">
import { CollectionWithMeta } from '@/types';
import { onMounted, reactive, ref } from 'vue';
import { getCollections, removeCollection, fetchColletionDetail } from '@/service/EthService/museumService'
import { useRoute, useRouter } from 'vue-router';
import { fetchFromIpfs } from '@/service/ipfsService';

const state = reactive({ createdCollections: {} as Array<CollectionWithMeta> })

onMounted(async () => {
  /* get all collections */
  const originList = await getCollections()
  /* get meta of collections */
  state.createdCollections = await Promise.all(
    originList.map(
      async (i) => {
        return (
          async () => {
            /* Gets metadata from ipfs */
            const data = (await fetchFromIpfs(i.metaURL)).data
            const name = i.info.cName
            const id = i.info.id
            const itemWithMeta = { id: id, cName: name, meta: data }
            return itemWithMeta
          })()
      }
    ))
  console.log(state.createdCollections);

})

const deleteCollection = async (itemID: string) => {
  await removeCollection(itemID)
}

/* go to detail */
const router = useRouter()
const checkDetail = async (itemId: string) => {
  router.push({ name: 'Detail', query: { id: itemId } })
}
</script>