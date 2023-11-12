import React, { useEffect, useState } from "react";

import { DeleteOutlined, EditOutlined } from "@ant-design/icons";
import { Button, Col, Form, Input, message, Modal, Row, Table, Select } from "antd";
import { Link } from "react-router-dom";
import instance from "../service/client";
import customerApi from "../service/customerService";
import axios from 'axios';
const { Option } = Select;

const Customers = () => {
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
      render: (text, record) => (
        <Link to={`/customer/${record._id}`}>{text}</Link>
      ),
    },
    {
      title: "Email",
      dataIndex: "email",
      key: "email",
    },
    {
      title: "Location",
      dataIndex: "location",
      key: "location",
    },
    {
      title: "Phone",
      key: "phone",
      dataIndex: "phone",
    },
    {
      title: "Action",
      key: "action",
      render: (_, record) => (
        <Row>
          <Col>
            <Button type="link" icon={<EditOutlined />} onClick={() => showModalEdit(record)} />
          </Col>
          <Col>
            <Button type="link" icon={<DeleteOutlined />} onClick={() => showModalDelete(record)} />
          </Col>
        </Row>
      ),
    },
  ];

  const [openEdit, setOpenEdit] = useState(false);
  const [userSelected, setUserSelected] = useState(null);
  const [openCreate, setOpenCreate] = useState(false);
  const [loading, setLoading] = useState(true);
  const [listUser, setListUser] = useState([]);
  const [form] = Form.useForm();
  const [formEdit] = Form.useForm();

  const [openDelete, setOpenDelete] = useState(false);
  const [confirmLoading, setConfirmLoading] = useState(false);
  const [userDeleteSelected, setUserDeleteSelected] = useState(null);


  const showModalDelete = (value) => {
    setOpenDelete(true);
    setUserDeleteSelected(value._id)
  };

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

  const handleCancel = () => {
    setOpenDelete(false);
    setUserDeleteSelected(null);
  };

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

  const onFinishEdit = (values) => {
    const final = {
      ...values,
      role: 'customer'
    }
    console.log(values)
    const onSubmitForm = async () => {
      await instance
        .patch(`user/update/${userSelected}`, final)
        .then((res) => {
          message.success({ content: ' Thành công' });
          loadData();
        })
        .catch((err) => {
          message.error({
            content: err,
          });
        });
    }
    onSubmitForm();
    hideModalEdit();
  }

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

  const hideModalEdit = () => {
    setOpenEdit(false);

  };

  const showModalCreate = () => {
    setOpenCreate(true);
  };

  const hideModalCreate = () => {
    setOpenCreate(false);
  };


  //address
  const [cities, setCities] = useState([]);
  const [districts, setDistricts] = useState([]);
  const [wards, setWards] = useState([]);
  const [city, setCity] = useState();
  const [district, setDistrict] = useState([]);
  const [ward, setWard] = useState([]);

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
      <div className="row justify-between">
        <div className="col-3">
          <h2 className="page-header">Danh sách khách hàng</h2>
        </div>
        <div className="col-3">
          <div style={{ paddingRight: "55px" }} className="row justify-end">
            <Button type="primary" onClick={showModalCreate}>
              + Thêm mới khách hàng
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
                dataSource={listUser}
                rowKey={(record) => record._id}
              />
            </div>
          </div>
        </div>
      </div>

      <Modal
        title="Cập nhật thông tin khách hàng"
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
          <Form.Item label="Tên" name="name">
            <Input />
          </Form.Item>
          <Form.Item label="Email" name="email">
            <Input />
          </Form.Item>
          <Form.Item label="Số điện thoại" name="phone">
            <Input />
          </Form.Item>
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
          
          <Form.Item label="Ví trí" name="location">
            <Input />
          </Form.Item>
        </Form>
      </Modal>

      <Modal
        title="Thêm mới khách hàng"
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
          <Form.Item label="Tên" name="name"  rules={[{ required: true, message: "Vui lòng nhập Tên!" }]}>
            <Input />
          </Form.Item>
          <Form.Item label="Email" name="email"  rules={[{ required: true, message: "Vui lòng nhập Eamil!" }]}>
            <Input />
          </Form.Item>
          <Form.Item label="Mật khẩu" name="password"  rules={[{ required: true, message: "Vui lòng nhập Mật khẩu!" }]}>
            <Input />
          </Form.Item>
          <Form.Item label="Số điện thoại" name="phone"  rules={[{ required: true, message: "Vui lòng nhập Số điện thoại!" }]}>
            <Input />
          </Form.Item>
          {/* <Form.Item label="Địa chỉ" name="address">
            <Input />
          </Form.Item> */}
          <Form.Item label="Tỉnh thành" name="cityId"  rules={[{ required: true, message: "Vui lòng chọn Tỉnh thành!" }]}>
            <Select
              placeholder="Select"
              onChange={handleCityChange}
              allowClear
            >
              {/* <Option value="">Chọn tỉnh thành</Option> */}
              {cities.map(city => <Option key={city.Id} value={city.Id}>{city.Name}</Option>)}
            </Select>
          </Form.Item>
          <Form.Item label="Quận huyện" name="districtId"  rules={[{ required: true, message: "Vui lòng chọn Quận huyện!" }]}>
            <Select
              style={{ marginRight: "55px" }}
              placeholder="Select"
              onChange={handleDistrictChange}
            >
              {/* <Option value="">Chọn quận huyện</Option> */}
              {districts.map(district => <Option key={district.Id} value={district.Id}>{district.Name}</Option>)}
            </Select>
          </Form.Item>
          <Form.Item label="Phường xã" name="wardId"  rules={[{ required: true, message: "Vui lòng chọn Phường xã!" }]}>
            <Select
              style={{ marginRight: "55px" }}
              placeholder="Select"
              onChange={handleWardChange}
            >
              {/* <Option value="">Chọn phường xã</Option> */}
              {wards.map(ward => <Option key={ward.Id} value={ward.Id}>{ward.Name}</Option>)}
            </Select>
          </Form.Item>

          <Form.Item label="Ví trí" name="location"  rules={[{ required: true, message: "Vui lòng chọn Vị trí!" }]}>
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
        <p> Xóa người dùng này?</p>
      </Modal>
    </div>
  );
};

export default Customers;
