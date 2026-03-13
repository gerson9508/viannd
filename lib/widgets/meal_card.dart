import 'package:flutter/material.dart';
import '../models/meal_model.dart';

class MealCard extends StatelessWidget {
  final MealModel meal;
  final VoidCallback? onDelete;

  const MealCard({super.key, required this.meal, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: meal.outsideDiet ? const Color(0xFFFFEDED) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: meal.outsideDiet
                  ? const Color(0xFFFFCDD2)
                  : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              meal.outsideDiet ? Icons.fastfood : Icons.egg_alt,
              color: meal.outsideDiet ? Colors.red : const Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal.foodName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                Text('${meal.quantity.toInt()}g', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${meal.calories?.toInt() ?? 0} kcal',
                style: TextStyle(
                  color: meal.outsideDiet ? Colors.red : const Color(0xFF4CAF50),
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (meal.outsideDiet)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Fuera de dieta', style: TextStyle(color: Colors.red, fontSize: 11)),
                ),
            ],
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red, size: 18),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}