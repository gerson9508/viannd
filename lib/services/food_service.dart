import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/api_client.dart';

class FoodService {
  Future<List<dynamic>> searchFoods(String query, String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/foods/search?query=$query'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return ApiClient.parseList(response);
  }

  Future<Map<String, dynamic>> getFoodById(int id, String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/foods/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return ApiClient.parseMap(response);
  }

  Future<List<dynamic>> getFoodsByCategory(String category, String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/foods/category/$category'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return ApiClient.parseList(response);
  }

    Future<List<dynamic>> getCategories(String token) async {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/foods/category/list'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return ApiClient.parseList(response);
    }
}