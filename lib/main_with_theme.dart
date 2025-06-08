import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  
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
      title: 'Integrity Tools',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: MainScreen(onThemeChanged: _updateTheme),
    );
  }
}

class MainScreen extends StatefulWidget {
  final Function() onThemeChanged;
  
  const MainScreen({
    super.key, 
    required this.onThemeChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool get _isDarkMode => AppTheme.isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Integrity Tools',
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
      drawer: AppDrawer(),
      body: Container(
        color: AppTheme.background,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Main App with Theme Switching',
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
                        'Current Theme: ${_isDarkMode ? "Dark" : "Light"}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This demonstrates the theme switching functionality',
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

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppTheme.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Integrity Tools',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Theme Demo',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: AppTheme.textSecondary),
              title: Text(
                'Home',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: AppTheme.textSecondary),
              title: Text(
                'Settings',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Divider(color: AppTheme.divider),
            ListTile(
              leading: Icon(
                AppTheme.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: AppTheme.textSecondary,
              ),
              title: Text(
                AppTheme.isDarkMode ? 'Light Mode' : 'Dark Mode',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                AppTheme.toggleTheme();
                Navigator.pop(context);
                // Force rebuild of the entire app
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyApp(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
