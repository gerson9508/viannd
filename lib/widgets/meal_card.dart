import 'package:flutter/material.dart';
import '../models/meal_model.dart';

class MealCard extends StatelessWidget {
  final MealModel meal;
  final VoidCallback? onDelete;

  const MealCard({super.key, required this.meal, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = meal.outsideDiet
        ? (isDark ? const Color(0xFF4E0000) : const Color(0xFFFFEDED))
        : theme.cardColor;

    final iconBgColor = meal.outsideDiet
        ? (isDark ? const Color(0xFF7F0000) : const Color(0xFFFFCDD2))
        : (isDark ? const Color(0xFF1B5E20) : const Color(0xFFE8F5E9));

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              meal.outsideDiet ? Icons.fastfood : Icons.egg_alt,
              color: meal.outsideDiet ? Colors.red[isDark ? 200 : 700] : const Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.foodName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${meal.quantity.toInt()}g',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${meal.calories?.toInt() ?? 0} kcal',
                style: TextStyle(
                  color: meal.outsideDiet ? Colors.red[isDark ? 200 : 700] : const Color(0xFF4CAF50),
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (meal.outsideDiet)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red[isDark ? 200 : 700]!),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Fuera de dieta',
                    style: TextStyle(
                      color: Colors.red[isDark ? 200 : 700],
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          if (onDelete != null)
            IconButton(
              icon: Icon(Icons.close, color: Colors.red[isDark ? 200 : 700], size: 18),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
