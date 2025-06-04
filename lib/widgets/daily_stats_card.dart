import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DailyStatsCard extends StatelessWidget {
  const DailyStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: const BorderSide(color: AppTheme.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: AppTheme.accent5, size: 24),
                const SizedBox(width: AppTheme.paddingMedium),
                Text(
                  'Today\'s Progress',
                  style: AppTheme.titleLarge.copyWith(
                    color: AppTheme.accent5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatIndicator(
                  context,
                  'Tasks Completed',
                  '4/6',
                  0.67,
                  AppTheme.accent1,
                  Icons.assignment_turned_in,
                ),
                _buildStatIndicator(
                  context,
                  'Active Digs',
                  '3',
                  0.5,
                  AppTheme.accent2,
                  Icons.engineering,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatIndicator(
    BuildContext context,
    String label,
    String value,
    double progress,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 8,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 