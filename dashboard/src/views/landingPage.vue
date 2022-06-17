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

        <div v-else id="map-box" class="grid" style="margin-bottom: 10px;">
            <div class="col-11 mx-auto">
                <Card>
                    <template #title>
                        Der Ölpreis und seine Effekte auf unser Stromerzeugungsverhalten und unsere Emissionen
                    </template>
                    <template #content>
                        <Card style="margin-bottom: 10px;">
                            <template #title>
                                <l-map style="height: 80vh"
                                    :zoom="4"
                                    :center="[56.410136, 11.342403]"
                                    :minZoom="3"
                                    :maxZoom="5">
                                    <l-tile-layer url="https://api.mapbox.com/styles/v1/r9119/cl38x3mzx000c14ouyqlzk91f/tiles/{z}/{x}/{y}?access_token=sk.eyJ1IjoicjkxMTkiLCJhIjoiY2wzOHdmeWVrMDQ1MTNlbnh2bWlodG8xdiJ9.NJJp41iVxiedQPzG9w7P-Q
"/>
                                    <l-geo-json ref="map" :geojson="geojson" :options="geojsonOptions">
                                        <!-- <l-tooltip ref="tooltip" id="tool-tip" v-show="showTooltip" style="position: absolute, left: -100px, top: 10px">
                                            <b>{{ currentHover.properties.name }}</b>
                                        </l-tooltip> -->
                                    </l-geo-json>
                                </l-map>
                            </template>
                        </Card>
                        
                        <Card>
                            <template #title>
                                Ein kurzer Überblick
                            </template>
                            <template #content>
                                <Line 
                                    :chart-options="oilOptions"
                                    :chart-data="oilPrice"
                                    chart-id="oil-price-chart"
                                    :width="400"
                                    :height="180"
                                />
                            </template>
                            <template #footer>
                                <b>Quellen:</b>
                                <p><a target="_blank" href="https://tradingeconomics.com/commodity/brent-crude-oil">Brentölpreis</a>  <a target="_blank" href="https://ourworldindata.org/grapher/co-emissions-by-sector?country=~European+Union+%2827%29">EU Emissionen</a></p>
                            </template>
                        </Card>
                    </template>
                </Card>
            </div>
        </div>
    </div>
</template>

<script>
import Navbar from '../components/NavBar.vue'
import geoData from '../../public/EU_geoJSON.json'
import "leaflet/dist/leaflet.css"
import { LMap, LGeoJson, LTileLayer, LTooltip } from "@vue-leaflet/vue-leaflet";
import dataService from '../services/dataService'
import { Line } from 'vue-chartjs'
import { Chart as ChartJS, Title, Tooltip, Legend, LineElement, LinearScale, PointElement, CategoryScale, Decimation, TimeScale } from 'chart.js'
import chartZoom from 'chartjs-plugin-zoom'
import annotationPlugin from 'chartjs-plugin-annotation';

ChartJS.register(Title, Tooltip, Legend, LineElement, LinearScale, PointElement, CategoryScale, chartZoom, annotationPlugin, TimeScale)

export default {
    components: {
        Navbar,
        LMap,
        LGeoJson,
        LTileLayer,
        LTooltip,
        Line
    },
    data() {
        return {
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
                    y1: {
                        title: {
                            display: true,
                            text: "Europäische Emissionen (kt Co2)"
                        },
                        position: "right",
                        ticks: {
                            callback: function(value, index, ticks) {
                                return (value/1000) + "kt"
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
                        text: "Der Brentölpreis und die Emissionen der EU im Überblick"
                    },
                    annotation: {
                        annotations: {
                            label1: {
                                type: 'label',
                                xValue: 18,
                                yValue: 14000,
                                xAdjust: -150,
                                yAdjust: -15,
                                backgroundColor: 'rgba(245,245,245)',
                                content: ['Die 2008 Immobilienkreise.'],
                                textAlign: 'start',
                                font: {
                                    size: 18
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
            oilPrice: {
                labels: [],
                datasets: []
            },
            geojson: geoData,
            geojsonOptions: {
                onEachFeature: this.routeToCountry
                // title: 'Emissions (Million tons of CO2'
            },
            currentHover: {
                properties: {
                    name: null
                }
            },
            showTooltip: false,
            loading: false,
            temp: null
        }
    },
    async beforeMount() {
        this.loading = true
        const { circleMarker } = await import("leaflet/dist/leaflet-src.esm");

        this.geojsonOptions.pointToLayer = (feature, latLng) =>
        circleMarker(latLng, { radius: 8 });
        this.mapIsReady = true;

        this.temp = (await dataService.indexYearlyBrent()).data

        this.oilPrice.labels = this.temp.labels
        this.oilPrice.datasets.push({
            label: "Brentölpreis",
            fill: false,
            borderWidth: 2,
            borderColor: "#4B1D91CC",
            tension: 0.5,
            pointRadius: 0,
            data: this.temp.sums,
            yAxisID: 'y'
        })

        this.temp = (await dataService.indexEuEmissions()).data

        this.oilPrice.datasets.push({
            label: "Emissionen der gesamten EU",
            fill: false,
            borderWidth: 2,
            borderColor: "#EB4E82CC",
            tension: 0.5,
            pointRadius: 0,
            data: this.temp.emissions,
            yAxisID: 'y1'
        })

        this.loading = false
    },
    methods: {
        routeToCountry(feature, layer) {
            layer.on({
                click: (event) => {
                    if (event.target && event.target.feature) {
                        this.$router.push({
                            path: '/details',
                            query: {
                                land: event.target.feature.properties.name_long
                            }
                        })
                    }
                },
                mouseover: (event) => {
                    if (event.target && event.target.feature) {
                        this.currentHover = event.target.feature
                        this.showTooltip = true
                        layer.setStyle({
                            weight: 2,
                            color: '#3e1046',
                            dashArray: '',
                            fillOpacity: 0.5
                        })
                    }
                },
                mouseout: (event) => {
                    if (event.target && event.target.feature) {
                        this.$refs.map.leafletObject.resetStyle()
                        this.showTooltip = false
                        this.currentHover = {
                            properties: {
                                name: null
                            }
                        }
                    }
                }
            })
        }
    }
}
</script>