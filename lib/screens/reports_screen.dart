import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
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
                    child: Icon(Icons.bar_chart, size: 40, color: AppTheme.primaryBlue),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inspection Reports',
                          style: AppTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'View and manage your inspection reports',
                          style: AppTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Quick Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Reports',
                      '156',
                      Icons.description_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'This Month',
                      '23',
                      Icons.calendar_today_outlined,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Recent Reports List
              Text(
                'Recent Reports',
                style: AppTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildReportCard(
                      'Pipeline Segment A-123',
                      'Corrosion Assessment',
                      '2 hours ago',
                      'High Priority',
                      Colors.red,
                    ),
                    const SizedBox(height: 12),
                    _buildReportCard(
                      'Valve Station B-456',
                      'Pressure Test Results',
                      '1 day ago',
                      'Medium Priority',
                      Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _buildReportCard(
                      'Compressor Station C-789',
                      'Equipment Inspection',
                      '2 days ago',
                      'Low Priority',
                      Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildReportCard(
                      'Pipeline Segment D-012',
                      'Crack Assessment',
                      '3 days ago',
                      'High Priority',
                      Colors.red,
                    ),
                    const SizedBox(height: 12),
                    _buildReportCard(
                      'Valve Station E-345',
                      'Leak Test Results',
                      '4 days ago',
                      'Medium Priority',
                      Colors.orange,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement new report creation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create new report')),
          );
        },
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primaryBlue),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTheme.headlineMedium.copyWith(
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, String type, String time, String priority, Color priorityColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to report detail screen
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Text(
                      priority,
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                type,
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: AppTheme.bodyMedium.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 