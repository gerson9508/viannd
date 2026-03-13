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
      context.read<MealProvider>().loadMeals(auth.user!.id, auth.token!);
    });

  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: const Color(0xFFF5F0EB),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
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
                      const Text('Mis comidas', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      const Icon(Icons.notifications_outlined, color: Colors.white),
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
                      ? const Center(child: Text('Sin comidas registradas'))
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