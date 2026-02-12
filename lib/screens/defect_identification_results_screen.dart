import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../models/defect_match.dart';

/// Screen for displaying defect identification results
class DefectIdentificationResultsScreen extends StatelessWidget {
  final DefectIdentificationResponse response;
  final File? photoFile;
  final XFile? photoXFile;

  const DefectIdentificationResultsScreen({
    Key? key,
    required this.response,
    this.photoFile,
    this.photoXFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Identification Results'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Pop twice to get back to landing screen
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo thumbnail
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                child: kIsWeb
                    ? Image.network(
                        photoXFile!.path,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        photoFile!,
                        fit: BoxFit.cover,
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Processing time
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Analysis complete in ${response.processingTime.toStringAsFixed(1)}s',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Results header
            const Text(
              'AI Identification Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Top ${response.matches.length} possible matches:',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),

            const SizedBox(height: 16),

            // Display each match
            ...response.matches.asMap().entries.map((entry) {
              final index = entry.key;
              final match = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildMatchCard(context, match, index + 1),
              );
            }).toList(),

            const SizedBox(height: 24),

            // Action buttons
            ElevatedButton.icon(
              onPressed: () {
                // Pop to landing screen
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Identify Another Defect'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.home),
              label: const Text('Back to Home'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: AppTheme.primaryBlue,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, DefectMatch match, int rank) {
    final Color confidenceColor = _getConfidenceColor(match.confidence);
    final Color bgColor = confidenceColor.withOpacity(0.1);
    final Color borderColor = confidenceColor.withOpacity(0.3);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with rank and confidence
          Row(
            children: [
              // Rank badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: confidenceColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.defectType,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: confidenceColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          match.confidenceEmoji,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${match.confidence.toUpperCase()} CONFIDENCE (${match.confidenceScore.toStringAsFixed(0)}%)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: confidenceColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (match.visualIndicators.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Visual Indicators Identified:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 6),
            ...match.visualIndicators.map((indicator) {
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.arrow_right,
                      size: 18,
                      color: confidenceColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        indicator,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],

          if (match.reasoning.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'AI Reasoning:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              match.reasoning,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getConfidenceColor(String confidence) {
    switch (confidence.toLowerCase()) {
      case 'high':
        return Colors.green.shade700;
      case 'medium':
        return Colors.orange.shade700;
      case 'low':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade600;
    }
  }
}
