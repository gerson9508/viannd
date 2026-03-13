import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class DayService {
  Future<List<dynamic>> getDaysByUser(int userId, String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/days/user/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> createDay(Map<String, dynamic> data, String token) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/days'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  Future<void> completeDay(int id, String token) async {
    await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/days/$id/complete'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}