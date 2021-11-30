import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
import Index from '../views/management/Index.vue'

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    name: 'About',
    component: Index
  },
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

export default router
