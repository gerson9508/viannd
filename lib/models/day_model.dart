class DayModel {
  final int id;
  final int userId;
  final String date;
  final bool completed;

  DayModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.completed,
  });

  factory DayModel.fromJson(Map<String, dynamic> json) {
    return DayModel(
      id: json['id'],
      userId: json['userId'],
      date: json['date'] ?? '',
      completed: json['completed'] ?? false,
    );
  }
}