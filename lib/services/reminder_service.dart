import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ReminderService {
  Future<List<dynamic>> getRemindersByUser(int userId, String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/reminders/user/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> createReminder(Map<String, dynamic> data, String token) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/reminders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  Future<void> toggleReminder(int id, String token) async {
    await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/reminders/$id/toggle'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<void> updateReminderTime(int id, String time, String token) async {
    await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/reminders/$id/toggle'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'time': time}),
    );
  }

  Future<void> deleteReminder(int id, String token) async {
    await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/reminders/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}