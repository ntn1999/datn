import React, { useEffect, useState } from "react";
import StatusCard from "../components/status-card/StatusCard";
import customerApi from "../service/customerService";
import deviceApi from "../service/deviceService";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
} from "recharts";
import { useHistory } from "react-router-dom";
import {
  Button,
  Col,
  Form,
  Input,
  message,
  Modal,
  Row,
  Table,
  Select,
} from "antd";
import { DeleteOutlined, EditOutlined } from "@ant-design/icons";
import { Link } from "react-router-dom";
import instance from "../service/client";
import axios from "axios";
import mqtt from "mqtt";

const Dashboard = () => {
  const user = JSON.parse(localStorage.getItem("user"));
  const { Option } = Select;
  const { TextArea } = Input;
  const columns = [
    {
      title: "",
      dataIndex: "id",
      key: "id",
    },
    {
      title: "Location",
      dataIndex: "name",
      key: "name",
      render: (text, record) => (
        <Link to={`/location/${record.userId}`}>{text}</Link>
      ),
    },
    {
      title: "Humidity",
      dataIndex: "humidityAir",
      key: "humidityAir",
    },
    {
      title: "Temperature",
      dataIndex: "temperature",
      key: "temperature",
    },
    {
      title: "PM 2.5",
      key: "p25",
      dataIndex: "p25",
    },
    {
      title: "PM 10",
      key: "p10",
      dataIndex: "p10",
    },
    {
      title: "AQI",
      key: "aqi",
      dataIndex: "aqi",
    },
    {
      title: "Mac Address",
      key: "macaddress",
      dataIndex: "description",
    },
    {
      title: "Status",
      key: "status",
      dataIndex: "status",
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

  const [listUser, setListUser] = useState();
  const [listDevice, setListDevice] = useState();
  const [listErrDevice, setLisErrDevice] = useState();
  const [quantity, setQuantity] = useState([]);
  const [openCreate, setOpenCreate] = useState(false);
  const [openDelete, setOpenDelete] = useState(false);
  const [userDeleteSelected, setUserDeleteSelected] = useState(null);
  const [userSelected, setUserSelected] = useState(null);
  const [openEdit, setOpenEdit] = useState(false);
  const [loading, setLoading] = useState(true);
  const [formEdit] = Form.useForm();
  const [form] = Form.useForm();
  const [mqttData, setMqttData] = useState("");
  const [confirmLoading, setConfirmLoading] = useState(false);
  const history = useHistory();
  // const [city, setCity] = useState();
  // const [district, setDistrict] = useState([]);
  // const [ward, setWard] = useState([]);
  // const [cities, setCities] = useState([]);
  // const [districts, setDistricts] = useState([]);
  // const [wards, setWards] = useState([]);

  const [openCreateReport, setOpenCreateReport] = useState(false);
  const [formReport] = Form.useForm();
  const [customer, setCustomer] = useState();
  const [deviceSelected, setDeviceSelected] = useState();
  const [deviceDeleteSelected, setDeviceDeleteSelected] = useState(null);

  useEffect(() => {
    connectMqtt();
    // getListLocation();
    getApi();
    loadData();
    const user = JSON.parse(localStorage.getItem("user"));
    if (user.role !== "admin") {
      history.push("/requests");
    }
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
        setMqttData(message.toString());
      }
    });

    return () => {
      client.end();
    };
  };

  // const getListLocation = () => {
  //   const url =
  //     "https://raw.githubusercontent.com/kenzouno1/DiaGioiHanhChinhVN/master/data.json";
  //   axios
  //     .get(url)
  //     .then((response) => {
  //       setCities(response.data);
  //     })
  //     .catch((error) => {
  //       console.log(error);
  //     });
  // };

  const getApi = () => {
    let mounted = true;
    const getUserList = customerApi.getAll("/user/userList?role=customer");
    const getDeviceList = deviceApi.getAll("/device/listDevice");
    const getQuantity = customerApi.getQuantity("/user/count");

    Promise.all([getUserList, getDeviceList, getQuantity])
      .then((res) => {
        if (mounted) {
          setListUser(res[0].data.users);
          setListDevice(res[1].data.devices);
          setLisErrDevice(
            res[1].data.devices.filter((item) => item.status === false)
          );
          var output = Object.entries(res[2].data.result).map(
            ([name, value]) => ({ name, value })
          );
          setQuantity(output);
        }
      })
      .catch((err) => {
        console.log(err);
      });

    return () => (mounted = false);
  };

  const showModalCreate = () => {
    setOpenCreate(true);
  };

  const showModalEdit = (value) => {
    setDeviceSelected(value._id);
    setOpenEdit(true);
  };

  const showModalDelete = (value) => {
    setOpenDelete(true);
    setDeviceDeleteSelected(value._id);
  };

  const loadData = async () => {
    setLoading(true);

    const getUser = customerApi.getCustomerById("/user", {
      id: user.id,
    });
    const getDeviceList = deviceApi.getAll("/device/listDevice", {
      userId: user.id,
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

  const hideModalCreateReport = () => {
    formReport.resetFields();
    setOpenCreateReport(false);
  };

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

  const hideModalEdit = () => {
    formEdit.resetFields();
    setOpenEdit(false);
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

  const handleChange = (value) => {
    console.log(`selected ${value}`);
  };

  const hideModalCreate = () => {
    form.resetFields();
    setOpenCreate(false);
  };

  const onFinish = (values) => {
    const final = {
      ...values,
      deviceOwner: customer?.email,
      userId: customer?._id,
      statusRequest: false,
    };
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
        });
    };
    onSubmitForm();
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

  const mapDataMqtt = (listDevice, mqttData) => {
    if (mqttData) {
      const data = JSON.parse(mqttData);
      listDevice[0] = { ...listDevice[0], ...data };
      listDevice = [...listDevice];
    }
    return listDevice;
  };

  return (
    <div>
      <h2 className="page-header">Dashboard</h2>
      <div className="row justify-center">
        <div className="col-8">
          <div className="row">
            <div className="col-4">
              <StatusCard
                icon="bx bx-user-pin"
                count={listUser?.length}
                title=" Users"
              />
            </div>
            <div className="col-4">
              <StatusCard
                icon="bx bx-package"
                count={listDevice?.length}
                title=" Locations"
              />
            </div>
            <div className="col-4">
              <Button
                type="primary"
                onClick={showModalCreate}
                className="new-location"
              >
                New Location
              </Button>
            </div>
          </div>
        </div>
        <div className="col-12">
          <div className="card">
            <div className="card__body">
              <Table
                columns={columns}
                dataSource={mapDataMqtt(listDevice, mqttData)}
                rowKey={(record) => record._id}
              />
            </div>
          </div>
        </div>
        {/* <div className="col-8">
          <div className="row">
            <BarChart width={800} height={300} data={quantity}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="name" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Bar
                dataKey="value"
                fill="#8884d8"
                name="Số lượng khách hàng đăng ký "
              />
            </BarChart>
          </div>
        </div> */}
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

export default Dashboard;
