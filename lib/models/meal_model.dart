class MealModel {
  final int id;
  final int userId;
  final int foodId;
  final String foodName;
  final double quantity;
  final int mealType;
  final String date;
  final String time;
  final bool outsideDiet;
  final bool completed;
  final int? dayId;
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;

  MealModel({
    required this.id,
    required this.userId,
    required this.foodId,
    required this.foodName,
    required this.quantity,
    required this.mealType,
    required this.date,
    required this.time,
    required this.outsideDiet,
    required this.completed,
    this.dayId,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'],
      userId: json['userId'],
      foodId: json['foodId'],
      foodName: json['foodName'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      mealType: json['mealType'],
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      outsideDiet: json['outsideDiet'] ?? false,
      completed: json['completed'] ?? false,
      dayId: json['dayId'],
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
    );
  }
}