<template>
    <div>
        <Menubar style="margin-bottom: 10px">
            <template #start>
                <a href="/"><b>Home</b></a>
            </template>
        </Menubar>
    </div>
</template>

<script>
import earth from 'vue-material-design-icons/earth.vue';

export default {
    components: {
        earth
    },
    data() {
        return {
            store: null
        }
    }
}
</script>

<style scoped>
:deep(.p-splitbutton-menubutton > .p-button-icon::before) {
    content: "\e94a";
}

a:link { text-decoration: none; }
a:visited { text-decoration: none; }
a:hover { text-decoration: none; }
a:active { text-decoration: none; }
</style>