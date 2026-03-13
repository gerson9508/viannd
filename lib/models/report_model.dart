class ReportModel {
  final double avgCalories;
  final double avgProtein;
  final double avgCarbs;
  final double avgFat;
  final int totalExtras;
  final int consecutiveDays;
  final double compliancePercent;
  final List<Map<String, dynamic>> dailyCalories;

  ReportModel({
    required this.avgCalories,
    required this.avgProtein,
    required this.avgCarbs,
    required this.avgFat,
    required this.totalExtras,
    required this.consecutiveDays,
    required this.compliancePercent,
    required this.dailyCalories,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      avgCalories: (json['avgCalories'] ?? 0).toDouble(),
      avgProtein: (json['avgProtein'] ?? 0).toDouble(),
      avgCarbs: (json['avgCarbs'] ?? 0).toDouble(),
      avgFat: (json['avgFat'] ?? 0).toDouble(),
      totalExtras: json['totalExtras'] ?? 0,
      consecutiveDays: json['consecutiveDays'] ?? 0,
      compliancePercent: (json['compliancePercent'] ?? 0).toDouble(),
      dailyCalories: List<Map<String, dynamic>>.from(json['dailyCalories'] ?? []),
    );
  }
}