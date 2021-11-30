import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'
import 'tailwindcss/tailwind.css'
import { Quasar } from 'quasar'
import '@/styles/quasar.scss'
import 'quasar/dist/quasar.css'
import '@quasar/extras/eva-icons/eva-icons.css'
import '@quasar/extras/roboto-font/roboto-font.css'
import '@quasar/extras/material-icons/material-icons.css'
import ipfs from 'ipfs-http-client'
import "ant-design-vue/dist/antd.css";
import { Upload } from 'ant-design-vue'
const app = createApp(App)

app.use(store).use(router).use(Quasar).use(Upload).mount('#app')
