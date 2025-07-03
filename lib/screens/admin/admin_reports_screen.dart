import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../models/report.dart';
import '../../models/user_profile.dart';
import '../../services/report_service.dart';
import '../../services/user_service.dart';
import '../report_preview_screen.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> with SingleTickerProviderStateMixin {
  final ReportService _reportService = ReportService();
  final UserService _userService = UserService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _searchQuery = '';
  String? _selectedMethod;
  String? _selectedUserId;
  Map<String, UserProfile> _userProfiles = {};
  
  final List<String> _inspectionMethods = ['MT', 'UT', 'PT', 'PAUT', 'VT', 'RT'];
  
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
    _loadUserProfiles();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfiles() async {
    try {
      final users = await _userService.getAllUsers();
      setState(() {
        _userProfiles = {for (var user in users) user.userId: user};
      });
    } catch (e) {
      print('Error loading user profiles: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Report Management'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: MediaQuery.of(context).size.width < 1200,
      ),
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
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search and filter section
                      _buildSearchAndFilters(),
                      const SizedBox(height: 24),
                      
                      // Reports list
                      Expanded(
                        child: StreamBuilder<List<Report>>(
                          stream: _reportService.getAllReportsStream(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return _buildErrorState(snapshot.error.toString());
                            }

                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return _buildLoadingState();
                            }

                            final allReports = snapshot.data ?? [];
                            final filteredReports = _filterReports(allReports);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with count
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'All Reports (${filteredReports.length})',
                                        style: AppTheme.titleMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      if (_hasActiveFilters())
                                        TextButton.icon(
                                          onPressed: _clearFilters,
                                          icon: const Icon(Icons.clear, size: 18),
                                          label: const Text('Clear Filters'),
                                          style: TextButton.styleFrom(
                                            foregroundColor: AppTheme.primaryBlue,
                                            padding: EdgeInsets.zero,
                                            visualDensity: VisualDensity.compact,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                
                                // Reports list
                                Expanded(
                                  child: filteredReports.isEmpty
                                      ? _buildEmptyState()
                                      : ListView.builder(
                                          physics: const AlwaysScrollableScrollPhysics(),
                                          itemCount: filteredReports.length,
                                          itemBuilder: (context, index) {
                                            final report = filteredReports[index];
                                            final userProfile = _userProfiles[report.userId];
                                            return _buildReportCard(report, userProfile, index);
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search & Filter Reports',
            style: AppTheme.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Search bar
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search by location, technician, or method...',
              hintStyle: TextStyle(color: AppTheme.textSecondary),
              prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                borderSide: BorderSide(color: AppTheme.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                borderSide: BorderSide(color: AppTheme.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                borderSide: BorderSide(color: AppTheme.primaryBlue),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
          ),
          const SizedBox(height: 16),
          
          // Filter dropdowns
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedMethod,
                  decoration: InputDecoration(
                    labelText: 'Inspection Method',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Methods'),
                    ),
                    ..._inspectionMethods.map((method) => DropdownMenuItem<String>(
                      value: method,
                      child: Text(method),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedMethod = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedUserId,
                  decoration: InputDecoration(
                    labelText: 'Report Owner',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Users'),
                    ),
                    ..._userProfiles.values.map((user) => DropdownMenuItem<String>(
                      value: user.userId,
                      child: Text(user.displayName ?? user.email),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedUserId = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Report report, UserProfile? userProfile, int index) {
    final priorityColor = _getPriorityColor(report);
    
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportPreviewScreen(
                  technicianName: report.technicianName,
                  inspectionDate: report.inspectionDate,
                  location: report.location,
                  pipeDiameter: report.pipeDiameter,
                  wallThickness: report.wallThickness,
                  method: report.method,
                  findings: report.findings,
                  correctiveActions: report.correctiveActions,
                  additionalNotes: report.additionalNotes,
                  reportId: report.id,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                          report.method,
                          style: TextStyle(
                            color: priorityColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
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
                            report.location,
                            style: AppTheme.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'by ${report.technicianName}',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Report owner info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Report Owner: ',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          userProfile?.email ?? 'Unknown User',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Report details
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(report.createdAt),
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(report.inspectionDate),
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    if (report.imageUrls.isNotEmpty) ...[
                      const SizedBox(width: 16),
                      Icon(
                        Icons.photo_camera,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${report.imageUrls.length}',
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
            _hasActiveFilters() ? 'No reports match your filters' : 'No reports found',
            style: AppTheme.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _hasActiveFilters() 
                ? 'Try adjusting your search criteria'
                : 'Reports will appear here once users create them',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
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

  List<Report> _filterReports(List<Report> reports) {
    var filtered = reports;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final searchLower = _searchQuery.toLowerCase();
      filtered = filtered.where((report) {
        return report.location.toLowerCase().contains(searchLower) ||
               report.technicianName.toLowerCase().contains(searchLower) ||
               report.method.toLowerCase().contains(searchLower);
      }).toList();
    }

    // Apply method filter
    if (_selectedMethod != null) {
      filtered = filtered.where((report) => report.method == _selectedMethod).toList();
    }

    // Apply user filter
    if (_selectedUserId != null) {
      filtered = filtered.where((report) => report.userId == _selectedUserId).toList();
    }

    return filtered;
  }

  bool _hasActiveFilters() {
    return _searchQuery.isNotEmpty || _selectedMethod != null || _selectedUserId != null;
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedMethod = null;
      _selectedUserId = null;
    });
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
    switch (report.method) {
      case 'MT':
        return const Color(0xFF3F51B5); // Indigo
      case 'UT':
        return const Color(0xFF009688); // Teal
      case 'PT':
        return const Color(0xFFFF9800); // Orange
      case 'PAUT':
        return const Color(0xFF673AB7); // Deep Purple
      case 'VT':
        return const Color(0xFF4CAF50); // Green
      case 'RT':
        return const Color(0xFFE91E63); // Pink
      default:
        return const Color(0xFF607D8B); // Blue Grey
    }
  }
}
