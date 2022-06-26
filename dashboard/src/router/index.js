import { createRouter, createWebHistory } from 'vue-router'
import landingPage from '../views/landingPage.vue'
import countryPage from '../views/countryPage.vue'
// import countryPageOld from '../views/countryPageOld.vue'
// import test from '../views/temp.vue'

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
    },
    // {
    //   path: '/details-old',
    //   name: 'countryPageOld',
    //   component: countryPageOld,
    //   props: true
    // },
    // {
    //   path: '/test',
    //   name: 'test',
    //   component: test,
    //   props: true
    // }
  ]
})

export default router
