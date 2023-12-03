import instance from "./client";

class SensorApi {
  getData = (url, params) => {
    return instance.get(url, { params });
  };
}
const sensorApi = new SensorApi();
export default sensorApi;
