import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Integrity Tools',
      theme: AppTheme.theme,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false, // 👈 This removes the debug banner
    );
  }
}
