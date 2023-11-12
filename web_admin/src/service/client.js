import axios from 'axios';

const instance = axios.create({
    // baseURL: 'http://localhost:4000/api',
    baseURL: 'https://server-smarthome.herokuapp.com/api',
    timeout: 5000,
    headers: {
    'Content-Type': 'application/json'}
});

instance.interceptors.request.use(function (config) {
    // Do something before request is sent
    return config;
}, function (error) {
    // Do something with request error
    return Promise.reject(error);
});

// Add a response interceptor


export default instance;