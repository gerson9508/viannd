import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/api_client.dart';

class ReminderService {
  static const _timeout = Duration(seconds: 10);

  Map<String, String> _headers(String token, {bool json = false}) => {
        if (json) 'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<List<dynamic>> getRemindersByUser(int userId, String token) async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/reminders/user'),
          headers: _headers(token),
        )
        .timeout(_timeout);
    return ApiClient.parseList(response);
  }

  Future<Map<String, dynamic>> createReminder(
      Map<String, dynamic> data, String token) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/reminders'),
          headers: _headers(token, json: true),
          body: jsonEncode(data),
        )
        .timeout(_timeout);
    return ApiClient.parseMap(response);
  }

  Future<void> toggleReminder(int id, String token) async {
    final response = await http
        .patch(
          Uri.parse('${ApiConfig.baseUrl}/reminders/$id/toggle'),
          headers: _headers(token),
        )
        .timeout(_timeout);
    if (response.statusCode >= 400) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Error al cambiar recordatorio');
    }
  }

  Future<void> updateReminderTime(int id, String time, String token) async {
    final response = await http
        .patch(
          Uri.parse('${ApiConfig.baseUrl}/reminders/$id/toggle'),
          headers: _headers(token, json: true),
          body: jsonEncode({'time': time}),
        )
        .timeout(_timeout);
    if (response.statusCode >= 400) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Error al actualizar recordatorio');
    }
  }


  Future<void> deleteReminder(int id, String token) async {
    final response = await http
        .delete(
          Uri.parse('${ApiConfig.baseUrl}/reminders/$id'),
          headers: _headers(token),
        )
        .timeout(_timeout);
    if (response.statusCode >= 400) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Error al eliminar recordatorio');
    }
  }
}