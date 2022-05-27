import Api from './Api'

export default {
    indexOilPrice() {
        return Api().get('/index-oil-price')
    },
    indexEmissions(country) {
        return Api().get('/index-emissions', {
            params: {
                country
            }
        })
    },
    indexElecPrice(country) {
        return Api().get('/index-elec-price', {
            params: {
                country
            }
        })
    },
    indexEnergyGen(country) {
        return Api().get('/index-energy-gen', {
            params: {
                country
            }
        })
    },
    indexElecShare(country) {
        return Api().get('/index-share-of-elec', {
            params: {
                country
            }
        })
    }
}