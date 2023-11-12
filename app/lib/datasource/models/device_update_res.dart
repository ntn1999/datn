class DeviceUpdateResponse {
  Device? device;
  String? message;

  DeviceUpdateResponse({this.device, this.message});

  DeviceUpdateResponse.fromJson(Map<String, dynamic> json) {
    device =
    json['device'] != null ? new Device.fromJson(json['device']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.device != null) {
      data['device'] = this.device!.toJson();
      data['message'] = this.message;
    }
    return data;
  }
}

class Device {
  String? sId;
  String? name;
  String? userId;
  String? deviceOwner;
  String? description;
  String? installationDate;
  String? note;
  String? room;
  bool? status;
  int? iV;

  Device(
      {this.sId,
        this.name,
        this.userId,
        this.deviceOwner,
        this.description,
        this.installationDate,
        this.note,
        this.room,
        this.status,
        this.iV});

  Device.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    userId = json['userId'];
    deviceOwner = json['deviceOwner'];
    description = json['description'];
    installationDate = json['installationDate'];
    note = json['note'];
    room = json['room'];
    status = json['status'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['userId'] = this.userId;
    data['deviceOwner'] = this.deviceOwner;
    data['description'] = this.description;
    data['installationDate'] = this.installationDate;
    data['note'] = this.note;
    data['room'] = this.room;
    data['status'] = this.status;
    data['__v'] = this.iV;
    return data;
  }
}