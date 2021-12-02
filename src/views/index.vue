<template>
  <div>
    <div v-for="(item, index) in state.collectionList" :key="index">
      <div>展品名称{{ item.cName }}</div>
      <div>作者{{ item.author }}</div>
      <div>分类{{ item.genre }}</div>
      <div>详情{{ item.detailHash }}</div>
      <div>朝代{{ item.dynasty }}</div>
      <img :src="getImgUrl(item.imgHash)" class="w-20" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { getCollections } from "@/service/ethService";
import { onMounted } from "@vue/runtime-core";
import { reactive, ref } from "vue";
import { Collection } from "@/types";
import { fetchFromIpfs, getImgUrl } from "@/service/ipfsService";

/* fetch collection list */
let state = reactive({ collectionList: [] as Collection[] });
let imgUrl = ref("");
(async () => {
  getCollections().then((list) => {
    list.map((item: Collection) => {
      const { id, cName, author, dynasty, genre, imgHash } = item;
      let detailHash: string;
      fetchFromIpfs(item.detailHash).then((res: any) => {
        detailHash = res.data;
        state.collectionList.push({
          id,
          author,
          cName,
          detailHash,
          dynasty,
          genre,
          imgHash,
        });
        
      });
      
    });
  });
})();
</script>

<style scoped>
</style>