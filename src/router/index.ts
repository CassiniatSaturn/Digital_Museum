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
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

export default router
