import { createApp } from 'vue'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router'

import 'primevue/resources/themes/vela-purple/theme.css'

import PrimeVue from 'primevue/config'
import Menubar from 'primevue/menubar'
import Button from 'primevue/button'
import InputText from 'primevue/inputtext';

const app = createApp(App)

app.use(createPinia())
app.use(router)
app.use(PrimeVue, {ripple: true})

app.component('Menubar', Menubar)
app.component('Button', Button)
app.component('InputText', InputText)

app.mount('#app')
