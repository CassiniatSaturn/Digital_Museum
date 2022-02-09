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
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

export default router
