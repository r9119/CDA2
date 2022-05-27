import { createApp } from 'vue'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router'
import PrimeVue from 'primevue/config'

import 'primevue/resources/themes/saga-blue/theme.css'
import 'primevue/resources/primevue.min.css'
import 'primeicons/primeicons.css'
import '/node_modules/primeflex/primeflex.css'

import Menubar from 'primevue/menubar'
import Button from 'primevue/button'
import InputText from 'primevue/inputtext'
import Dropdown from 'primevue/dropdown'
import SplitButton from 'primevue/splitbutton'
import SpeedDial from 'primevue/speeddial'
import Divider from 'primevue/divider'
import Card from 'primevue/card'
import TabView from 'primevue/tabview';
import TabPanel from 'primevue/tabpanel';

const app = createApp(App)

app.use(createPinia())
app.use(router)
app.use(PrimeVue, {ripple: true})

app.component('Button', Button)
app.component('InputText', InputText)
app.component('Menubar', Menubar)
app.component('Dropdown', Dropdown)
app.component('SplitButton', SplitButton)
app.component('SpeedDial', SpeedDial)
app.component('Card', Card)
app.component('Divider', Divider)
app.component('TabView', TabView)
app.component('TabPanel', TabPanel)


app.mount('#app')
