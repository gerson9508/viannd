import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/food_plan_provider.dart'; // 👈 NUEVO
import '../../widgets/bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    if (auth.user != null && auth.token != null) {
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final end = monday.add(const Duration(days: 6));
      await context.read<ReportProvider>().loadReport(
        auth.user!.id, auth.token!, monday, end,
      );
      // 👈 NUEVO: cargar plan al abrir perfil (por si se actualizó)
      await context.read<FoodPlanProvider>().loadPlan(auth.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final report = context.watch<ReportProvider>().report;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = auth.user;
    final initial = user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U';

    return Scaffold(
      body: Column(
        children: [
          // ── Header con gradiente ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
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
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 32,
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.gps_fixed, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Controlar peso · ${user?.dailyKcal ?? 1800} kcal',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Contenido scrolleable ─────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ── Card de estadísticas ───────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statItem(context, '${report?.consecutiveDays ?? 0}', 'Días activos'),
                        _divider(context),
                        _statItem(context, '${report?.compliancePercent.toInt() ?? 0}%', 'Cumplimiento'),
                        _divider(context),
                        _statItem(context, '${report?.consecutiveDays ?? 0}', 'Racha días'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Card de menú ───────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _menuItem(
                          context,
                          Icons.person_outline,
                          'Datos personales',
                          Colors.blue[100]!,
                          () => context.push('/personal-data'),
                        ),
                        Divider(height: 1, color: theme.dividerColor),
                        _toggleItem(context, Icons.nightlight_outlined, 'Modo oscuro', Colors.purple[100]!),
                        Divider(height: 1, color: theme.dividerColor),
                        _menuItem(
                          context,
                          Icons.notifications_outlined,
                          'Recordatorios',
                          Colors.pink[100]!,
                          () => context.push('/reminders'),
                        ),
                        Divider(height: 1, color: theme.dividerColor), // 👈 NUEVO
                        _menuItem(                                       // 👈 NUEVO
                          context,
                          Icons.restaurant_menu_outlined,
                          'Plan alimenticio',
                          Colors.orange[100]!,
                          () => context.push('/food-plan/view'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Card de cerrar sesión ──────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: ListTile(
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            title: const Text(
                              '¿Cerrar sesión?',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            content: const Text(
                                '¿Estás seguro de que deseas cerrar sesión?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(
                                  'Cancelar',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6)),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text(
                                  'Cerrar sesión',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          context.read<FoodPlanProvider>().clearPlan(); // 👈 NUEVO
                          await auth.logout();
                          if (context.mounted) context.go('/');
                        }
                      },
                      title: const Text(
                        'Cerrar sesión',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w600),
                      ),
                      trailing: const Icon(Icons.logout, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 4),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _statItem(BuildContext context, String value, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _divider(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Theme.of(context).dividerColor,
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String label,
      Color iconBg, VoidCallback onTap) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconBg.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.3 : 1.0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: theme.colorScheme.onSurface),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right,
          color: theme.colorScheme.onSurface.withOpacity(0.4)),
    );
  }

  Widget _toggleItem(
      BuildContext context, IconData icon, String label, Color iconBg) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconBg.withOpacity(themeProvider.isDark ? 0.3 : 1.0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: theme.colorScheme.onSurface),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Switch(
        value: themeProvider.isDark,
        onChanged: (val) => themeProvider.toggleTheme(val),
        activeColor: const Color(0xFF4CAF50),
      ),
    );
  }
}
