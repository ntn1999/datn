import 'dart:convert';

Sensor sensorFromJson(String str) => Sensor.fromJson(json.decode(str));

String sensorToJson(Sensor data) => json.encode(data.toJson());

class Sensor {
  Sensor({
    this.humidityAir,
    this.temperature,
  });

  num? humidityAir;
  num? temperature;

  factory Sensor.fromJson(Map<String, dynamic> json) => Sensor(
    humidityAir: json["humidityAir"],
    temperature: json["temperature"],
  );

  Map<String, dynamic> toJson() => {
    "humidityAir": humidityAir,
    "temperature": temperature,
  };
}
