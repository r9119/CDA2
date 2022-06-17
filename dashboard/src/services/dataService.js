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
    indexConsumerElecPrice(country) {
        return Api().get('/index-elec-price-consumer', {
            params: {
                country
            }
        })
    },
    indexIndustryElecPrice(country) {
        return Api().get('/index-elec-price-industry', {
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
    indexInstalledCapacity(country) {
        return Api().get('/index-installed-capacity', {
            params: {
                country
            }
        })
    },
    indexShareOfRenew(country) {
        return Api().get('/index-share-of-renew', {
            params: {
                country
            }
        })
    },
    indexLcoe() {
        return Api().get('/index-lcoe')
    },
    indexLm(country) {
        return Api().get('/index-lm', {
            params: {
                country
            }
        })
    },
    indexYearlyBrent() {
        return Api().get('/index-yearly-brent')
    },
    indexEuEmissions() {
        return Api().get('/index-eu-emissions')
    },
    indexSimulation(country) {
      return Api().get('/index-simulation', {
          params: {
              country
          }
      })
  },
}