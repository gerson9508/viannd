import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class FoodPlanService {
  static const _timeout = Duration(seconds: 10);

  Map<String, String> _headers(String token, {bool json = false}) => {
        if (json) 'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<Map<String, dynamic>?> getPlan(String token) async {
    final res = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/plan'), headers: _headers(token))
        .timeout(_timeout);
    if (res.statusCode == 404) return null;
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Error al obtener plan');
  }

  Future<Map<String, dynamic>> createPlan(Map<String, dynamic> data, String token) async {
    final res = await http
        .post(Uri.parse('${ApiConfig.baseUrl}/plan'),
            headers: _headers(token, json: true), body: jsonEncode(data))
        .timeout(_timeout);
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['message'] ?? 'Error al crear plan');
  }

  Future<Map<String, dynamic>> updatePlan(Map<String, dynamic> data, String token) async {
    final res = await http
        .put(Uri.parse('${ApiConfig.baseUrl}/plan'),
            headers: _headers(token, json: true), body: jsonEncode(data))
        .timeout(_timeout);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['message'] ?? 'Error al actualizar plan');
  }

  Future<List<Map<String, dynamic>>> getCategories(String token) async {
    final res = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/foods/category/list'),
            headers: _headers(token))
        .timeout(_timeout);
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Error al cargar categorías');
  }
}
