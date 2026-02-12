import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:path_provider/path_provider.dart';
import 'firebase_options.dart';
import 'services/offline_service.dart';
import 'services/update_service.dart';
import 'services/performance_service.dart';
import 'widgets/auto_update_notification.dart';
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
import 'screens/reset_password_screen.dart';
import 'screens/email_verification_screen.dart';
import 'screens/terms_of_service_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/news_updates_screen.dart';
import 'screens/tools_screen.dart';
import 'screens/method_hours_screen.dart';
import 'screens/feedback_screen.dart';
import 'services/auth_service.dart';
import 'services/onboarding_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize offline service
  final offlineService = OfflineService();
  await offlineService.initialize();
  
  // Initialize PWA update service (web only)
  final updateService = UpdateService();
  await updateService.initialize();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Firebase Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    
    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    
    // Initialize AuthService with persistence
    final authService = AuthService();
    await authService.initialize();
    
    // Initialize Firebase Performance Monitoring
    // Performance monitoring is automatically enabled for web and mobile
    // No additional initialization required - traces can be started immediately
    if (kDebugMode) {
      print('[Performance] Firebase Performance Monitoring enabled');
    }
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
      home: const AggressiveUpdateWrapper(
        child: AuthGate(),
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/reset_password': (context) => const ResetPasswordScreen(),
        '/email_verification': (context) => const EmailVerificationScreen(),
        '/terms_of_service': (context) => const TermsOfServiceScreen(),
        '/privacy_policy': (context) => const PrivacyPolicyScreen(),
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
        '/method_hours': (context) => const MethodHoursScreen(),
        '/feedback': (context) => const FeedbackScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
      }
    );
  }
}

/// Wrapper that shows aggressive auto-update notification
class AggressiveUpdateWrapper extends StatefulWidget {
  final Widget child;

  const AggressiveUpdateWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<AggressiveUpdateWrapper> createState() => _AggressiveUpdateWrapperState();
}

class _AggressiveUpdateWrapperState extends State<AggressiveUpdateWrapper> {
  final UpdateService _updateService = UpdateService();
  String? _updateVersion;

  @override
  void initState() {
    super.initState();
    // Listen for updates
    _updateService.updateAvailableStream.listen((version) {
      setState(() {
        _updateVersion = version;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Show aggressive auto-update notification if update available
        if (_updateVersion != null)
          AutoUpdateOverlay(version: _updateVersion!),
      ],
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
                backgroundColor: AppTheme.background,
                body: Center(
                  child: LoadingLogo(),
                ),
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

            // Check onboarding status for authenticated users
            return const OnboardingChecker();
          },
        );
      },
    );
  }
}

/// Widget that checks if user needs onboarding and email verification
class OnboardingChecker extends StatelessWidget {
  const OnboardingChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: OnboardingService().hasCompletedOnboarding(),
      builder: (context, snapshot) {
        // Show loading while checking
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppTheme.background,
            body: Center(
              child: LoadingLogo(),
            ),
          );
        }

        // If user hasn't completed onboarding, show onboarding screen
        final hasCompleted = snapshot.data ?? false;
        if (!hasCompleted) {
          return const OnboardingScreen();
        }

        // After onboarding, check email verification
        return const EmailVerificationChecker();
      },
    );
  }
}

/// Widget that checks if user needs email verification (with grandfathering)
class EmailVerificationChecker extends StatelessWidget {
  const EmailVerificationChecker({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    
    if (user == null) {
      return const LoginScreen();
    }

    // GRANDFATHERING LOGIC: Protect existing users
    // Cutoff date: February 12, 2026 (deployment date)
    final cutoffDate = DateTime(2026, 2, 12);
    final accountCreated = user.metadata.creationTime;

    // If account was created BEFORE the cutoff date, skip email verification
    if (accountCreated != null && accountCreated.isBefore(cutoffDate)) {
      if (kDebugMode) {
        print('[EmailVerification] Grandfathered user (created: $accountCreated) - skipping verification');
      }
      return const MainScreen();
    }

    // For NEW users (created on or after cutoff), check email verification
    if (!user.emailVerified) {
      if (kDebugMode) {
        print('[EmailVerification] New user (created: $accountCreated) - requires verification');
      }
      return const EmailVerificationScreen();
    }

    // Email is verified - proceed to main screen
    if (kDebugMode) {
      print('[EmailVerification] Email verified - granting access');
    }
    return const MainScreen();
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

/// Loading screen with pulsing company logo
class LoadingLogo extends StatefulWidget {
  const LoadingLogo({super.key});

  @override
  State<LoadingLogo> createState() => _LoadingLogoState();
}

class _LoadingLogoState extends State<LoadingLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: SizedBox(
        width: 250,
        height: 250,
        child: Image.asset(
          'assets/logos/logo_main.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
