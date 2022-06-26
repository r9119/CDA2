// Scatter plot testing page - No longer in use

<template>
    <div>
        <Scatter 
            :chart-options="testOptions"
            :chart-data="tempData"
            chart-id="oil-price-chart"
            :width="400"
            :height="180"
        />
        <Line 
            :chart-options="lmOptions"
            :chart-data="lm"
            chart-id="oil-price-chart"
            :width="400"
            :height="180"
        />
    </div>
</template>

<script>
import { Scatter, Line } from 'vue-chartjs'
import { Chart as ChartJS, Title, Tooltip, Legend, LineElement, LinearScale, PointElement, CategoryScale, TimeScale } from 'chart.js'
import chartZoom from 'chartjs-plugin-zoom'
import annotationPlugin from 'chartjs-plugin-annotation'
import dataService from '../services/dataService'

ChartJS.register(Title, Tooltip, Legend, LineElement, LinearScale, PointElement, CategoryScale, chartZoom, annotationPlugin, TimeScale)

export default {
    components: {
        Scatter,
        Line
    },
    data() {
        return {
            testOptions: {
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
                    }
                }
            },
            lmOptions: {
                responsive: true
            },
            tempData: {
                // labels: [],
                datasets: []
            },
            temp: null,
            lm: {
                labels: [],
                datasets: []
            }
        }
    },
    async beforeMount() {
        this.temp = (await dataService.indexLm("Spain")).data

        this.tempData.datasets.push({
            label: "LM",
            parsing: false,
            fill: false,
            borderWidth: 2,
            borderColor: "rgb(75, 192, 192)",
            tension: 0.5,
            pointRadius: 3,
            data: this.temp.scatterData
        })

        this.lm.labels = this.temp.labels
        this.lm.datasets.push({
            label: "Korrelation",
            fill: false,
            borderWidth: 2,
            borderColor: "rgb(75, 192, 192)",
            tension: 0.5,
            pointRadius: 2,
            data: this.temp.values
        })

        this.temp = null
    }
}
</script>