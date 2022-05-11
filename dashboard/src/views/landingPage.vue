<template>
    <div id="landing-page-main">
        <div id="nav-bar">
            <Menubar>
                <template #end>
                    <InputText placeholder="Search" type="text" />
                </template>
            </Menubar>
        </div>

        <div id="map-main">
            <div id="map-plot" ref="map">

            </div>
        </div>
    </div>
</template>

<script>
import  Plotly  from 'plotly.js-dist/plotly';

export default {
    data() {
        return {
            data: [{
                type: 'choropleth',
                z: [11,9,8,7,6,5,4,3,2,1],
                text: ['germany', 'netherlands', 'poland', 'sweden', 'finland', 'portugal', 'austria', 'greece', 'iceland', 'turkey', 'Spain'],
                locations: ['GER', 'NLD', 'POL', 'SWE', 'FIN', 'PRT', 'AUT', 'GRC', 'ISL', 'TUR', 'ESP'],
                autocoloscale: true
            }],
            layout: {title: 'Emissions (Million tons of CO2'}
        }
    },
    mounted() {
        Plotly.newPlot(this.$refs.map, this.data, this.layout)
    }
}
</script>