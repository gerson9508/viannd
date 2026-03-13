import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/reminder_service.dart';
import '../../models/reminder_model.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/notification_service.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final _reminderService = ReminderService();
  final _notificationService = NotificationService(); 
  List<ReminderModel> _reminders = [];
  bool _isLoading = true;

  final _mealTypeNames = {1: 'Desayuno', 2: 'Comida', 3: 'Cena', 4: 'Colación'};
  final _mealTypeIcons = {
    1: Icons.coffee_outlined,
    2: Icons.restaurant_outlined,
    3: Icons.nightlight_outlined,
    4: Icons.cookie_outlined,
  };
  final _mealTypeColors = {
    1: const Color(0xFFFFF8E1),
    2: const Color(0xFFE8F5E9),
    3: const Color(0xFFEDE7F6),
    4: const Color(0xFFFFEBEE),
  };
  final _mealTypeIconColors = {
    1: const Color(0xFFFFB300),
    2: const Color(0xFF43A047),
    3: const Color(0xFF7E57C2),
    4: const Color(0xFFE53935),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReminders());
  }

  Future<void> _loadReminders() async {
  final auth = context.read<AuthProvider>();
  if (auth.user == null || auth.token == null) return;
  setState(() => _isLoading = true);
  try {
    final data = await _reminderService.getRemindersByUser(auth.user!.id, auth.token!);
    setState(() {
      _reminders = data.map((r) => ReminderModel.fromJson(r)).toList();
    });
  } catch (e) {
    setState(() => _reminders = []);
  }

  
  await _syncNotifications(_reminders);

  setState(() => _isLoading = false);
}

    
    Future<void> _syncNotifications(List<ReminderModel> reminders) async {
      for (final r in reminders) {
        if (r.active && r.time.isNotEmpty && r.time != '00:00') {
          await _notificationService.scheduleReminderNotification(
            id: r.id,
            mealType: r.mealType,
            time: r.time,
          );
        } else {
          await _notificationService.cancelReminderNotification(r.id);
        }
      }
    }

  Future<void> _toggleReminder(int id) async {
    final auth = context.read<AuthProvider>();
    await _reminderService.toggleReminder(id, auth.token!);
    await _loadReminders();
  }

  Future<void> _editReminderTime(ReminderModel reminder) async {
    // Parsear la hora actual del recordatorio
    TimeOfDay initialTime = const TimeOfDay(hour: 8, minute: 0);
    if (reminder.time.isNotEmpty && reminder.time != '00:00') {
      final parts = reminder.time.split(':');
      if (parts.length == 2) {
        final h = int.tryParse(parts[0]) ?? 8;
        final m = int.tryParse(parts[1]) ?? 0;
        initialTime = TimeOfDay(hour: h, minute: m);
      }
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4CAF50),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null || !mounted) return;

    final timeStr =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    final auth = context.read<AuthProvider>();

    // Eliminar y recrear con nueva hora (la API de toggle no acepta time,
    // así que borramos y creamos de nuevo)
    await _reminderService.deleteReminder(reminder.id, auth.token!);
    await _reminderService.createReminder(
      {
        'userId': auth.user!.id,
        'mealType': reminder.mealType,
        'time': timeStr,
        'active': reminder.active,
      },
      auth.token!,
    );
    await _loadReminders();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alarma de ${_mealTypeNames[reminder.mealType]} actualizada a $timeStr'),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _createDefaultReminders() async {
    final auth = context.read<AuthProvider>();
    final defaults = [
      {'userId': auth.user!.id, 'mealType': 1, 'time': '08:00', 'active': true},
      {'userId': auth.user!.id, 'mealType': 2, 'time': '14:00', 'active': true},
      {'userId': auth.user!.id, 'mealType': 3, 'time': '20:00', 'active': true},
      {'userId': auth.user!.id, 'mealType': 4, 'time': '00:00', 'active': false},
    ];
    for (final r in defaults) {
      await _reminderService.createReminder(r, auth.token!);
    }
    await _loadReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [
          // Header oscuro
          Container(
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
            color: const Color(0xFF1A1A1A),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.go('/profile'),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Recordatorios',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.notifications_outlined, color: Colors.white),
              ],
            ),
          ),

          // Lista de recordatorios
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
                : _reminders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.alarm_off, size: 60, color: Colors.grey[600]),
                            const SizedBox(height: 16),
                            Text(
                              'Sin recordatorios',
                              style: TextStyle(color: Colors.grey[400], fontSize: 16),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _createDefaultReminders,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Crear recordatorios',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                        itemCount: _reminders.length,
                        itemBuilder: (_, i) {
                          final r = _reminders[i];
                          final name = _mealTypeNames[r.mealType] ?? '';
                          final icon = _mealTypeIcons[r.mealType] ?? Icons.alarm;
                          final bgColor = _mealTypeColors[r.mealType] ?? Colors.grey[200]!;
                          final iconColor =
                              _mealTypeIconColors[r.mealType] ?? Colors.grey;
                          final timeDisplay =
                              r.time.isEmpty || r.time == '00:00' ? 'Sin hora' : r.time;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2C2C),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                // Ícono de tipo de comida
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: Icon(icon, color: iconColor, size: 22),
                                ),
                                const SizedBox(width: 14),
                                // Nombre y hora
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        timeDisplay,
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Switch activo/inactivo
                                Switch(
                                  value: r.active,
                                  onChanged: (_) => _toggleReminder(r.id),
                                  activeColor: const Color(0xFF4CAF50),
                                  inactiveThumbColor: Colors.grey[600],
                                  inactiveTrackColor: Colors.grey[700],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),

          // Botón editar alarma — ahora funcional con picker
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _reminders.isEmpty
                    ? null
                    : () => _showEditAlarmSheet(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  disabledBackgroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.alarm, color: Colors.white),
                label: const Text(
                  'Editar alarma',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 4),
    );
  }

  void _showEditAlarmSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C2C2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¿Qué alarma deseas editar?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ..._reminders.map((r) {
                final name = _mealTypeNames[r.mealType] ?? '';
                final icon = _mealTypeIcons[r.mealType] ?? Icons.alarm;
                final bgColor = _mealTypeColors[r.mealType] ?? Colors.grey[200]!;
                final iconColor = _mealTypeIconColors[r.mealType] ?? Colors.grey;
                final timeDisplay =
                    r.time.isEmpty || r.time == '00:00' ? 'Sin hora' : r.time;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  title: Text(name,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: Text(timeDisplay,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                  trailing:
                      const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.pop(context);
                    _editReminderTime(r);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
