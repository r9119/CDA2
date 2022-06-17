const db = require('../models')
const BrentOilPrice = db.BrentOilPrice
const Emission = db.Emission
const ConsumerPrices = db.ConsumerPrices
const IndustryPrices = db.IndustryPrices
const EnergyGen = db.EnergyGeneration
const InstalledCapacity = db.InstalledCapacity
const LCOE = db.LCOE
const LM = db.LinearModel
const YearlyBrent = db.YearlyBrentOilPrice
const EuEmissions = db.EmissionsEurope
const Simulation = db.Simulation

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

                // data.map(i => {
                //     results.push([i.period, i.value])
                // })

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
                // switch(country) {
                //     case "Spain":
                //         data[0].data.map(i => {
                //             results.push({
                //                 name: i.label,
                //                 lables: i.data.map(a => a.date),
                //                 percentages: i.data.map(a => a.percentage),
                //                 values: i.data.map(a => a.value)
                //             })
                //         })
                //         break;
                //     default:
                        data.map(i => {
                          results.push({
                              date: i.data.map(a => a.date),
                              emissions: i.data.map(a => a['Fuel combustion in public electricity and heat production'])
                          })
                      })
                        // data[0].data.map(i => {
                        //     i.data.map(j => {
                        //         results.push({
                        //             name: i.label,
                        //             data: {
                        //                 name: j.label,
                        //                 code: j.code,
                        //                 labels: j.data.map(a => a.date),
                        //                 values: j.data.map(a => a.value)
                        //             }
                        //         })
                        //     })
                        // })
                // }

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
                // switch(country) {
                //     case "Spain":
                //             data[1].data.map(i => {
                //                 results.push({
                //                     period: "Pre 2007",
                //                     data: {
                //                         name: i.label,
                //                         code: i.code,
                //                         values: i.data.map(a => a.value),
                //                         labels: i.data.map(a => a.date)
                //                     }
                //                 })
                //             })

                //             data[2].data.map(i => {
                //                 results.push({
                //                     period: "Post 2007",
                //                     data: {
                //                         name: i.label,
                //                         code: i.code,
                //                         values: i.data.map(a => a.value),
                //                         labels: i.data.map(a => a.date)
                //                     }
                //                 })
                //             })
                //         break;
                //     default:
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
                // }

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
    async indexEnergyGen (req, res) {
        try {
            let country = req.query.country

            await EnergyGen.find({ country_name: country })
            .then(data => {
                let results = []
                        data.map(i => {
                            results.push({
                                date: i.data.map(a => a.date),
                                absolute: {
                                    'Coal and manufactured gases': i.data.map(a => a['Coal and manufactured gases']),
                                    'Natural gas': i.data.map(a => a['Natural gas']),
                                    'Nuclear fuels and other fuels n_e_c_': i.data.map(a => a['Nuclear fuels and other fuels n_e_c_']),
                                    'Oil and petroleum products (exluding biofuel portion)': i.data.map(a => a['Oil and petroleum products (exluding biofuel portion)']),
                                    'Hydro': i.data.map(a => a['Hydro']),
                                    'Geothermal': i.data.map(a => a['Geothermal']),
                                    'Wind on shore': i.data.map(a => a['Wind on shore']),
                                    'Wind off shore': i.data.map(a => a['Wind off shore']),
                                    'Solar thermal': i.data.map(a => a['Solar thermal']),
                                    'Solar photovoltaic': i.data.map(a => a['Solar photovoltaic']),
                                    'Other renewable energies': i.data.map(a => a['Other renewable energies']),
                                    'Other fuels n_e_c_': i.data.map(a => a['Other fuels n_e_c_'])
                                },
                                percentage: {
                                    'Coal': i.data.map(a => a['Coal and manufactured gases percentage']),
                                    'Natural gas': i.data.map(a => a['Natural gas percentage']),
                                    'Nuclear fuels and other fuels n_e_c_': i.data.map(a => a['Nuclear fuels and other fuels n_e_c_ percentage']),
                                    'Oil and petroleum products (exluding biofuel portion)': i.data.map(a => a['Oil and petroleum products (exluding biofuel portion) percentage']),
                                    'Hydro': i.data.map(a => a['Hydro percentage']),
                                    'Geothermal': i.data.map(a => a['Geothermal percentage']),
                                    'Wind on shore': i.data.map(a => a['Wind on shore percentage']),
                                    'Wind off shore': i.data.map(a => a['Wind off shore percentage']),
                                    'Solar thermal': i.data.map(a => a['Solar thermal percentage']),
                                    'Solar photovoltaic': i.data.map(a => a['Solar photovoltaic percentage']),
                                    'Other renewable energies': i.data.map(a => a['Other renewable energies percentage']),
                                    'Other fuels n_e_c_': i.data.map(a => a['Other fuels n_e_c_ percentage'])
                                },
                                total: {
                                    'Produzierte Energie': i.data.map(a => a['Total'])
                                }
                            })
                        })
                res.send(results)
            })
        } catch (err) {
            console.log(err)
            res.status(500).send({
                error: "There was an error fetching electricity generation data for: " + req.query.country
            })
        }
    },
    async indexLcoe (req, res) {
        try {
            await LCOE.find({}).then(data => {
                res.send(data[0])
            })
        } catch (err) {
            console.log(err)
            res.status(500).send({
                error: "There was an error fetching LCOE"
            })
        }
    },
    async indexLinearModel (req, res) {
        try {
            let country = req.query.country
            let results = {
                labels: [],
                values: [],
                rValue: null,
                scatterData: []
            }

            let tempOil = []
            let tempEmissions = []
            await LM.find({ country_name: country }).then(data => {
                data[0].data.map(i => {
                    results.labels.push(i[0])
                    results.values.push(i[1])
                })
                results.rValue = data[0].r2
            })

            await YearlyBrent.find({}).then(data => {
                data = data.slice(32)
                data.map(i => {
                    tempOil.push(i.sum)
                })
            })
            await Emission.find({ country_name: country }).then(data => {
                console.log(data)
                data[0].data.map(i => {
                    tempEmissions.push(i['Fuel combustion in public electricity and heat production'])
                })
            })

            tempOil.map((element, index) => {
                results.scatterData.push({
                    x: element,
                    y: tempEmissions[index]
                })
            })

            res.send(results)
        } catch (err) {
            console.log(err)
            res.status(500).send({
                error: "There was an error fetching the linear model for " + req.query.country
            })
        }
    },
    async indexYearlyBrent (req, res) {
        try {
            await YearlyBrent.find({}).then(data => {
                let results = {
                    labels: [],
                    sums: [],
                    avgs: []
                }

                data.map(i => {
                    results.labels.push(i.year)
                    results.sums.push(i.sum)
                    results.avgs.push(i.avg)
                })

                res.send(results)
            })
        } catch (err) {
            console.log(err)
            res.status(500).send({
                error: "There was an error fetching the reduced brent oil price"
            })
        }
    },
    async indexEuEmissions (req, res) {
        try {
            await EuEmissions.find({}).then(data => {
                let results = {
                    labels: [],
                    emissions: []
                }

                data.map(i => {
                    results.labels.push(i.Year)
                    results.emissions.push(i.Electricity_and_heat)
                })

                res.send(results)
            })
        } catch (err) {
            res.status(500).send({
                error: "There was en error fetching EU emissions"
            })
        }
    },
    async indexSimulation (req, res) {
      try {
          let country = req.query.country

          await Simulation.find({ country_name: country })
          .then(data => {
              let results = []
              data.map(i => {
                  results.push({
                    consumer_price: i.consumer_price,
                    industry_price: i.industry_price,
                    unexplained_consumer: i.unexplained_consumer,
                    unexplained_industry: i.unexplained_industry,
                    percentages: i.data
                  })
              })
              res.send(results)
          })
      } catch (err) {
          console.log(err)
          res.status(500).send({
              error: "There was an error fetching simulation data for: " + req.query.country
          })
      }
  },
}

// If we add coal prices/more just import the model (const name = db.nameInDb) and copy one of the index functions and change the name and error message.
// After creating the function add it as a middle ware in a new route