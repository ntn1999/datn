import 'dart:convert';

SensorsResponse sensorsResponseFromJson(String str) => SensorsResponse.fromJson(json.decode(str));

String sensorsResponseToJson(SensorsResponse data) => json.encode(data.toJson());

class SensorsResponse {
  SensorsResponse({
    this.code,
    this.result,
  });

  int? code;
  List<Result>? result;

  factory SensorsResponse.fromJson(Map<String, dynamic> json) => SensorsResponse(
    code: json["code"],
    result: List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "result": List<dynamic>.from(result!.map((x) => x.toJson())),
  };
}

class Result {
  Result({
    this.humidityAir,
    this.temperature,
    this.time,
  });

  double? humidityAir;
  double? temperature;
  int? time;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    humidityAir: json["humidityAir"].toDouble(),
    temperature: json["temperature"].toDouble(),
    time: json["time"].toInt(),
  );

  Map<String, dynamic> toJson() => {
    "humidityAir": humidityAir,
    "temperature": temperature,
    "time": time,
  };
}