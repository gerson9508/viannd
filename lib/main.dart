import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'providers/meal_provider.dart';
import 'providers/day_provider.dart';
import 'providers/report_provider.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/meals/meals_screen.dart';
import 'screens/meals/add_meal_screen.dart';
import 'screens/days/history_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/reminders_screen.dart';
import 'screens/profile/personal_data_screen.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Mexico_City'));
  await NotificationService().init();
  final authProvider = AuthProvider();
  await authProvider.loadSession();
  runApp(MyApp(authProvider: authProvider));
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;
  const MyApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    //  Router creado UNA SOLA VEZ, fuera del Consumer
    final router = GoRouter(
      initialLocation: authProvider.isAuthenticated ? '/home' : '/',
      refreshListenable: authProvider, // ← escucha cambios sin recrear el router
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;

        final isPublicRoute = state.matchedLocation == '/' ||
                              state.matchedLocation == '/login' ||
                              state.matchedLocation == '/register';

        // Si no está logueado y quiere ir a ruta privada → manda al inicio
        if (!isLoggedIn && !isPublicRoute) return '/';

        // Si ya está logueado y quiere ir a rutas de auth → manda al home
        if (isLoggedIn && isPublicRoute) return '/home';

        return null; // sin redirección
      },
      routes: [
        GoRoute(path: '/',             builder: (_, __) => const WelcomeScreen()),
        GoRoute(path: '/login',        builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register',     builder: (_, __) => const RegisterScreen()),
        GoRoute(path: '/home',         builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/meals',        builder: (_, __) => const MealsScreen()),
        GoRoute(path: '/add-meal',     builder: (_, __) => const AddMealScreen()),
        GoRoute(path: '/history',      builder: (_, __) => const HistoryScreen()),
        GoRoute(path: '/reports',      builder: (_, __) => const ReportsScreen()),
        GoRoute(path: '/profile',      builder: (_, __) => const ProfileScreen()),
        GoRoute(path: '/reminders',    builder: (_, __) => const RemindersScreen()),
        GoRoute(path: '/personal-data',builder: (_, __) => const PersonalDataScreen()),
      ],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => MealProvider()),
        ChangeNotifierProvider(create: (_) => DayProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      // ✅ Ya no necesitas Consumer aquí
      child: MaterialApp.router(
        title: 'Viannd',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        routerConfig: router,
      ),
    );
  }
}
