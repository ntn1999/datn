class UserResponse {
  int? code;
  User? user;

  UserResponse({this.code, this.user});

  UserResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  String? role;
  String? sId;
  String? name;
  String? email;
  String? password;
  String? location;
  String? phone;
  String? createdDate;
  String? modifiedDate;
  int? iV;

  User(
      {this.role,
        this.sId,
        this.name,
        this.email,
        this.password,
        this.location,
        this.phone,
        this.createdDate,
        this.modifiedDate,
        this.iV});

  User.fromJson(Map<String, dynamic> json) {
    role = json['role'];
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    location = json['location'];
    phone = json['phone'];
    createdDate = json['createdDate'];
    modifiedDate = json['modifiedDate'];
    iV = json['__v'];
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
    data['createdDate'] = this.createdDate;
    data['modifiedDate'] = this.modifiedDate;
    data['__v'] = this.iV;
    return data;
  }
}