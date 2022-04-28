<template>
  <div>
    <main-vue>
      <router-view />
    </main-vue>
  </div>
</template>


<script lang="ts" setup>
import { onMounted, reactive, ref } from 'vue';
import MainVue from './layout/Main.vue';
import { web3 } from './Web3/web3';
import { Role } from './types';
import { User } from '@/types'
import { useRoute } from 'vue-router';

const state = reactive({ userInfo: {} as User })

onMounted(async () => {
  console.log('1');
  
  /* verify role , store info*/
  if (localStorage.getItem('user')) localStorage.removeItem('user')
  state.userInfo.account = (await web3.eth.getAccounts())[0]
  state.userInfo.role = state.userInfo.account == '0x03E462A632c42593F42ba57738b642A2272Bc06C' ? Role.Admin : Role.visitor
  localStorage.setItem('user', JSON.stringify(state.userInfo))
})



</script>

<style lang="scss">
</style>
