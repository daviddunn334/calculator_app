import 'package:flutter/material.dart';
import '../calculators/abs_es_calculator.dart';
import '../calculators/pit_depth_calculator.dart';
import '../calculators/time_clock_calculator.dart';
import '../calculators/dent_ovality_calculator.dart';
import '../calculators/b31g_calculator.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import 'corrosion_grid_logger_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(
              title: 'Tools',
              subtitle: 'Select a calculator',
              icon: Icons.build,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                children: [
                  _buildCalculatorCard(
                    context,
                    'ABS + ES Calculator',
                    Icons.calculate_outlined,
                    'Calculate ABS and ES values',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AbsEsCalculator(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  _buildCalculatorCard(
                    context,
                    'Pit Depth Calculator',
                    Icons.height_outlined,
                    'Calculate pit depths and measurements',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PitDepthCalculator(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  _buildCalculatorCard(
                    context,
                    'Time Clock Calculator',
                    Icons.access_time_outlined,
                    'Track and calculate work hours',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TimeClockCalculator(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  _buildCalculatorCard(
                    context,
                    'Dent Ovality Calculator',
                    Icons.circle_outlined,
                    'Calculate dent ovality percentage',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DentOvalityCalculator(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  _buildCalculatorCard(
                    context,
                    'B31G Calculator',
                    Icons.engineering_outlined,
                    'Calculate pipe defect assessment using B31G method',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const B31GCalculator(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  _buildCalculatorCard(
                    context,
                    'Corrosion Grid Logger',
                    Icons.grid_on_outlined,
                    'Log and export corrosion grid data for RSTRENG',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CorrosionGridLoggerScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
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
    // Define tags for each calculator
    List<String> tags = [];
    if (title == 'ABS + ES Calculator') {
      tags = ['Offset', 'Distance', 'RGW'];
    } else if (title == 'Pit Depth Calculator') {
      tags = ['Corrosion', 'Wall Loss', 'Remaining'];
    } else if (title == 'Time Clock Calculator') {
      tags = ['Clock Position', 'Distance', 'Conversion'];
    } else if (title == 'Dent Ovality Calculator') {
      tags = ['Dent', 'Deformation', 'Percentage'];
    } else if (title == 'B31G Calculator') {
      tags = ['Corrosion', 'Assessment', 'ASME'];
    } else if (title == 'Corrosion Grid Logger') {
      tags = ['Grid', 'RSTRENG', 'Export'];
    }

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
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 24, color: AppTheme.primaryBlue),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTheme.titleMedium.copyWith(color: AppTheme.accent5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: AppTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.map((tag) => _buildTag(tag)).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppTheme.primaryBlue,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
} 