import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'home_screen.dart';
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
      duration: const Duration(milliseconds: 300),
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
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: !isLargeScreen
            ? IconButton(
                icon: const Icon(Icons.menu, color: AppTheme.textPrimary),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              )
            : null,
        title: Text(
          _getLabelForIndex(_selectedIndex),
          style: AppTheme.titleLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Company Text Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                AppTheme.primaryNavy,
                BlendMode.srcIn,
              ),
              child: Image.asset(
                'assets/logos/logo_text_final.png',
                height: 24,
                fit: BoxFit.contain,
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
        color: AppTheme.background,
        child: Row(
          children: [
            if (isLargeScreen)
              Container(
                width: 280,
                color: Colors.white,
                child: AppDrawer(
                  selectedIndex: _selectedIndex,
                  onItemSelected: _onItemTapped,
                ),
              ),
            Expanded(
              child: Container(
                color: AppTheme.background,
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
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
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
                              color: AppTheme.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryBlue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            )
                          : null,
                      child: Icon(
                        _getIconForIndex(index, isSelected),
                        color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
                      ),
                    ),
                    label: _getLabelForIndex(index),
                  );
                }),
                currentIndex: _selectedIndex < 5 ? _selectedIndex : 0,
                selectedItemColor: AppTheme.primaryBlue,
                unselectedItemColor: AppTheme.textSecondary,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
                onTap: _onItemTapped,
                elevation: 0,
                backgroundColor: Colors.transparent,
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
        return isSelected ? Icons.build : Icons.build_outlined;
      case 2:
        return isSelected ? Icons.map : Icons.map_outlined;
      case 3:
        return isSelected ? Icons.note_alt : Icons.note_alt_outlined;
      case 4:
        return isSelected ? Icons.psychology : Icons.psychology_outlined;
      case 5:
        return isSelected ? Icons.person : Icons.person_outline;
      case 6:
        return isSelected ? Icons.inventory_2 : Icons.inventory_2_outlined;
      case 7:
        return isSelected ? Icons.people_alt : Icons.people_alt_outlined;
      case 8:
        return isSelected ? Icons.newspaper : Icons.newspaper_outlined;
      case 9:
        return isSelected ? Icons.transform : Icons.transform_outlined;
      case 10:
        return isSelected ? Icons.feedback : Icons.feedback_outlined;
      case 11:
        return isSelected ? Icons.analytics : Icons.analytics_outlined;
      case 12:
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
        return 'Tools';
      case 2:
        return 'Maps';
      case 3:
        return 'Method Hours';
      case 4:
        return 'KB';
      case 5:
        return 'Profile';
      case 6:
        return 'Inventory';
      case 7:
        return 'Directory';
      case 8:
        return 'News & Updates';
      case 9:
        return 'Equotip Data Converter';
      case 10:
        return 'Send Feedback';
      case 11:
        return 'Defect AI Analyzer';
      case 12:
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
        return 'tools';
      case 2:
        return 'maps';
      case 3:
        return 'method_hours';
      case 4:
        return 'knowledge_base';
      case 5:
        return 'profile';
      case 6:
        return 'inventory';
      case 7:
        return 'company_directory';
      case 8:
        return 'news_updates';
      case 9:
        return 'equotip_converter';
      case 10:
        return 'feedback';
      case 11:
        return 'defect_analyzer';
      case 12:
        return 'defect_identifier';
      default:
        return 'unknown';
    }
  }
}
