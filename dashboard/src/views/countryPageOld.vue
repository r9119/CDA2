<template>
    <div id="landing-page-main">
        <div id="nav-bar">
            <Navbar />
        </div>

        <div id="details-box">
            <div class="col-11 mx-auto">
                <Card>
                    <template #title>
                       Eine Analyse der Effects des Brentölpreises auf die Emissionen in: {{ $route.query.land }}
                    </template>
                    <template #content>
                        <div id="charts" class="grid">
                            <div class="col-12 mx-auto">
                                <Card id="oil-card">
                                    <template #header>
                                        <TabView>
                                            <TabPanel header="Simple">
                                                <Line 
                                                    :chart-options="oilOptions"
                                                    :chart-data="oilPrice"
                                                    chart-id="oil-price-chart"
                                                    :width="400"
                                                    :height="180"
                                                />
                                            </TabPanel>
                                            <TabPanel header="Detailed">
                                                <Line 
                                                    :chart-options="oilOptions"
                                                    :chart-data="oilPrice"
                                                    chart-id="oil-price-chart"
                                                    :width="400"
                                                    :height="180"
                                                />
                                            </TabPanel>
                                        </TabView>  
                                    </template>
                                    <template #content>
                                        {{ dataStory.oilSection }}
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
                                </Card>

                                <Divider align="center">
                                    <b>Werden die energiepreise betroffen?</b>
                                </Divider>

                                <Card id="elec-price-card">
                                    <template #header>
                                        <Line
                                            :chart-options="elecPriceOptions"
                                            :chart-data="elecPrices"
                                            chart-id="electricity-prices-chart"
                                            :width="400"
                                            :height="180"
                                        />
                                    </template>
                                    <template #content>
                                        {{ dataStory.elecPriceSection }}
                                    </template>
                                </Card>

                                <Divider align="center">
                                    <b>Wie viel Energie wird produziert?</b>
                                </Divider>

                                <Card id="energy-gen-card">
                                    <template #header>
                                        <TabView>
                                            <TabPanel header="Simple">
                                                <Line
                                                    :chart-options="energyGenerationOptions"
                                                    :chart-data="energyGeneration"
                                                    chart-id="energy-generation-chart"
                                                    :width="400"
                                                    :height="180"
                                                />
                                            </TabPanel>
                                            <TabPanel header="Detailed">
                                                <Line
                                                    :chart-options="energyGenerationOptions"
                                                    :chart-data="energyGeneration"
                                                    chart-id="energy-generation-chart"
                                                    :width="400"
                                                    :height="180"
                                                />
                                            </TabPanel>
                                        </TabView>
                                    </template>
                                    <template #content>
                                        {{ dataStory.energyGenSection }}
                                    </template>
                                </Card>

                                <Divider align="center">
                                    <b>Emissionen aus dem Energiesektor</b>
                                </Divider>

                                <Card id="emissions-card">
                                    <template #header>
                                        <TabView>
                                            <TabPanel header="Simple">
                                                <Line
                                                    :chart-options="emissionOptions"
                                                    :chart-data="emissions"
                                                    chart-id="energy-emissions-chart"
                                                    :width="400"
                                                    :height="180"
                                                />
                                            </TabPanel>
                                            <TabPanel header="Detailed">
                                                <Line
                                                    :chart-options="emissionOptions"
                                                    :chart-data="emissions"
                                                    chart-id="energy-emissions-chart"
                                                    :width="400"
                                                    :height="180"
                                                />
                                            </TabPanel>
                                        </TabView>
                                    </template>
                                    <template #content>
                                        {{ dataStory.emissionsSection }}
                                    </template>
                                </Card>

                                <Divider align="center">
                                    <b>Hat der Ölpreis einen Einfluss auf Emissionen?</b>
                                </Divider>

                                <Card id="model-card">
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
                                        Das ist noch nicht fertig
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
// All of this needs to be dynamic from DB at some point
import story from '../../../Data sets/spain-dataStory.json'
import oilPrice from '../../../Data sets/DCOILBRENTEU.json'
import shareOfElec from '../../../Data sets/share-elec-by-source.json'
import elecPrices from '../../../Data sets/Electricity_prices_spain.json'
import energyGeneration from '../../../Data sets/Total generation-energyGeneration.json'
import emissions from '../../../Data sets/Total tCO2 eq-emissions.json'
import { Line } from 'vue-chartjs'
import { Chart as ChartJS, Title, Tooltip, Legend, LineElement, LinearScale, PointElement, CategoryScale } from 'chart.js'
import chartZoom from 'chartjs-plugin-zoom'
import annotationPlugin from 'chartjs-plugin-annotation';

ChartJS.register(Title, Tooltip, Legend, LineElement, LinearScale, PointElement, CategoryScale, chartZoom, annotationPlugin)

export default {
    components: {
        Navbar,
        Line
    },
    data() {
        return {
            oilOptions: {
                responsive: true,
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
                    zoom: {
                        limits: {
                            y: {min: -10, max: 175}
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
                    },
                    annotation: {
                        annotations: {
                            label1: {
                                type: 'label',
                                xValue: 5517,
                                yValue: 143.1,
                                xAdjust: 100,
                                yAdjust: -5,
                                backgroundColor: 'rgba(245,245,245)',
                                content: ['Die 2008 Immobilienkreise.'],
                                textAlign: 'start',
                                font: {
                                    size: 10
                                },
                                callout: {
                                    enabled: true,
                                    side: 10
                                }
                            },
                            label2: {
                                type: 'label',
                                xValue: 8556,
                                yValue: 51,
                                xAdjust: -100,
                                yAdjust: 50,
                                backgroundColor: 'rgba(245,245,245)',
                                content: ['Der Covid Öl crash.'],
                                textAlign: 'start',
                                font: {
                                    size: 10
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
                scales: {
                    y: {
                        title: {
                            display: true,
                            text: "Anteil (%)"
                        },
                        ticks: {
                            callback: function(value, index, ticks) {
                                return value + "%"
                            }
                        }
                    },
                    x: {
                        title: {
                            display: true,
                            text: "Jahr"
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
                            y: {min: -5, max: 60}
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
                scales: {
                    y: {
                        title: {
                            display: true,
                            text: "Preis für 1 kWh (€)"
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
                    },
                    zoom: {
                        limits: {
                            y: {min: 0, max: 0.5}
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
            energyGenerationOptions: {
                responsive: true,
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
                            y: {min: 0, max: 10000000}
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
                scales: {
                    y: {
                        title: {
                            display: true,
                            text: "Gesamtenergieemissionen (tCO2)"
                        },
                        ticks: {
                            callback: function(value, index, ticks) {
                                return value + " tCO2" 
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
                            y: {min: 0, max: 30000}
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
            dataStory: null,
            oilPrice: null,
            shareOfElec: null,
            elecPrices: null,
            energyGeneration: null,
            emissions: null
        }
    },
    beforeMount() {
        this.dataStory = story
        this.oilPrice = oilPrice
        this.shareOfElec = shareOfElec
        this.elecPrices = elecPrices
        this.energyGeneration = energyGeneration
        this.emissions = emissions
    },
    mounted() {
        this.energyGenerationOptions.plugins.zoom.limits.y.max = Math.max(...this.energyGeneration.datasets[0].data) + 10000
        this.emissionOptions.plugins.zoom.limits.y.max = Math.max(...this.emissions.datasets[0].data) + 1000
    }
}
</script>