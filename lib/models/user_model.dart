class UserModel {
  final int id;
  final String name;
  final String email;
  final int? age;
  final String? gender;
  final int? dailyKcal;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.age,
    this.gender,
    this.dailyKcal,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      age: json['age'],
      gender: json['gender'],
      dailyKcal: json['dailyKcal'],
    );
  }
}