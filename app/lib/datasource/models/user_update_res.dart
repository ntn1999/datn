class UserUpdateResponse {
  UserUpdate? user;

  UserUpdateResponse({this.user});

  UserUpdateResponse.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new UserUpdate.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class UserUpdate {
  String? role;
  String? sId;
  String? name;
  String? email;
  String? password;
  String? location;
  String? phone;
  String? district;
  String? city;
  String? ward;
  String? districtId;
  String? cityId;
  String? wardId;
  String? supporterId;
  String? supporterName;
  String? createdDate;
  String? modifiedDate;
  int? iV;
  String? address;

  UserUpdate(
      {this.role,
        this.sId,
        this.name,
        this.email,
        this.password,
        this.location,
        this.phone,
        this.district,
        this.city,
        this.ward,
        this.districtId,
        this.cityId,
        this.wardId,
        this.supporterId,
        this.supporterName,
        this.createdDate,
        this.modifiedDate,
        this.iV,
        this.address});

  UserUpdate.fromJson(Map<String, dynamic> json) {
    role = json['role'];
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    location = json['location'];
    phone = json['phone'];
    district = json['district'];
    city = json['city'];
    ward = json['ward'];
    districtId = json['districtId'];
    cityId = json['cityId'];
    wardId = json['wardId'];
    supporterId = json['supporterId'];
    supporterName = json['supporterName'];
    createdDate = json['createdDate'];
    modifiedDate = json['modifiedDate'];
    iV = json['__v'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['role'] = this.role;
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['password'] = this.password;
    data['location'] = this.location;
    data['phone'] = this.phone;
    data['district'] = this.district;
    data['city'] = this.city;
    data['ward'] = this.ward;
    data['districtId'] = this.districtId;
    data['cityId'] = this.cityId;
    data['wardId'] = this.wardId;
    data['supporterId'] = this.supporterId;
    data['supporterName'] = this.supporterName;
    data['createdDate'] = this.createdDate;
    data['modifiedDate'] = this.modifiedDate;
    data['__v'] = this.iV;
    data['address'] = this.address;
    return data;
  }
}