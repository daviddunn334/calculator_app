import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool showLogout;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.showLogout = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            ),
            child: Icon(icon, size: 40, color: AppTheme.primaryBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.headlineMedium,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          if (showLogout)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                try {
                  await AuthService().signOut();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Successfully logged out')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error logging out: ${e.toString()}')),
                    );
                  }
                }
              },
            ),
        ],
      ),
    );
  }
} 