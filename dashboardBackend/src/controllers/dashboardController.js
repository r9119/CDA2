const {Log} = require('../dashboardModels')

module.exports = {
    async indexCountries (req, res) {
        try {
            const countries = await Log.findAll()

            res.send(countries)
        } catch (err) {
            console.log(err)
            res.status(500).send({
                error: "There was an error fetching country names"
            })
        }
    },
    async indexCountryData (req, res) {
        try {
            let country = req.query.country
            const data = await Log.findAll()

            res.send(data)
        } catch (err) {
            console.log(err)
            res.status(500).send({
                error: "There was an error fetching the data from country: " + req.query.country
            })
        }
    }
}