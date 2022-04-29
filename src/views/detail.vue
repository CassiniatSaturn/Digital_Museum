<template>
  <div class=" w-8/12 mx-auto">
    <div class=" text-gray-400 text-lg pt-10 pb-5">{{ state.detail.cName }} · {{ genre(state.detail.genre) }}</div>
    <div class=" flex text-white">
      <img :src="getFileUrl(state.detail.imgHash)" class=" w-1/2 pr-20" />
      <div class=" w-1/2">
        <div>朝代：{{ state.detail.dynasty }}</div>
        <div class=" pt-4">作者：{{ state.detail.author }}</div>
        <div class=" pt-4 justify-between">描述：{{ des }}</div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { fetchColletionDetail } from "@/service/EthService/museumService";
import { computed, onMounted } from "@vue/runtime-core";
import { reactive, ref } from "vue";
import { Collection, Info } from "@/types";
import { fetchFromIpfs, getFileUrl } from "@/service/ipfsService";
import { Category } from "@/types";
import { web3 } from "@/Web3/web3";
import { useRoute } from "vue-router";

/* fetch collection list */
let state = reactive({ detail: {} as Info });
let currentAccount = ref('')
const route = useRoute()

const currentID = computed((): string => {
  console.log(route.query.id);

  return (route.query.id ? route.query.id : '') as string
})

const des = ref('')
onMounted(async () => {
  if (currentID.value) {
    currentAccount.value = (await web3.eth.getAccounts())[0]
    state.detail = await fetchColletionDetail(currentID.value, currentAccount.value)
    des.value = ((await fetchFromIpfs(state.detail.detailHash)).data) as unknown as string
  }
})

/* filteredGenre */
const genre = computed(() => {
  return (type: number) => {
    let result
    if (type == 0) result = "珠宝首饰"
    else if (type == 1) result = "绘画"
    else if (type == 2) result = "陶瓷"
    return result
  }
})
</script>

<style scoped>
</style>