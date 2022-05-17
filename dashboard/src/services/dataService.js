import Api from './Api'

export default {
    index() {
        return Api().get('/cda-dashboard/index')
    },
    indexCountryData(country) {
        return Api().get('/cda-dashboard/index-country', {
            params: {
                country: country
            }
        })
    }
}