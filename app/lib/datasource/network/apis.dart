import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../configs/constants.dart';
import '../models/change_password_res.dart';
import '../models/device_update_res.dart';
import '../models/devices_res.dart';
import '../models/login_res.dart';
import '../models/sensors_res.dart';
import '../models/signup_res.dart';
import '../models/user_res.dart';
import '../models/user_update_res.dart';
import 'dio_client.dart';

class Api {
  RestClient restClient = RestClient(Dio());

  Future<LoginResponse?> login(String email, String password) async {
    Response response;
    try {
      response = await restClient
          .post('api/auth/login', data: {'email': email, 'password': password});
      print(response);
      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.data);
      } else if (response.statusCode == 401) {
        print(response.data.toString());
        return LoginResponse.fromJson(response.data);
      } else {
        print('There is some problem status code not 200');
        return null;
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data.toString());
        return null;
      } else {
        print(e.message);
        return null;
      }
    }
    return null;
  }

  Future<ChangePasswordResponse?> changePassword(
      String email, String oldPassword, String newPassword) async {
    Response response;
    try {
      response = await restClient.post('api/auth/changePassword', data: {
        'email': email,
        'oldPassword': oldPassword,
        'newPassword': newPassword
      });
      if (response.statusCode == 200) {
        return ChangePasswordResponse.fromJson(response.data);
      } else {
        print('There is some problem status code not 200');
        return ChangePasswordResponse.fromJson(response.data);
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data.toString());
      } else {
        print(e.message);
      }
    }
    return null;
  }

  Future<UserUpdateResponse?> changeProfile(
      {required String name,
      required String phone,
      required String address,
      required String id}) async {
    Response response;
    try {
      response = await restClient.patch('api/user/update/$id', data: {
        'name': name,
        'phone': phone,
        'location': address,
      });
      if (response.statusCode == 200) {
        return UserUpdateResponse.fromJson(response.data);
      } else {
        print('There is some problem status code not 200');
        return UserUpdateResponse.fromJson(response.data);
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data.toString());
      } else {
        print(e.message);
      }
    }
    return null;
  }

  Future<UserResponse?> getUser(String token, String userId) async {
    Dio dio = Dio();
    // dio.options.headers["Authorization"] = "Bearer $token";
    dio.interceptors.add(PrettyDioLogger());
    Response response;
    try {
      response = await dio.get('${AppConstants.baseUrl}api/user',
          queryParameters: {'id': userId});
      if (response.statusCode == 200) {
        return UserResponse.fromJson(response.data);
      } else {
        print('There is some problem status code not 200');
      }
    } on Exception catch (e) {
      print(e);
    }
    return null;
  }

  Future<DeviceResponse?> getDevice(String token, String userId) async {
    Dio dio = Dio();
    dio.options.headers["Authorization"] = "Bearer $token";
    dio.interceptors.add(PrettyDioLogger());
    Response response;
    try {
      response = await dio.get('${AppConstants.baseUrl}api/device/listDevice',
          queryParameters: {'userId': userId});
      if (response.statusCode == 200) {
        return DeviceResponse.fromJson(response.data);
      } else {
        print('There is some problem status code not 200');
      }
    } on Exception catch (e) {
      print(e);
    }
    return null;
  }

  Future<DeviceUpdateResponse?> updateDevice( String id, String note) async {
    Dio dio = Dio();
    final pref = await SharedPreferences.getInstance();
    String token = (pref.getString('token') ?? "");
    dio.options.headers["Authorization"] = "Bearer $token";
    dio.interceptors.add(PrettyDioLogger());
    Response response;
    try {
      response = await dio.patch('${AppConstants.baseUrl}api/device/update/$id',
          data: {'note': note, 'status': false});
      if (response.statusCode == 200) {
        return DeviceUpdateResponse.fromJson(response.data);
      } else {
        print('There is some problem status code not 200');
      }
    } on Exception catch (e) {
      print(e);
    }
    return null;
  }

  Future<DeviceUpdateResponse?> updateStatusDevice( String id, bool status) async {
    Dio dio = Dio();
    final pref = await SharedPreferences.getInstance();
    String token = (pref.getString('token') ?? "");
    dio.options.headers["Authorization"] = "Bearer $token";
    dio.interceptors.add(PrettyDioLogger());
    Response response;
    try {
      response = await dio.patch('${AppConstants.baseUrl}api/device/update/$id',
          data: {'status': status});
      if (response.statusCode == 200) {
        return DeviceUpdateResponse.fromJson(response.data);
      } else {
        print('There is some problem status code not 200');
      }
    } on Exception catch (e) {
      print(e);
    }
    return null;
  }


  Future<SensorsResponse?> getSensors(String dateBegin, String dateEnd) async {
    Dio dio = Dio();
    //dio.options.headers["Authorization"] = "Bearer $token";
    dio.interceptors.add(PrettyDioLogger());
    Response response;
    try {
      response = await dio.get('${AppConstants.baseUrl}api/sensor',
          queryParameters: {'begin': dateBegin, 'end': dateEnd});
      if (response.statusCode == 200) {
        print(response.data);
        return SensorsResponse.fromJson(response.data);
      } else {
        print('There is some problem status code not 200');
      }
    } on Exception catch (e) {
      print(e);
    }
    return null;
  }
}
