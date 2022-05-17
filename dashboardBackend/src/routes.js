const dashboardController = require('./controllers/dashboardController')

module.exports = (app) => {
    // Dashboard routes
    app.get('/cda-dashboard/index',
    dashboardController.indexCountries)

    app.get('/cda-dashboard/index-country',
    dashboardController.indexCountryData)
}