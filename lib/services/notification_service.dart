import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  // Nombres para las notificaciones según mealType
  static const _mealNames = {
    1: 'Desayuno 🍳',
    2: 'Comida 🍽️',
    3: 'Cena 🌙',
    4: 'Colación 🍪',
  };

  static const _mealBodies = {
    1: '¡Es hora de tu desayuno! Registra lo que comiste.',
    2: '¡Es hora de comer! No olvides registrar tu comida.',
    3: '¡Es hora de cenar! Recuerda registrar tu cena.',
    4: '¡Es hora de tu colación! Registra tu snack.',
  };

  Future<void> init() async {
   // tz.initializeTimeZones();
    
    //tz.setLocalLocation(tz.getLocation('America/Mexico_City')); 

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }


  /// Programa una notificación diaria repetitiva para un recordatorio
  Future<void> scheduleReminderNotification({
    required int id,
    required int mealType,
    required String time, // formato "HH:mm" o "HH:mm:ss"
  }) async {
    // Parsear hora
    final parts = time.split(':');
    if (parts.isEmpty) return;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    final title = _mealNames[mealType] ?? 'Recordatorio';
    final body = _mealBodies[mealType] ?? 'Es hora de registrar tu comida.';

    const androidDetails = AndroidNotificationDetails(
      'meal_reminders_channel',
      'Recordatorios de comida',
      channelDescription: 'Notificaciones para recordar registrar tus comidas',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      sound: 'default',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    // Calcular el próximo momento en que ocurra esa hora
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    // Si ya pasó hoy, programar para mañana
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id, // Usamos el id del recordatorio directamente
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Se repite diario
    );
  }

  /// Cancela la notificación de un recordatorio
  Future<void> cancelReminderNotification(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancela todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}
