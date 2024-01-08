import React, { useState, useEffect } from "react";
import ReactSpeedometer from "react-d3-speedometer";
import GoogleMapReact from "google-map-react";
import temperature from "../assets/images/temperature.png";
import humidity from "../assets/images/humidity.png";
import co2 from "../assets/images/co2-3.png";
import co from "../assets/images/co-2.png";
import { CheckCircleOutlined, CloseCircleOutlined } from "@ant-design/icons";
import {
  Button,
  message,
  Form,
  Input,
  Modal,
  Select,
  Col,
  Row,
  Tag,
  Table,
} from "antd";
import { EditOutlined, DeleteOutlined } from "@ant-design/icons";
import customerApi from "../service/customerService";
import deviceApi from "../service/deviceService";
import { useParams } from "react-router-dom";
import { TiLocation } from "react-icons/ti";
import instance from "../service/client";
import { geocodeByAddress, getLatLng } from "react-google-places-autocomplete";
import {
  LineChart,
  BarChart,
  Bar,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
} from "recharts";
import sensorApi from "../service/sensorService";
import moment from "moment";
import mqtt from "mqtt";
const { TextArea } = Input;

const AnyReactComponent = ({ text, icon }) => (
  <div>
    <span>{text}</span>
    {icon}
  </div>
);

const Label = (props) => {
  const { x, y, value } = props;

  return (
    <text
      x={x}
      y={y}
      dx={"2%"}
      dy={"-1%"}
      fontSize="15"
      fontWeight="bold"
      fill={"#181818"}
      textAnchor="left"
    >
      {value}
    </text>
  );
};

const Location = () => {
  const user = JSON.parse(localStorage.getItem("user"));

  const defaultProps = {
    center: {
      lat: 10.99835602,
      lng: 77.01502627,
    },
    zoom: 11,
  };

  const columns = [
    {
      title: "",
      dataIndex: "id",
      key: "id",
    },
    {
      title: "Name",
      dataIndex: "name",
      key: "name",
    },
    {
      title: "Phòng",
      dataIndex: "room",
      key: "room",
    },
    {
      title: "Mô tả",
      dataIndex: "description",
      key: "description",
    },
    {
      title: "Ngày lắp đặt",
      key: "installationDate",
      dataIndex: "installationDate",
    },
    {
      title: "Ghi chú",
      key: "note",
      dataIndex: "note",
    },
    {
      title: "Trạng thái",
      key: "statusRequest",
      dataIndex: "statusRequest",
      render: (_, record) =>
        record.statusRequest == true ? (
          <Tag icon={<CloseCircleOutlined />} color="error">
            Yêu cầu sửa
          </Tag>
        ) : (
          <Tag icon={<CheckCircleOutlined />} color="success">
            Hoạt động
          </Tag>
        ),
    },
  ];

  const params = useParams();
  const [loading, setLoading] = useState(true);
  const [customer, setCustomer] = useState();
  const [listDevice, setListDevice] = useState([]);
  const [listErrDevice, setLisErrDevice] = useState();
  const [listening, setListening] = useState(false);
  const [cpuUsage, setcpuUsage] = useState(0);
  const [memoryUsage, setmemoryUsage] = useState(0);
  const [dataSensor, setDataSensor] = useState([]);
  const [coords, setCoords] = useState(null);
  const [mqttData, setMqttData] = useState("");
  const [optionSelected, setOptionSelected] = useState("humidityAir");

  useEffect(() => {
    connectMqtt();
    getLocaion();
    getDataSensor();
  }, []);

  const connectMqtt = () => {
    const client = mqtt.connect("wss://broker.hivemq.com:8884/mqtt");
    client.on("connect", () => {
      console.log("Connected to MQTT broker");
      // Đăng ký để nhận dữ liệu từ topic 'demo1'
      client.subscribe("demo1");
    });

    // Khi nhận được dữ liệu từ MQTT broker
    client.on("message", (topic, message) => {
      if (message.toString() !== "aaaa") {
        const data = JSON.parse(message.toString());
        setMqttData(data);
      }
    });

    return () => {
      client.end();
    };
  };

  const getLocaion = () => {
    // navigator.geolocation.getCurrentPosition(
    //   ({ coords: { longitude, latitude } }) => {
    //     setCoords({ lat: latitude, lng: longitude });
    //   }
    // );
    const getCoords = async () => {
      const results = await geocodeByAddress("Thach That, Ha Noi");
      const latLng = await getLatLng(results[0]);
      setCoords(latLng);
    };
    setTimeout(() => {
      getCoords();
    }, 2000);
  };

  const getDataSensor = () => {
    const endTime = moment().valueOf();
    const startTime = moment().subtract(1, "months").valueOf();

    sensorApi
      .getData(`/sensor?begin=${startTime}&end=${endTime}`)
      .then((res) => {
        res.data.result.forEach((item) => {
          item.humidityAir = item.humidityAir.toFixed(2);
          item.temperature = item.temperature.toFixed(2);
          item.gasVal = item.gasVal.toFixed(2);
          if (item.humidityAir === "0.00") {
            item.humidityAir = 45;
          }
          if (item.temperature === "0.00") {
            item.temperature = 25;
          }
          item.name = moment(item.time).format("DD/MM");
        });
        if (res.data.result.length) {
          console.log(res.data.result);
          setDataSensor(res.data.result);
        }
      })
      .catch((err) => {
        console.log(err);
      });
  };

  // let eventSource = undefined;

  // useEffect(() => {
  //   if (!listening) {
  //     eventSource = new EventSource(
  //       "http://localhost:8080/event/resources/usage"
  //     );
  //     eventSource.onmessage = (event) => {
  //       const usage = JSON.parse(event.data);
  //       setcpuUsage(usage.cpuUsage);
  //       setmemoryUsage(usage.memoryUsage);
  //     };
  //     eventSource.onerror = (err) => {
  //       console.error("EventSource failed:", err);
  //       eventSource.close();
  //     };
  //     setListening(true);
  //   }
  //   return () => {
  //     eventSource.close();
  //     console.log("event closed");
  //   };
  // }, []);

  // const loadData = async () => {
  //   setLoading(true);

  //   const getUser = customerApi.getCustomerById("/user", {
  //     id: params.id,
  //   });
  //   const getDeviceList = deviceApi.getAll("/device/listDevice", {
  //     userId: params.id,
  //   });
  //   Promise.all([getUser, getDeviceList])
  //     .then((res) => {
  //       setCustomer(res[0].data.user);
  //       setListDevice(res[1].data.devices);
  //       setLisErrDevice(
  //         res[1].data.devices.filter((item) => item.status === false)
  //       );
  //     })
  //     .catch((err) => {
  //       console.log(err);
  //     });

  //   setLoading(false);
  // };

  const changeBarChartData = (chartType) => {
    console.log(chartType);
    setOptionSelected(chartType);
  };

  return (
    <div>
      <div className="row">
        <div className="col-4">
          <h4>Thông tin chi tiết điểm đo</h4>
        </div>
      </div>

      <div className="row mb-5">
        <div className="card col-6">
          <div className="row">
            <span style={{ marginLeft: "10px" }}>Tên: {user?.name}</span>
          </div>
          <div className="row">
            <div style={{ marginLeft: "10px" }}>Email: {user?.email}</div>
          </div>
          <div className="row">
            <div style={{ marginLeft: "10px" }}>
              Số điện thoại: {user?.phone}
            </div>
          </div>
          <div className="row">
            <div style={{ marginLeft: "10px" }}>Vị trí: {user?.location}</div>
          </div>
          <div className="row">
            <div style={{ marginLeft: "10px" }}>
              Địa chỉ: {customer?.ward}, {customer?.district}, {customer?.city}
            </div>
          </div>
        </div>
        <div className="col-6">
          <div style={{ height: "300px", width: "570px" }}>
            <GoogleMapReact
              bootstrapURLKeys={{
                key: "AIzaSyAMcAoFKRllxlboROQyrqLF68Sw6JyZrkk",
              }}
              defaultCenter={coords}
              defaultZoom={11}
              center={coords}
            >
              <AnyReactComponent
                lat={coords?.lat}
                lng={coords?.lng}
                icon={<TiLocation color="red" size={24} />}
                text="Cau Giay, Ha Noi"
              />
            </GoogleMapReact>
          </div>
        </div>
      </div>

      <div className="row mb-5">
        <div className="col-3 d-flex justify-content-center">
          <img
            src={temperature}
            alt="company logo"
            style={{ width: "70px", height: "70px" }}
          />
          <div style={{ margin: "12px" }}>
            <h6>Temperature</h6>
            <span className="fw-bold">{mqttData.temperature}&#8451;</span>
          </div>
        </div>
        <div className="col-3 d-flex justify-content-center">
          <img
            src={humidity}
            alt="company logo"
            style={{ width: "70px", height: "70px" }}
          />
          <div style={{ margin: "12px" }}>
            <h6>Humidity</h6>
            <span className="fw-bold">{mqttData.humidityAir}%</span>
          </div>
        </div>
        <div className="col-3 d-flex justify-content-center">
          <img
            src={co2}
            alt="company logo"
            style={{ width: "70px", height: "70px" }}
          />
          <div style={{ margin: "12px" }}>
            <h6>CO2</h6>
            <span className="fw-bold">{mqttData.humidityAir}ppm</span>
          </div>
        </div>
        <div className="col-3 d-flex justify-content-center">
          <img
            src={co}
            alt="company logo"
            style={{ width: "70px", height: "70px" }}
          />
          <div style={{ margin: "12px" }}>
            <h6>CO</h6>
            <span className="fw-bold">{mqttData.humidityAir}ppm</span>
          </div>
        </div>
      </div>

      <div className="row">
        <div className="col-4 d-flex justify-content-center">
          <ReactSpeedometer
            maxValue={100}
            value={27}
            valueFormat={"d"}
            customSegmentStops={[0, 25, 50, 75, 100]}
            segmentColors={["#a3be8c", "#ebcb8b", "#d08770", "#bf616a"]}
            currentValueText={"AQI: ${value} AQI"}
            textColor={"black"}
          />
        </div>
        <div className="col-4 d-flex justify-content-center">
          <ReactSpeedometer
            maxValue={100}
            value={mqttData.p25}
            valueFormat={"d"}
            customSegmentStops={[0, 25, 50, 75, 100]}
            segmentColors={["#a3be8c", "#ebcb8b", "#d08770", "#bf616a"]}
            currentValueText={"PM2.5: ${value}"}
            textColor={"black"}
          />
        </div>
        <div className="col-4 d-flex justify-content-center">
          <ReactSpeedometer
            maxValue={100}
            value={mqttData.p10}
            valueFormat={"d"}
            customSegmentStops={[0, 25, 50, 75, 100]}
            segmentColors={["#a3be8c", "#ebcb8b", "#d08770", "#bf616a"]}
            currentValueText={"PM10: ${value}"}
            textColor={"black"}
          />
        </div>
      </div>

      <div className="row">
        <div className="col-6">
          <LineChart
            width={580}
            height={400}
            data={dataSensor}
            margin={{
              top: 5,
              right: 30,
              left: 20,
              bottom: 5,
            }}
          >
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="name" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Line
              type="monotone"
              dataKey="humidityAir"
              stroke="#8884d8"
              activeDot={{ r: 8 }}
            />
            <Line type="monotone" dataKey="temperature" stroke="#82ca9d" />
          </LineChart>
        </div>
        <div className="col-6">
          <BarChart width={565} height={400} data={dataSensor}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="name" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Bar
              dataKey={optionSelected}
              fill="#8884d8"
              name="Số lượng khách hàng đăng ký "
            />
          </BarChart>
          <div
            className="d-flex justify-content-around"
            style={{ marginLeft: "120px", marginRight: "60px" }}
          >
            <button
              type="button"
              className={
                "btn btn-outline-primary " +
                (optionSelected === "humidityAir" ? "bg-primary text-white" : "")
              }
              onClick={() => changeBarChartData("humidityAir")}
            >
              AQI
            </button>
            <button
              type="button"
              className={
                "btn btn-outline-primary " +
                (optionSelected === "pm25" ? "bg-primary text-white" : "")
              }
              onClick={() => changeBarChartData("pm25")}
            >
              PM 2.5
            </button>
            <button
              type="button"
              className={
                "btn btn-outline-primary " +
                (optionSelected === "pm10" ? "bg-primary text-white" : "")
              }
              onClick={() => changeBarChartData("pm10")}
            >
              PM 10
            </button>
            <button
              type="button"
              className={
                "btn btn-outline-primary " +
                (optionSelected === "gasVal" ? "bg-primary text-white" : "")
              }
              onClick={() => changeBarChartData("gasVal")}
            >
              CO
            </button>
            <button
              type="button"
              className={
                "btn btn-outline-primary " +
                (optionSelected === "co2" ? "bg-primary text-white" : "")
              }
              onClick={() => changeBarChartData("co2")}
            >
              CO2
            </button>
          </div>
        </div>
      </div>

      <div className="row">
        <div className="card col-12">
          <div className="card__body">
            <Table
              columns={columns}
              dataSource={listDevice}
              rowKey={(record) => record._id}
            />
          </div>
        </div>
      </div>
    </div>
  );
};

export default Location;
