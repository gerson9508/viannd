import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class MealService {
  Future<List<dynamic>> getMealsByUser(int userId, String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/meals/user'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(response.body);
  }

  Future<List<dynamic>> getMealsByUserAndDate(int userId, String date, String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/meals/user/date?date=$date'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> createMeal(Map<String, dynamic> data, String token) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/meals'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  Future<void> deleteMeal(int id, String token) async {
    await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/meals/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}