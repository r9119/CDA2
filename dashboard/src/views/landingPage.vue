<template>
    <div id="landing-page-main">
        <div id="nav-bar">
            <Navbar />
        </div>


        <div id="map-box" class="grid" style="margin-bottom: 10px;">
            <div class="col-11 mx-auto">
                <Card>
                    <template #title>
                        Welcome
                    </template>
                    <template #content>
                        <div class="grid">
                            <div class="col-12 mx-auto">
                                <l-map style="height: 80vh"
                                    :zoom="4"
                                    :center="[55.161603, 5.911815]"
                                    :minZoom="3"
                                    :maxZoom="5">
                                    <l-geo-json ref="map" :geojson="geojson" :options="geojsonOptions" />
                                    <l-tile-layer url="https://api.mapbox.com/styles/v1/r9119/cl38x3mzx000c14ouyqlzk91f/tiles/{z}/{x}/{y}?access_token=sk.eyJ1IjoicjkxMTkiLCJhIjoiY2wzOHdmeWVrMDQ1MTNlbnh2bWlodG8xdiJ9.NJJp41iVxiedQPzG9w7P-Q
"/>
                                </l-map>
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
import geoData from '../../public/EU_geoJSON.json'
import "leaflet/dist/leaflet.css"
import { LMap, LGeoJson, LTileLayer } from "@vue-leaflet/vue-leaflet";

export default {
    components: {
        Navbar,
        LMap,
        LGeoJson,
        LTileLayer
    },
    data() {
        return {
            geojson: geoData,
            geojsonOptions: {
                onEachFeature: this.routeToCountry
                // title: 'Emissions (Million tons of CO2'
            }
        }
    },
    async beforeMount() {
        const { circleMarker } = await import("leaflet/dist/leaflet-src.esm");

        this.geojsonOptions.pointToLayer = (feature, latLng) =>
        circleMarker(latLng, { radius: 8 });
        this.mapIsReady = true;
    },
    methods: {
        routeToCountry(feature, layer) {
            layer.on({
                click: (event) => {
                    if (event.target && event.target.feature) {
                        this.$router.push({
                            path: '/details',
                            query: {
                                country: event.target.feature.properties.name
                            }
                        })
                    }
                },
                mouseover: (event) => {
                    if (event.target && event.target.feature) {
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
                    }
                }
            })
        }
    }
}
</script>