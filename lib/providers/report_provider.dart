import 'package:flutter/material.dart';           
import '../services/report_service.dart';         
import '../models/report_model.dart';

class ReportProvider extends ChangeNotifier {
  final ReportService _reportService = ReportService();
  ReportModel? _report;
  bool _isLoading = false;
  DateTime? _userFirstDate;

  ReportModel? get report => _report;
  bool get isLoading => _isLoading;
  DateTime? get userFirstDate => _userFirstDate;

  // Cuántas semanas completas desde la primera fecha
  int get totalWeeks {
    if (_userFirstDate == null) return 1;
    final diff = DateTime.now().difference(_userFirstDate!).inDays;
    return (diff / 7).ceil().clamp(1, 12); // máximo 12 semanas
  }

  Future<void> loadUserWeeks(int userId, String token) async {
    final firstDate = await _reportService.getUserFirstDate(userId, token);
    _userFirstDate = firstDate;
    notifyListeners();
  }

  Future<void> loadReport(int userId, String token, DateTime startDate, DateTime endDate) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _reportService.getWeeklyReport(
        userId, token,
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      );
      _report = ReportModel.fromJson(data);
    } catch (e) {
      _report = null;
    }
    _isLoading = false;
    notifyListeners();
  }
}