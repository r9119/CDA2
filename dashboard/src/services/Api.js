import axios from 'axios';

export default () => {
    return axios.create({
        baseURL: 'https://r9119cdn.xyz/'
    });
};