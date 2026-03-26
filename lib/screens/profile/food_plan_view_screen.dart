import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/food_plan_provider.dart';

class FoodPlanViewScreen extends StatelessWidget {
  const FoodPlanViewScreen({super.key});
  static const _green = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<FoodPlanProvider>().plan;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan alimenticio'),
        backgroundColor: _green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          )
        ],
      ),
      body: plan == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botón Editar
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/food-plan/edit'),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Editar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tipo de alimentación
                  _sectionTitle('Tipo de alimentación'),
                  const SizedBox(height: 8),
                  _infoBox(plan.dietType, theme),
                  const SizedBox(height: 24),

                  // Alimentos preferidos
                  _sectionTitle('Alimentos preferidos'),
                  const SizedBox(height: 8),
                  plan.preferredFoods.isEmpty
                      ? const Text('Ninguno registrado',
                          style: TextStyle(color: Colors.grey))
                      : Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _green.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: _green.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: plan.preferredFoods
                                .map((f) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 3),
                                      child: Text(f,
                                          style: const TextStyle(
                                              fontSize: 14)),
                                    ))
                                .toList(),
                          ),
                        ),
                  const SizedBox(height: 24),

                  // Alimentos restringidos
                  _sectionTitle('Alimentos restringidos'),
                  const SizedBox(height: 8),
                  plan.restrictedFoods.isEmpty
                      ? const Text('Ninguno registrado',
                          style: TextStyle(color: Colors.grey))
                      : Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _green.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: _green.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: plan.restrictedFoods
                                .map((f) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 3),
                                      child: Text(f,
                                          style: const TextStyle(
                                              fontSize: 14)),
                                    ))
                                .toList(),
                          ),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String text) => Text(text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));

  Widget _infoBox(String text, ThemeData theme) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(text, style: const TextStyle(fontSize: 15)),
      );
}
