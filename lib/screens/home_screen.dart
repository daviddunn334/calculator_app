import 'package:flutter/material.dart';
import '../calculators/abs_es_calculator.dart';
import '../calculators/pit_depth_calculator.dart';
import '../calculators/time_clock_calculator.dart';
import '../screens/mile_tracker.dart';
import '../screens/company_directory.dart';
import '../theme/app_theme.dart';
import '../calculators/soc_eoc_calculator.dart';
import '../calculators/dent_ovality_calculator.dart';

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
                            style: AppTheme.headlineMedium,
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

                // Activity Feed
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Activity Feed', style: AppTheme.titleLarge),
                    TextButton.icon(
                      onPressed: () => _showAddNoteDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Note'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildActivityItem('Logged Dig #1045', 'Mile Post 136.5', '2 hrs ago'),
                const Divider(height: 24),
                _buildActivityItem('Updated GPS Location', 'Station 12+50', '4 hrs ago'),
                const Divider(height: 24),
                _buildActivityItem('Completed Inspection', 'Valve Site #23', 'Yesterday'),
                const Divider(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String title, IconData icon, VoidCallback onPressed) {
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

  Widget _buildActivityItem(String title, String location, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTheme.titleMedium),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(location, style: AppTheme.bodyMedium),
            Text(time, style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
          ],
        ),
      ],
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Quick Note'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter your note...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement note saving
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note added')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
} 