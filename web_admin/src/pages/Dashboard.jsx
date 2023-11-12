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

const Dashboard = () => {
  const [listUser, setListUser] = useState();
  const [listDevice, setListDevice] = useState();
  const [listErrDevice, setLisErrDevice] = useState();
  const [quantity, setQuantity] = useState([]);
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

  return (
    <div>
      <h2 className="page-header">Dashboard</h2>
      <div className="row justify-center">
        <div className="col-6">
          <div className="row">
            <div className="col-4">
              <StatusCard
                icon="bx bx-user-pin"
                count={listUser?.length}
                title="Khách hàng"
              />
            </div>
            <div className="col-4">
              <StatusCard
                icon="bx bx-package"
                count={listDevice?.length}
                title=" thiết bị"
              />
            </div>
            <div className="col-4">
              <StatusCard
                icon="bx bx-package"
                count={listErrDevice?.length}
                title=" thiết bị lỗi"
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
    </div>
  );
};

export default Dashboard;
