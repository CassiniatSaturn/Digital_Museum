<template>
  <div class=" text-white border-b border-white py-4">
    <div class=" w-bodySet mx-auto flex justify-between">
      <div class=" flex">
        <svg-icon iconClass="logo" class=" w-8 h-8 mr-4"></svg-icon>
        <span class=" pr-10">数字故宫</span>
        <span class=" pr-10" v-for="(i, n) in items" :key="n" @click="$router.push(i.path)">
          {{ i.name }}
        </span>
      </div>

      <div class=" flex" v-if="role!=undefined">
        <svg-icon :iconClass="role == Role.Admin ? 'admin' : 'visitor'" class=" w-6 h-6 mr-4"></svg-icon>
        {{ roleName }}
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { User, Role } from '@/types';
import { computed, reactive } from 'vue';
import { useRoute } from 'vue-router';

/* role control  */
const role = computed(() => {
  const info = JSON.parse(localStorage.getItem('user')!) as User
  return localStorage.getItem('user')?info.role:undefined
})

const route = useRoute();
const roleName = computed(() => {
  return role.value == Role.Admin ? '管理中心' : '访客'
})

/* navbar content */
interface navItem {
  type: number,
  item: {
    name: string,
    path: string
  }[]
}

const navList: Array<navItem> = [
  {
    type: 0,
    item: [
      {
        name: '数字展览',
        path: '/'
      },
      {
        name: '藏品市场',
        path: '/nftMarket'
      },
      // {
      //   name: '我的NFT',
      //   path: '/myNft'
      // }
    ]
  },
  {
    type: 1,
    item: [
      {
        name: '上传',
        path: '/createCollection'
      },
      {
        name: '已发布',
        path: '/manageCollections'
      },
    ]
  },
  {
    type: 2,
    item: [
      {
        name: '藏品注册',
        path: '/createItems'
      },
      {
        name: '藏品上市',
        path: '/dashboard'
      },
      // {
      //   name: '在市藏品',
      //   path: '/nftMarket'
      // },
    ]
  }
]

const items = computed(() => {
  return route.meta.nv != undefined ? navList[route.meta.nv as unknown as number].item : []
})
</script>

