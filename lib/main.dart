import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart';
import 'firebase_options.dart';
import 'services/offline_service.dart';
import 'screens/main_screen.dart';
import 'screens/corrosion_grid_logger_screen.dart';
import 'screens/inspection_checklist_screen.dart';
import 'screens/common_formulas_screen.dart';
import 'screens/knowledge_base_screen.dart';
import 'screens/field_safety_screen.dart';
import 'screens/terminology_screen.dart';
import 'screens/ndt_procedures_screen.dart';
import 'screens/defect_types_screen.dart';
import 'screens/equipment_guides_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/news_updates_screen.dart';
import 'screens/tools_screen.dart';
import 'screens/field_log_screen.dart';
import 'services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize offline service
  final offlineService = OfflineService();
  await offlineService.initialize();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize AuthService with persistence
    final authService = AuthService();
    await authService.initialize();
  } catch (e) {
    print('Error initializing Firebase: $e');
    // App can still function offline with calculator tools
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Integrity Tools',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/corrosion_grid_logger': (context) => const CorrosionGridLoggerScreen(),
        '/inspection_checklist': (context) => const InspectionChecklistScreen(),
        '/common_formulas': (context) => const CommonFormulasScreen(),
        '/knowledge_base': (context) => const KnowledgeBaseScreen(),
        '/field_safety': (context) => const FieldSafetyScreen(),
        '/terminology': (context) => const TerminologyScreen(),
        '/ndt_procedures': (context) => const NDTProceduresScreen(),
        '/defect_types': (context) => const DefectTypesScreen(),
        '/equipment_guides': (context) => const EquipmentGuidesScreen(),
        '/reporting': (context) => const ReportsScreen(),
        '/news_updates': (context) => const NewsUpdatesScreen(),
        '/tools': (context) => const ToolsScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/field_log': (context) => const FieldLogScreen(),
      }
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to offline status
    return StreamBuilder<bool>(
      stream: OfflineService().onConnectivityChanged,
      initialData: OfflineService().isOnline,
      builder: (context, offlineSnapshot) {
        final bool isOnline = offlineSnapshot.data ?? true;
        
        // If offline, bypass authentication and go directly to tools
        if (!isOnline) {
          return const OfflineMainScreen();
        }
        
        // If online, proceed with normal authentication flow
        return StreamBuilder<fb_auth.User?>(
          stream: AuthService().authStateChanges,
          builder: (context, snapshot) {
            // Show loading indicator while checking auth state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Show error if there's an issue with auth state
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text('Error: ${snapshot.error}'),
                ),
              );
            }

            // Show login screen if not authenticated
            if (!snapshot.hasData) {
              return const LoginScreen();
            }

            // Show main screen if authenticated
            return const MainScreen();
          },
        );
      },
    );
  }
}

/// A simplified main screen for offline mode that only shows calculator tools
class OfflineMainScreen extends StatelessWidget {
  const OfflineMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Integrity Tools (Offline)'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Offline banner
          Container(
            width: double.infinity,
            color: Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: const Row(
              children: [
                Icon(Icons.wifi_off, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'You are offline. Only calculator tools are available.',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          // Tools screen
          const Expanded(
            child: ToolsScreen(),
          ),
        ],
      ),
    );
  }
}
