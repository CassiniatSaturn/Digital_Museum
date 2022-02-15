import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    name: 'exhibition',
    component: () => import('@/views/index.vue')
  },
  {
    path: '/create',
    name: 'CreateCollection',
    component: () => import('@/views/management/Index.vue')
  },
  {
    path: '/createItems',
    name: 'CreateItems',
    component: () => import('@/views/management/createItems.vue')
  },
  {
    path: '/nftMarket',
    name: 'NftMarket',
    component: () => import('@/views/nftMarket.vue')
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: () => import('@/views/management/dashboard.vue')
  },
  {
    path: '/setItemStatus',
    name: 'SetItemStatus',
    component: () => import('@/views/management/setItemStatus.vue')
  },
  {
    path: '/myNft',
    name: 'MyNft',
    component: () => import('@/views/client/myNft.vue')
  },
  {
    path: '/nftDetail',
    name: 'NFTDetail',
    component: () => import('@/views/nftDetail.vue')
  },
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

export default router
