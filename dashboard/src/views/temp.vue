<template>
    <div>
        <Line 
            :chart-options="oilOptions"
            :chart-data="oilPrice"
            chart-id="oil-price-chart"
            :width="400"
            :height="180"
        />
    </div>
</template>

<script>
import { Line } from 'vue-chartjs'
import { Chart as ChartJS, Title, Tooltip, Legend, LineElement, LinearScale, PointElement, CategoryScale, Decimation, TimeScale } from 'chart.js'
import chartZoom from 'chartjs-plugin-zoom'
import annotationPlugin from 'chartjs-plugin-annotation'
import oilPrice from '../../../Data sets/temp.json'

ChartJS.register(Title, Tooltip, Legend, LineElement, LinearScale, PointElement, CategoryScale, chartZoom, annotationPlugin, Decimation, TimeScale)

export default {
    components: {
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
                    decimation: {
                        algorithm: 'lttb',
                        enabled: true,
                        samples: 500
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
            oilPrice: {
                // labels: [],
                datasets: []
            },
        }
    },
    beforeMount() {
        this.oilPrice.datasets.push({
            label: "Brent Oil Price",
            parsing: false,
            fill: false,
            borderWidth: 2,
            borderColor: "rgb(75, 192, 192)",
            tension: 0.5,
            pointRadius: 3,
            data: oilPrice.data
        })

        console.log(this.oilPrice)
    }
}
</script>