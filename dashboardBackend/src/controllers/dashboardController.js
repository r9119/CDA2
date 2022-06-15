const db = require('../models')
const BrentOilPrice = db.BrentOilPrice
const Emission = db.Emission
const ConsumerPrices = db.ConsumerPrices
const IndustryPrices = db.IndustryPrices
const EneryGen = db.EnergyGeneration
const InstalledCapacity = db.InstalledCapacity
const ShareOfRenewables = db.ShareOfRenewables

// let dates = array.map(a => a.date) 

// Will add 'simple' data indexes once we have them in db
module.exports = {
    async indexOilPrice (req, res) {
        try {
            await BrentOilPrice.find({})
            .sort('period')
            .then(data => {
                // let results = {
                //     labels: data.map(a => a.period),
                //     values: data.map(a => a.value)
                // }
                let results = []

                data.map(i => {
                    results.push({
                        x: i.period,
                        y: i.value
                    })
                })

                res.send(results);
            })
        } catch (err) {
            console.log(err)
            res.status(500).send({
                error: "There was an error fetching oil price data"
            })
        }
    },
    async indexEmissions (req, res) {
        try {
            let country = req.query.country

            await Emission.find({ country_name: country })
            .then(data => {
                let results = []
                
                // If Spain is queried, REEData has a different structure than EuroStat data. So this is accounting for that
                switch(country) {
                    case "Spain":
                        data[0].data.map(i => {
                            results.push({
                                name: i.label,
                                lables: i.data.map(a => a.date),
                                percentages: i.data.map(a => a.percentage),
                                values: i.data.map(a => a.value)
                            })
                        })
                        break;
                    default:
                        data[0].data.map(i => {
                            i.data.map(j => {
                                results.push({
                                    name: i.label,
                                    data: {
                                        name: j.label,
                                        code: j.code,
                                        labels: j.data.map(a => a.date),
                                        values: j.data.map(a => a.value)
                                    }
                                })
                            })
                        })
                }

                res.send(results)
            })
        } catch (err) {
            console.log(err)
            res.status(500).send({
                error: "There was an error fetching emissions data for: " + req.query.country
            })
        }
    },
    async indexConsumerElecPrices (req, res) {
        try {
            let country = req.query.country

            await ConsumerPrices.find({ country_name: country })
            .then(data => {
                let results = []
                // If Spain is queried, skip over REE Data
                switch(country) {
                    case "Spain":
                            data[1].data.map(i => {
                                results.push({
                                    period: "Pre 2007",
                                    data: {
                                        name: i.label,
                                        code: i.code,
                                        values: i.data.map(a => a.value),
                                        labels: i.data.map(a => a.date)
                                    }
                                })
                            })

                            data[2].data.map(i => {
                                results.push({
                                    period: "Post 2007",
                                    data: {
                                        name: i.label,
                                        code: i.code,
                                        values: i.data.map(a => a.value),
                                        labels: i.data.map(a => a.date)
                                    }
                                })
                            })
                        break;
                    default:
                        data[0].data.map(i => {
                            results.push({
                                period: "Pre 2007",
                                data: {
                                    name: i.label,
                                    code: i.code,
                                    values: i.data.map(a => a.value),
                                    labels: i.data.map(a => a.date)
                                }
                            })
                        })

                        data[1].data.map(i => {
                            results.push({
                                period: "Post 2007",
                                data: {
                                    name: i.label,
                                    code: i.code,
                                    values: i.data.map(a => a.value),
                                    labels: i.data.map(a => a.date)
                                }
                            })
                        })
                }

                res.send(results)
            })
        } catch (err) {
            console.log(err)
            res.status(500).send({
                error: "There was an error fetching consumer electricity prices for: " + req.query.country
            })
        }
    },
    async indexIndustryElecPrices (req, res) {
        try {
            let country = req.query.country

            await IndustryPrices.find({ country_name: country })
            .then(data => {
                let results = []

                data[0].data.map(i => {
                    results.push({
                        period: "Pre 2007",
                        data: {
                            name: i.label,
                            code: i.code,
                            values: i.data.map(a => a.value),
                            labels: i.data.map(a => a.date)
                        }
                    })
                })

                data[1].data.map(i => {
                    results.push({
                        period: "Post 2007",
                        data: {
                            name: i.label,
                            code: i.code,
                            values: i.data.map(a => a.value),
                            labels: i.data.map(a => a.date)
                        }
                    })
                })

                res.send(results)
            })
        } catch (err) {
            console.log(err)
            res.status(500).send({
                error: "There was an error fetching consumer electricity prices for: " + req.query.country
            })
        }
    },
    async indexEneryGen (req, res) {
        try {
            let country = req.query.country

            await EneryGen.find({ country_name: country })
            .then(data => {
                let results = []

                switch(country) {
                    case "Spain":
                        data[0].data.map(i => {
                            results.push({
                                name: i.label,
                                code: i.code,
                                data: {
                                    labels: i.data.map(a => a.date),
                                    percentages: i.data.map(a => a.percentage),
                                    values: i.data.map(a => a.value)
                                }
                            })
                        })
                        break;
                    default:
                        data[0].data.map(i => {
                            results.push({
                                name: i.label,
                                code: i.code,
                                data: {
                                    labels: i.data.map(a => a.date),
                                    values: i.data.map(a => a.value)
                                }
                            })
                        })
                }

                res.send(results)
            })
        } catch (err) {
            console.log(err)
            res.status(500).send({
                error: "There was an error fetching electricity generation data for: " + req.query.country
            })
        }
    },
    async indexInstalledCapacity (req, res) {
        try {
            let country = req.query.country

            await InstalledCapacity.find({ country_name: country })
            .then(data => {
                let results = []

                switch(country) {
                    case "Spain":
                        data[0].data.map(i => {
                            results.push({
                                name: i.label,
                                code: i.code,
                                data: {
                                    labels: i.data.map(a => a.date.substring(0,10)),
                                    percentages: i.data.map(a => a.percentage),
                                    values: i.data.map(a => a.value)
                                }
                            })
                        })
                        
                        break;
                    default:
                        data[0].data.map(i => {
                            i.data.map(j => {
                                results.push({
                                    name: i.label,
                                    data: {
                                        name: j.label,
                                        code: j.code,
                                        data: {
                                            labels: j.data.map(a => a.date),
                                            values: j.data.map(a => a.value)
                                        }
                                    }
                                })
                            })
                            results.push({
                                name: i.label,
                                data: {
                                    labels: i.data.map(a => a.date),
                                    values: i.data.map(a => a.value)
                                }
                            })
                        })
                }

                res.send(results)
            })
        } catch (err) {
            console.log(err)
            res.status(500).send({
                error: "There was an error fetching share of electricity data for: " + req.query.country
            })
        }
    },
    async indexShareOfRenew (req, res) {
        try {
            let country = req.query.country

            await ShareOfRenewables.find({ country_name: country })
            .then(data => {
                let results = []

                data[0].data.map(i => {
                    results.push({
                        name: i.label,
                        code: i.code,
                        data: {
                            labels: i.data.map(a => a.date),
                            values: i.data.map(a => a.value)
                        }
                    })
                })

                res.send(results)
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