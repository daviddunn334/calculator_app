import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ReportPreviewScreen extends StatelessWidget {
  final String technicianName;
  final DateTime inspectionDate;
  final String location;
  final String pipeDiameter;
  final String wallThickness;
  final String method;
  final String findings;
  final String correctiveActions;
  final String? additionalNotes;

  const ReportPreviewScreen({
    super.key,
    required this.technicianName,
    required this.inspectionDate,
    required this.location,
    required this.pipeDiameter,
    required this.wallThickness,
    required this.method,
    required this.findings,
    required this.correctiveActions,
    this.additionalNotes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Preview'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              // TODO: Implement print functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Print functionality coming soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                side: const BorderSide(color: AppTheme.divider),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NDT Inspection Report',
                      style: AppTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),
                    _buildInfoRow('Technician:', technicianName),
                    _buildInfoRow(
                      'Date:',
                      '${inspectionDate.year}-${inspectionDate.month.toString().padLeft(2, '0')}-${inspectionDate.day.toString().padLeft(2, '0')}',
                    ),
                    _buildInfoRow('Location:', location),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.paddingLarge),

            // Pipe Specifications
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                side: const BorderSide(color: AppTheme.divider),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pipe Specifications',
                      style: AppTheme.titleLarge,
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    _buildInfoRow('Pipe Diameter:', pipeDiameter),
                    _buildInfoRow('Wall Thickness:', wallThickness),
                    _buildInfoRow('Inspection Method:', method),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.paddingLarge),

            // Findings
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                side: const BorderSide(color: AppTheme.divider),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Findings',
                      style: AppTheme.titleLarge,
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    Text(
                      findings,
                      style: AppTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.paddingLarge),

            // Corrective Actions
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                side: const BorderSide(color: AppTheme.divider),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Corrective Actions',
                      style: AppTheme.titleLarge,
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    Text(
                      correctiveActions,
                      style: AppTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            if (additionalNotes != null && additionalNotes!.isNotEmpty) ...[
              const SizedBox(height: AppTheme.paddingLarge),
              // Additional Notes
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  side: const BorderSide(color: AppTheme.divider),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Notes',
                        style: AppTheme.titleLarge,
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),
                      Text(
                        additionalNotes!,
                        style: AppTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
} 