<template>
  <div class="bg-purple-300">
    <div>
      <p>作品名稱</p>
      <input type="text" v-model="cName" />
    </div>
    <div>
      <p>作者名稱</p>
      <input type="text" v-model="author" />
    </div>
    <div>
      <p>詳情hash</p>
      <input type="text" v-model="detailHash" />
    </div>
    <div>
      <p>圖片hash</p>
      <input type="text" v-model="imgHash" />
    </div>
    <div>
      <p>朝代</p>
      <input type="text" v-model="dynasty" />
    </div>
    <div>
      <p>分類</p>
      <q-select
        :modelValue="displayedValue"
        :options="typeList"
        @update:modelValue="type = typeList.indexOf(displayedValue)"
      />
    </div>
    <button @click="createNewCollection">創建</button>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive, computed,toRefs } from "vue";
import { getCollections, createCollection } from "@/service/ethService";
import { fetchFromIpfs, getImgUrl } from "@/service/ipfsService";
import { Collection } from "@/types";

/* create a collection */
const cName = ref("");
const author = ref("");
const detailHash = ref("");
const imgHash = ref("");
const dynasty = ref("");
const typeList=[ 'jewelry','painting','pottery']
const displayedValue = ref(typeList[0])
const type = ref(0)

const createNewCollection = async ()=>{
  await createCollection(cName.value,author.value,detailHash.value,dynasty.value,imgHash.value,type.value)
  fetchCollections()
}

/* fetch the collection list */
let state = reactive({collectionList:[]as Collection[]})
const fetchCollections = async()=>{
  state.collectionList = await getCollections()
  console.log(state.collectionList);
}
const handleUpdate = (value:any)=>{
  console.log(value);
}
</script>

<style scoped>
</style>