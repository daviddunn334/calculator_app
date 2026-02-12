import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../models/photo_identification.dart';
import '../services/defect_identifier_service.dart';
import '../services/analytics_service.dart';

class PhotoIdentificationDetailScreen extends StatefulWidget {
  final String photoId;

  const PhotoIdentificationDetailScreen({
    Key? key,
    required this.photoId,
  }) : super(key: key);

  @override
  State<PhotoIdentificationDetailScreen> createState() =>
      _PhotoIdentificationDetailScreenState();
}

class _PhotoIdentificationDetailScreenState
    extends State<PhotoIdentificationDetailScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  final DefectIdentifierService _service = DefectIdentifierService();

  @override
  void initState() {
    super.initState();
    // Log photo viewed
    _analyticsService.logEvent(
      name: 'photo_identification_viewed',
      parameters: {
        'photo_id': widget.photoId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Photo Details'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('photo_identifications')
            .doc(widget.photoId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Photo not found',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          final photo = PhotoIdentification.fromFirestore(snapshot.data!);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Photo Display
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  child: Image.network(
                    photo.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 300,
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Status Section
                if (photo.isAnalyzing)
                  _buildAnalyzingStatus()
                else if (photo.hasAnalysis)
                  _buildAnalysisResults(photo)
                else if (photo.hasAnalysisError)
                  _buildAnalysisError(photo)
                else
                  _buildPendingStatus(),

                const SizedBox(height: 24),

                // Metadata
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Photo Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.calendar_today,
                        'Uploaded',
                        DateFormat('MMM dd, yyyy • hh:mm a')
                            .format(photo.localCreatedAt),
                      ),
                      if (photo.localAnalysisCompletedAt != null) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        _buildInfoRow(
                          Icons.access_time,
                          'Analyzed',
                          DateFormat('MMM dd, yyyy • hh:mm a')
                              .format(photo.localAnalysisCompletedAt!),
                        ),
                      ],
                      if (photo.processingTime != null) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        _buildInfoRow(
                          Icons.timer_outlined,
                          'Processing Time',
                          '${photo.processingTime!.toStringAsFixed(1)} seconds',
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzingStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade100,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: Colors.blue.shade300),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Analyzing Photo...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI is identifying the defect type. This may take 5-10 seconds.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue.shade800,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPendingStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(
            Icons.pending_outlined,
            size: 48,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            'Analysis Pending',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Photo analysis will begin shortly.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisError(PhotoIdentification photo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red.shade700,
          ),
          const SizedBox(height: 16),
          Text(
            'Analysis Failed',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            photo.errorMessage ?? 'An error occurred during photo analysis.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade800,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResults(PhotoIdentification photo) {
    if (photo.matches == null || photo.matches!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'AI Identification Results',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Top ${photo.matches!.length} matches identified:',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),

        // Display all matches
        ...photo.matches!.asMap().entries.map((entry) {
          final index = entry.key;
          final match = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: index < photo.matches!.length - 1 ? 12 : 0),
            child: _buildMatchCard(match, index + 1),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMatchCard(match, int rank) {
    Color bgColor;
    Color borderColor;

    switch (match.confidence.toLowerCase()) {
      case 'high':
        bgColor = Colors.green.shade50;
        borderColor = Colors.green.shade300;
        break;
      case 'medium':
        bgColor = Colors.orange.shade50;
        borderColor = Colors.orange.shade300;
        break;
      case 'low':
        bgColor = Colors.red.shade50;
        borderColor = Colors.red.shade300;
        break;
      default:
        bgColor = Colors.grey.shade50;
        borderColor = Colors.grey.shade300;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rank and Type
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  match.defectType,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Text(
                match.confidenceEmoji,
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Confidence Score
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Confidence: ${match.confidenceScore.toStringAsFixed(0)}% (${match.confidence.toUpperCase()})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Visual Indicators
          if (match.visualIndicators.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.visibility_outlined,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Visual Indicators:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...match.visualIndicators.map<Widget>((indicator) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('  • ', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Text(
                        indicator,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 12),
          ],

          // Reasoning
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'AI Reasoning:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  match.reasoning,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo?'),
        content: const Text(
          'Are you sure you want to delete this photo identification? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await _service.deletePhotoIdentification(widget.photoId);
        
        _analyticsService.logEvent(
          name: 'photo_identification_deleted',
          parameters: {
            'photo_id': widget.photoId,
          },
        );
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting photo: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
