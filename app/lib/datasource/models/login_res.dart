class LoginResponse {
  String? accessToken;
  String? message;
  UserData? user;

  LoginResponse({this.accessToken, this.user, this.message});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    accessToken = json['accessToken'];
    message = json['message'];
    user = json['user'] != null ? new UserData.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['accessToken'] = this.accessToken;
    data['message'] = this.message;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class UserData {
  String? role;
  String? id;
  String? name;
  String? email;
  String? location;
  String? phone;

  UserData({this.role, this.id, this.name, this.email, this.location, this.phone});

  UserData.fromJson(Map<String, dynamic> json) {
    role = json['role'];
    id = json['id'];
    name = json['name'];
    email = json['email'];
    location = json['location'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['role'] = this.role;
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['location'] = this.location;
    data['phone'] = this.phone;
    return data;
  }
}