import 'package:flutter/material.dart';
import '../services/meal_service.dart';
import '../models/meal_model.dart';

class MealProvider extends ChangeNotifier {
  final MealService _mealService = MealService();
  List<MealModel> _meals = [];
  bool _isLoading = false;

  List<MealModel> get meals => _meals;
  bool get isLoading => _isLoading;

  List<MealModel> getMealsByType(int mealType) =>
      _meals.where((m) => m.mealType == mealType).toList();

  Future<void> loadMeals(int userId, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _mealService.getMealsByUser(userId, token);
      _meals = data.map((m) => MealModel.fromJson(m)).toList();
    } catch (e) {
      _meals = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addMeal(Map<String, dynamic> data, String token, int userId) async {
    try {
      final result = await _mealService.createMeal(data, token);
      if (result['id'] != null) {
        await loadMeals(userId, token);
        //_meals.add(MealModel.fromJson(result));
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteMeal(int id, String token) async {
    await _mealService.deleteMeal(id, token);
    _meals.removeWhere((m) => m.id == id);
    notifyListeners();
  }
}