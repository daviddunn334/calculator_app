import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // User Profile Section
            Container(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.divider,
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 32,
                        backgroundColor: AppTheme.primaryBlue,
                        child: Icon(
                          Icons.person,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    Text(
                      AuthService().currentUser?.email ?? 'User',
                      style: AppTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            // Navigation Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context,
                    'Home',
                    Icons.home_outlined,
                    Icons.home,
                    0,
                  ),
                  _buildDrawerItem(
                    context,
                    'Tools',
                    Icons.build_outlined,
                    Icons.build,
                    1,
                  ),
                  _buildDrawerItem(
                    context,
                    'Reports',
                    Icons.bar_chart_outlined,
                    Icons.bar_chart,
                    2,
                  ),
                  _buildDrawerItem(
                    context,
                    'Miles',
                    Icons.directions_car_outlined,
                    Icons.directions_car,
                    3,
                  ),
                  _buildDrawerItem(
                    context,
                    'To-Do',
                    Icons.checklist_outlined,
                    Icons.checklist,
                    4,
                  ),
                  _buildDrawerItem(
                    context,
                    'Knowledge Base',
                    Icons.psychology_outlined,
                    Icons.psychology,
                    5,
                  ),
                  _buildDrawerItem(
                    context,
                    'Profile',
                    Icons.person_outline,
                    Icons.person,
                    6,
                  ),
                ],
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppTheme.divider,
                    width: 1,
                  ),
                ),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign Out'),
                onTap: () async {
                  await AuthService().signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    String title,
    IconData icon,
    IconData selectedIcon,
    int index,
  ) {
    final bool isSelected = selectedIndex == index;
    return ListTile(
      leading: Icon(
        isSelected ? selectedIcon : icon,
        color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
      ),
      title: Text(
        title,
        style: AppTheme.bodyLarge.copyWith(
          color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppTheme.primaryBlue.withOpacity(0.1),
      onTap: () {
        onItemSelected(index);
        Navigator.pop(context);
      },
    );
  }
} 