class FoodModel {
  final int id;
  final int? localId;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  FoodModel({
    required this.id,
    this.localId,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'],
      localId: json['localId'],
      name: json['name'] ?? '',
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
    );
  }
}