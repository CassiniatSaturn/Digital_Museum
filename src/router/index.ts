import { Role, User } from '@/types'
import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
import { web3 } from '@/Web3/web3'
/* 
  change navbar depending on the role 
    0: frontend    
    1: backend-collection
    2: backend-nft
*/

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    name: 'exhibition',
    meta: { nv: 0 },
    component: () => import('@/views/index.vue')
  },
  {
    path: '/detail',
    name: 'Detail',
    meta: { nv: 0 },
    component: () => import('@/views/detail.vue')
  },
  {
    path: '/nftMarket',
    name: 'NftMarket',
    meta: { nv: 0 },
    component: () => import('@/views/nftMarket.vue')
  },
  {
    path: '/myNft',
    name: 'MyNft',
    meta: { nv: 0 },
    component: () => import('@/views/client/myNft.vue')
  },
  {
    path: '/nftDetail',
    name: 'NFTDetail',
    meta: { nv: 0 },
    component: () => import('@/views/nftDetail.vue')
  },
  {
    path: '/manageCollections',
    name: 'ManageCollections',
    meta: { nv: 1 },
    component: () => import('@/views/management/manageCollections.vue')
  },
  {
    path: '/createCollection',
    name: 'CreateCollection',
    meta: { nv: 1 },
    component: () => import('@/views/management/Index.vue')
  },

  {
    path: '/createItems',
    name: 'CreateItems',
    meta: { nv: 2 },
    component: () => import('@/views/management/createItems.vue')
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    meta: { nv: 2 },
    component: () => import('@/views/management/dashboard.vue')
  },
  {
    path: '/setItemStatus',
    name: 'SetItemStatus',
    meta: { nv: 2 },
    component: () => import('@/views/management/setItemStatus.vue')
  },
  {
    path: '/Crypto',
    name: 'Crypto',
    component: () => import('@/views/Crypto.vue')
  },
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

router.beforeEach(async (to, from,next) => {
  const account = (await web3.eth.getAccounts())[0]
  if(to.meta.nv && account != '0x03E462A632c42593F42ba57738b642A2272Bc06C') next({name:'exhibition'})
  else next()
})

export default router
