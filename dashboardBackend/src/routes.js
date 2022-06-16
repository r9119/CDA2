const dashboardController = require('./controllers/dashboardController')

module.exports = (app) => {
    // Dashboard routes
    // app.get('/cda-dashboard/index',
    // dashboardController.indexCountries)

    app.get('/index-oil-price',
    dashboardController.indexOilPrice)

    app.get('/index-elec-price-consumer',
    dashboardController.indexConsumerElecPrices)

    app.get('/index-elec-price-industry',
    dashboardController.indexIndustryElecPrices)

    app.get('/index-energy-gen',
    dashboardController.indexEnergyGen)

    app.get('/index-emissions',
    dashboardController.indexEmissions)

    // app.get('/index-installed-capacity',
    // dashboardController.indexInstalledCapacity)

    app.get('/index-lcoe',
    dashboardController.indexLcoe)

    app.get('/index-lm',
    dashboardController.indexLinearModel)

    app.get('/index-yearly-brent',
    dashboardController.indexYearlyBrent)

    app.get('/index-eu-emissions',
    dashboardController.indexEuEmissions)

    app.get('/index-simulation',
    dashboardController.indexSimulation)
}