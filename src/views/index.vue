<template>
  <div class=" w-10/12 mx-auto">
    <div class=" text-center text-white font-bold py-5">探索展览</div>
    <div class=" text-white flex justify-around py-3 border-b border-gray-800">
      <div v-for="(i, index) in genres" :key="index" @click="currentGenres = index">{{ i }}</div>
    </div>

    <div class="  flex flex-wrap mt-6 ">
      <div v-for="(item, index) in list" :key="index" class="w-1/3 px-4 pb-8" @click="goToDetail(item.id)">
        <div class=" border border-white rounded-md w-full">
          <img :src="getFileUrl(item.imgHash)" class=" h-96 w-full rounded-t-md" />
          <div class=" text-lg text-gray-500 text-center my-2"> <span class=" pr-2">{{ item.cName }} </span><span
              class=" text-sm"> {{ item.dynasty }}</span></div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { getCollections } from "@/service/EthService/museumService";
import { computed, onMounted } from "@vue/runtime-core";
import { reactive, ref } from "vue";
import { Collection, Info } from "@/types";
import { fetchFromIpfs, getFileUrl } from "@/service/ipfsService";
import { Category } from "@/types";
import { web3 } from "@/Web3/web3";
import { useRouter } from "vue-router";

/* fetch collection list */
let state = reactive({ collectionList: [] as Info[] });
let currentAccount = ref('')

onMounted(async () => {
  currentAccount.value = (await web3.eth.getAccounts())[0]
  const list = await getCollections()
  console.log(list);
  list.map(async (item: Collection) => {
    const { id, cName, author, dynasty, genre, imgHash } = item.info;
    const res = await fetchFromIpfs(item.info.detailHash)
    const detailHash = res.data
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
})

/* collection genre */
const genres = ['全部', '珠宝首饰', '绘画', '陶瓷']
const currentGenres = ref(0)

const list = computed(() => {
  const filtered = state.collectionList.filter(i => {
    if (currentGenres.value) {
      if (i.genre == currentGenres.value - 1) {
        return i
      }
    }
  })
  return currentGenres.value ? filtered : state.collectionList
})


/* filter */
const transGenre = (type: Category): string => {
  let result = "";
  if (type == Category.jewelry) result = "珠宝首饰";
  if (type == Category.painting) result = "绘画";
  if (type == Category.pottery) result = "陶瓷";
  return result;
};

const router = useRouter()
const goToDetail = (id: string) => {
  router.push({ name: 'Detail', query: { id: id } })
}
</script>

<style scoped>
</style>