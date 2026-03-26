class FoodPlanModel {
  final int? id;
  final String dietType;
  final List<String> preferredFoods;
  final List<String> restrictedFoods;

  FoodPlanModel({
    this.id,
    required this.dietType,
    required this.preferredFoods,
    required this.restrictedFoods,
  });

  factory FoodPlanModel.fromJson(Map<String, dynamic> json) => FoodPlanModel(
        id: json['id'],
        dietType: json['dietType'] ?? 'Omnivoro',
        preferredFoods: List<String>.from(json['preferredFoods'] ?? []),
        restrictedFoods: List<String>.from(json['restrictedFoods'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'dietType': dietType,
        'preferredFoods': preferredFoods,
        'restrictedFoods': restrictedFoods,
      };
}
