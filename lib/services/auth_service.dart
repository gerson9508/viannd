import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/api_client.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return ApiClient.parseMap(response);
  }

  Future<Map<String, dynamic>> register(
  String name, String email, String password, int age, String gender,
    {required String code}
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name, 'email': email, 'password': password,
        'age': age, 'gender': gender, 'code': code,
      }),
    );
    return ApiClient.parseMap(response);
  }

  Future<Map<String, dynamic>> sendVerificationCode({
    required String name,
    required String email,
    required String password,
    required int age,
    required String gender,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/send-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'age': age,
        'gender': gender,
      }),
    );
    return ApiClient.parseMap(response);
  }
}