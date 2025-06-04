import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AppDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 1200;
    
    return Container(
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shield_outlined, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Integrity Tools',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            selected: selectedIndex == 0,
            onTap: () {
              if (!isLargeScreen) {
                Navigator.pop(context);
              }
              onItemSelected(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.build_outlined),
            title: const Text('Tools'),
            selected: selectedIndex == 1,
            onTap: () {
              if (!isLargeScreen) {
                Navigator.pop(context);
              }
              onItemSelected(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart_outlined),
            title: const Text('Reports'),
            selected: selectedIndex == 2,
            onTap: () {
              if (!isLargeScreen) {
                Navigator.pop(context);
              }
              onItemSelected(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.directions_car_outlined),
            title: const Text('Miles'),
            selected: selectedIndex == 3,
            onTap: () {
              if (!isLargeScreen) {
                Navigator.pop(context);
              }
              onItemSelected(3);
            },
          ),
          ListTile(
            leading: const Icon(Icons.checklist_outlined),
            title: const Text('To-Do'),
            selected: selectedIndex == 4,
            onTap: () {
              if (!isLargeScreen) {
                Navigator.pop(context);
              }
              onItemSelected(4);
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: const Text('Knowledge Base'),
            selected: selectedIndex == 5,
            onTap: () {
              if (!isLargeScreen) {
                Navigator.pop(context);
              }
              onItemSelected(5);
            },
          ),
          ListTile(
            leading: const Icon(Icons.verified_user_outlined),
            title: const Text('Certifications'),
            selected: selectedIndex == 7,
            onTap: () {
              if (!isLargeScreen) {
                Navigator.pop(context);
              }
              onItemSelected(7);
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('Inventory'),
            selected: selectedIndex == 8,
            onTap: () {
              if (!isLargeScreen) {
                Navigator.pop(context);
              }
              onItemSelected(8);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Company Directory'),
            selected: selectedIndex == 9,
            onTap: () {
              if (!isLargeScreen) {
                Navigator.pop(context);
              }
              onItemSelected(9);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            selected: selectedIndex == 6,
            onTap: () {
              if (!isLargeScreen) {
                Navigator.pop(context);
              }
              onItemSelected(6);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              if (!isLargeScreen) {
                Navigator.pop(context);
              }
              // TODO: Navigate to Settings screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {
              if (!isLargeScreen) {
                Navigator.pop(context);
              }
              // TODO: Navigate to Help & Support screen
            },
          ),
        ],
      ),
    );
  }
} 