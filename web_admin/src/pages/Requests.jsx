import React, { useEffect, useState } from "react";

import { SnippetsOutlined } from "@ant-design/icons";
import {
  Button,
  Col,
  Form,
  Input,
  message,
  Modal,
  Row,
  Select,
  Table,
  Tag,
} from "antd";
import axios from "axios";
import { Link } from "react-router-dom";
import instance from "../service/client";
import customerApi from "../service/customerService";
const { Option } = Select;

var params = {};
const supporters = [
  {
    supporterId: "63ff2865e6da1f3c1c80a815",
    supporterName: "Nguyen Van A - support",
  },
  {
    supporterId: "63ff286fe6da1f3c1c80a816",
    supporterName: "Nguyen Van b - support",
  },
];
const Requests = () => {
  const user = JSON.parse(localStorage.getItem("user"));

  const columns = [
    {
      title: "",
      dataIndex: "id",
      key: "id",
    },
    {
      title: "Khách hàng",
      dataIndex: "name",
      key: "name",
      render: (text, record) => (
        <Link to={`/customer/${record._id}`}>{text}</Link>
      ),
    },
    {
      title: "Tỉnh thành",
      dataIndex: "city",
      key: "city",
    },
    {
      title: "Quận huyện",
      dataIndex: "district",
      key: "district",
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
      title: "Số thiết bị cần sửa",
      key: "devices",
      align: "center",
      render: (_, record) => (
        <Tag
          color={"volcano"}
          style={{ paddingRight: "16px", paddingLeft: "16px" }}
        >
          {record.devices.length}
        </Tag>
      ),
    },
    {
      title: "Supporter",
      key: "supporterName",
      dataIndex: "supporterName",
    },
    {
      title: "Action",
      key: "action",
      render: (_, record) => (
        <Row>
          <Col>
            <Button
              type="link"
              icon={<SnippetsOutlined />}
              onClick={() => showModalEdit(record)}
            />
          </Col>
        </Row>
      ),
    },
  ];

  if (user.role !== "admin") {
    columns.pop();
  }

  const [openEdit, setOpenEdit] = useState(false);
  const [userSelected, setUserSelected] = useState(null);
  const [openCreate, setOpenCreate] = useState(false);
  const [loading, setLoading] = useState(true);
  const [listUser, setListUser] = useState([]);
  const [listUserRequest, setListUserRequest] = useState([]);
  const [form] = Form.useForm();
  const [formEdit] = Form.useForm();

  const [openDelete, setOpenDelete] = useState(false);
  const [confirmLoading, setConfirmLoading] = useState(false);
  const [userDeleteSelected, setUserDeleteSelected] = useState(null);

  // const [param, setParam] = useState({});

  const showModalDelete = (value) => {
    setOpenDelete(true);
    setUserDeleteSelected(value._id);
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

    const getUserRequest = customerApi.getUserRequest(
      "/user/userRequest",
      params
    );

    Promise.all([getUserRequest])
      .then((res) => {
        const convertUserList = res[0].data.result.map((item) => {
          const user = item.user;
          const devices = item.devices;
          return { ...user, devices };
        });
        if (user.role !== "admin") {
          const listUser = convertUserList.filter(
            (item) => item.supporterName === user.name
          );
          setListUser(listUser);
          return;
        }
        setListUser(convertUserList);
      })
      .catch((err) => {
        console.log(err);
      });

    // await instance
    //   .get("/user/userRequest", {...param})
    //   .then((res) => {
    //     const convertUserList = res.data.result.map((item) => {
    //       const user = item.user;
    //       const devices = item.devices;
    //       return { ...user, devices };
    //     });
    //     setListUser(convertUserList);

    //   })
    //   .catch((err) => {
    //     message.error({
    //       content: err,
    //     });
    //   });

    setLoading(false);
  };

  useEffect(() => {
    loadData();
  }, []);

  // const onFinish = (values) => {
  //   const final={
  //       ...values,
  //       role: 'customer'
  //   }
  //   console.log(final)
  //   const onSubmitForm= async () => {
  //     await instance
  //     .post('auth/register', final)
  //     .then((res)=>{
  //       message.success({content:' Thêm thành công'});
  //       hideModalCreate();
  //       loadData();
  //     })
  //     .catch((err) => {
  //       hideModalCreate();
  //       message.error({
  //         content: err,
  //       });
  //     });
  //   }
  //   onSubmitForm();
  // }

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

  const showModalEdit = (value) => {
    setUserSelected(value._id);
    console.log(value);
    formEdit.setFieldsValue({
      email: value.email,
      name: value.name,
      phone: value.phone,
      location: value.location,
      address: value.address,
      supporterName: value.supporterName,
      city: value.city,
      district: value.district,
      ward: value.ward,
    });
    setOpenEdit(true);
  };

  const hideModalEdit = () => {
    setOpenEdit(false);
  };

  // const showModalCreate = () => {
  //   setOpenCreate(true);
  // };

  // const hideModalCreate = () => {
  //   setOpenCreate(false);
  // };
  const [cities, setCities] = useState([]);
  const [districts, setDistricts] = useState([]);
  const [wards, setWards] = useState([]);

  useEffect(() => {
    const url =
      "https://raw.githubusercontent.com/kenzouno1/DiaGioiHanhChinhVN/master/data.json";
    axios
      .get(url)
      .then((response) => {
        setCities(response.data);
      })
      .catch((error) => {
        console.log(error);
      });
  }, []);

  const handleCityChange = (event) => {
    params = {
      cityId: event,
    };
    const selectedCity = cities.find((city) => city.Id === event);
    setDistricts(selectedCity.Districts);

    setWards([]);
    loadData();
  };

  const handleDistrictChange = (event) => {
    params = {
      ...params,
      districtId: event,
      wardId: "",
    };
    const selectedDistrict = districts.find(
      (district) => district.Id === event
    );
    setWards(selectedDistrict.Wards);

    loadData();
  };

  const handleWardChange = (event) => {
    params = {
      ...params,
      wardId: event,
    };
    const selectedWard = wards.find((ward) => ward.Id === event);

    loadData();
  };

  const handleChangeSupport = (value) => {};

  return (
    <div>
      <div className="row justify-between">
        <div className="col-3">
          <h2 className="page-header">Danh sách</h2>
        </div>
        <div className="col-3">
          <div style={{ paddingRight: "55px" }} className="row justify-end">
            {/* <Button type="primary" onClick={showModalCreate}>
              + Thêm mới khách hàng
            </Button> */}
          </div>
        </div>
      </div>
      <div className="row">
        <div className="col-12">
          <div style={{ paddingBottom: "55px" }}>
            <Select
              style={{ marginRight: "55px" }}
              placeholder="Chọn Tỉnh Thành    "
              onChange={handleCityChange}
            >
              {/* <Option value="">Chọn tỉnh thành</Option> */}
              {cities.map((city) => (
                <Option key={city.Id} value={city.Id}>
                  {city.Name}
                </Option>
              ))}
            </Select>
            <Select
              style={{ marginRight: "55px" }}
              placeholder="Chọn Quận huyện"
              onChange={handleDistrictChange}
            >
              {/* <Option value="">Chọn quận huyện</Option> */}
              {districts.map((district) => (
                <Option key={district.Id} value={district.Id}>
                  {district.Name}
                </Option>
              ))}
            </Select>
            <Select
              style={{ marginRight: "55px" }}
              placeholder="Chọn Phường xã"
              onChange={handleWardChange}
            >
              {/* <Option value="">Chọn phường xã</Option> */}
              {wards.map((ward) => (
                <Option key={ward.Id} value={ward.Id}>
                  {ward.Name}
                </Option>
              ))}
            </Select>
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
        title="Cập nhật"
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
            <Input disabled />
          </Form.Item>
          <Form.Item label="Email" name="email">
            <Input disabled />
          </Form.Item>
          <Form.Item label="Số điện thoại" name="phone">
            <Input disabled />
          </Form.Item>
          {/* <Form.Item label="Địa chỉ" name="address">
            <Input disabled />
          </Form.Item> */}

          <Form.Item label="Tỉnh thành" name="city">
            <Input disabled />
          </Form.Item>
          <Form.Item label="Quận huyện" name="district">
            <Input disabled />
          </Form.Item>
          <Form.Item label="Phường xã" name="ward">
            <Input disabled />
          </Form.Item>
          <Form.Item label="Ví trí" name="location">
            <Input disabled />
          </Form.Item>
          <Form.Item label="Supporter" name="supporterName">
            <Select
              placeholder="Select"
              onChange={handleChangeSupport}
              allowClear
            >
              {supporters.map((sp) => (
                <Option value={sp.supporterName}>{sp.supporterName}</Option>
              ))}
              {/*               
                 <Option value={city.Id}>	Nguyen Van A - support</Option>
                 <Option value={city.Id}>Nguyen Van b - support</Option> */}
            </Select>
          </Form.Item>
        </Form>
      </Modal>

      {/* <Modal
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
          <Form.Item label="Tên" name="name">
            <Input />
          </Form.Item>
          <Form.Item label="Email" name="email">
            <Input />
          </Form.Item>
          <Form.Item label="Mật khẩu" name="password">
            <Input />
          </Form.Item>
          <Form.Item label="Số điện thoại" name="phone">
            <Input />
          </Form.Item>
          <Form.Item label="Địa chỉ" name="address">
            <Input />
          </Form.Item>
          <Form.Item label="Địa chỉ" name="address">
              <Select
                  placeholder="Select"
                  onChange={handleCityChange}
                  allowClear
                >
                  <Option value="">Chọn tỉnh thành</Option>
                  {cities.map(city => <Option key={city.Id} value={city.Id}>{city.Name}</Option>)}
            </Select>
          </Form.Item>
          <Form.Item label="Ví trí" name="location">
            <Input />
          </Form.Item>
        </Form>
      </Modal> */}

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

export default Requests;
