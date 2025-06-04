import 'package:flutter/material.dart';
import '../calculators/abs_es_calculator.dart';
import '../calculators/pit_depth_calculator.dart';
import '../calculators/time_clock_calculator.dart';
import '../screens/mile_tracker.dart';
import '../screens/company_directory.dart';
import '../theme/app_theme.dart';
import '../calculators/soc_eoc_calculator.dart';
import '../calculators/dent_ovality_calculator.dart';
import '../widgets/weather_widget.dart';
import '../widgets/safety_banner.dart';
import '../widgets/daily_stats_card.dart';
import '../widgets/news_updates_section.dart';
import '../widgets/app_header.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (MediaQuery.of(context).size.width >= 1200)
                const AppHeader(
                  title: 'Welcome to Integrity Tools',
                  subtitle: 'Your pipeline inspection companion',
                  icon: Icons.dashboard,
                ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingLarge,
                        vertical: AppTheme.paddingMedium,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppTheme.paddingMedium),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                            ),
                            child: const Icon(
                              Icons.engineering_rounded,
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
                                  'Welcome to Integrity Tools',
                                  style: AppTheme.titleLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Your comprehensive pipeline inspection toolkit',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Safety Banner
                    const SafetyBanner(),
                    const SizedBox(height: 24),

                    // Weather Widget
                    const WeatherWidget(),
                    const SizedBox(height: 24),

                    // Daily Stats Card
                    const DailyStatsCard(),
                    const SizedBox(height: 24),

                    // News & Updates Section
                    const NewsUpdatesSection(),
                    const SizedBox(height: 24),

                    // Core Buttons Section
                    _buildButton(
                      context,
                      'New Dig Checklist',
                      Icons.checklist,
                      () => Navigator.pushNamed(context, '/inspection_checklist'),
                    ),
                    const SizedBox(height: 12),
                    _buildButton(
                      context,
                      'Common Formulas',
                      Icons.calculate,
                      () => Navigator.pushNamed(context, '/common_formulas'),
                      backgroundColor: AppTheme.accent1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String title, IconData icon, VoidCallback onPressed, {Color? backgroundColor}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }
} 