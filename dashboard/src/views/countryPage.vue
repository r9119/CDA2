<template>
    <div id="landing-page-main">
        <div id="nav-bar">
            <Navbar />
        </div>

        <div v-if="loading">
            <div style="position: absolute; top: 50%; left: 50%;">
                <i class="pi pi-spin pi-spinner" style="font-size: 5rem; color: #551a8b;"></i>
            </div>
        </div>

        <div v-else id="details-box">
            <div class="col-11 mx-auto">
                <Card>
                    <template #title>
                       Eine Analyse der Effekte des Brentölpreises auf die Emissionen in: {{ $route.query.land }}
                    </template>
                    <template #content>
                        <div id="charts" class="grid">
                            <div class="col-12 mx-auto">
                                <Card id="oil-card">
                                    <template #header>
                                        <TabView>
                                            <TabPanel header="Simple">
                                                <Line 
                                                    :chart-options="oilOptionsReduced"
                                                    :chart-data="oilPriceReduced"
                                                    chart-id="oil-price-chart-reduced"
                                                    :width="400"
                                                    :height="180"
                                                />
                                            </TabPanel>
                                            <TabPanel header="Detailed">
                                                <Line 
                                                    :chart-options="oilOptions"
                                                    :chart-data="oilPrice"
                                                    chart-id="oil-price-chart-full"
                                                    :width="400"
                                                    :height="180"
                                                />
                                            </TabPanel>
                                        </TabView>
                                    </template>
                                    <template #content>
                                        {{ dataStory.oilSection }}
                                    </template>
                                    <template #footer>
                                        <b>Quelle:</b>
                                        <p><a target="_blank" href="https://tradingeconomics.com/commodity/brent-crude-oil">Brentölpreis</a></p>
                                    </template>
                                </Card>

                                <Divider align="center">
                                    <b>Woher kommt die Energie?</b>
                                </Divider>

                                <Card id="share-of-elec-card">
                                    <template #header>
                                        <Line
                                            :chart-options="shareOfElecOptions"
                                            :chart-data="shareOfElec"
                                            chart-id="share-of-electricity-chart"
                                            :width="400"
                                            :height="180"
                                        />
                                    </template>
                                    <template #content>
                                        {{ dataStory.shareOfElecSection }}
                                    </template>
                                    <template #footer>
                                        <b>Quelle:</b>
                                        <p><a target="_blank" href="https://ec.europa.eu/eurostat/databrowser/view/nrg_cb_pem/default/table?lang=en&category=env.env_air.env_air_ai">Eurostat</a></p>
                                    </template>
                                </Card>

                                <Divider align="center">
                                    <b>Werden die Energiepreise betroffen?</b>
                                </Divider>

                                <Card id="elec-price-card">
                                    <template #header>
                                        <TabView>
                                            <TabPanel header="Vor 2007 (Househalte)">
                                                <Line
                                                    :chart-options="elecPriceOptions"
                                                    :chart-data="elecPricesConsumerPre2007"
                                                    chart-id="consumer-electricity-prices-chart-pre-2007"
                                                    :width="400"
                                                    :height="180"
                                                />
                                            </TabPanel>
                                            <TabPanel header="Nach 2007 (Househalte)">
                                                <Line
                                                    :chart-options="elecPriceOptions"
                                                    :chart-data="elecPricesConsumerPost2007"
                                                    chart-id="consumer-electricity-prices-chart-post-2007"
                                                    :width="400"
                                                    :height="180"
                                                />
                                            </TabPanel>
                                            <TabPanel header="Vor 2007 (Industrie)">
                                                <Line
                                                    :chart-options="elecPriceOptions"
                                                    :chart-data="elecPricesIndustryPre2007"
                                                    chart-id="industry-electricity-prices-chart-pre-2007"
                                                    :width="400"
                                                    :height="180"
                                                />
                                            </TabPanel>
                                            <TabPanel header="Nach 2007 (Industrie)">
                                                <Line
                                                    :chart-options="elecPriceOptions"
                                                    :chart-data="elecPricesIndustryPost2007"
                                                    chart-id="industry-electricity-prices-chart-post-2007"
                                                    :width="400"
                                                    :height="180"
                                                />
                                            </TabPanel>
                                        </TabView>
                                        
                                    </template>
                                    <template #content>
                                        {{ dataStory.elecPriceSection }}
                                    </template>
                                    <template #footer>
                                        <b>Quellen:</b>
                                        <p><a target="_blank" href="https://ec.europa.eu/eurostat/databrowser/view/nrg_pc_204_h/default/table?lang=en&category=env.env_air.env_air_ai">Haushaltpreise vor 2007</a>  <a target="_blank" href="https://ec.europa.eu/eurostat/databrowser/view/nrg_pc_204/default/table?lang=en&category=env.env_air.env_air_ai">Haushaltsppreise nach 2007</a> <a target="_blank" href="https://ec.europa.eu/eurostat/databrowser/view/nrg_pc_205_h/default/table?lang=en&category=env.env_air.env_air_ai">Industriepreise vor 2007</a> <a target="_blank" href="https://ec.europa.eu/eurostat/databrowser/view/nrg_pc_205/default/table?lang=en&category=env.env_air.env_air_ai">Industrieppreise nach 2007</a></p>
                                    </template>
                                </Card>

                                <Divider align="center">
                                    <b>Wie viel Energie wird produziert?</b>
                                </Divider>

                                <Card id="energy-gen-card">
                                    <template #header>
                                        <Line
                                            :chart-options="energyGenerationOptions"
                                            :chart-data="energyGeneration"
                                            chart-id="energy-generation-chart"
                                            :width="400"
                                            :height="180"
                                        />
                                    </template>
                                    <template #content>
                                        {{ dataStory.energyGenSection }}
                                    </template>
                                    <template #footer>
                                        <b>Quellen:</b>
                                        <p><a target="_blank" href="https://ec.europa.eu/eurostat/databrowser/view/nrg_cb_pem/default/table?lang=en&category=env.env_air.env_air_ai">Eurostat</a></p>
                                    </template>
                                </Card>

                                <Divider align="center">
                                    <b>Emissionen aus dem Energiesektor</b>
                                </Divider>

                                <Card id="emissions-card">
                                    <template #header>
                                        <Line
                                            :chart-options="emissionOptions"
                                            :chart-data="emissions"
                                            chart-id="energy-emissions-chart"
                                            :width="400"
                                            :height="180"
                                        />
                                    </template>
                                    <template #content>
                                        {{ dataStory.emissionsSection }}
                                    </template>
                                    <template #footer>
                                        <b>Quellen:</b>
                                        <p><a target="_blank" href="https://ec.europa.eu/eurostat/databrowser/view/env_air_gge/default/table?lang=en&category=env.env_air.env_air_ai">Eurostat</a></p>
                                    </template>
                                </Card>

                                <Divider align="center">
                                    <b>Hat der Ölpreis einen Einfluss auf Emissionen?</b>
                                </Divider>

                                <Card id="model-card">
                                    <template #header>
                                        <Scatter
                                            :chart-options="linearModelOptions"
                                            :chart-data="linearModel"
                                            chart-id="linear-model-chart"
                                            :width="400"
                                            :height="180"
                                        />
                                    </template>
                                    <template #content>
                                            {{ dataStory.modelSection }}
                                    </template>
                                    <template #footer>
                                        <b>Quellen:</b>
                                        <p><a target="_blank" href="https://tradingeconomics.com/commodity/brent-crude-oil">Brentölpreis</a>  <a target="_blank" href="https://ourworldindata.org/grapher/co-emissions-by-sector?country=~European+Union+%2827%29">Emissionen</a></p>
                                    </template>
                                </Card>

                                <Divider align="center">
                                    <b>Wie verändert sich der Strompreis, wenn der Anteil fossiler Brennstoffe ändert</b>
                                </Divider>

                                <Card>
                                    <template #header>
                                        <div class="col-10 mx-auto">
                                            <div class="col-3" style="display: inline-block">
                                                <Dropdown style="width: 100%" v-model="simulation.increasingSector" :options="simulation.increaseOptions" optionLabel="label" placeholder="Technologie zum Erhöhen" @change="updateMinMax" />
                                            </div>
                                            <div class="col-6" style="display: inline-block">
                                                <b>{{simulation.increasingSector.label}}:</b> {{simulation.values[simulation.increasingSector.value] * 100}}%
                                                <Slider :step="0.01" style="margin: 10px;" v-model="simulation.values[simulation.decreasingSector.value]" :min="simulation.min" :max="simulation.max" @change="updateIncreaseValue" />
                                                <b>{{simulation.decreasingSector.label}}:</b> {{simulation.values[simulation.decreasingSector.value] * 100}}%
                                            </div>
                                            <div class="col-3" style="display: inline-block">
                                                <Dropdown style="width: 100%" v-model="simulation.decreasingSector" :options="simulation.decreaseOptions" optionLabel="label" placeholder="Technologie zum Senken" @change="updateMinMax" />
                                            </div>
                                        </div>

                                        <Bar
                                            :chart-options="simulationOptions"
                                            :chart-data="simulationData"
                                            chart-id="simulation-chart"
                                            :width="400"
                                            :height="180"
                                        />
                                    </template>
                                    <template #content>
                                            {{ dataStory.simulationSection }}
                                    </template>
                                    <template #footer>
                                        <b>Quellen:</b>
                                        <p><a target="_blank" href="https://ourworldindata.org/cheap-renewables-growth">LCOEs</a>  <a target="_blank" href="https://ec.europa.eu/eurostat/databrowser/view/nrg_pc_204/default/table?lang=en&category=env.env_air.env_air_ai">Haushaltspreis</a> <a target="_blank" href="https://ec.europa.eu/eurostat/databrowser/view/nrg_pc_205/default/table?lang=en&category=env.env_air.env_air_ai">Industrieppreis</a> <a target="_blank" href="https://ec.europa.eu/eurostat/databrowser/view/nrg_cb_pem/default/table?lang=en&category=env.env_air.env_air_ai">Anteile Energieproduktion</a></p>
                                    </template>
                                </Card>
                            </div>
                        </div>
                    </template>
                </Card>
            </div>
        </div>
    </div>
</template>

<script>
import Navbar from '../components/NavBar.vue'
import dataService from '../services/dataService'
import story from '../../../Data sets/spain-dataStory.json'
import { Line, Bar, Scatter } from 'vue-chartjs'
import { Chart as ChartJS, Title, Tooltip, Legend, LineElement, BarElement, LinearScale, PointElement, CategoryScale, Decimation, TimeScale } from 'chart.js'
import chartZoom from 'chartjs-plugin-zoom'
import annotationPlugin from 'chartjs-plugin-annotation';
import {sum, round} from 'mathjs'

ChartJS.register(Title, Tooltip, Legend, LineElement, BarElement, LinearScale, PointElement, CategoryScale, chartZoom, annotationPlugin, Decimation, TimeScale)

// Dropdown with year selection by LM
// One graph with all years with no scatter data to compare years

export default {
    components: {
        Navbar,
        Line,
        Bar,
        Scatter
    },
    data() {
        return {
            loading: true,
            temp: null,
            oilOptions: {
                responsive: true,
                interaction: {
                    mode: 'index',
                    intersect: false
                },
                scales: {
                    y: {
                        title: {
                            display: true,
                            text: "Brentölpreis ($)"
                        },
                        ticks: {
                            callback: function(value, index, ticks) {
                                return "$" + value
                            }
                        }
                    },
                    x: {
                        title: {
                            display: true,
                            text: "Datum"
                        }
                    }
                },
                plugins: {
                    title: {
                        display: true,
                        text: "Der Brentölpreis im Überblick"
                    },
                    annotation: {
                        annotations: {
                            label1: {
                                type: 'label',
                                xValue: '2008-07-03',
                                yValue: 144,
                                xAdjust: 100,
                                yAdjust: -5,
                                backgroundColor: 'rgba(245,245,245)',
                                content: ['Die 2008 Immobilienkreise.'],
                                textAlign: 'start',
                                font: {
                                    size: 12
                                },
                                callout: {
                                    enabled: true,
                                    side: 10
                                }
                            },
                            label2: {
                                type: 'label',
                                xValue: '2020-02-20',
                                yValue: 51,
                                xAdjust: -100,
                                yAdjust: 50,
                                backgroundColor: 'rgba(245,245,245)',
                                content: ['Der Covid Öl crash.'],
                                textAlign: 'start',
                                font: {
                                    size: 12
                                },
                                callout: {
                                    enabled: true,
                                    side: 10
                                }
                            }
                        }
                    }
                }
            },
            oilOptionsReduced: {
                responsive: true,
                interaction: {
                    mode: 'index',
                    intersect: false
                },
                scales: {
                    y: {
                        title: {
                            display: true,
                            text: "Brentölpreis ($)"
                        },
                        ticks: {
                            callback: function(value, index, ticks) {
                                return "$" + value
                            }
                        }
                    },
                    x: {
                        title: {
                            display: true,
                            text: "Datum"
                        }
                    }
                },
                plugins: {
                    title: {
                        display: true,
                        text: "Der Brentölpreis im Überblick"
                    },
                    annotation: {
                        annotations: {
                            label1: {
                                type: 'label',
                                xValue: 18,
                                yValue: 92.554,
                                xAdjust: -125,
                                yAdjust: -10,
                                backgroundColor: 'rgba(245,245,245)',
                                content: ['Die 2008 Immobilienkreise.'],
                                textAlign: 'start',
                                font: {
                                    size: 12
                                },
                                callout: {
                                    enabled: true,
                                    side: 10
                                }
                            }
                        }
                    }
                }
            },
            shareOfElecOptions: {
                responsive: true,
                interaction: {
                    mode: 'index',
                    intersect: false
                },
                scales: {
                    y: {
                        title: {
                            display: true,
                            text: "Anteil (%)"
                        },
                        ticks: {
                            callback: function(value, index, ticks) {
                                return value * 100 + "%"
                            }
                        }
                    },
                    x: {
                        title: {
                            display: true,
                            text: "Datum"
                        }
                    }
                },
                plugins: {
                    title: {
                        display: true,
                        text: `Der Anteil Stromerzeugung nach Quellen in ${this.$route.query.land}`
                    },
                    zoom: {
                        limits: {
                            y: {min: 0, max: 1}
                        },
                        pan: {
                            enabled: true
                        },
                        zoom: {
                            wheel: {
                                enabled: true,
                                speed: 0.3
                            }
                        }
                    }
                }
            },
            elecPriceOptions: {
                responsive: true,
                interaction: {
                    mode: 'index',
                    intersect: false
                },
                scales: {
                    y: {
                        title: {
                            display: true,
                            text: "Preis für 1 MWh (€)"
                        },
                        ticks: {
                            callback: function(value, index, ticks) {
                                return "€" + value 
                            }
                        }
                    },
                    x: {
                        title: {
                            display: true,
                            text: "Halb Jahr"
                        }
                    }
                },
                plugins: {
                    title: {
                        display: true,
                        text: `Strompreise in ${this.$route.query.land}`
                    }
                }
            },
            energyGenerationOptions: {
                responsive: true,
                interaction: {
                    mode: 'index',
                    intersect: false
                },
                scales: {
                    y: {
                        title: {
                            display: true,
                            text: "Gesamte Energieerzeugung (MWh)"
                        },
                        ticks: {
                            callback: function(value, index, ticks) {
                                return value + " MWh" 
                            }
                        }
                    },
                    x: {
                        title: {
                            display: true,
                            text: "Datum"
                        }
                    }
                },
                plugins: {
                    title: {
                        display: true,
                        text: `Gesamte Energieerzeugung in ${this.$route.query.land}`
                    },
                    zoom: {
                        limits: {
                            y: {min: 0, max: 15000}
                        },
                        pan: {
                            enabled: true
                        },
                        zoom: {
                            wheel: {
                                enabled: true,
                                speed: 0.3
                            }
                        }
                    }
                }
            },
            emissionOptions: {
                responsive: true,
                interaction: {
                    mode: 'index',
                    intersect: false
                },
                scales: {
                    y: {
                        title: {
                            display: true,
                            text: "GHG Emissionen (tCO2 eq.)"
                        },
                        ticks: {
                            callback: function(value, index, ticks) {
                                return value + " tCO2 eq." 
                            }
                        }
                    },
                    x: {
                        title: {
                            display: true,
                            text: "Datum"
                        }
                    }
                },
                plugins: {
                    title: {
                        display: true,
                        text: `Gesamtemissionen aus der Energieerzeugung in ${this.$route.query.land}`
                    },
                    zoom: {
                        limits: {
                            y: {min: 0, max: 200000}
                        },
                        pan: {
                            enabled: true
                        },
                        zoom: {
                            wheel: {
                                enabled: true,
                                speed: 0.3
                            }
                        }
                    }
                }
            },
            linearModelOptions: {
                responsive: true,
                interaction: {
                    mode: 'index',
                    intersect: false
                },
                plugins: {
                    title: {
                        display: true,
                        text: `Lineare Modell zum einfluss der ölpreis auf die emissionen in ${this.$route.query.land}`
                    }
                }
            },
            simulationOptions: {
                responsive: true,
                scales: {
                    y: {
                        title: {
                            display: true,
                            text: "Preis (€) / MWh"
                        },
                        ticks: {
                            callback: function(value, index, ticks) {
                                return "€" + value 
                            }
                        },
                        max: 350
                    },
                    x: {
                        title: {
                            display: true,
                            text: "Sektor"
                        }
                    }
                },
                plugins: {
                    title: {
                        display: true,
                        text: "Wie energie preise mit der energie quellen ändern"
                    }
                }
            },
            dataStory: null,
            oilPrice: {
                datasets: []
            },
            oilPriceReduced: {
                labels: [],
                datasets: []
            },
            shareOfElec: {
                labels: [],
                datasets: []
            },
            elecPricesConsumerPre2007: {
                labels: [],
                datasets: []
            },
            elecPricesConsumerPost2007: {
                labels: [],
                datasets: []
            },
            elecPricesIndustryPre2007: {
                labels: [],
                datasets: []
            },
            elecPricesIndustryPost2007: {
                labels: [],
                datasets: []
            },
            energyGeneration: {
              labels: [],
              datasets: []
            },
            emissions: {
              labels: [],
              datasets: []
            },
            linearModel: {
                labels: [],
                datasets: []
            },
            simulationData: {
                labels: ['Haushalt', 'Industrie'],
                datasets: []
            },
            simulation: {
                increaseOptions: [{
                    label: "Wind on shore",
                    value: 2
                },{
                    label: "Wind off shore",
                    value: 3
                },{
                    label: "Solar photovoltaik",
                    value: 5
                },{
                    label: "Solar thermisch",
                    value: 4
                }],
                decreaseOptions: [{
                    label: "Kohle",
                    value: 0
                },{
                    label: "Erdgas",
                    value: 1
                }],
                values: [],
                valueMatrix: [],
                originalIncreaseValue: 0,
                originalDecreaseValue: 0,
                min: 0,
                max: 1,
                increasingSector: {label: "", value: ""},
                decreasingSector: {label: "", value: ""}
            },
            unexplainedConsumer: null,
            unexplainedIndustry: null,
            Lcoe: null,
            LcoeMatrix: []
        }
    },
    async beforeMount() {
        this.loading = true
        this.dataStory = story

        let country = this.$route.query.land

        let colors = ["#4B1D91CC", "#661796CC", "#7D129ACC", "#910F9CCC", "#A4129DCC", "#B51A9CCC", "#C42599CC", "#D23293CC", "#DF408CCC", "#EB4E82CC", "#EF6276CC", "#F1756BCC", "#F38763CC", "#F3975ECC", "#F2A75FCC", "#F0B768CC", "#ECC579CC", "#E7D39ACC"]

        this.oilPrice.datasets.push({
            label: "Brentölpreis",
            fill: false,
            borderWidth: 2,
            borderColor: colors[0],
            tension: 0.5,
            pointRadius: 0,
            data: (await dataService.indexOilPrice()).data
        })

        this.temp = (await dataService.indexYearlyBrent()).data

        this.oilPriceReduced.labels = this.temp.labels
        this.oilPriceReduced.datasets.push({
            label: "Brentölpreis",
            fill: false,
            borderWidth: 2,
            borderColor: colors[0],
            tension: 0.5,
            pointRadius: 0,
            data: this.temp.avgs,
        })

        this.temp = (await dataService.indexEnergyGen(country)).data
        this.shareOfElec.labels = this.temp[0].date
        Object.keys(this.temp[0].percentage).forEach((element, index) => {
            this.shareOfElec.datasets.push({
                label: element,
                fill: false,
                borderWidth: 2,
                borderColor: colors[index],
                tension: 0.5,
                pointRadius: 0,
                data: this.temp[0].percentage[element]
            })
        });
        
        this.energyGeneration.labels = this.temp[0].date
        Object.keys(this.temp[0].percentage).forEach((element, index) => {
            this.energyGeneration.datasets.push({
                label: element,
                fill: false,
                borderWidth: 2,
                borderColor: colors[index],
                tension: 0.5,
                pointRadius: 0,
                data: this.temp[0].absolute[element]
            })
        });

        this.temp = (await dataService.indexConsumerElecPrice(country)).data
        this.elecPricesConsumerPre2007.labels = this.temp[0].data.labels
        this.elecPricesConsumerPost2007.labels = this.temp[6].data.labels
        this.temp.slice(0,5).forEach((element, index) => {
            this.elecPricesConsumerPre2007.datasets.push({
                label: element.data.name,
                fill: false,
                borderWidth: 2,
                borderColor: colors[index],
                tension: 0.5,
                pointRadius: 2,
                data: element.data.values
            })
        });
        this.temp.slice(-5).forEach((element, index) => {
            this.elecPricesConsumerPost2007.datasets.push({
                label: element.data.name,
                fill: false,
                borderWidth: 2,
                borderColor: colors[index],
                tension: 0.5,
                pointRadius: 2,
                data: element.data.values
            })
        });

        this.temp = (await dataService.indexIndustryElecPrice(country)).data
        this.elecPricesIndustryPre2007.labels = this.temp[0].data.labels
        this.elecPricesIndustryPost2007.labels = this.temp[10].data.labels
        this.temp.slice(0,9).forEach((element, index) => {
            this.elecPricesIndustryPre2007.datasets.push({
                label: element.data.name,
                fill: false,
                borderWidth: 2,
                borderColor: colors[index],
                tension: 0.5,
                pointRadius: 2,
                data: element.data.values
            })
        });
        this.temp.slice(-7).forEach((element, index) => {
            this.elecPricesIndustryPost2007.datasets.push({
                label: element.data.name,
                fill: false,
                borderWidth: 2,
                borderColor: colors[index],
                tension: 0.5,
                pointRadius: 2,
                data: element.data.values
            })
        });

        this.temp = (await dataService.indexEmissions(country)).data
        this.emissions.labels = this.temp[0].date
        this.emissions.datasets.push({
            label: "Emissionen",
            fill: false,
            borderWidth: 2,
            borderColor: colors[0],
            tension: 0.5,
            pointRadius: 2,
            data: this.temp[0].emissions
        })

        this.temp = (await dataService.indexLm(country)).data
        this.linearModel.datasets.push({
            label: "Korrelation",
            fill: false,
            borderWidth: 2,
            borderColor: colors[0],
            tension: 0.5,
            pointRadius: 2,
            data: this.temp.scatterData
        })

        this.temp = (await dataService.indexSimulation(country)).data
        this.simulationData.datasets.push({
            label: "2019 Preise",
            data: [this.temp[0].consumer_price, this.temp[0].industry_price],
            borderColor: colors[0],
            backgroundColor: 'rgba(75, 29, 145, 0.3)',
            borderWidth: 2,
            borderSkipped: false
        })
        this.simulationData.datasets.push({
            label: "Simulations Preise",
            data: [this.temp[0].consumer_price, this.temp[0].industry_price],
            borderColor: colors[12],
            backgroundColor: "rgba(243, 135, 99, 0.3)",
            borderWidth: 2,
            borderSkipped: false
        })

        this.simulation.values = Object.values(this.temp[0].percentages[0])

        this.unexplainedConsumer = this.temp[0].unexplained_consumer
        this.unexplainedIndustry = this.temp[0].unexplained_industry

        this.Lcoe = Object.values((await dataService.indexLcoe()).data).slice(1)

        this.temp = null
        
        this.loading = false
    },
    methods: {
        async updateMinMax() {
            try {
                this.temp = (await dataService.indexSimulation(this.$route.query.land)).data
                this.simulation.values = Object.values(this.temp[0].percentages[0])
                this.simulation.max = this.simulation.values[this.simulation.increasingSector.value] + this.simulation.values[this.simulation.decreasingSector.value]
                this.simulation.originalDecreaseValue = this.simulation.values[this.simulation.decreasingSector.value]
                this.simulation.originalIncreaseValue = this.simulation.values[this.simulation.increasingSector.value]
                this.temp = null
            } catch (err) {
                console.log(err)
            }
        },
        updateIncreaseValue() {
            this.simulation.values[this.simulation.increasingSector.value] = round(this.simulation.originalIncreaseValue + (this.simulation.originalDecreaseValue - this.simulation.values[this.simulation.decreasingSector.value]), 4)
            let result = []
            let temp = []

            this.simulation.values.map((a, index) => {
                temp.push(a * this.Lcoe[index])
            })

            temp = sum(temp)

            result.push(this.unexplainedConsumer + temp)
            result.push(this.unexplainedIndustry + temp)
            this.simulationData.datasets[1].data = result
        }
    }
}
</script>