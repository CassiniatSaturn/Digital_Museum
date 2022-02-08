<template>
  <div>

    <div v-for="(item, index) in state.collectionList" :key="index">
      <div>展品名称{{ item.cName }}</div>
      <div>作者{{ item.author }}</div>
      <div>分类{{ transGenre(item.genre) }}</div>
      <div>详情{{ item.detailHash }}</div>
      <div>朝代{{ item.dynasty }}</div>
      <img :src="getImgUrl(item.imgHash)" class="w-20" />
      <q-chip clickable color="red" text-color="white" @click="addToFavor(index)" icon="favorite">
        收藏
      </q-chip>
    </div>
  
  </div>
</template>

<script setup lang="ts">
import { getCollections } from "@/service/ethService";
import { computed, onMounted } from "@vue/runtime-core";
import { reactive, ref } from "vue";
import { Collection } from "@/types";
import { fetchFromIpfs, getImgUrl } from "@/service/ipfsService";
import { Category } from "@/types";
import svgIcon from "@/components/svgIcon.vue"

/* fetch collection list */
let state = reactive({ collectionList: [] as Collection[] });
let imgUrl = ref("");

(async () => {
  getCollections().then((list) => {
    console.log(list);
    
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

/* filter */
const transGenre = (type: Category): string => {
  let result = "";
  if (type == Category.jewelry) result = "珠宝首饰";
  if (type == Category.painting) result = "绘画";
  if (type == Category.pottery) result = "陶瓷";
  return result;
};

/* add item to favorite list */
const addToFavor = (index: number) => {
  console.log(index);
  
};
</script>

<style scoped>
</style>