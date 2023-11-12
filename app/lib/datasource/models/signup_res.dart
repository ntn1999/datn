// To parse this JSON data, do
//
//     final signupResponse = signupResponseFromJson(jsonString);

import 'dart:convert';

SignupResponse signupResponseFromJson(String str) => SignupResponse.fromJson(json.decode(str));

String signupResponseToJson(SignupResponse data) => json.encode(data.toJson());

class SignupResponse {
  SignupResponse({
    this.error,
    this.status,
  });

  String ?error;
  String ?status;

  factory SignupResponse.fromJson(Map<String, dynamic> json) => SignupResponse(
    error: json["error"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "status": status,
  };
}
