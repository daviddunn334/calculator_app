import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
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
import 'screens/reporting_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase first
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Then initialize Supabase
  await Supabase.initialize(
    url: 'https://cefujtovqdicsfqywfxw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNlZnVqdG92cWRpY3NmcXl3Znh3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5MDE5NTQsImV4cCI6MjA2MjQ3Nzk1NH0.B-gvG-6hchT6sOV6rhJBl8KbDlumorIzx4L8YauypDE',
  );
  
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
      routes: {
        '/corrosion_grid_logger': (context) => const CorrosionGridLoggerScreen(),
        '/inspection_checklist': (context) => const InspectionChecklistScreen(),
        '/common_formulas': (context) => const CommonFormulasScreen(),
        '/knowledge_base': (context) => const KnowledgeBaseScreen(),
        '/field_safety': (context) => const FieldSafetyScreen(),
        '/terminology': (context) => const TerminologyScreen(),
        '/ndt_procedures': (context) => const NDTProceduresScreen(),
        '/defect_types': (context) => const DefectTypesScreen(),
        '/equipment_guides': (context) => const EquipmentGuidesScreen(),
        '/reporting': (context) => const ReportingScreen(),
      }
    );
  }
}
