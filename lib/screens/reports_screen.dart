import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  final ReportService _reportService = ReportService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Background design elements
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryBlue.withOpacity(0.03),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accent2.withOpacity(0.05),
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (MediaQuery.of(context).size.width >= 1200)
                  const AppHeader(
                    title: 'Inspection Reports',
                    subtitle: 'Track and manage your pipeline inspection findings',
                    icon: Icons.bar_chart,
                  ),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.paddingLarge),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title section for mobile
                            if (MediaQuery.of(context).size.width < 1200)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.paddingLarge,
                                  vertical: AppTheme.paddingMedium,
                                ),
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(AppTheme.paddingMedium),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme.primaryBlue,
                                            AppTheme.primaryBlue.withOpacity(0.8),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primaryBlue.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.bar_chart_rounded,
                                        size: 32,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: AppTheme.paddingLarge),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Inspection Reports',
                                            style: AppTheme.titleLarge.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Track and manage your pipeline inspection findings',
                                            style: AppTheme.bodyMedium.copyWith(
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
                            // Search and filter bar
                            Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Search reports...',
                                        hintStyle: TextStyle(color: AppTheme.textSecondary),
                                        prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 56,
                                    width: 1,
                                    color: AppTheme.divider,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.filter_list,
                                      color: AppTheme.textSecondary,
                                    ),
                                    onPressed: () {
                                      // TODO: Implement filter functionality
                                    },
                                    tooltip: 'Filter reports',
                                  ),
                                ],
                              ),
                            ),
                            
                            // Reports content
                            Expanded(
                              child: StreamBuilder<User?>(
                                stream: FirebaseAuth.instance.authStateChanges(),
                                builder: (context, authSnapshot) {
                                  if (!authSnapshot.hasData) {
                                    return _buildErrorState('Please log in to view reports');
                                  }
                                  
                                  final user = authSnapshot.data!;
                                  
                                  return StreamBuilder<List<Report>>(
                                    stream: _reportService.getUserReportsStream(user.uid),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        return _buildErrorState(snapshot.error.toString());
                                      }

                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return _buildLoadingState();
                                      }

                                      final reports = snapshot.data ?? [];

                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Recent reports section header
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 16),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Recent Reports',
                                                  style: AppTheme.titleMedium.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.textPrimary,
                                                  ),
                                                ),
                                                TextButton.icon(
                                                  onPressed: () {
                                                    // TODO: Navigate to all reports view
                                                  },
                                                  icon: const Icon(Icons.visibility_outlined, size: 18),
                                                  label: const Text('View All'),
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: AppTheme.primaryBlue,
                                                    padding: EdgeInsets.zero,
                                                    visualDensity: VisualDensity.compact,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          
                                          // Reports list - takes up all remaining space
                                          Expanded(
                                            child: reports.isEmpty
                                                ? _buildEmptyState()
                                                : ListView.builder(
                                                    physics: const AlwaysScrollableScrollPhysics(),
                                                    itemCount: reports.length,
                                                    itemBuilder: (context, index) {
                                                      final report = reports[index];
                                                      return _buildReportCard(
                                                        report.location,
                                                        report.method,
                                                        _formatDate(report.createdAt),
                                                        _getPriorityColor(report),
                                                        report: report,
                                                        index: index,
                                                      );
                                                    },
                                                  ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportFormScreen()),
          );
        },
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add),
        label: const Text('New Report'),
        elevation: 2,
      ),
    );
  }


  Widget _buildReportCard(
    String title,
    String type,
    String time,
    Color priorityColor, {
    Report? report,
    int index = 0,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
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
          onLongPress: () {
            if (report != null) {
              _showReportOptions(report);
            }
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Center(
                    child: Text(
                      type,
                      style: TextStyle(
                        color: priorityColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            report?.technicianName ?? 'Unknown',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          if (report?.imageUrls.isNotEmpty == true) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.photo_camera,
                              size: 14,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${report!.imageUrls.length}',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (report != null) {
                      switch (value) {
                        case 'edit':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReportFormScreen(report: report, reportId: report.id),
                            ),
                          );
                          break;
                        case 'delete':
                          _deleteReport(report);
                          break;
                      }
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  child: const Icon(
                    Icons.more_vert,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.description_outlined,
              size: 48,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No reports yet',
            style: AppTheme.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first inspection report',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportFormScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('New Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading reports...',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Reports',
            style: AppTheme.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              error,
              style: AppTheme.bodyMedium.copyWith(color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          ),
        ],
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
        return Color(0xFF3F51B5); // Indigo
      case 'UT':
        return Color(0xFF009688); // Teal
      case 'PT':
        return Color(0xFFFF9800); // Orange
      case 'PAUT':
        return Color(0xFF673AB7); // Deep Purple
      default:
        return Color(0xFF607D8B); // Blue Grey
    }
  }

  /// Show report options (edit/delete)
  void _showReportOptions(Report report) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Report'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportFormScreen(report: report, reportId: report.id),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Report', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteReport(report);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Delete a report with confirmation
  Future<void> _deleteReport(Report report) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Report'),
          content: Text('Are you sure you want to delete the report for "${report.location}"?\n\nThis action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        // Delete the report from Firestore
        await _reportService.deleteReport(report.id);
        
        // Delete associated images from Firebase Storage
        for (final imageUrl in report.imageUrls) {
          try {
            // Extract the image path from the URL and delete it
            // This is a simplified approach - you might need to adjust based on your URL structure
            final uri = Uri.parse(imageUrl);
            final path = uri.pathSegments.last;
            // You would implement deleteImageByPath in ImageService
            // await _imageService.deleteImageByPath(path);
          } catch (e) {
            print('Error deleting image: $e');
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Report "${report.location}" deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting report: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
