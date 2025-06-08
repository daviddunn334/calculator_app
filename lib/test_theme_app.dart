import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This is needed to rebuild the app when the theme changes
  bool _isDarkMode = AppTheme.isDarkMode;
  
  // Update theme and rebuild the app
  void _updateTheme() {
    setState(() {
      _isDarkMode = AppTheme.isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Theme Test',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: ThemeTestScreen(onThemeChanged: _updateTheme),
    );
  }
}

class ThemeTestScreen extends StatefulWidget {
  final Function() onThemeChanged;
  
  const ThemeTestScreen({
    super.key, 
    required this.onThemeChanged,
  });

  @override
  State<ThemeTestScreen> createState() => _ThemeTestScreenState();
}

class _ThemeTestScreenState extends State<ThemeTestScreen> {
  bool get _isDarkMode => AppTheme.isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Theme Test',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Theme toggle button
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: AppTheme.textSecondary,
            ),
            onPressed: () {
              AppTheme.toggleTheme();
              widget.onThemeChanged();
              setState(() {});
            },
            tooltip: _isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
        ],
      ),
      body: Container(
        color: AppTheme.background,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Current Theme: ${_isDarkMode ? "Dark" : "Light"}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                color: AppTheme.surface,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'This is a card',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This demonstrates how the theme affects UI elements',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  AppTheme.toggleTheme();
                  widget.onThemeChanged();
                  setState(() {});
                },
                child: Text(
                  'Toggle Theme',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
