import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/meal_provider.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/meal_card.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final auth = context.read<AuthProvider>();
      final today = DateTime.now();
      final date = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      context.read<MealProvider>().loadMealsByDate(auth.user!.id, date, auth.token!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final auth = context.watch<AuthProvider>();
    final mealProvider = context.watch<MealProvider>();

    final mealTypes = [
      {'label': 'Desayuno', 'type': 1},
      {'label': 'Comida', 'type': 2},
      {'label': 'Cena', 'type': 3},
      {'label': 'Colación', 'type': 4},
    ];

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF2E7D32), const Color(0xFF388E3C)]
                      : [const Color(0xFF43A047), const Color(0xFF66BB6A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/home'),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Mis comidas',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => context.push('/reminders'),
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TabBar(
                    isScrollable: true,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    tabs: mealTypes.map((m) => Tab(text: m['label'] as String)).toList(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: mealTypes.map((mt) {
                  final meals = mealProvider.getMealsByType(mt['type'] as int);
                  return meals.isEmpty
                      ? Center(
                          child: Text(
                            'Sin comidas registradas',
                            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: meals.length,
                          itemBuilder: (_, i) => MealCard(
                            meal: meals[i],
                            onDelete: () => mealProvider.deleteMeal(meals[i].id, auth.token!),
                          ),
                        );
                }).toList(),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF4CAF50),
          onPressed: () async {
            await context.push('/add-meal');
            final auth = context.read<AuthProvider>();
            await context.read<MealProvider>().loadMeals(auth.user!.id, auth.token!);
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
        bottomNavigationBar: const BottomNav(currentIndex: 0),
      ),
    );
  }
}
