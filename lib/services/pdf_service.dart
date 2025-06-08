import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../models/report.dart';

class PdfService {
  /// Generates a PDF report from a Report object
  Future<File> generateReportPdf(Report report) async {
    try {
      // Create a PDF document
      final pdf = pw.Document();

      // Add a page to the PDF document
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              _buildHeader(report),
              pw.SizedBox(height: 20),
              _buildPipeSpecifications(report),
              pw.SizedBox(height: 20),
              _buildFindings(report),
              pw.SizedBox(height: 20),
              _buildCorrectiveActions(report),
              if (report.additionalNotes != null && report.additionalNotes!.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                _buildAdditionalNotes(report),
              ],
            ];
          },
        ),
      );

      // Try to get the temporary directory
      Directory output;
      try {
        output = await getTemporaryDirectory();
      } catch (e) {
        // Fallback to application documents directory if temporary directory fails
        output = await getApplicationDocumentsDirectory();
      }

      // Save the PDF document
      final file = File('${output.path}/report_${report.id}.pdf');
      await file.writeAsBytes(await pdf.save());
      return file;
    } catch (e) {
      print('Error generating PDF: $e');
      rethrow;
    }
  }

  /// Builds the header section of the PDF
  pw.Widget _buildHeader(Report report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1, color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Center(
            child: pw.Text(
              'NDT Inspection Report',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 16),
          _buildInfoRow('Technician:', report.technicianName),
          _buildInfoRow(
            'Date:',
            '${report.inspectionDate.year}-${report.inspectionDate.month.toString().padLeft(2, '0')}-${report.inspectionDate.day.toString().padLeft(2, '0')}',
          ),
          _buildInfoRow('Location:', report.location),
        ],
      ),
    );
  }

  /// Builds the pipe specifications section of the PDF
  pw.Widget _buildPipeSpecifications(Report report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1, color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Pipe Specifications',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          _buildInfoRow('Pipe Diameter:', report.pipeDiameter),
          _buildInfoRow('Wall Thickness:', report.wallThickness),
          _buildInfoRow('Inspection Method:', report.method),
        ],
      ),
    );
  }

  /// Builds the findings section of the PDF
  pw.Widget _buildFindings(Report report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1, color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Findings',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(report.findings),
        ],
      ),
    );
  }

  /// Builds the corrective actions section of the PDF
  pw.Widget _buildCorrectiveActions(Report report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1, color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Corrective Actions',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(report.correctiveActions),
        ],
      ),
    );
  }

  /// Builds the additional notes section of the PDF
  pw.Widget _buildAdditionalNotes(Report report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1, color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Additional Notes',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(report.additionalNotes ?? ''),
        ],
      ),
    );
  }

  /// Builds an information row with a label and value
  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }

  /// Shares the generated PDF file
  Future<void> sharePdf(File file) async {
    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'NDT Inspection Report',
      );
    } catch (e) {
      print('Error sharing PDF: $e');
      rethrow;
    }
  }
}
