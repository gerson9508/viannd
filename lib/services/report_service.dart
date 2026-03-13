import 'dart:convert';                        
import 'package:http/http.dart' as http;     
import '../config/api_config.dart';          

class ReportService {
  Future<DateTime?> getUserFirstDate(int userId, String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/reports/weeks/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = jsonDecode(response.body);
    if (data['firstDate'] == null) return null;
    return DateTime.parse(data['firstDate']);
  }

  Future<Map<String, dynamic>> getWeeklyReport(
    int userId, String token, String startDate, String endDate
  ) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/reports/weekly/$userId')
        .replace(queryParameters: {'startDate': startDate, 'endDate': endDate});
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(response.body);
  }
}