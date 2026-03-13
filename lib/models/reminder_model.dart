class ReminderModel {
  final int id;
  final int userId;
  final int mealType;
  final String time;
  final bool active;

  ReminderModel({
    required this.id,
    required this.userId,
    required this.mealType,
    required this.time,
    required this.active,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'],
      userId: json['userId'],
      mealType: json['mealType'],
      time: json['time'] ?? '',
      active: json['active'] ?? false,
    );
  }
}