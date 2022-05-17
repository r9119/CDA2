<template>
    <div id="landing-page-main">
        <div id="nav-bar">
            <Navbar />
        </div>

        <div id="details-box">
            <div class="col-11 mx-auto">
                <Card>
                    <template #title>
                        An analysis of the effects of the brent oil price on emissions in {{ $route.query.country }}
                    </template>
                    <template #content>
                        <div class="grid">
                            <div class="col-12 mx-auto" style="max-height: 80vh">
                                <Line 
                                    :chart-options="chartOptions"
                                    :chart-data="oilPrice"
                                    chart-id="oil-price-chart"
                                    :width="400"
                                    :height="180"
                                />
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
import oilPrice from '../../../Data sets/DCOILBRENTEU.json'
import { Line } from 'vue-chartjs'
import { Chart as ChartJS, Title, Tooltip, Legend, LineElement, LinearScale, PointElement, CategoryScale } from 'chart.js'

ChartJS.register(Title, Tooltip, Legend, LineElement, LinearScale, PointElement, CategoryScale)

export default {
    components: {
        Navbar,
        Line
    },
    data() {
        return {
            chartOptions: {
                responsive: true
            },
            oilPrice: null,
            shareOfElec: null,
            elecPrices: null,
            energyGeneration: null,
            emissions: null
        }
    },
    beforeMount() {
        this.oilPrice = oilPrice
    }
}
</script>