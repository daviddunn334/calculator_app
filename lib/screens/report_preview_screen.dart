import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/report.dart';
import '../services/pdf_service.dart';
import 'dart:io';

class ReportPreviewScreen extends StatefulWidget {
  final String technicianName;
  final DateTime inspectionDate;
  final String location;
  final String pipeDiameter;
  final String wallThickness;
  final String method;
  final String findings;
  final String correctiveActions;
  final String? additionalNotes;
  final String? reportId;

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
    this.reportId,
  });

  @override
  State<ReportPreviewScreen> createState() => _ReportPreviewScreenState();
}

class _ReportPreviewScreenState extends State<ReportPreviewScreen> {
  final PdfService _pdfService = PdfService();
  bool _isGeneratingPdf = false;

  Future<void> _generateAndSharePdf() async {
    if (widget.reportId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report ID is missing, cannot generate PDF')),
      );
      return;
    }

    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      // Create a temporary Report object from the preview data
      final report = Report(
        id: widget.reportId!,
        userId: '', // Not needed for PDF generation
        technicianName: widget.technicianName,
        inspectionDate: widget.inspectionDate,
        location: widget.location,
        pipeDiameter: widget.pipeDiameter,
        wallThickness: widget.wallThickness,
        method: widget.method,
        findings: widget.findings,
        correctiveActions: widget.correctiveActions,
        additionalNotes: widget.additionalNotes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final file = await _pdfService.generateReportPdf(report);
      if (mounted) {
        await _pdfService.sharePdf(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });
      }
    }
  }

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
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Generate Final Report',
            onPressed: widget.reportId == null || _isGeneratingPdf
                ? null
                : _generateAndSharePdf,
          ),
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
                    _buildInfoRow('Technician:', widget.technicianName),
                    _buildInfoRow(
                      'Date:',
                      '${widget.inspectionDate.year}-${widget.inspectionDate.month.toString().padLeft(2, '0')}-${widget.inspectionDate.day.toString().padLeft(2, '0')}',
                    ),
                    _buildInfoRow('Location:', widget.location),
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
                    _buildInfoRow('Pipe Diameter:', widget.pipeDiameter),
                    _buildInfoRow('Wall Thickness:', widget.wallThickness),
                    _buildInfoRow('Inspection Method:', widget.method),
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
                      widget.findings,
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
                      widget.correctiveActions,
                      style: AppTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            if (widget.additionalNotes != null && widget.additionalNotes!.isNotEmpty) ...[
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
                        widget.additionalNotes!,
                        style: AppTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            // Final Report Button
            if (widget.reportId != null) ...[
              const SizedBox(height: AppTheme.paddingLarge),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Generate Final Report'),
                  onPressed: _isGeneratingPdf ? null : _generateAndSharePdf,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
