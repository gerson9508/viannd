import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/meal_provider.dart';
import '../../providers/day_provider.dart';
import '../../services/food_service.dart';
import '../../models/food_model.dart';
import '../../widgets/bottom_nav.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _foodService = FoodService();
  List<FoodModel> _searchResults = [];
  final List<Map<String, dynamic>> _selectedFoods = [];
  bool _isSearching = false;
  bool _isOutsideDiet = false;
  int _selectedMealType = 1;
  double _selectedQuantity = 100;
  String _selectedCategory = 'todo';
  final DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCategories());
  }

  Future<void> _loadCategories() async {
    final auth = context.read<AuthProvider>();
    try {
      final results = await _foodService.getCategories(auth.token!);
      setState(() {
        _categories = List<Map<String, dynamic>>.from(results);
        _categories.insert(0, {'nombre': 'Todo', 'nombre_api': ''});
      });
    } catch (e) {
      _categories = [];
    }
  }

  Future<void> _searchFoods(String query) async {
    if (query.isEmpty) return;
    final auth = context.read<AuthProvider>();
    setState(() => _isSearching = true);
    try {
      final results = await _foodService.searchFoods(query, auth.token!);
      setState(() => _searchResults = results.map((f) => FoodModel.fromJson(f)).toList());
    } catch (e) {
      setState(() => _searchResults = []);
    }
    setState(() => _isSearching = false);
  }

  Future<void> _loadByCategory(String category) async {
    final auth = context.read<AuthProvider>();
    setState(() { _isSearching = true; _selectedCategory = category; });
    try {
      final results = await _foodService.getFoodsByCategory(category, auth.token!);
      setState(() => _searchResults = results.map((f) => FoodModel.fromJson(f)).toList());
    } catch (e) {
      setState(() => _searchResults = []);
    }
    setState(() => _isSearching = false);
  }

  void _addFood(FoodModel food) {
    setState(() {
      _selectedFoods.add({
        'food': food,
        'quantity': _selectedQuantity,
        'calories': food.calories * _selectedQuantity / 100,
      });
    });
  }

  double get _totalCalories => _selectedFoods.fold(0, (s, f) => s + (f['calories'] as double));

  Future<void> _saveMeal() async {
    if (_selectedFoods.isEmpty) return;
    final auth = context.read<AuthProvider>();
    final meals = context.read<MealProvider>();
    final days = context.read<DayProvider>();
    final day = days.getTodayDay();

    for (final item in _selectedFoods) {
      final food = item['food'] as FoodModel;
      final localId = food.localId ?? food.id;
      await meals.addMeal({
        'userId': auth.user!.id,
        'foodId': localId,
        'name': food.name,
        'calories': food.calories,
        'protein': food.protein,
        'fat': food.fat,
        'carbs': food.carbs,
        'quantity': item['quantity'],
        'mealType': _selectedMealType,
        'date': _selectedDate.toIso8601String().split('T')[0],
        'time': TimeOfDay.now().format(context),
        'outsideDiet': _isOutsideDiet,
        'completed': true,
        'dayId': day?.id,
      }, auth.token!, auth.user!.id);
    }

    if (context.mounted) context.go('/meals');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final scaffoldBg = _isOutsideDiet
        ? (isDark ? const Color(0xFF2D1200) : const Color(0xFFFFF3E0))
        : theme.scaffoldBackgroundColor;

    final headerColor = _isOutsideDiet ? Colors.deepOrange : const Color(0xFF43A047);

    final chipUnselectedColor = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : Colors.white;

    final chipUnselectedText = isDark
        ? theme.colorScheme.onSurface
        : Colors.black87;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 16),
            color: headerColor,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.go('/meals'),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Agregar alimento',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => context.push('/reminders'),
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                ),
              ],
            ),
          ),
          if (_isOutsideDiet)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF4E1A00) : const Color(0xFFFFEDED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Alimento no planificado', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                      Text('Se registrará como extra del día', style: TextStyle(color: Colors.orange, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Fecha: ', style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                              style: TextStyle(color: theme.colorScheme.onSurface),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.onSurface),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => setState(() => _isOutsideDiet = !_isOutsideDiet),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isOutsideDiet ? Colors.deepOrange : theme.cardColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Fuera de dieta',
                            style: TextStyle(
                              color: _isOutsideDiet ? Colors.white : theme.colorScheme.onSurface,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Tipo de comida', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        {'label': 'Desayuno', 'type': 1},
                        {'label': 'Comida', 'type': 2},
                        {'label': 'Cena', 'type': 3},
                        {'label': 'Colación', 'type': 4},
                      ].map((mt) {
                        final selected = _selectedMealType == mt['type'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedMealType = mt['type'] as int),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? const Color(0xFF4CAF50) : chipUnselectedColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              mt['label'] as String,
                              style: TextStyle(
                                color: selected ? Colors.white : chipUnselectedText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Nombre del platillo', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Nombre',
                      hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    onSubmitted: _searchFoods,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Buscar alimento...',
                      hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search, color: theme.colorScheme.onSurface),
                        onPressed: () => _searchFoods(_searchController.text),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final selected = _selectedCategory == cat['nombre_api'];
                        return GestureDetector(
                          onTap: () => _loadByCategory(cat['nombre_api']),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? const Color(0xFF4CAF50) : chipUnselectedColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              cat['nombre'],
                              style: TextStyle(color: selected ? Colors.white : chipUnselectedText),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Seleccionar porción', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  Row(
                    children: [100.0, 250.0, 500.0].map((q) {
                      final selected = _selectedQuantity == q;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedQuantity = q),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected ? const Color(0xFF4CAF50) : chipUnselectedColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${q.toInt()} g',
                            style: TextStyle(
                              color: selected ? Colors.white : chipUnselectedText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_isSearching)
                    const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
                  if (_searchResults.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text('Resultados', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                    const SizedBox(height: 8),
                    ..._searchResults.take(5).map((food) => ListTile(
                      tileColor: theme.cardColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      title: Text(food.name, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                      subtitle: Text(
                        '${food.calories.toInt()} kcal / 100g',
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle, color: Color(0xFF4CAF50)),
                        onPressed: () => _addFood(food),
                      ),
                    )),
                  ],
                  if (_selectedFoods.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1B5E20) : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Alimentos seleccionados',
                            style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ..._selectedFoods.map((item) {
                            final food = item['food'] as FoodModel;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${food.name} · ${(item['quantity'] as double).toInt()}g · ${(item['calories'] as double).toInt()} kcal',
                                      style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => setState(() => _selectedFoods.remove(item)),
                                    child: const Icon(Icons.close, color: Colors.red, size: 18),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total estimado:', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                        Text(
                          '${_totalCalories.toInt()} kcal',
                          style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _selectedFoods.clear()),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.3)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Limpiar', style: TextStyle(color: theme.colorScheme.onSurface)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveMeal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }
}
