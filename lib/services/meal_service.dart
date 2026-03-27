import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/api_client.dart';

class MealService {
  Future<List<dynamic>> getMealsByUser(int userId, String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/meals/user'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return ApiClient.parseList(response);
  }

  Future<List<dynamic>> getMealsByUserAndDate(int userId, String date, String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/meals/user/date?date=$date'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return ApiClient.parseList(response);
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
    return ApiClient.parseMap(response);
  }

  Future<void> deleteMeal(int id, String token) async {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/meals/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode >= 400) {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Error al eliminar comida');
      }
  }

}