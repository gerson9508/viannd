import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_plan_provider.dart';
import '../../models/food_plan_model.dart';

class FoodPlanFormScreen extends StatefulWidget {
  final bool isEditing;
  const FoodPlanFormScreen({super.key, this.isEditing = false});

  @override
  State<FoodPlanFormScreen> createState() => _FoodPlanFormScreenState();
}

class _FoodPlanFormScreenState extends State<FoodPlanFormScreen> {
  static const _green = Color(0xFF4CAF50);

  String _dietType = 'Omnivoro';
  final List<String> _dietOptions = ['Omnivoro', 'Vegetariano', 'Vegano', 'Pescetariano'];

  final List<String> _preferredFoods = [];
  final _preferredController = TextEditingController();

  final Map<String, bool> _restrictedCheckboxes = {};
  final _otherRestrictedController = TextEditingController();

  bool _loadingCategories = true;

  // ─── Restricciones implícitas por tipo de dieta ──────────────────────────
  static const Map<String, List<String>> _impliedRestrictions = {
    'Vegetariano': [
      'Carne de res', 'Carne de cerdo', 'Aves',
      'Cordero, ternera y carnes de caza', 'Embutidos y carnes frías',
    ],
    'Vegano': [
      'Carne de res', 'Carne de cerdo', 'Aves',
      'Cordero, ternera y carnes de caza', 'Embutidos y carnes frías',
      'Lácteos y huevos',
    ],
    'Pescetariano': [
      'Carne de res', 'Carne de cerdo', 'Aves',
      'Cordero, ternera y carnes de caza', 'Embutidos y carnes frías',
    ],
    'Omnivoro': [],
  };

  // Retorna true si la categoría está bloqueada por el tipo de dieta actual
  bool _isImplied(String categoryName) =>
      (_impliedRestrictions[_dietType] ?? []).contains(categoryName);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final token = context.read<AuthProvider>().token!;
    final planProvider = context.read<FoodPlanProvider>();

    await planProvider.loadCategories(token);

    setState(() {
      for (final cat in planProvider.categories) {
        _restrictedCheckboxes[cat['nombre']] = false;
      }
      _loadingCategories = false;
    });

    if (widget.isEditing) _loadExistingData();
  }

  void _loadExistingData() {
    final plan = context.read<FoodPlanProvider>().plan;
    if (plan == null) return;
    setState(() {
      _dietType = plan.dietType;
      _preferredFoods.addAll(plan.preferredFoods);
      for (final r in plan.restrictedFoods) {
        if (_restrictedCheckboxes.containsKey(r)) {
          _restrictedCheckboxes[r] = true;
        } else {
          _otherRestrictedController.text = r;
        }
      }
    });
  }

  void _addPreferredFood() {
    final val = _preferredController.text.trim();
    if (val.isNotEmpty && !_preferredFoods.contains(val)) {
      setState(() => _preferredFoods.add(val));
      _preferredController.clear();
    }
  }

  // Solo guarda explícitas — las implícitas el provider ya las maneja
  List<String> get _buildRestrictedList {
    final list = _restrictedCheckboxes.entries
        .where((e) => e.value && !_isImplied(e.key))
        .map((e) => e.key)
        .toList();
    final other = _otherRestrictedController.text.trim();
    if (other.isNotEmpty) list.add(other);
    return list;
  }

  Future<void> _onSave() async {
    final token = context.read<AuthProvider>().token!;
    final provider = context.read<FoodPlanProvider>();
    final data = FoodPlanModel(
      dietType: _dietType,
      preferredFoods: _preferredFoods,
      restrictedFoods: _buildRestrictedList,
    ).toJson();

    final ok = await provider.savePlan(data, token);
    if (!mounted) return;
    if (ok) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar el plan. Intenta de nuevo.')),
      );
    }
  }

  @override
  void dispose() {
    _preferredController.dispose();
    _otherRestrictedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<FoodPlanProvider>();
    final hasImplied = _impliedRestrictions[_dietType]?.isNotEmpty ?? false;

    return Scaffold(
      appBar: widget.isEditing
          ? AppBar(
              title: const Text('Plan alimenticio'),
              backgroundColor: _green,
              foregroundColor: Colors.white,
            )
          : null,
      body: SafeArea(
        child: _loadingCategories
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!widget.isEditing) ...[
                      const SizedBox(height: 12),
                      Text('Plan alimenticio',
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                    ],

                    // ─── Tipo de alimentación ─────────────────────────────
                    _sectionTitle('Tipo de alimentación'),
                    const Text('Selecciona el tipo de dieta que sigues',
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: _dietOptions.map((option) {
                          final selected = _dietType == option;
                          return RadioListTile<String>(
                            value: option,
                            groupValue: _dietType,
                            title: Text(option,
                                style: TextStyle(
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.normal)),
                            activeColor: _green,
                            tileColor: selected
                                ? _green.withOpacity(0.08)
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            onChanged: (v) => setState(() => _dietType = v!),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── Alimentos preferidos ─────────────────────────────
                    _sectionTitle('Alimentos preferidos'),
                    const Text('Añade tus alimentos favoritos:',
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _preferredController,
                            decoration: InputDecoration(
                              hintText: 'Ej. Aguacate, tomate...',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                            ),
                            onSubmitted: (_) => _addPreferredFood(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addPreferredFood,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Añadir'),
                        ),
                      ],
                    ),
                    if (_preferredFoods.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _preferredFoods
                            .map((f) => Chip(
                                  label: Text(f),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () =>
                                      setState(() => _preferredFoods.remove(f)),
                                  backgroundColor: _green.withOpacity(0.12),
                                  labelStyle: const TextStyle(
                                      color: Color(0xFF2E7D32)),
                                ))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // ─── Alimentos restringidos ───────────────────────────
                    _sectionTitle('Alimentos restringidos'),
                    const Text('¿Hay algo que prefieras evitar?',
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                    // Leyenda de categorías bloqueadas
                    if (hasImplied)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 2),
                        child: Row(
                          children: [
                            Icon(Icons.lock_outline,
                                size: 13, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Las categorías en gris ya están restringidas por tu tipo de dieta',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          ..._buildDynamicCheckboxGrid(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                const Text('Otro: ',
                                    style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _otherRestrictedController,
                                    decoration: InputDecoration(
                                      hintText: 'Escribe aquí...',
                                      isDense: true,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ─── Botón Guardar ────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : _onSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          disabledBackgroundColor: Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: provider.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Guardar',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  // ─── Grid dinámico de checkboxes ─────────────────────────────────────────
  List<Widget> _buildDynamicCheckboxGrid() {
    final keys = _restrictedCheckboxes.keys.toList();
    final rows = <Widget>[];
    for (int i = 0; i < keys.length; i += 2) {
      rows.add(Row(
        children: [
          Expanded(child: _checkboxTile(keys[i])),
          if (i + 1 < keys.length)
            Expanded(child: _checkboxTile(keys[i + 1]))
          else
            const Expanded(child: SizedBox()),
        ],
      ));
    }
    return rows;
  }

  Widget _checkboxTile(String label) {
    final implied = _isImplied(label);

    return CheckboxListTile(
      // Si es implícita siempre aparece marcada y bloqueada
      value: implied ? true : (_restrictedCheckboxes[label] ?? false),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: implied ? Colors.grey : null,
        ),
      ),
      // Ícono de candado para las bloqueadas
      secondary: implied
          ? const Icon(Icons.lock_outline, size: 16, color: Colors.grey)
          : null,
      activeColor: implied ? Colors.grey : _green,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
      // null = deshabilitado (no interactuable)
      onChanged: implied
          ? null
          : (v) => setState(() => _restrictedCheckboxes[label] = v ?? false),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );
}
