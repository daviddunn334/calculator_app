import 'package:flutter/material.dart';
import '../calculators/abs_es_calculator.dart';
import '../calculators/pit_depth_calculator.dart';
import '../calculators/time_clock_calculator.dart';
import '../screens/mile_tracker.dart';
import '../screens/company_directory.dart';
import '../theme/app_theme.dart';
// import '../widgets/app_logo.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                        Image.asset(
                          'assets/app_icon.png',
                          width: 48,
                          height: 48,
                        ),
                        const SizedBox(width: AppTheme.paddingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NDT Calculator',
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
                    'Mile Tracker',
                    Icons.directions_run_outlined,
                    'Track and manage mileage',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              title: const Text('Mile Tracker'),
                            ),
                            body: const MileTracker(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  _buildCalculatorCard(
                    context,
                    'Company Directory',
                    Icons.people_outline,
                    'Access company contacts and information',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              title: const Text('Company Directory'),
                            ),
                            body: const CompanyDirectory(),
                          ),
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