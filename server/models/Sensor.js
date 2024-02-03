const mongoose = require("mongoose");

const sensorSchema = new mongoose.Schema(
  {
    humidityAir: {
      type: Number,
      required: true,
    },
    temperature: {
      type: Number,
      required: true,
    },
    gasVal: {
      type: Number,
      required: true,
    },
    p25: {
      type: Number,
      required: true,
    },
    p10: {
      type: Number,
      required: true,
    },
    co: {
      type: Number,
      required: true,
    },
    co2: {
      type: Number,
      required: true,
    },
    createdDate: {
      type: Date,
      default: Date.now,
    },
    modifiedDate: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Sensor", sensorSchema);
