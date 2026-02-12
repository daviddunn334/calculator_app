import 'package:flutter/material.dart';
import '../calculators/snells_law_calculator.dart';
import '../calculators/mode_conversion_calculator.dart';
import '../calculators/critical_angle_calculator.dart';
import '../calculators/wedge_delay_time_calculator.dart';
import '../theme/app_theme.dart';

class SnellsLawSuiteCategoryScreen extends StatelessWidget {
  const SnellsLawSuiteCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                    color: AppTheme.textPrimary,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Snell\'s Law Suite',
                          style: AppTheme.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Refraction angle and velocity calculations for ultrasonic testing',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tool card - Refraction Angle Calculator (Snell's Law)
              _buildToolCard(
                context,
                title: '⚡ Refraction Angle Calculator',
                description: 'Calculate refracted or incident angles when ultrasonic waves pass from one medium to another using Snell\'s Law',
                tags: ['Refraction', 'Wedge', 'Dual Mode', 'Critical Angle'],
                color: const Color(0xFF00BCD4), // Cyan
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SnellsLawCalculator(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Tool card - Mode Conversion Calculator
              _buildToolCard(
                context,
                title: '🔄 Mode Conversion Calculator',
                description: 'Predict refracted angles for both Longitudinal and Shear wave modes when entering a test material from a wedge',
                tags: ['L-wave', 'S-wave', 'Multi-Mode', 'Critical Angles'],
                color: const Color(0xFF9C27B0), // Purple
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ModeConversionCalculator(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Tool card - Critical Angle Calculator
              _buildToolCard(
                context,
                title: '🎯 Critical Angle Calculator',
                description: 'Calculate critical incident angles for L-wave and S-wave modes where refraction reaches 90° (total internal reflection)',
                tags: ['L-wave', 'S-wave', 'Critical Angle', 'Total Reflection'],
                color: const Color(0xFFFF5722), // Deep Orange
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CriticalAngleCalculator(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Tool card - Wedge Delay Time Calculator
              _buildToolCard(
                context,
                title: '⏱️ Wedge Delay Time',
                description: 'Calculate ultrasonic transit time through wedge material - helps estimate initial delay and zero offset for UT setup',
                tags: ['Wedge Delay', 'Time of Flight', 'Zero Offset', 'Calibration'],
                color: const Color(0xFF4CAF50), // Green
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WedgeDelayTimeCalculator(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required String description,
    required List<String> tags,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: BorderSide(color: AppTheme.divider, width: 1.5),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTheme.titleMedium.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: color,
                      ),
                    ],
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags.map((tag) => _buildTag(tag, color)).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
