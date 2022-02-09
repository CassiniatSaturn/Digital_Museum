<template>
  <div>
    price<input type="text" placeholder="please enter the price" v-model="price"/>
    url<input type="text" placeholder="please enter the ipfs hash" v-model="url" />
    <button type="button" @click="create">create digital asset</button>
  </div>
</template>

<script setup lang="ts">
import {createMktItem} from "@/service/EthService/mktService"
import { ref } from "vue";


const price = ref(0)
const url = ref('')
const create = async ()=>{ 
  await createMktItem(price.value,url.value)
  console.log('item has been created');
  
}
</script>