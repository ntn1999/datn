import instance from "./client"

class DeviceApi {
    getAll = (url, params) => {
        return instance.get(url, { params})
    };
    getDeviceById = (url, params) => {
        return instance.get(url, { params })
    }
    addDevice = (url, params) => {
        return instance.post(url, { params })
    }
}
const deviceApi = new DeviceApi();
export default deviceApi;