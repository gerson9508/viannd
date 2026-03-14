import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/meal_provider.dart';
import '../../providers/day_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/calorie_ring.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
  final auth = context.read<AuthProvider>();
  final meals = context.read<MealProvider>();
  final report = context.read<ReportProvider>();

  if (auth.user != null && auth.token != null) {
    await meals.loadMeals(auth.user!.id, auth.token!);

    // Cargar reporte de la semana actual
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    await report.loadReport(auth.user!.id, auth.token!, weekStart, weekEnd);
  }
}

  String _formattedDate() {
    final now = DateTime.now();
    const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    const months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return '${days[now.weekday - 1]}, ${now.day} de ${months[now.month - 1]}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final mealProvider = context.watch<MealProvider>();
    final days = context.read<DayProvider>();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final todayMeals = mealProvider.meals.where((m) => m.date.startsWith(today)).toList();
    final totalCalories = todayMeals.fold<double>(0, (sum, m) => sum + (m.calories ?? 0));
    final totalProtein = todayMeals.fold<double>(0, (sum, m) => sum + (m.protein ?? 0));
    final totalCarbs = todayMeals.fold<double>(0, (sum, m) => sum + (m.carbs ?? 0));
    final totalFat = todayMeals.fold<double>(0, (sum, m) => sum + (m.fat ?? 0));
    final goalCalories = (auth.user?.dailyKcal ?? 1800).toDouble();
    final percent = (totalCalories / goalCalories * 100).clamp(0, 100).toDouble();
    
    final mealTypes = [
      {'label': 'Desayuno', 'type': 1, 'icon': Icons.egg_alt},
      {'label': 'Comida', 'type': 2, 'icon': Icons.restaurant},
      {'label': 'Cena', 'type': 3, 'icon': Icons.nightlight},
      {'label': 'Colación', 'type': 4, 'icon': Icons.cookie},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
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
                const Text('Inicio', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => context.go('/reminders'),
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                )

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
                    Text(_formattedDate(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          CalorieRing(
                            percent: percent,
                            label: 'Hoy',
                            sublabel: '${percent.toInt()}%',
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min, 
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Calorías consumidas', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                Text('${totalCalories.toInt()} kcal', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _nutrientText('${totalProtein.toInt()} g', 'Proteínas'),
                                    _nutrientText('${totalCarbs.toInt()} g', 'Carbs'),
                                    _nutrientText('${totalFat.toInt()} g', 'Grasas'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildStreakCard(),
                    const SizedBox(height: 20),
                    const Text('Comidas de hoy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: mealTypes.map((mt) {
                        final typeMeals = todayMeals.where((m) => m.mealType == mt['type']).toList();
                        final typeCalories = typeMeals.fold<double>(0, (s, m) => s + (m.calories ?? 0));
                        final registered = typeMeals.isNotEmpty;
                        return GestureDetector(
                          onTap: () => context.go('/meals'),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(mt['icon'] as IconData, color: const Color(0xFF4CAF50)),
                                const Spacer(),
                                Text(mt['label'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                                Text('${typeCalories.toInt()} kcal', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: registered ? const Color(0xFFE8F5E9) : const Color(0xFFFFEDED),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    registered ? 'Registrado' : 'Pendiente',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: registered ? const Color(0xFF4CAF50) : Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }

  Widget _nutrientText(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildStreakCard() {
    final report = context.watch<ReportProvider>().report;
    final weekDays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    // El API devuelve "Mon","Tue","Wed","Thu","Fri","Sat","Sun"
    const apiDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final activeDays = report?.dailyCalories
        .map((d) => d['day'] as String)
        .toSet() ?? {};

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Racha de registros  🔥 ${report?.consecutiveDays ?? 0} días',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Días consecutivos', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final hasDay = activeDays.contains(apiDays[i]);
              return Column(
                children: [
                  Text(weekDays[i], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: hasDay ? const Color(0xFF4CAF50) : Colors.grey[700],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}