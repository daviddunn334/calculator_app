import 'package:flutter/material.dart';
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
