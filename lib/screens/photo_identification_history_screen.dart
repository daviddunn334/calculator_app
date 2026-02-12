import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/photo_identification.dart';
import '../services/defect_identifier_service.dart';
import 'photo_identification_detail_screen.dart';

class PhotoIdentificationHistoryScreen extends StatelessWidget {
  const PhotoIdentificationHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = DefectIdentifierService();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Photo History'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<PhotoIdentification>>(
        stream: service.getPhotoIdentifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
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
                    'Error loading photos',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final photos = snapshot.data ?? [];

          if (photos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_camera_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Photos Yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Identified photos will appear here',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              return _buildPhotoCard(context, photo);
            },
          );
        },
      ),
    );
  }

  Widget _buildPhotoCard(BuildContext context, PhotoIdentification photo) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhotoIdentificationDetailScreen(
                photoId: photo.id,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  photo.photoUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge
                    _buildStatusBadge(photo),
                    const SizedBox(height: 8),

                    // Top Match or Status Text
                    if (photo.hasAnalysis && photo.topMatch != null) ...[
                      Row(
                        children: [
                          Text(
                            photo.topMatch!.confidenceEmoji,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              photo.topMatch!.defectType,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${photo.topMatch!.confidenceScore.toStringAsFixed(0)}% confidence',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ] else if (photo.isAnalyzing) ...[
                      Text(
                        'Analyzing photo...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ] else if (photo.hasAnalysisError) ...[
                      Text(
                        'Analysis failed',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Waiting to analyze...',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Timestamp
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateFormat.format(photo.localCreatedAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
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

  Widget _buildStatusBadge(PhotoIdentification photo) {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    if (photo.isAnalyzing) {
      bgColor = Colors.blue.shade50;
      textColor = Colors.blue.shade700;
      label = 'Analyzing';
      icon = Icons.sync;
    } else if (photo.hasAnalysis) {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
      label = 'Complete';
      icon = Icons.check_circle;
    } else if (photo.hasAnalysisError) {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      label = 'Error';
      icon = Icons.error;
    } else {
      bgColor = Colors.grey.shade50;
      textColor = Colors.grey.shade700;
      label = 'Pending';
      icon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
