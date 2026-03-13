import 'package:flutter/material.dart';
import '../services/day_service.dart';
import '../models/day_model.dart';

class DayProvider extends ChangeNotifier {
  final DayService _dayService = DayService();
  List<DayModel> _days = [];
  bool _isLoading = false;

  List<DayModel> get days => _days;
  bool get isLoading => _isLoading;

  Future<void> loadDays(int userId, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _dayService.getDaysByUser(userId, token);
      _days = data.map((d) => DayModel.fromJson(d)).toList();
    } catch (e) {
      _days = [];
    }
    _isLoading = false;
    notifyListeners();
  }

   Future<void> completeDay(int dayId, String token) async {
     await _dayService.completeDay(dayId, token);
   }

  Future<void> createTodayDay(int userId, String token) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final exists = _days.any((d) => d.date.startsWith(today));
    if (!exists) {
      await _dayService.createDay({'userId': userId, 'date': today}, token);
      await loadDays(userId, token);
    }
  }

  DayModel? getTodayDay() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    try {
      return _days.firstWhere((d) => d.date.startsWith(today));
    } catch (e) {
      return null;
    }
  }
}