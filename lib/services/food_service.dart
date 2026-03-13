import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class FoodService {
  Future<List<dynamic>> searchFoods(String query, String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/foods/search?query=$query'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getFoodById(int id, String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/foods/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(response.body);
  }

  Future<List<dynamic>> getFoodsByCategory(String category, String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/foods/category/$category'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(response.body);
  }

    Future<List<dynamic>> getCategories(String token) async {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/foods/category/list'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return jsonDecode(response.body);
    }
}