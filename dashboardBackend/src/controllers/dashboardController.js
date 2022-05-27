const db = require('../models')
const BrentOilPrice = db.BrentOilPrice
const Emission = db.Emission
const ElecPrice = db.ElectricityPrice
const EneryGen = db.EnergyGeneration
const ElecShare = db.ShareOfElec


// Will add 'simple' data indexes once we have them in db
module.exports = {
    connectToDb (req, res) {
        try {

        } catch (err) {
            console.log(err)
            res.status(500).send({
                error: "There was an error connecting to the DB"
            })
        }
    },
    closeConnection (req, res) {
        try {

        } catch (err) {
            console.log(err)
            res.status(500).send({
                error: "There was an error disconnecting from the DB"
            })
        }
    },
    indexOilPrice (req, res) {
        try {
            BrentOilPrice.find({})
            .then(data => {
                res.send(data);
            })
        } catch (err) {
            console.log(err)
            res.status(500).send({
                error: "There was an error fetching oil price data"
            })
        }
    },
    indexEmissions (req, res) {
        try {
            const country = req.query.country

            Emission.find({ country: country })
            .then(data => {
                res.send(data)
            })
        } catch (err) {
            console.log(err)
            res.status(500).send({
                error: "There was an error fetching emissions data for: " + req.query.country
            })
        }
    },
    indexElecPrices (req, res) {
        try {
            const country = req.query.country

            ElecPrice.find({ country: country })
            .then(data => {
                res.send(data)
            })
        } catch (err) {
            console.log(err)
            res.status(500).send({
                error: "There was an error fetching electricity prices for: " + req.query.country
            })
        }
    },
    indexEneryGen (req, res) {
        try {
            const country = req.query.country

            EneryGen.find({ country: country })
            .then(data => {
                res.send(data)
            })
        } catch (err) {
            console.log(err)
            res.status(500).send({
                error: "There was an error fetching electricity generation data for: " + req.query.country
            })
        }
    },
    indexElecShare (req, res) {
        try {
            const country = req.query.country

            ElecShare.find({ country: country })
            .then(data => {
                res.send(data)
            })
        } catch (err) {
            console.log(err)
            res.status(500).send({
                error: "There was an error fetching share of electricity data for: " + req.query.country
            })
        }
    }
}

// If we add coal prices/more just import the model (const name = db.nameInDb) and copy one of the index functions and change the name and error message.
// After creating the function add it as a middle ware in a new route