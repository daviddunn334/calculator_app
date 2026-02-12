import 'package:flutter/material.dart';
import '../calculators/trig_beam_path_calculator.dart';
import '../calculators/skip_distance_calculator.dart';
import '../calculators/sound_path_length_calculator.dart';
import '../calculators/tof_calculator.dart';
import '../calculators/beam_index_offset_calculator.dart';
import '../calculators/surface_distance_depth_converter.dart';
import '../theme/app_theme.dart';

class BeamGeometryCategoryScreen extends StatelessWidget {
  const BeamGeometryCategoryScreen({super.key});

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
                          'Beam Geometry',
                          style: AppTheme.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Beam path calculations and visualization tools',
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

              // Tool cards
              _buildToolCard(
                context,
                title: '📐 Trigonometric Beam Path Tool',
                description: 'Calculate beam path geometry for shear wave UT inspections using right-triangle trigonometry',
                tags: ['Shear Wave', 'Beam Path', 'Skip Distance'],
                color: const Color(0xFFFF5722), // Deep Orange
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrigBeamPathCalculator(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildToolCard(
                context,
                title: '📏 Skip Distance Table',
                description: 'Quick reference table showing surface distances for legs 1-5 in shear-wave UT',
                tags: ['Skip Distance', 'Quick Reference', 'Legs 1-5'],
                color: const Color(0xFF4CAF50), // Green
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SkipDistanceCalculator(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildToolCard(
                context,
                title: '📏 Sound Path Length',
                description: 'Calculate true sound path (beam path length) through material for shear-wave UT in flat plates',
                tags: ['Sound Path', 'Beam Length', 'Dual Mode'],
                color: const Color(0xFF2196F3), // Blue
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SoundPathLengthCalculator(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildToolCard(
                context,
                title: '⏱️ Time-of-Flight (TOF)',
                description: 'Calculate ultrasonic travel time using sound path and wave velocity. Supports dual modes and optional angle calculations',
                tags: ['TOF', 'Travel Time', 'Microseconds'],
                color: const Color(0xFF9C27B0), // Purple
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TofCalculator(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildToolCard(
                context,
                title: '📏 Beam Index Offset',
                description: 'Estimate horizontal offset from probe element to beam exit point (index point) on test surface for angle-beam wedge setups',
                tags: ['Wedge Geometry', 'Index Point', 'Snell\'s Law'],
                color: const Color(0xFFFF9800), // Orange
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BeamIndexOffsetCalculator(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildToolCard(
                context,
                title: '↔️ Surface Distance ↔ Depth',
                description: 'Convert between surface distance and depth for angle-beam UT. Includes single-leg and multi-leg modes with right-triangle trigonometry',
                tags: ['Converter', 'Dual Mode', 'Multi-leg'],
                color: const Color(0xFF00BCD4), // Cyan
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SurfaceDistanceDepthConverter(),
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
