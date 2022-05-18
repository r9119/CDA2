import { createRouter, createWebHistory } from 'vue-router'
import landingPage from '../views/landingPage.vue'
import countryPage from '../views/countryPage.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'landingPage',
      component: landingPage
    },
    {
      path: '/details',
      name: 'countryPage',
      component: countryPage,
      props: true
    }
  ]
})

export default router
