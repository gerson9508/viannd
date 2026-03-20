import 'dart:convert';                        
import 'package:http/http.dart' as http;     
import '../config/api_config.dart';          

class ReportService {
  Future<DateTime?> getUserFirstDate(int userId, String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/reports/weeks'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = jsonDecode(response.body);
    if (data['firstDate'] == null) return null;
    return DateTime.parse(data['firstDate']);
  }

 Future<Map<String, dynamic>> getWeeklyReport(
  int userId, String token, String startDate, String endDate
) async {
  // Sumar un día al endDate
  final parsedEndDate = DateTime.parse(endDate);
  final newEndDate = parsedEndDate.add(const Duration(days: 1));
  final adjustedEndDate = newEndDate.toIso8601String().split('T')[0]; // "yyyy-MM-dd"

  final uri = Uri.parse('${ApiConfig.baseUrl}/reports/weekly')
      .replace(queryParameters: {'startDate': startDate, 'endDate': adjustedEndDate});
  final response = await http.get(
    uri,
    headers: {'Authorization': 'Bearer $token'},
  );
  return jsonDecode(response.body);
}
}