import 'package:flutter/material.dart';
import 'calculators/abs_es_calculator.dart';
import 'calculators/pit_depth_calculator.dart';
import 'calculators/time_clock_calculator.dart';
import 'screens/mile_tracker.dart';
import 'screens/company_directory.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NDT Calculator',
      theme: AppTheme.theme,
      home: const CalculatorDashboard(),
    );
  }
}

class CalculatorDashboard extends StatelessWidget {
  const CalculatorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NDT Calculator',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select a calculator',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1C2E),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildCalculatorCard(
                          context,
                          'ABS + ES Calculator',
                          Icons.calculate,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  appBar: AppBar(
                                    title: const Text('ABS + ES Calculator'),
                                    flexibleSpace: Container(
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.primaryGradient,
                                      ),
                                    ),
                                  ),
                                  body: const AbsEsCalculator(),
                                ),
                              ),
                            );
                          },
                        ),
                        _buildCalculatorCard(
                          context,
                          'Pit Depth Calculator',
                          Icons.height,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  appBar: AppBar(
                                    title: const Text('Pit Depth Calculator'),
                                    flexibleSpace: Container(
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.primaryGradient,
                                      ),
                                    ),
                                  ),
                                  body: const PitDepthCalculator(),
                                ),
                              ),
                            );
                          },
                        ),
                        _buildCalculatorCard(
                          context,
                          'Time Clock Calculator',
                          Icons.access_time,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  appBar: AppBar(
                                    title: const Text('Time Clock Calculator'),
                                    flexibleSpace: Container(
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.primaryGradient,
                                      ),
                                    ),
                                  ),
                                  body: const TimeClockCalculator(),
                                ),
                              ),
                            );
                          },
                        ),
                        _buildCalculatorCard(
                          context,
                          'Mile Tracker',
                          Icons.directions_run,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  appBar: AppBar(
                                    title: const Text('Mile Tracker'),
                                    flexibleSpace: Container(
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.primaryGradient,
                                      ),
                                    ),
                                  ),
                                  body: const MileTracker(),
                                ),
                              ),
                            );
                          },
                        ),
                        _buildCalculatorCard(
                          context,
                          'Company Directory',
                          Icons.people,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  appBar: AppBar(
                                    title: const Text('Company Directory'),
                                    flexibleSpace: Container(
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.primaryGradient,
                                      ),
                                    ),
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
                ),
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
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
