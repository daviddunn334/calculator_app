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
      decoration: BoxDecoration(
        color: const Color(0xFF1E232A), // Main background
        border: Border(
          right: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF242A33), // Slightly elevated surface
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/logos/logo_main_white.png',
                    width: 84,
                    height: 84,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Integrity Tools',
                  style: TextStyle(
                    color: const Color(0xFFEDF9FF), // Primary text
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Professional NDT Suite',
                  style: TextStyle(
                    color: const Color(0xFFAEBBC8), // Secondary text
                    fontSize: 12,
                    letterSpacing: 0.3,
                  ),
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
                  'Most Used Tools',
                  Icons.star_outlined,
                  Icons.star,
                  1,
                  isLargeScreen,
                ),
                _buildMenuItem(
                  context,
                  'NDT Tools',
                  Icons.build_outlined,
                  Icons.build,
                  2,
                  isLargeScreen,
                ),
                _buildMenuItem(
                  context,
                  'Maps',
                  Icons.map_outlined,
                  Icons.map,
                  3,
                  isLargeScreen,
                ),
                _buildMenuItem(
                  context,
                  'Method Hours',
                  Icons.note_alt_outlined,
                  Icons.note_alt,
                  4,
                  isLargeScreen,
                ),
                _buildMenuItem(
                  context,
                  'Knowledge Base',
                  Icons.menu_book_outlined,
                  Icons.menu_book,
                  5,
                  isLargeScreen,
                ),
                _buildMenuItem(
                  context,
                  'Equotip Data Converter',
                  Icons.transform_outlined,
                  Icons.transform,
                  10,
                  isLargeScreen,
                ),
                _buildMenuItem(
                  context,
                  'Defect AI Analyzer',
                  Icons.analytics_outlined,
                  Icons.analytics,
                  12,
                  isLargeScreen,
                ),
                _buildMenuItem(
                  context,
                  'Defect AI Identifier',
                  Icons.photo_camera_outlined,
                  Icons.photo_camera,
                  13,
                  isLargeScreen,
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(
                    height: 1,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                  child: Text(
                    'PROFESSIONAL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF7F8A96), // Muted text
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                
                _buildMenuItem(
                  context,
                  'Inventory',
                  Icons.inventory_2_outlined,
                  Icons.inventory_2,
                  7,
                  isLargeScreen,
                ),
                _buildMenuItem(
                  context,
                  'Send Feedback',
                  Icons.feedback_outlined,
                  Icons.feedback,
                  11,
                  isLargeScreen,
                ),
                _buildMenuItem(
                  context,
                  'Company Directory',
                  Icons.people_outline,
                  Icons.people,
                  8,
                  isLargeScreen,
                ),
                _buildMenuItem(
                  context,
                  'Profile',
                  Icons.person_outline,
                  Icons.person,
                  6,
                  isLargeScreen,
                ),
                _buildMenuItem(
                  context,
                  'News & Updates',
                  Icons.newspaper_outlined,
                  Icons.newspaper,
                  9,
                  isLargeScreen,
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(
                    height: 1,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                  child: Text(
                    'LEGAL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF7F8A96), // Muted text
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                
                ListTile(
                  leading: Icon(
                    Icons.gavel_outlined,
                    color: const Color(0xFFAEBBC8), // Secondary text
                    size: 22,
                  ),
                  title: Text(
                    'Terms of Service',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFEDF9FF), // Primary text
                    ),
                  ),
                  dense: true,
                  visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
                  onTap: () {
                    if (!isLargeScreen) {
                      Navigator.pop(context);
                    }
                    Navigator.of(context).pushNamed('/terms_of_service');
                  },
                ),
                
                ListTile(
                  leading: Icon(
                    Icons.privacy_tip_outlined,
                    color: const Color(0xFFAEBBC8), // Secondary text
                    size: 22,
                  ),
                  title: Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFEDF9FF), // Primary text
                    ),
                  ),
                  dense: true,
                  visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
                  onTap: () {
                    if (!isLargeScreen) {
                      Navigator.pop(context);
                    }
                    Navigator.of(context).pushNamed('/privacy_policy');
                  },
                ),
                
                // Admin Dashboard - Only show for admin users
                StreamBuilder<bool>(
                  stream: UserService().isCurrentUserAdminStream(),
                  builder: (context, snapshot) {
                    final isAdmin = snapshot.data ?? false;
                    if (!isAdmin) return const SizedBox.shrink();
                    
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Divider(
                            height: 1,
                            color: Colors.white.withOpacity(0.05),
                          ),
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
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFE637E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFE637E).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
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
                            backgroundColor: const Color(0xFFFE637E),
                          ),
                        );
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout,
                          color: const Color(0xFFFE637E),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: const Color(0xFFFE637E),
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? const Color(0xFF6C5BFF).withOpacity(0.12)
            : Colors.transparent,
        border: isSelected
            ? Border.all(
                color: const Color(0xFF6C5BFF).withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {
            if (!isLargeScreen) {
              Navigator.pop(context);
            }
            onItemSelected(index);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isSelected ? filledIcon : outlinedIcon,
                  color: isSelected
                      ? const Color(0xFF6C5BFF) // Primary accent
                      : const Color(0xFFAEBBC8), // Secondary text
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFFEDF9FF) // Primary text
                          : const Color(0xFFAEBBC8), // Secondary text
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5BFF), // Primary accent
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
