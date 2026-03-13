import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _darkMode = false;

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
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final report = context.watch<ReportProvider>().report;
    final user = auth.user;
    final initial = user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Text(initial, style: const TextStyle(fontSize: 32, color: Color(0xFF4CAF50), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                Text(user?.name ?? '', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.gps_fixed, color: Colors.white70, size: 16),
                    SizedBox(width: 4),
                    Text('Controlar peso · 1,800 kcal', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statItem('${report?.consecutiveDays ?? 0}', 'Días activos'),
                        _divider(),
                        _statItem('${report?.compliancePercent.toInt() ?? 0}%', 'Cumplimiento'),
                        _divider(),
                        _statItem('${report?.consecutiveDays ?? 0}', 'Racha días'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                    ),
                    child: Column(
                      children: [
                        _menuItem(Icons.person_outline, 'Datos personales', Colors.blue[100]!, () => context.go('/personal-data')),
                        const Divider(height: 1),
                        _toggleItem(Icons.nightlight_outlined, 'Modo oscuro', Colors.purple[100]!),
                        const Divider(height: 1),
                        _menuItem(Icons.notifications_outlined, 'Recordatorios', Colors.pink[100]!, () => context.go('/reminders')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                    ),
                    child: ListTile(
                      onTap: () async {
                        await auth.logout();
                        if (context.mounted) context.go('/');
                      },
                      title: const Text('Cerrar sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
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

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 40, color: Colors.grey[200]);
  }

  Widget _menuItem(IconData icon, String label, Color iconBg, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  Widget _toggleItem(IconData icon, String label, Color iconBg) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Switch(
        value: _darkMode,
        onChanged: (val) => setState(() => _darkMode = val),
        activeColor: const Color(0xFF4CAF50),
      ),
    );
  }
}