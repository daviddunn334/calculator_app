import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../screens/admin/admin_main_screen.dart';

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
    final authService = AuthService();
    
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryNavy.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Company Text Logo
                Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Image.asset(
                    'assets/logos/logo_text_final.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                // Tagline
                Text(
                  'Our people are trained to be the difference.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 11,
                    letterSpacing: 0.2,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),
                _buildMenuItem(
                  context,
                  'Home',
                  Icons.home_outlined,
                  Icons.home,
                  0,
                  isLargeScreen,
                ),
                _buildMenuItem(
                  context,
                  'Tools',
                  Icons.build_outlined,
                  Icons.build,
                  1,
                  isLargeScreen,
                ),
                _buildMenuItem(
                  context,
                  'Maps',
                  Icons.map_outlined,
                  Icons.map,
                  2,
                  isLargeScreen,
                ),
                _buildMenuItem(
                  context,
                  'Field Log',
                  Icons.note_alt_outlined,
                  Icons.note_alt,
                  3,
                  isLargeScreen,
                ),
                _buildMenuItem(
                  context,
                  'Knowledge Base',
                  Icons.menu_book_outlined,
                  Icons.menu_book,
                  4,
                  isLargeScreen,
                ),
                _buildMenuItem(
                  context,
                  'Equotip Data Converter',
                  Icons.transform_outlined,
                  Icons.transform,
                  9,
                  isLargeScreen,
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(height: 1),
                ),
                
                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 8, bottom: 4),
                  child: Text(
                    'PROFESSIONAL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                
                _buildMenuItem(
                  context,
                  'Inventory',
                  Icons.inventory_2_outlined,
                  Icons.inventory_2,
                  6,
                  isLargeScreen,
                ),
                _buildMenuItem(
                  context,
                  'Company Directory',
                  Icons.people_outline,
                  Icons.people,
                  7,
                  isLargeScreen,
                ),
                _buildMenuItem(
                  context,
                  'Profile',
                  Icons.person_outline,
                  Icons.person,
                  5,
                  isLargeScreen,
                ),
                _buildMenuItem(
                  context,
                  'News & Updates',
                  Icons.newspaper_outlined,
                  Icons.newspaper,
                  8,
                  isLargeScreen,
                ),
                
                // Admin Dashboard - Only show for admin users
                StreamBuilder<bool>(
                  stream: UserService().isCurrentUserAdminStream(),
                  builder: (context, snapshot) {
                    final isAdmin = snapshot.data ?? false;
                    if (!isAdmin) return const SizedBox.shrink();
                    
                    return Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Divider(height: 1),
                        ),
                        _buildMenuItem(
                          context,
                          'Admin Dashboard',
                          Icons.admin_panel_settings_outlined,
                          Icons.admin_panel_settings,
                          -1,
                          isLargeScreen,
                          onTap: () {
                            if (!isLargeScreen) {
                              Navigator.pop(context);
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminMainScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Logout Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () async {
                try {
                  await authService.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error signing out: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.logout, color: Colors.white, size: 20),
              label: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData outlinedIcon,
    IconData filledIcon,
    int index,
    bool isLargeScreen, {
    VoidCallback? onTap,
  }) {
    final isSelected = index == selectedIndex;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        color: isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          isSelected ? filledIcon : outlinedIcon,
          color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        dense: true,
        visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
        onTap: onTap ?? () {
          if (!isLargeScreen) {
            Navigator.pop(context);
          }
          onItemSelected(index);
        },
      ),
    );
  }
}
