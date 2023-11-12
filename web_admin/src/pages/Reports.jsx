import React, { useEffect, useState } from "react";

import { DeleteOutlined } from "@ant-design/icons";
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
} from "antd";
import instance from "../service/client";
import moment from "moment/moment";
const { Option } = Select;

const Reports = () => {
  const columns = [
    {
      title: "",
      dataIndex: "id",
      key: "id",
    },
    {
      title: "Title",
      dataIndex: "title",
      key: "title",
      render: (text, record) => (
        <Button
          type="link"
          onClick={() => {
            setOpenDetail(true);
            setReport(record);
          }}
        >
          {text}
        </Button>
      ),
    },
    {
      title: "Khách hàng",
      dataIndex: "customerName",
      key: "customerName",
    },
    {
      title: "Nội dung",
      dataIndex: "content",
      key: "content",
    },
    {
      title: "Đơn giá",
      key: "bill",
      dataIndex: "bill",
    },
    {
      title: "Action",
      key: "action",
      render: (_, record) => (
        <Row>
          {/* <Col>
            <Button type="link" icon={<EditOutlined />} onClick={() => showModalEdit(record)} />
          </Col> */}
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

  const [openEdit, setOpenEdit] = useState(false);
  const [openDetail, setOpenDetail] = useState(false);
  const [report, setReport] = useState();

  const [reportSelected, setReportSelected] = useState(null);
  const [openCreate, setOpenCreate] = useState(false);
  const [loading, setLoading] = useState(true);
  const [listReport, setListReport] = useState([]);
  const [form] = Form.useForm();
  const [formEdit] = Form.useForm();

  const [openDelete, setOpenDelete] = useState(false);
  const [confirmLoading, setConfirmLoading] = useState(false);
  const [userDeleteSelected, setUserDeleteSelected] = useState(null);
  const user = JSON.parse(localStorage.getItem("user"));

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
    await instance
      .get("/report/reports")
      .then((res) => {
        if (user.role !== "admin") {
          const listReport = res.data.reports.filter(
            (item) => item.nameUser === user.name
          );
          setListReport(listReport);
          return;
        }
        setListReport(res.data.reports);
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
    };
    console.log(final);
    const onSubmitForm = async () => {
      await instance
        .post("auth/register", final)
        .then((res) => {
          message.success({ content: " Thêm thành công" });
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
    };
    onSubmitForm();
  };

  const onFinishEdit = (values) => {
    const final = {
      ...values,
      role: "customer",
    };
    console.log(values);
    const onSubmitForm = async () => {
      await instance
        .patch(`report/update/${reportSelected}`, final)
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
    setReportSelected(value._id);
    formEdit.setFieldsValue({
      email: value.email,
      name: value.name,
      phone: value.phone,
      location: value.location,
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

  return (
    <div>
      <div className="row justify-between">
        <div className="col-3">
          <h2 className="page-header">Báo cáo</h2>
        </div>
        <div className="col-3">
          {/* <div style={{ paddingRight: "55px" }} className="row justify-end">
            <Button type="primary" onClick={showModalCreate}>
              + Thêm mới 
            </Button>
          </div> */}
        </div>
      </div>
      <div className="row">
        <div className="col-12">
          <div className="card">
            <div className="card__body">
              <Table
                columns={columns}
                dataSource={listReport}
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
            <Input />
          </Form.Item>
          <Form.Item label="Email" name="email">
            <Input />
          </Form.Item>
          <Form.Item label="Số điện thoại" name="phone">
            <Input />
          </Form.Item>
          <Form.Item label="Ví trí" name="location">
            <Input />
          </Form.Item>
        </Form>
      </Modal>

      <Modal
        title="Tạo báo cáo"
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
          <Form.Item label="Tiêu đề" name="title">
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
          <Form.Item label="Ví trí" name="location">
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
        <p> Xóa báo cáo này?</p>
      </Modal>

      <Modal
        title="Báo cáo"
        open={openDetail}
        onOk={() => {
          setOpenDetail(false);
        }}
        onCancel={() => {
          setOpenDetail(false);
        }}
        footer={null}
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
          <Form.Item label="Người báo cáo" name="name">
            {report?.nameUser}
          </Form.Item>
          <Form.Item label="Tiêu đề" name="email">
            {report?.title}
          </Form.Item>
          <Form.Item label="Nội dung" name="phone">
            {report?.content}
          </Form.Item>
          <Form.Item label="Khách hàng" name="location">
            {report?.customerName}
          </Form.Item>
          <Form.Item label="Đơn giá" name="location">
            {report?.bill}
          </Form.Item>
          <Form.Item label="Ngày báo cáo" name="location">
            {moment(report?.createdDate).format("MM/DD/YYYY HH:mm")}
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default Reports;
