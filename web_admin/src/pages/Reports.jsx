import React, { useEffect, useState } from "react";

import { Table } from "antd";
import moment from "moment/moment";
import sensorApi from "../service/sensorService";

const Reports = () => {
  const columns = [
    {
      title: "",
      dataIndex: "id",
      key: "id",
    },
    {
      title: "Time",
      dataIndex: "createdAt",
      key: "createdAt",
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
      title: "CO",
      key: "co",
      dataIndex: "co",
    },
    {
      title: "CO2",
      key: "co2",
      dataIndex: "co2",
    }
  ];
  const [listReport, setListReport] = useState([]);
  const getDataSensor = () => {
    sensorApi
      .getData(`/sensor/listSensors`)
      .then((res) => {
        const listReport = res.data.rs;
        listReport.forEach((item) => {
          item.createdAt = moment(item.createdAt).format("DD/MM/YYYY HH:mm:ss");
        });
        setListReport(listReport);
        return;
      })
      .catch((err) => {
        console.log(err);
      });
  };

  useEffect(() => {
    getDataSensor();
  }, []);

  return (
    <div>
      <div className="row justify-between">
        <div className="col-3">
          <h2 className="page-header">Report</h2>
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
    </div>
  );
};

export default Reports;
