import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/feedback_submission.dart';
import '../../services/feedback_service.dart';

class FeedbackManagementScreen extends StatefulWidget {
  const FeedbackManagementScreen({super.key});

  @override
  State<FeedbackManagementScreen> createState() => _FeedbackManagementScreenState();
}

class _FeedbackManagementScreenState extends State<FeedbackManagementScreen> {
  final FeedbackService _feedbackService = FeedbackService();
  FeedbackType? _filterType;
  FeedbackStatus? _filterStatus;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Feedback Management'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _buildFeedbackList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search feedback...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All Types', _filterType == null, () {
                  setState(() {
                    _filterType = null;
                  });
                }),
                const SizedBox(width: 8),
                ...FeedbackType.values.map((type) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildFilterChip(
                        type.displayName,
                        _filterType == type,
                        () {
                          setState(() {
                            _filterType = type;
                          });
                        },
                        color: type.color,
                      ),
                    )),
                const SizedBox(width: 16),
                Container(
                  height: 30,
                  width: 1,
                  color: AppTheme.divider,
                ),
                const SizedBox(width: 16),
                _buildFilterChip('All Status', _filterStatus == null, () {
                  setState(() {
                    _filterStatus = null;
                  });
                }),
                const SizedBox(width: 8),
                ...FeedbackStatus.values.map((status) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildFilterChip(
                        status.displayName,
                        _filterStatus == status,
                        () {
                          setState(() {
                            _filterStatus = status;
                          });
                        },
                        color: status.color,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap,
      {Color? color}) {
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey[100],
      selectedColor: color ?? AppTheme.primaryBlue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textPrimary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildFeedbackList() {
    return StreamBuilder<List<FeedbackSubmission>>(
      stream: _feedbackService.getAllFeedback(
        type: _filterType,
        status: _filterStatus,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text('Error loading feedback: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        List<FeedbackSubmission> feedbacks = snapshot.data ?? [];

        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          feedbacks = feedbacks.where((feedback) {
            return feedback.subject.toLowerCase().contains(query) ||
                feedback.description.toLowerCase().contains(query) ||
                feedback.userName.toLowerCase().contains(query) ||
                feedback.userEmail.toLowerCase().contains(query);
          }).toList();
        }

        if (feedbacks.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: feedbacks.length,
          itemBuilder: (context, index) {
            return _buildFeedbackCard(feedbacks[index]);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.feedback_outlined,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No feedback found',
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Feedback submissions will appear here',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(FeedbackSubmission feedback) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: feedback.type.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    feedback.type.icon,
                    color: feedback.type.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.subject,
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildTypeChip(feedback.type),
                          const SizedBox(width: 8),
                          _buildStatusChip(feedback.status),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleFeedbackAction(value, feedback),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 16),
                          SizedBox(width: 8),
                          Text('View Details'),
                        ],
                      ),
                    ),
                    if (feedback.status != FeedbackStatus.inReview)
                      const PopupMenuItem(
                        value: 'mark_review',
                        child: Row(
                          children: [
                            Icon(Icons.rate_review, size: 16),
                            SizedBox(width: 8),
                            Text('Mark In Review'),
                          ],
                        ),
                      ),
                    if (feedback.status != FeedbackStatus.resolved)
                      const PopupMenuItem(
                        value: 'mark_resolved',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 16, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Mark Resolved'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              feedback.description,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Screenshot indicator
            if (feedback.screenshotUrl != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.image,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Has screenshot',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // User Info and Timestamp
            Row(
              children: [
                Icon(Icons.person, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${feedback.userName} (${feedback.userEmail})',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  _formatDate(feedback.timestamp),
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),

            // Device Info
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.devices, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  feedback.deviceInfo['platform'] ?? 'Unknown',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(FeedbackType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: type.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: type.color.withOpacity(0.3)),
      ),
      child: Text(
        type.displayName,
        style: AppTheme.bodySmall.copyWith(
          color: type.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusChip(FeedbackStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status.color.withOpacity(0.3)),
      ),
      child: Text(
        status.displayName,
        style: AppTheme.bodySmall.copyWith(
          color: status.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _handleFeedbackAction(String action, FeedbackSubmission feedback) async {
    switch (action) {
      case 'view':
        _showFeedbackDetails(feedback);
        break;
      case 'mark_review':
        await _feedbackService.updateStatus(feedback.id!, FeedbackStatus.inReview);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Marked as in review'),
              backgroundColor: Colors.blue,
            ),
          );
        }
        break;
      case 'mark_resolved':
        await _feedbackService.updateStatus(feedback.id!, FeedbackStatus.resolved);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Marked as resolved'),
              backgroundColor: Colors.green,
            ),
          );
        }
        break;
      case 'delete':
        _showDeleteConfirmation(feedback);
        break;
    }
  }

  void _showFeedbackDetails(FeedbackSubmission feedback) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(feedback.type.icon, color: feedback.type.color),
            const SizedBox(width: 8),
            Expanded(child: Text(feedback.subject)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Type', feedback.type.displayName),
              _buildDetailRow('Status', feedback.status.displayName),
              _buildDetailRow('User', feedback.userName),
              _buildDetailRow('Email', feedback.userEmail),
              _buildDetailRow('Date', _formatDate(feedback.timestamp)),
              _buildDetailRow('Platform', feedback.deviceInfo['platform'] ?? 'Unknown'),
              const Divider(),
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(feedback.description),
              if (feedback.screenshotUrl != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Screenshot:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    feedback.screenshotUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.grey[200],
                        child: const Text('Failed to load screenshot'),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(FeedbackSubmission feedback) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Feedback'),
        content: Text('Are you sure you want to delete this feedback from "${feedback.userName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _feedbackService.deleteFeedback(feedback.id!);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Feedback deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}
