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
import axios from 'axios';
const { Option } = Select;

const Dashboard = () => {
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
        <Link to={`/location/${record._id}`}>{text}</Link>
      ),
    },
    {
      title: "Humidity",
      dataIndex: "humidity",
      key: "humidity",
    },
    {
      title: "Temperature",
      dataIndex: "temperature",
      key: "temperature",
    },
    {
      title: "PM 2.5",
      key: "pm25",
      dataIndex: "pm25",
    },
    {
      title: "PM 10",
      key: "pm10",
      dataIndex: "pm10",
    },
    {
      title: "AQI",
      key: "aqi",
      dataIndex: "aqi",
    },
    {
      title: "Mac Address",
      key: "macaddress",
      dataIndex: "macaddress",
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

  const [confirmLoading, setConfirmLoading] = useState(false);
 

  const history = useHistory();

  useEffect(() => {
    const user = JSON.parse(localStorage.getItem("user"));
    if (user.role !== "admin") {
      history.push("/requests");
    }
  }, []);

  useEffect(() => {
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
  }, []);

  const showModalCreate = () => {
    console.log("showModalCreate");
    setOpenCreate(true);
  };

  const hideModalCreate = () => {
    setOpenCreate(false);
  };

  const hideModalEdit = () => {
    setOpenEdit(false);
  };

  const showModalEdit = (value) => {
    setUserSelected(value._id);
    formEdit.setFieldsValue({
      email: value.email,
      name: value.name,
      phone: value.phone,
      location: value.location,
      // city:value.city,

      //address: value.address
    });
    setOpenEdit(true);
  };

  const showModalDelete = (value) => {
    setOpenDelete(true);
    setUserDeleteSelected(value._id);
  };

  const handleCancel = () => {
    setOpenDelete(false);
    setUserDeleteSelected(null);
  };

  const onFinishEdit = (values) => {
    const final = {
      ...values,
      role: "customer",
    };
    console.log(values);
    const onSubmitForm = async () => {
      await instance
        .patch(`user/update/${userSelected}`, final)
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
    hideModalEdit();
  };

  const onFinish = (values) => {
    const final = {
      ...values,
      city: city,
      district: district,
      ward: ward,
      role: 'customer'
    }
    console.log(final)
    const onSubmitForm = async () => {
      await instance
        .post('auth/register', final)
        .then((res) => {
          message.success({ content: ' Thêm thành công' });
          form.resetFields();
          hideModalCreate();
          loadData();
        })
        .catch((err) => {
          hideModalCreate();
          message.error({
            content: err,
          });
        });
    }
    onSubmitForm();
  }

  const loadData = async () => {
    setLoading(true);
    await instance
      .get("/user/userList")
      .then((res) => {
        setListUser(res.data.users);
      })
      .catch((err) => {
        message.error({
          content: err,
        });
      });
    setLoading(false);
  };
  useEffect(() => {
    loadData();
  }, []);

  const handleOkDelete = async () => {
    setConfirmLoading(true);

    await instance
      .get(`user/delete/${userDeleteSelected}`)
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

  //address
  const [city, setCity] = useState();
  const [district, setDistrict] = useState([]);
  const [ward, setWard] = useState([]);
  const [cities, setCities] = useState([]);
  const [districts, setDistricts] = useState([]);
  const [wards, setWards] = useState([]);

  useEffect(() => {
    const url = "https://raw.githubusercontent.com/kenzouno1/DiaGioiHanhChinhVN/master/data.json";
    axios.get(url)
      .then((response) => {
        setCities(response.data);
      })
      .catch((error) => {
        console.log(error);
      });
  }, []);

  const handleCityChange = (event) => {
    const selectedCity = cities.find(city => city.Id === event);
    setDistricts(selectedCity?.Districts);
    setCity(selectedCity.Name);
    console.log(city)
    setWards([]);
  };

  const handleDistrictChange = (event) => {
    const selectedDistrict = districts.find(district => district.Id === event);
    setDistrict(selectedDistrict.Name);
    setWards(selectedDistrict?.Wards);
  };

  const handleWardChange = (event) => {
    const selectedWard = wards.find(ward => ward.Id === event);
    setWard(selectedWard.Name);
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
                title=" Sensors"
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
              {/* <StatusCard
                icon="bx bx-package"
                count={listErrDevice?.length}
                title=" thiết bị lỗi"
              /> */}
              <Button type="primary" onClick={showModalCreate}>
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
                dataSource={listUser}
                rowKey={(record) => record._id}
              />
            </div>
          </div>
        </div>
        <div className="col-8">
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
        </div>
      </div>

      <Modal
        title="Cập nhật thông tin vị trí"
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
          <Form.Item label="Customer" name="customer">
            <Input />
          </Form.Item>
          <Form.Item label="Mac address" name="macAddress">
            <Input />
          </Form.Item>
          {/* <Form.Item label="Số điện thoại" name="phone">
            <Input />
          </Form.Item> */}
          {/* <Form.Item label="Địa chỉ" name="address">
            <Input />
          </Form.Item> */}
          {/* 
          <Form.Item label="Tỉnh thành" name="city">
            <Select
              placeholder="Select"
              onChange={handleCityChange}
              allowClear
            >        
              {cities.map(city => <Option key={city.Id} value={city.Id}>{city.Name}</Option>)}
            </Select>
          </Form.Item>
          <Form.Item label="Quận huyện" name="district">
            <Select
              style={{ marginRight: "55px" }}
              placeholder="Select"
              onChange={handleDistrictChange}
            >           
              {districts.map(district => <Option key={district.Id} value={district.Id}>{district.Name}</Option>)}
            </Select>
          </Form.Item>
          <Form.Item label="Phường xã" name="ward">
            <Select
              style={{ marginRight: "55px" }}
              placeholder="Select"
              onChange={handleWardChange}
            >
              {wards.map(ward => <Option key={ward.Id} value={ward.Id}>{ward.Name}</Option>)}
            </Select>
          </Form.Item> */}

          <Form.Item label="Location" name="location">
            <Input />
          </Form.Item>
        </Form>
      </Modal>

      <Modal
        title="Add New Location"
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
          {/* <Form.Item
            label="Location"
            name="location"
            rules={[{ required: true, message: "Vui lòng nhập Location!" }]}
          >
            <Input />
          </Form.Item> */}
          <Form.Item
            label="Customer"
            name="customer"
            rules={[{ required: true, message: "Vui lòng nhập Customer!" }]}
          >
            <Input />
          </Form.Item>
          <Form.Item
            label="Mac address"
            name="macAddress"
            rules={[{ required: true, message: "Vui lòng nhập Mac address!" }]}
          >
            <Input />
          </Form.Item>
          {/* <Form.Item
            label="Số điện thoại"
            name="phone"
            rules={[
              { required: true, message: "Vui lòng nhập Số điện thoại!" },
            ]}
          >
            <Input />
          </Form.Item> */}
          {/* <Form.Item label="Địa chỉ" name="address">
            <Input />
          </Form.Item> */}
          <Form.Item
            label="Tỉnh thành"
            name="cityId"
            rules={[{ required: true, message: "Vui lòng chọn Tỉnh thành!" }]}
          >
            <Select placeholder="Select" onChange={handleCityChange} allowClear>
              {/* <Option value="">Chọn tỉnh thành</Option> */}
              {cities.map((city) => (
                <Option key={city.Id} value={city.Id}>
                  {city.Name}
                </Option>
              ))}
            </Select>
          </Form.Item>
          <Form.Item
            label="Quận huyện"
            name="districtId"
            rules={[{ required: true, message: "Vui lòng chọn Quận huyện!" }]}
          >
            <Select
              style={{ marginRight: "55px" }}
              placeholder="Select"
              onChange={handleDistrictChange}
            >
              {/* <Option value="">Chọn quận huyện</Option> */}
              {districts.map((district) => (
                <Option key={district.Id} value={district.Id}>
                  {district.Name}
                </Option>
              ))}
            </Select>
          </Form.Item>
          <Form.Item
            label="Phường xã"
            name="wardId"
            rules={[{ required: true, message: "Vui lòng chọn Phường xã!" }]}
          >
            <Select
              style={{ marginRight: "55px" }}
              placeholder="Select"
              onChange={handleWardChange}
            >
              {/* <Option value="">Chọn phường xã</Option> */}
              {wards.map((ward) => (
                <Option key={ward.Id} value={ward.Id}>
                  {ward.Name}
                </Option>
              ))}
            </Select>
          </Form.Item>

          <Form.Item
            label="Ví trí"
            name="location"
            rules={[{ required: true, message: "Vui lòng chọn Vị trí!" }]}
          >
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
        <p> Xóa vị trí này?</p>
      </Modal>
    </div>
  );
};

export default Dashboard;
