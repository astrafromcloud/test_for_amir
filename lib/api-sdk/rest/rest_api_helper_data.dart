import 'package:dio/dio.dart';

class RestApiHelper {
  Dio dio = Dio();

  Future<Response> register(String name, String email, String password, String confirmPassword) async {
    return await dio.post('192.168.0.103:8000/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': confirmPassword,
    });
  }

  Future<Response> login(String phoneNumber, String password) async {
    return await dio.post('192.168.0.103:8000/login', data: {
      'phone_number': phoneNumber,
      'password': password,
    });
  }
}
