import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static Map<String, dynamic> _decode(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 400) {
      final message = body is Map ? body['message'] ?? 'Error del servidor' : 'Error del servidor';
      throw Exception(message);
    }
    return body is Map<String, dynamic> ? body : {};
  }

  static List<dynamic> _decodeList(http.Response response) {
    if (response.statusCode >= 400) {
      final body = jsonDecode(response.body);
      final message = body is Map ? body['message'] ?? 'Error del servidor' : 'Error del servidor';
      throw Exception(message);
    }
    final body = jsonDecode(response.body);
    return body is List ? body : [];
  }

  static Map<String, dynamic> parseMap(http.Response response) => _decode(response);
  static List<dynamic> parseList(http.Response response) => _decodeList(response);
}
