class DeviceResponse {
  List<Devices>? devices;

  DeviceResponse({this.devices});

  DeviceResponse.fromJson(Map<String, dynamic> json) {
    if (json['devices'] != null) {
      devices = <Devices>[];
      json['devices'].forEach((v) {
        devices!.add(new Devices.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.devices != null) {
      data['devices'] = this.devices!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Devices {
  String? sId;
  bool? status;
  String? name;
  String? deviceOwner;
  String? description;
  String? installationDate;
  String? note;
  String? room;
  bool? statusRequest;
  bool? isControl;
  int? iV;

  Devices(
      {this.sId,
        this.status,
        this.name,
        this.deviceOwner,
        this.description,
        this.installationDate,
        this.note,
        this.room,
        this.statusRequest,
        this.isControl,
        this.iV});

  Devices.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    status = json['status'];
    name = json['name'];
    deviceOwner = json['deviceOwner'];
    description = json['description'];
    installationDate = json['installationDate'];
    note = json['note'];
    room = json['room'];
    statusRequest = json['statusRequest'];
    isControl = json['isControl'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['status'] = this.status;
    data['name'] = this.name;
    data['deviceOwner'] = this.deviceOwner;
    data['description'] = this.description;
    data['installationDate'] = this.installationDate;
    data['note'] = this.note;
    data['room'] = this.room;
    data['statusRequest'] = this.statusRequest;
    data['isControl'] = this.isControl;
    data['__v'] = this.iV;
    return data;
  }
}

class DeviceStatus extends Devices{
   bool? statusControl;

  DeviceStatus({this.statusControl});
}