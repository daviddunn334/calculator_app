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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.paddingMedium),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      ),
                      child: Icon(Icons.dashboard, size: 40, color: AppTheme.primaryBlue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to Integrity Tools',
                            style: AppTheme.headlineMedium.copyWith(
                              color: AppTheme.accent5
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your pipeline inspection companion',
                            style: AppTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
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
                const SizedBox(height: 24),

                // Quick Access Grid
                Text('Quick Access', style: AppTheme.titleLarge),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _buildGridItem(
                      context,
                      'Start New Inspection',
                      Icons.assignment,
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Starting new inspection...')),
                      ),
                    ),
                    _buildGridItem(
                      context,
                      'Log Mileage',
                      Icons.directions_car,
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening mileage log...')),
                      ),
                    ),
                    _buildGridItem(
                      context,
                      'Capture GPS',
                      Icons.location_on,
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Getting GPS location...')),
                      ),
                    ),
                    _buildGridItem(
                      context,
                      'Company Directory',
                      Icons.contacts,
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening directory...')),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
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

  Widget _buildGridItem(BuildContext context, String title, IconData icon, VoidCallback onTap) {
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
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium, vertical: AppTheme.paddingSmall),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: AppTheme.primaryBlue),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 