import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF4CAF50),
      unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.5),
      backgroundColor: theme.colorScheme.surface,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        switch (index) {
          case 0: context.go('/home'); break;
          case 1: context.go('/history'); break;
          case 2: context.go('/add-meal'); break;
          case 3: context.go('/reports'); break;
          case 4: context.go('/profile'); break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Historial'),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 40, color: Color(0xFF4CAF50)), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reportes'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }
}
