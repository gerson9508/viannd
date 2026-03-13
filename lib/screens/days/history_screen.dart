import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/meal_provider.dart';
import '../../providers/day_provider.dart';
import '../../widgets/bottom_nav.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    if (auth.user != null && auth.token != null) {
      await context.read<DayProvider>().loadDays(auth.user!.id, auth.token!);
      await context.read<MealProvider>().loadMeals(auth.user!.id, auth.token!);
    }
  }

  final _mealTypeNames = {1: 'Desayuno', 2: 'Comida', 3: 'Cena', 4: 'Colación'};
  final _mealTypeIcons = {
    1: Icons.wb_sunny,
    2: Icons.restaurant,
    3: Icons.nightlight,
    4: Icons.cookie,
  };

  @override
  Widget build(BuildContext context) {
    final days = context.watch<DayProvider>().days;
    final meals = context.watch<MealProvider>().meals;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final today = now.toIso8601String().split('T')[0];
    final yesterday = now.subtract(const Duration(days: 1)).toIso8601String().split('T')[0];

    final selectedStr = _selectedDay.toIso8601String().split('T')[0];
    final selectedMeals = meals.where((m) => m.date.startsWith(selectedStr)).toList();
    final isToday = selectedStr == today;
    final isYesterday = selectedStr == yesterday;
    final sectionTitle = isToday
        ? 'Comidas de hoy'
        : isYesterday
            ? 'Comidas de ayer'
            : 'Comidas del $selectedStr';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.calendar_today, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Historial', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Icon(Icons.notifications_outlined, color: Colors.white),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Plan semanal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(7, (i) {
                          final day = weekStart.add(Duration(days: i));
                          final dayStr = day.toIso8601String().split('T')[0];
                          final hasDay = days.any((d) => d.date.startsWith(dayStr));
                          const weekLabels = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sáb', 'Dom'];
                          final isSelected = dayStr == selectedStr;

                          return GestureDetector(
                            onTap: () => setState(() => _selectedDay = day),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: isSelected
                                    ? Border.all(color: const Color(0xFF4CAF50), width: 2)
                                    : null,
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
                              ),
                              child: Column(
                                children: [
                                  Text(weekLabels[i],
                                      style: TextStyle(
                                          color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
                                          fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(day.day.toString().padLeft(2, '0'),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? const Color(0xFF4CAF50) : Colors.black)),
                                  const SizedBox(height: 6),
                                  Icon(Icons.check_circle,
                                      size: 20,
                                      color: hasDay ? const Color(0xFF4CAF50) : Colors.grey[300]),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDay,
                            firstDate: DateTime(2024),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => _selectedDay = picked);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.calendar_month, color: Colors.white),
                        label: const Text('Ver mes completo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(sectionTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildMealList(selectedMeals),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
    );
  }

  Widget _buildMealList(List meals) {
    if (meals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: const Center(child: Text('Sin comidas registradas', style: TextStyle(color: Colors.grey))),
      );
    }
    return Column(
      children: meals.map<Widget>((meal) {
        final icon = _mealTypeIcons[meal.mealType] ?? Icons.fastfood;
        final typeName = _mealTypeNames[meal.mealType] ?? '';
        final isRegistered = meal.completed;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isRegistered ? const Color(0xFFE8F5E9) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: isRegistered ? const Color(0xFF4CAF50) : Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(typeName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(meal.foodName, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
              if (isRegistered) const Icon(Icons.check, color: Color(0xFF4CAF50)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
