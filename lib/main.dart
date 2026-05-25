import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'screens/generator_screen.dart';
import 'screens/favorites_screen.dart';

void main() {
  runApp(const ShellApp());
}

class ShellApp extends StatelessWidget {
  const ShellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/main',
      routes: {
        '/main': (context) => const MainScreen(),
        '/generator': (context) => const GeneratorScreen(),
        '/favorites': (context) => const FavoritesScreen(),
      },
    );
  }
}
