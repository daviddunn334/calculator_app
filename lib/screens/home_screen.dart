import 'package:flutter/material.dart';
import '../calculators/abs_es_calculator.dart';
import '../calculators/pit_depth_calculator.dart';
import '../calculators/time_clock_calculator.dart';
import '../screens/mile_tracker.dart';
import '../screens/company_directory.dart';
import '../theme/app_theme.dart';
import '../calculators/soc_eoc_calculator.dart';
import '../calculators/dent_ovality_calculator.dart';
// import '../widgets/app_logo.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.dashboard, size: 80, color: AppTheme.primaryBlue),
              SizedBox(height: 24),
              Text(
                'Welcome to Integrity Tools!',
                style: AppTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'This is your dashboard. More features coming soon.',
                style: AppTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalculatorCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: const BorderSide(color: AppTheme.divider),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: AppTheme.paddingLarge),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.titleLarge,
                    ),
                    const SizedBox(height: AppTheme.paddingSmall),
                    Text(
                      description,
                      style: AppTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 