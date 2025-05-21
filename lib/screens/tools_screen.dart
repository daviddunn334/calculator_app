import 'package:flutter/material.dart';
import '../calculators/abs_es_calculator.dart';
import '../calculators/pit_depth_calculator.dart';
import '../calculators/time_clock_calculator.dart';
import '../calculators/soc_eoc_calculator.dart';
import '../calculators/dent_ovality_calculator.dart';
import '../calculators/b31g_calculator.dart';
import '../theme/app_theme.dart';
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
            Container(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.build_outlined,
                          size: 48,
                          color: AppTheme.primaryBlue,
                        ),
                        const SizedBox(width: AppTheme.paddingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tools',
                                style: AppTheme.headlineLarge,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppTheme.paddingSmall),
                              Text(
                                'Select a calculator',
                                style: AppTheme.bodyLarge,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              title: const Text('ABS + ES Calculator'),
                            ),
                            body: const AbsEsCalculator(),
                          ),
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
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              title: const Text('Pit Depth Calculator'),
                            ),
                            body: const PitDepthCalculator(),
                          ),
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
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              title: const Text('Time Clock Calculator'),
                            ),
                            body: const TimeClockCalculator(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  _buildCalculatorCard(
                    context,
                    'SOC & EOC Calculator',
                    Icons.straighten,
                    'Calculate Start/End of Coating from ABS & ES',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              title: const Text('SOC & EOC Calculator'),
                            ),
                            body: const SocEocCalculator(),
                          ),
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
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              title: const Text('Dent Ovality Calculator'),
                            ),
                            body: const DentOvalityCalculator(),
                          ),
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
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              title: const Text('B31G Calculator'),
                            ),
                            body: const B31GCalculator(),
                          ),
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
                  color: AppTheme.primaryBlue,
                  size: 24,
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
              Icon(
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