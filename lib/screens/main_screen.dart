import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'home_screen.dart';
import 'most_used_tools_screen.dart';
import 'tools_screen.dart';
import '../theme/app_theme.dart';
import 'profile_screen.dart';
import 'knowledge_base_screen.dart';
import 'maps_screen.dart';
import 'inventory_screen.dart';
import 'company_directory_screen.dart';
import 'method_hours_screen.dart';
import 'news_updates_screen.dart';
import '../widgets/app_drawer.dart';
import 'pdf_to_excel_screen.dart';
import 'feedback_screen.dart';
import 'defect_analyzer_screen.dart';
import 'defect_identifier_screen.dart';
import '../services/analytics_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MostUsedToolsScreen(),
    const ToolsScreen(),
    const MapsScreen(),
    const MethodHoursScreen(),
    const KnowledgeBaseScreen(),
    const ProfileScreen(),
    const InventoryScreen(),
    const CompanyDirectoryScreen(),
    const NewsUpdatesScreen(),
    const PdfToExcelScreen(),
    const FeedbackScreen(),
    const DefectAnalyzerScreen(),
    const DefectIdentifierScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
    
    // Log initial screen view
    AnalyticsService().logScreenView(_getScreenNameForIndex(_selectedIndex));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
      // Animate screen transition
      _animationController.reset();
      _animationController.forward();
      
      // Log screen view
      AnalyticsService().logScreenView(_getScreenNameForIndex(index));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 1200;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF242A33), // Slightly elevated surface
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: !isLargeScreen
            ? IconButton(
                icon: const Icon(Icons.menu, color: Color(0xFFEDF9FF)),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              )
            : null,
        title: Text(
          _getLabelForIndex(_selectedIndex),
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFFEDF9FF), // Primary text
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Company Logo Icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6C5BFF), // Primary accent
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.engineering,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      drawer: !isLargeScreen
          ? AppDrawer(
              selectedIndex: _selectedIndex,
              onItemSelected: _onItemTapped,
            )
          : null,
      body: Container(
        color: const Color(0xFF1E232A), // Main background
        child: Row(
          children: [
            if (isLargeScreen)
              SizedBox(
                width: 280,
                child: AppDrawer(
                  selectedIndex: _selectedIndex,
                  onItemSelected: _onItemTapped,
                ),
              ),
            Expanded(
              child: Container(
                color: const Color(0xFF1E232A), // Main background
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ClipRect(
                    child: _screens[_selectedIndex],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: !isLargeScreen
          ? Container(
              decoration: BoxDecoration(
                color: const Color(0xFF242A33), // Slightly elevated surface
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.05),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                items: List.generate(5, (index) {
                  final bool isSelected = index == _selectedIndex && _selectedIndex < 5;
                  return BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: isSelected
                          ? BoxDecoration(
                              color: const Color(0xFF6C5BFF).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF6C5BFF).withOpacity(0.3),
                                width: 1,
                              ),
                            )
                          : null,
                      child: Icon(
                        _getIconForIndex(index, isSelected),
                        color: isSelected
                            ? const Color(0xFF6C5BFF) // Primary accent
                            : const Color(0xFFAEBBC8), // Secondary text
                        size: 24,
                      ),
                    ),
                    label: _getLabelForIndex(index),
                  );
                }),
                currentIndex: _selectedIndex < 5 ? _selectedIndex : 0,
                selectedItemColor: const Color(0xFFEDF9FF), // Primary text
                unselectedItemColor: const Color(0xFFAEBBC8), // Secondary text
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
                onTap: _onItemTapped,
                elevation: 0,
                backgroundColor: Colors.transparent,
                selectedFontSize: 12,
                unselectedFontSize: 11,
              ),
            )
          : null,
    );
  }

  IconData _getIconForIndex(int index, bool isSelected) {
    switch (index) {
      case 0:
        return isSelected ? Icons.home : Icons.home_outlined;
      case 1:
        return isSelected ? Icons.star : Icons.star_outlined;
      case 2:
        return isSelected ? Icons.build : Icons.build_outlined;
      case 3:
        return isSelected ? Icons.map : Icons.map_outlined;
      case 4:
        return isSelected ? Icons.note_alt : Icons.note_alt_outlined;
      case 5:
        return isSelected ? Icons.psychology : Icons.psychology_outlined;
      case 6:
        return isSelected ? Icons.person : Icons.person_outline;
      case 7:
        return isSelected ? Icons.inventory_2 : Icons.inventory_2_outlined;
      case 8:
        return isSelected ? Icons.people_alt : Icons.people_alt_outlined;
      case 9:
        return isSelected ? Icons.newspaper : Icons.newspaper_outlined;
      case 10:
        return isSelected ? Icons.transform : Icons.transform_outlined;
      case 11:
        return isSelected ? Icons.feedback : Icons.feedback_outlined;
      case 12:
        return isSelected ? Icons.analytics : Icons.analytics_outlined;
      case 13:
        return isSelected ? Icons.photo_camera : Icons.photo_camera_outlined;
      default:
        return Icons.home_outlined;
    }
  }

  String _getLabelForIndex(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Most Used Tools';
      case 2:
        return 'NDT Tools';
      case 3:
        return 'Maps';
      case 4:
        return 'Method Hours';
      case 5:
        return 'KB';
      case 6:
        return 'Profile';
      case 7:
        return 'Inventory';
      case 8:
        return 'Directory';
      case 9:
        return 'News & Updates';
      case 10:
        return 'Equotip Data Converter';
      case 11:
        return 'Send Feedback';
      case 12:
        return 'Defect AI Analyzer';
      case 13:
        return 'Defect AI Identifier';
      default:
        return '';
    }
  }

  String _getScreenNameForIndex(int index) {
    switch (index) {
      case 0:
        return 'home';
      case 1:
        return 'most_used_tools';
      case 2:
        return 'ndt_tools';
      case 3:
        return 'maps';
      case 4:
        return 'method_hours';
      case 5:
        return 'knowledge_base';
      case 6:
        return 'profile';
      case 7:
        return 'inventory';
      case 8:
        return 'company_directory';
      case 9:
        return 'news_updates';
      case 10:
        return 'equotip_converter';
      case 11:
        return 'feedback';
      case 12:
        return 'defect_analyzer';
      case 13:
        return 'defect_identifier';
      default:
        return 'unknown';
    }
  }
}
