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

  const data = [
    {
      name: "Page A",
      uv: 4000,
      pv: 2400,
      amt: 2400,
    },
    {
      name: "Page B",
      uv: 3000,
      pv: 1398,
      amt: 2210,
    },
    {
      name: "Page C",
      uv: 2000,
      pv: 9800,
      amt: 2290,
    },
    {
      name: "Page D",
      uv: 2780,
      pv: 3908,
      amt: 2000,
    },
    {
      name: "Page E",
      uv: 1890,
      pv: 4800,
      amt: 2181,
    },
    {
      name: "Page F",
      uv: 2390,
      pv: 3800,
      amt: 2500,
    },
    {
      name: "Page G",
      uv: 3490,
      pv: 4300,
      amt: 2100,
    },
  ];

  const chartData = [
    { x: 5, y: 1508 },
    { x: 6, y: 107 },
    { x: 7, y: 325 },
    { x: 8, y: 439 },
    { x: 9, y: 982 },
    { x: 10, y: 1562 },
    { x: 11, y: 50 },
  ];

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

    {
      title: "Action",
      key: "action",
      render: (_, record) => (
        <Row>
          <Col>
            <Button
              type="link"
              icon={<EditOutlined />}
              onClick={() => showModalEdit(record)}
            />
          </Col>
          <Col>
            <Button
              type="link"
              icon={<DeleteOutlined />}
              onClick={() => showModalDelete(record)}
            />
          </Col>
        </Row>
      ),
    },
  ];

  const params = useParams();
  const [openEdit, setOpenEdit] = useState(false);
  const [openCreate, setOpenCreate] = useState(false);
  const [openCreateReport, setOpenCreateReport] = useState(false);
  const [loading, setLoading] = useState(true);
  const [customer, setCustomer] = useState();
  const [listDevice, setListDevice] = useState([]);
  const [listErrDevice, setLisErrDevice] = useState();
  const [deviceSelected, setDeviceSelected] = useState();
  const [form] = Form.useForm();
  const [formEdit] = Form.useForm();
  const [formReport] = Form.useForm();

  const [openDelete, setOpenDelete] = useState(false);
  const [confirmLoading, setConfirmLoading] = useState(false);
  const [deviceDeleteSelected, setDeviceDeleteSelected] = useState(null);

  const [listening, setListening] = useState(false);
  const [cpuUsage, setcpuUsage] = useState(0);
  const [memoryUsage, setmemoryUsage] = useState(0);
  const [coords, setCoords] = useState(null);

  useEffect(() => {
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
  });

  let eventSource = undefined;

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

  const showModalDelete = (value) => {
    setOpenDelete(true);
    setDeviceDeleteSelected(value._id);
  };

  const handleOkDelete = async () => {
    setConfirmLoading(true);
    await instance
      .get(`device/delete/${deviceDeleteSelected}`)
      .then((res) => {
        setOpenDelete(false);
        loadData();
        setConfirmLoading(false);
      })
      .catch((err) => {
        message.error({
          content: err,
        });
      });
  };
  const handleCancel = () => {
    setOpenDelete(false);
    setDeviceDeleteSelected(null);
  };

  const loadData = async () => {
    setLoading(true);

    const getUser = customerApi.getCustomerById("/user", {
      id: params.id,
    });
    const getDeviceList = deviceApi.getAll("/device/listDevice", {
      userId: params.id,
    });
    Promise.all([getUser, getDeviceList])
      .then((res) => {
        setCustomer(res[0].data.user);
        setListDevice(res[1].data.devices);
        setLisErrDevice(
          res[1].data.devices.filter((item) => item.status === false)
        );
      })
      .catch((err) => {
        console.log(err);
      });

    setLoading(false);
  };

  useEffect(() => {
    loadData();
  }, []);

  const onFinishReport = (values) => {
    const final = {
      ...values,
      customerId: customer?._id,
      userId: user.id,
      nameUser: customer?.supporterName,
    };

    const onSubmitForm = async () => {
      await instance
        .post("report/create", final)
        .then((res) => {
          message.success({ content: " Tạo thành công" });
          hideModalCreateReport();
        })
        .catch((err) => {
          message.error({ content: "Error" });
          hideModalCreateReport();
          message.error({
            content: err,
          });
        });
    };
    onSubmitForm();
  };

  const onFinish = (values) => {
    const final = {
      ...values,
      deviceOwner: customer?.email,
      userId: customer?._id,
      statusRequest: false,
    };
    console.log(final);
    const onSubmitForm = async () => {
      await instance
        .post("device/create", final)
        .then((res) => {
          message.success({ content: " Thêm thành công" });
          hideModalCreate();
          loadData();
        })
        .catch((err) => {
          message.error({ content: "Error" });
          hideModalCreate();
          // message.error({
          //   content: err,
          // });
        });
    };
    onSubmitForm();
  };

  const onFinishEdit = (values) => {
    const final = {
      ...values,
      statusRequest: values.statusRequest == "action" ? true : false,
    };
    const onSubmitForm = async () => {
      await instance
        .patch(`device/update/${deviceSelected}`, final)
        .then((res) => {
          message.success({ content: " Thành công" });
          loadData();
        })
        .catch((err) => {
          message.error({
            content: err,
          });
        });
    };
    onSubmitForm();
    formEdit.resetFields();
    hideModalEdit();
  };

  const showModalEdit = (value) => {
    setDeviceSelected(value._id);
    setOpenEdit(true);
  };

  const hideModalEdit = () => {
    formEdit.resetFields();
    setOpenEdit(false);
  };

  const showModalCreate = () => {
    setOpenCreate(true);
  };

  const hideModalCreate = () => {
    form.resetFields();
    setOpenCreate(false);
  };

  const showModalCreateReport = () => {
    formReport.setFieldsValue({
      customerName: customer?.name,
    });
    setOpenCreateReport(true);
  };

  const hideModalCreateReport = () => {
    formReport.resetFields();
    setOpenCreateReport(false);
  };

  const handleChange = (value) => {
    console.log(`selected ${value}`);
  };
  return (
    <div>
      <div>
        <div className="row justify-between">
          <div className="col-3">
            <h2>Thông tin khách hàng</h2>
          </div>
          <div className="col-3">
            {user.role !== "admin" ? (
              <div style={{ paddingRight: "55px" }} className="row justify-end">
                <Button type="primary" onClick={showModalCreateReport}>
                  Tạo báo cáo
                </Button>
              </div>
            ) : (
              <></>
            )}
          </div>
        </div>

        <div className="card">
          <div className="row">
            <div>Tên: </div>
            <div style={{ marginLeft: "10px" }}>{customer?.name}</div>
          </div>
          <div className="row">
            <div>Email: </div>
            <div style={{ marginLeft: "10px" }}>{customer?.email}</div>
          </div>
          <div className="row">
            <div>Số điện thoại: </div>
            <div style={{ marginLeft: "10px" }}>{customer?.phone}</div>
          </div>
          <div className="row">
            <div>Vị trí: </div>
            <div style={{ marginLeft: "10px" }}>{customer?.location}</div>
          </div>
          <div className="row">
            <div>Địa chỉ: </div>
            <div style={{ marginLeft: "10px" }}>
              {customer?.ward}, {customer?.district}, {customer?.city}
            </div>
          </div>
        </div>
      </div>
      <div className="row justify-between">
        <div className="col-3">
          <h2 className="page-header">Danh sách thiết bị </h2>
        </div>
        <div className="col-3">
          <div style={{ paddingRight: "55px" }} className="row justify-end">
            <Button type="primary" onClick={showModalCreate}>
              + Thêm mới thiết bị
            </Button>
          </div>
        </div>
      </div>
      <div className="row">
        <div className="col-12">
          <div className="card">
            <div className="card__body">
              <Table
                columns={columns}
                dataSource={listDevice}
                rowKey={(record) => record._id}
              />
            </div>
          </div>
          <ReactSpeedometer
            maxValue={100}
            value={27}
            valueFormat={"d"}
            customSegmentStops={[0, 25, 50, 75, 100]}
            segmentColors={["#a3be8c", "#ebcb8b", "#d08770", "#bf616a"]}
            currentValueText={"AQI: ${value} AQI"}
            textColor={"black"}
          />
          <ReactSpeedometer
            maxValue={100}
            value={27}
            valueFormat={"d"}
            customSegmentStops={[0, 25, 50, 75, 100]}
            segmentColors={["#a3be8c", "#ebcb8b", "#d08770", "#bf616a"]}
            currentValueText={"PM2.5: ${value}"}
            textColor={"black"}
          />
          <ReactSpeedometer
            maxValue={100}
            value={27}
            valueFormat={"d"}
            customSegmentStops={[0, 25, 50, 75, 100]}
            segmentColors={["#a3be8c", "#ebcb8b", "#d08770", "#bf616a"]}
            currentValueText={"PM10: ${value}"}
            textColor={"black"}
          />
          <img
            src={temperature}
            alt="company logo"
            style={{ width: "50px", height: "50px" }}
          />
          <img
            src={humidity}
            alt="company logo"
            style={{ width: "50px", height: "50px" }}
          />
          <img
            src={co2}
            alt="company logo"
            style={{ width: "50px", height: "50px" }}
          />
          <img
            src={co}
            alt="company logo"
            style={{ width: "50px", height: "50px" }}
          />
          <div style={{ height: "300px", width: "500px" }}>
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
          <LineChart
            width={500}
            height={300}
            data={data}
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
              dataKey="pv"
              stroke="#8884d8"
              activeDot={{ r: 8 }}
            />
            <Line type="monotone" dataKey="uv" stroke="#82ca9d" />
          </LineChart>
          <BarChart width={730} height={250} data={chartData}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis
              tick={{ fontSize: 8 }}
              dataKey="x"
              type="number"
              domain={[4.5, 13.5]}
              ticks={[5, 6, 7, 8, 9, 10, 11, 12, 13]}
            />
            <YAxis />
            <Bar dataKey="y" label={<Label />} fill="#8884d8" />
          </BarChart>
        </div>
      </div>
      <Modal
        title="Tạo báo cáo "
        open={openCreateReport}
        onOk={formReport.submit}
        onCancel={hideModalCreateReport}
        okText="OK"
        cancelText="Cancel"
      >
        <Form
          name="basic"
          form={formReport}
          labelCol={{ span: 8 }}
          wrapperCol={{ span: 16 }}
          style={{ maxWidth: 600 }}
          initialValues={{ remember: true }}
          onFinish={onFinishReport}
          //   onFinishFailed={onFinishFailed}
          autoComplete="off"
        >
          <Form.Item label="Khách hàng" name="customerName">
            <Input disabled />
          </Form.Item>
          <Form.Item
            label="Tiêu đề"
            name="title"
            rules={[{ required: true, message: "Vui lòng nhập Tiêu đề !" }]}
          >
            <Input />
          </Form.Item>
          <Form.Item
            label="Nội dung"
            name="content"
            rules={[{ required: true, message: "Vui lòng nhập Nội dung !" }]}
          >
            <TextArea rows={4} />
          </Form.Item>
          <Form.Item
            label="Đơn giá"
            name="bill"
            rules={[{ required: true, message: "Vui lòng nhập Đơn giá !" }]}
          >
            <Input />
          </Form.Item>
        </Form>
      </Modal>

      <Modal
        title="Cập nhật thiết bị"
        open={openEdit}
        onOk={formEdit.submit}
        onCancel={hideModalEdit}
        okText="OK"
        cancelText="Cancel"
      >
        <Form
          name="basic"
          form={formEdit}
          labelCol={{ span: 8 }}
          wrapperCol={{ span: 16 }}
          style={{ maxWidth: 600 }}
          initialValues={{ remember: true }}
          onFinish={onFinishEdit}
          //   onFinishFailed={onFinishFailed}
          autoComplete="off"
        >
          <Form.Item
            label="Mô tả"
            name="description"
            rules={[{ required: true }]}
          >
            <Input />
          </Form.Item>
          <Form.Item label="Ghi chú" name="note" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item
            label="Trạng thái"
            name="statusRequest"
            rules={[{ required: true }]}
          >
            <Select
              style={{ width: "100%" }}
              onChange={handleChange}
              options={[
                { value: "action", label: "Hoạt động" },
                // { value: "error", label: "Yêu cầu sửa" },
              ]}
            />
          </Form.Item>
        </Form>
      </Modal>

      <Modal
        title="Thêm mới thiết bị"
        open={openCreate}
        onOk={form.submit}
        onCancel={hideModalCreate}
        okText="OK"
        cancelText="Cancel"
      >
        <Form
          name="basic"
          form={form}
          labelCol={{ span: 8 }}
          wrapperCol={{ span: 16 }}
          style={{ maxWidth: 600 }}
          initialValues={{ remember: true }}
          onFinish={onFinish}
          //   onFinishFailed={onFinishFailed}
          autoComplete="off"
        >
          <Form.Item
            label="Tên thiết bị"
            name="name"
            rules={[{ required: true, message: "Vui lòng nhập Tên thiết bị!" }]}
          >
            <Input />
          </Form.Item>
          {/* <Form.Item label="Chủ thiết bị" name="owner">
            <Select
              style={{ width: "100%" }}
              onChange={handleChange}
              options={[
                { value: "succes", label: "Hoạt động" },
                { value: "error", label: "Yêu cầu sửa" },
              ]}
            />
          </Form.Item> */}
          <Form.Item
            label="Phòng"
            name="room"
            rules={[{ required: true, message: "Vui lòng nhập Phòng!" }]}
          >
            <Select
              style={{ width: "100%" }}
              onChange={handleChange}
              options={[
                { value: "living-room", label: "Phòng khách" },
                { value: "kitchen", label: "Phòng bếp" },
                { value: "bathroom", label: "Phòng tắm" },
                { value: "bedroom", label: "Phòng ngủ" },
              ]}
            />
          </Form.Item>

          <Form.Item
            label="Mô tả"
            name="description"
            rules={[{ required: true, message: "Vui lòng nhập Mô tả!" }]}
          >
            <Input />
          </Form.Item>
          <Form.Item
            label="Ngày lắp đặt"
            name="installationDate"
            rules={[{ required: true, message: "Vui lòng nhập Ngày lắp đặt!" }]}
          >
            <Input />
          </Form.Item>
          <Form.Item label="Ghi chú" name="note">
            <Input />
          </Form.Item>
        </Form>
      </Modal>

      <Modal
        title="Delete"
        open={openDelete}
        onOk={handleOkDelete}
        confirmLoading={confirmLoading}
        onCancel={handleCancel}
      >
        <p> Xóa thiết bị này?</p>
      </Modal>
    </div>
  );
};

export default Location;
