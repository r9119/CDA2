const dashboardController = require('./controllers/dashboardController')

module.exports = (app) => {
    // Dashboard routes
    // app.get('/cda-dashboard/index',
    // dashboardController.indexCountries)

    app.get('/index-oil-price',
    dashboardController.indexOilPrice)

    app.get('/index-elec-price',
    dashboardController.indexElecPrices)

    app.get('/index-enery-gen',
    dashboardController.indexEneryGen)

    app.get('/index-emissions',
    dashboardController.indexEmissions)

    app.get('/index-share-of-elec',
    dashboardController.indexElecShare)
}