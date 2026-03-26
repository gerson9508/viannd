import 'package:flutter/material.dart';
import '../services/food_plan_service.dart';
import '../models/food_plan_model.dart';

class FoodPlanProvider extends ChangeNotifier {
  final FoodPlanService _service = FoodPlanService();

  FoodPlanModel? _plan;
  bool _isLoading = false;
  bool _planChecked = false;
  List<Map<String, dynamic>> _categories = [];

  FoodPlanModel? get plan => _plan;
  bool get isLoading => _isLoading;
  bool get hasPlan => _plan != null;
  bool get planChecked => _planChecked;
  List<Map<String, dynamic>> get categories => _categories;

  // ─── Cargar plan ─────────────────────────────────────────────────────────
  Future<void> loadPlan(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _service.getPlan(token);
      _plan = data != null ? FoodPlanModel.fromJson(data) : null;
    } catch (_) {
      _plan = null;
    }
    _isLoading = false;
    _planChecked = true;
    notifyListeners();
  }

  // ─── Cargar categorías desde la BD ───────────────────────────────────────
  Future<void> loadCategories(String token) async {
    try {
      _categories = await _service.getCategories(token);
      notifyListeners();
    } catch (_) {
      _categories = [];
    }
  }

  // ─── Guardar / actualizar plan ────────────────────────────────────────────
  Future<bool> savePlan(Map<String, dynamic> data, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = hasPlan
          ? await _service.updatePlan(data, token)
          : await _service.createPlan(data, token);
      _plan = FoodPlanModel.fromJson(result);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearPlan() {
    _plan = null;
    _planChecked = false;
    _categories = [];
    notifyListeners();
  }

  // ─── Keywords por categoría (nombres exactos de la BD) ───────────────────
  static const Map<String, List<String>> _categoryKeywords = {
    'Carne de res': [
      'beef', 'steak', 'veal', 'ground beef', 'brisket',
      'ribeye', 'sirloin', 'chuck', 'flank',
    ],
    'Carne de cerdo': [
      'pork', 'bacon', 'ham', 'ribs', 'loin',
      'prosciutto', 'pancetta',
    ],
    'Aves': [
      'chicken', 'turkey', 'duck', 'poultry', 'hen',
      'wing', 'breast', 'thigh', 'drumstick', 'quail',
    ],
    'Cordero, ternera y carnes de caza': [
      'lamb', 'venison', 'bison', 'goat', 'rabbit',
      'deer', 'elk', 'mutton',
    ],
    'Embutidos y carnes frías': [
      'salami', 'pepperoni', 'chorizo', 'hot dog',
      'sausage', 'bologna', 'mortadella', 'pastrami',
    ],
    'Frutas y jugos de frutas': [
      'apple', 'orange', 'banana', 'grape', 'mango',
      'strawberry', 'juice', 'pear', 'peach', 'berry',
      'watermelon', 'pineapple', 'melon', 'fruit',
    ],
    'Verduras': [
      'broccoli', 'spinach', 'carrot', 'lettuce', 'tomato',
      'pepper', 'onion', 'garlic', 'zucchini', 'kale',
      'celery', 'cucumber', 'cabbage', 'vegetable',
    ],
    'Leguminosas': [
      'bean', 'lentil', 'chickpea', 'soy', 'pea',
      'tofu', 'edamame', 'legume', 'hummus',
    ],
    'Cereales y pastas': [
      'wheat', 'pasta', 'bread', 'flour', 'oat',
      'barley', 'rye', 'noodle', 'rice', 'quinoa',
      'cracker', 'tortilla',
    ],
    'Cereales de desayuno': [
      'cereal', 'granola', 'cornflakes', 'muesli',
      'oatmeal', 'porridge',
    ],
    'Lácteos y huevos': [
      'milk', 'cheese', 'egg', 'yogurt', 'butter',
      'cream', 'dairy', 'whey', 'kefir', 'ricotta',
      'mozzarella', 'cheddar', 'parmesan',
    ],
    'Tubérculos': [
      'potato', 'sweet potato', 'yam', 'cassava',
      'taro', 'turnip', 'beet', 'radish',
    ],
  };

  // ─── Restricciones implícitas por tipo de dieta ──────────────────────────
  static const Map<String, List<String>> _dietImpliedRestrictions = {
    'Vegetariano': [
      'Carne de res', 'Carne de cerdo', 'Aves',
      'Cordero, ternera y carnes de caza', 'Embutidos y carnes frías',
    ],
    'Vegano': [
      'Carne de res', 'Carne de cerdo', 'Aves',
      'Cordero, ternera y carnes de caza', 'Embutidos y carnes frías',
      'Lácteos y huevos',
    ],
    'Pescetariano': [
      'Carne de res', 'Carne de cerdo', 'Aves',
      'Cordero, ternera y carnes de caza', 'Embutidos y carnes frías',
    ],
    'Omnivoro': [],
  };

  // ─── Verificación principal ───────────────────────────────────────────────
  bool isFoodOutsideDiet(String foodName) {
    if (_plan == null) return false;
    final name = foodName.toLowerCase().trim();

    // 1️⃣ Restricciones explícitas del usuario (categorías marcadas)
    for (final restricted in _plan!.restrictedFoods) {
      if (_matchesCategory(name, restricted)) return true;
    }

    // 2️⃣ Restricciones implícitas del tipo de dieta
    final implied = _dietImpliedRestrictions[_plan!.dietType] ?? [];
    for (final category in implied) {
      if (_matchesCategory(name, category)) return true;
    }

    return false;
  }

  bool _matchesCategory(String foodNameLower, String categoryName) {
    final keywords = _categoryKeywords[categoryName];
    if (keywords != null) {
      return keywords.any((kw) => foodNameLower.contains(kw.toLowerCase()));
    }
    // Campo "Otro" → comparación directa
    return foodNameLower.contains(categoryName.toLowerCase());
  }
}
