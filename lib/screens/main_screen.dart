import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'home_screen.dart';
import 'tools_screen.dart';
import '../theme/app_theme.dart';
import 'profile_screen.dart';
import 'knowledge_base_screen.dart';
import 'reports_screen.dart';
import 'todo_screen.dart';
import 'certifications_screen.dart';
import 'inventory_screen.dart';
import 'company_directory_screen.dart';
import 'field_log_screen.dart';
import '../widgets/app_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const HomeScreen(),
    const ToolsScreen(),
    const ReportsScreen(),
    const FieldLogScreen(),
    const TodoScreen(),
    const KnowledgeBaseScreen(),
    const ProfileScreen(),
    const CertificationsScreen(),
    const InventoryScreen(),
    const CompanyDirectoryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 1200;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
          style: AppTheme.titleLarge.copyWith(color: AppTheme.textPrimary),
        ),
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
                child: ClipRect(
                  child: _screens[_selectedIndex],
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
                items: List.generate(7, (index) {
                  final bool isSelected = index == _selectedIndex && _selectedIndex <= 6;
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
                currentIndex: _selectedIndex <= 6 ? _selectedIndex : 0,
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
        return isSelected ? Icons.bar_chart : Icons.bar_chart_outlined;
      case 3:
        return isSelected ? Icons.note_alt : Icons.note_alt_outlined;
      case 4:
        return isSelected ? Icons.checklist : Icons.checklist_outlined;
      case 5:
        return isSelected ? Icons.psychology : Icons.psychology_outlined;
      case 6:
        return isSelected ? Icons.person : Icons.person_outline;
      case 7:
        return isSelected ? Icons.verified_user : Icons.verified_user_outlined;
      case 8:
        return isSelected ? Icons.inventory_2 : Icons.inventory_2_outlined;
      case 9:
        return isSelected ? Icons.people_alt : Icons.people_alt_outlined;
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
        return 'Reports';
      case 3:
        return 'Field Log';
      case 4:
        return 'To-Do';
      case 5:
        return 'KB';
      case 6:
        return 'Profile';
      case 7:
        return 'Certifications';
      case 8:
        return 'Inventory';
      case 9:
        return 'Directory';
      default:
        return '';
    }
  }
} 