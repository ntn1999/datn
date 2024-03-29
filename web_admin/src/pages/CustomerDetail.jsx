import React, { useState, useEffect } from "react";

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
import instance from "../service/client";
const { TextArea } = Input;

const CustomerDetail = () => {
  const user = JSON.parse(localStorage.getItem("user"));

  const columns = [
    {
      title: "",
      dataIndex: "id",
      key: "id",
    },
    {
      title: "Location",
      dataIndex: "location",
      key: "location",
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
      title: "AQI",
      key: "aqi",
      dataIndex: "aqi",
    },
    {
      title: "Mac Address",
      key: "address",
      dataIndex: "address",
    },
    {
      title: "Status",
      key: "status",
      dataIndex: "status",
      render: (_, record) =>
        record.status == true ? (
          <Tag icon={< CloseCircleOutlined/>} color="error">
               Warning
          </Tag>
        ) : "",
    }
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
        const dataTest = [{
          location: "Hà Nội",
          humidity: 71,
          temperature: 26.2,
          aqi: 100,
          address: "E7:DC:84:AH:25:D5",
          status: true
        }];
        setCustomer(res[0].data.user);
        setListDevice(dataTest);
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
          <div className="col-4">
            <h2>Thông tin nhân viên</h2>
          </div>
          <div className="col-4">
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
          <div>
            <span>Tên: </span>
            <span style={{ marginLeft: "10px" }}>{customer?.name}</span>
          </div>
          <div>
            <span>Email: </span>
            <span style={{ marginLeft: "10px" }}>{customer?.email}</span>
          </div>
          <div>
            <span>Số điện thoại: </span>
            <span style={{ marginLeft: "10px" }}>{customer?.phone}</span>
          </div>
          <div>
            <span>Vị trí: </span>
            <span style={{ marginLeft: "10px" }}>{customer?.location}</span>
          </div>
          <div>
            <span>Địa chỉ: </span>
            <span style={{ marginLeft: "10px" }}>{customer?.ward}, {customer?.district}, {customer?.city}</span>
          </div>
        </div>
      </div>
      <div className="row justify-between mt-5">
        <div className="col-8">
          <h2 className="page-header">Danh sách địa điểm giám sát</h2>
        </div>
        <div className="col-2">
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

export default CustomerDetail;
