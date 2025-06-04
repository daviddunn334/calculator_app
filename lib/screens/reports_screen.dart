import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../models/report.dart';
import '../services/report_service.dart';
import 'report_form_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportService _reportService = ReportService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(
              title: 'Reports',
              subtitle: 'Track and manage inspection findings',
              icon: Icons.bar_chart,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Stats
                    Expanded(
                      child: StreamBuilder<List<Report>>(
                        stream: _reportService.getReports(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            print('Firestore error: \n\n\n');
                            print(snapshot.error);
                            debugPrint('Firestore error: \n');
                            debugPrint(snapshot.error.toString());
                            return Center(
                              child: Text(
                                'Error: \n'+snapshot.error.toString(),
                                style: AppTheme.bodyMedium.copyWith(color: Colors.red),
                              ),
                            );
                          }

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final reports = snapshot.data ?? [];

                          // Calculate stats
                          final totalReports = reports.length;
                          final now = DateTime.now();
                          final monthlyReports = reports.where((report) =>
                            report.createdAt.year == now.year && report.createdAt.month == now.month
                          ).length;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      'Total Reports',
                                      totalReports.toString(),
                                      Icons.description_outlined,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildStatCard(
                                      'This Month',
                                      monthlyReports.toString(),
                                      Icons.calendar_today_outlined,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Recent Reports',
                                style: AppTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: reports.isEmpty
                                    ? Center(
                                        child: Text(
                                          'No reports yet. Create your first report!',
                                          style: AppTheme.bodyMedium,
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: reports.length,
                                        itemBuilder: (context, index) {
                                          final report = reports[index];
                                          return _buildReportCard(
                                            report.location,
                                            report.method,
                                            _formatDate(report.createdAt),
                                            _getPriorityColor(report),
                                            report: report,
                                          );
                                        },
                                      ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportFormScreen()),
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

  Widget _buildReportCard(String title, String type, String time, Color priorityColor, {Report? report}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: InkWell(
        onTap: () {
          if (report != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportFormScreen(report: report, reportId: report.id),
              ),
            );
          }
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
                      horizontal: AppTheme.paddingMedium,
                      vertical: AppTheme.paddingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Text(
                      type,
                      style: AppTheme.bodyMedium.copyWith(
                        color: priorityColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                time,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  Color _getPriorityColor(Report report) {
    // You can implement your own priority logic here
    // For now, we'll just use different colors based on the inspection method
    switch (report.method) {
      case 'MT':
        return Colors.blue;
      case 'UT':
        return Colors.green;
      case 'PT':
        return Colors.orange;
      case 'PAUT':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
} 