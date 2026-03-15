import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'providers/meal_provider.dart';
import 'providers/day_provider.dart';
import 'providers/report_provider.dart';
import 'providers/theme_provider.dart';
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

class MyApp extends StatefulWidget {
  final AuthProvider authProvider;
  const MyApp({super.key, required this.authProvider});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: widget.authProvider.isAuthenticated ? '/home' : '/',
      refreshListenable: widget.authProvider,
      redirect: (context, state) {
        final isLoggedIn = widget.authProvider.isAuthenticated;
        final isPublicRoute = state.matchedLocation == '/' ||
                              state.matchedLocation == '/login' ||
                              state.matchedLocation == '/register';
        if (!isLoggedIn && !isPublicRoute) return '/';
        if (isLoggedIn && isPublicRoute) return '/home';
        return null;
      },
      routes: [
        GoRoute(path: '/',              builder: (_, __) => const WelcomeScreen()),
        GoRoute(path: '/login',         builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register',      builder: (_, __) => const RegisterScreen()),
        GoRoute(path: '/home',          builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/meals',         builder: (_, __) => const MealsScreen()),
        GoRoute(path: '/add-meal',      builder: (_, __) => const AddMealScreen()),
        GoRoute(path: '/history',       builder: (_, __) => const HistoryScreen()),
        GoRoute(path: '/reports',       builder: (_, __) => const ReportsScreen()),
        GoRoute(path: '/profile',       builder: (_, __) => const ProfileScreen()),
        GoRoute(path: '/reminders',     builder: (_, __) => const RemindersScreen()),
        GoRoute(path: '/personal-data', builder: (_, __) => const PersonalDataScreen()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.authProvider),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MealProvider()),
        ChangeNotifierProvider(create: (_) => DayProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: _AppView(router: _router),
    );
  }
}

class _AppView extends StatelessWidget {
  final GoRouter router;
  const _AppView({required this.router});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'Viannd',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF4CAF50),
        brightness: Brightness.light,
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF5F0EB),
        cardColor: Colors.white,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF4CAF50),
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
      ),
      routerConfig: router,
    );
  }
}
