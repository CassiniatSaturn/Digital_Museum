<template>
  <div class=" bg-purple-300">
    Interact with smart contract
    <input type="text" v-model="brand"  />
    <input type="text" v-model="data" />
    <button @click="handleInput">SUBMIT</button>
    newbrand:{{ newbrand }}newdata:{{ newdata }}
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive, computed } from "vue";
import { getNumber, setNumber, getBrand, setBrand } from "@/Web3/web3/connect";
let data = ref(0);
let brand = ref("");
let newdata = ref(0);
let newbrand = ref("");

const handleInput = async () => {
  console.log(brand.value);
  
  await setBrand(brand.value);
  getBrand().then((val) => {
    newbrand.value = val;
  });
  await setNumber(data.value);
  getNumber().then((val) => {
    newdata.value = val;
    console.log(val);
  });
};

onMounted(() => {
  getNumber().then((val) => {
    newdata.value = val;
  });
  getBrand().then((val) => {
    newbrand.value = val;
  });
});
</script>

<style scoped>
</style>