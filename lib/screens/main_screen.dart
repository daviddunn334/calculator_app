import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'tools_screen.dart';
import '../theme/app_theme.dart';
import 'profile_screen.dart';
import 'knowledge_base_screen.dart';
import 'reports_screen.dart';
import 'mile_tracker_screen.dart';
import 'todo_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Placeholder screens for the other tabs
  final List<Widget> _screens = [
    const HomeScreen(),
    const ToolsScreen(),
    const ReportsScreen(),
    const MileTrackerScreen(),
    const TodoScreen(),
    const KnowledgeBaseScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
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
            final bool isSelected = index == _selectedIndex;
            return BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: isSelected ? BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ) : null,
                child: Icon(
                  _getIconForIndex(index, isSelected),
                  color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
                ),
              ),
              label: _getLabelForIndex(index),
            );
          }),
          currentIndex: _selectedIndex,
          selectedItemColor: AppTheme.primaryBlue,
          unselectedItemColor: AppTheme.textSecondary,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
      ),
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
        return isSelected ? Icons.directions_car : Icons.directions_car_outlined;
      case 4:
        return isSelected ? Icons.checklist : Icons.checklist_outlined;
      case 5:
        return isSelected ? Icons.psychology : Icons.psychology_outlined;
      case 6:
        return isSelected ? Icons.person : Icons.person_outline;
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
        return 'Miles';
      case 4:
        return 'To-Do';
      case 5:
        return 'KB';
      case 6:
        return 'Profile';
      default:
        return '';
    }
  }
} 