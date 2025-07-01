import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import '../models/report.dart';

class EnhancedPdfService {
  static const PdfColor _primaryColor =
      PdfColor.fromInt(0xFF2E5C3E); // Dark green
  static const PdfColor _accentColor = PdfColor.fromInt(0xFFD4AF37); // Gold
  static const PdfColor _tableHeaderColor = PdfColor.fromInt(0xFFE8F4FD);
  static const PdfColor _tableBorderColor = PdfColor.fromInt(0xFF000000);

  /// Generates a professional PDF report matching Integrity Specialists format
  Future<Uint8List> generateProfessionalReportPdf(Report report) async {
    try {
      final pdf = pw.Document();

      // Add cover page
      pdf.addPage(await _buildCoverPage(report));

      // Add main report pages
      pdf.addPage(await _buildMainReportPage(report));

      // Add additional pages if needed for findings/images
      if (report.findings.length > 500 ||
          report.additionalNotes?.isNotEmpty == true) {
        pdf.addPage(await _buildAdditionalDetailsPage(report));
      }

      // Add image pages - each image on its own page
      if (report.images.isNotEmpty) {
        for (int i = 0; i < report.images.length; i++) {
          try {
            final reportImage = report.images[i];
            final imagePage =
                await _buildImagePageWithType(report, reportImage, i + 1);
            pdf.addPage(imagePage);
          } catch (e) {
            print('Error adding image ${i + 1}: $e');
            // Continue with other images even if one fails
          }
        }
      }

      return await pdf.save();
    } catch (e) {
      print('Error generating PDF: $e');
      rethrow;
    }
  }

  /// Builds the cover page matching the Integrity Specialists format
  Future<pw.Page> _buildCoverPage(Report report) async {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) {
        return pw.Column(
          children: [
            // Company Logo/Header
            _buildCompanyHeader(),
            pw.SizedBox(height: 60),

            // Date and Dig Number section
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                pw.Column(
                  children: [
                    pw.Text(
                      _getMonthName(report.inspectionDate.month),
                      style: pw.TextStyle(
                          fontSize: 36, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      '${report.inspectionDate.day}${_getOrdinalSuffix(report.inspectionDate.day)}',
                      style: pw.TextStyle(fontSize: 24),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      '${report.inspectionDate.year}',
                      style: pw.TextStyle(
                          fontSize: 36, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.Container(
                  width: 2,
                  height: 120,
                  color: _tableBorderColor,
                ),
                pw.Column(
                  children: [
                    pw.Text(
                      'Dig #',
                      style: pw.TextStyle(
                          fontSize: 36, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      report.id.substring(
                          0, 3), // Use first 3 chars of ID as dig number
                      style: pw.TextStyle(
                          fontSize: 48, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 60),

            // Horizontal line
            pw.Container(
              width: double.infinity,
              height: 2,
              color: _tableBorderColor,
            ),

            pw.SizedBox(height: 40),

            // Report details
            pw.Column(
              children: [
                pw.Text(
                  '${report.location}',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Final Report',
                  style: pw.TextStyle(fontSize: 20),
                ),
                pw.SizedBox(height: 30),

                // Project details
                pw.Text('Pipeline Inspection Report',
                    style: pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 5),
                pw.Text('${report.pipeDiameter}',
                    style: pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 5),
                pw.Text('${report.method}', style: pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 5),
                pw.Text('Technician: ${report.technicianName}',
                    style: pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 5),
                pw.Text('Report ID: ${report.id}',
                    style: pw.TextStyle(fontSize: 14)),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Builds the main report page with project overview and pipe data
  Future<pw.Page> _buildMainReportPage(Report report) async {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30),
      build: (pw.Context context) {
        return pw.Column(
          children: [
            // Header
            _buildPageHeader(report),
            pw.SizedBox(height: 20),

            // Project Overview Table
            _buildProjectOverviewTable(report),
            pw.SizedBox(height: 20),

            // Pipe Static Data Table
            _buildPipeStaticDataTable(report),
            pw.SizedBox(height: 20),

            // Pipe Evaluation Table
            _buildPipeEvaluationTable(report),
            pw.SizedBox(height: 20),

            // Environment Table
            _buildEnvironmentTable(report),
            pw.SizedBox(height: 20),

            // Joint and Girth Weld Details Table
            _buildJointGirthWeldTable(report),
            pw.SizedBox(height: 20),

            // Defect Evaluation Table
            _buildDefectEvaluationTable(report),
            pw.SizedBox(height: 20),

            // Summary Table
            _buildSummaryTable(report),
            pw.SizedBox(height: 20),

            // Findings Section
            _buildFindingsSection(report),
          ],
        );
      },
    );
  }

  /// Builds additional details page for extensive findings
  Future<pw.Page> _buildAdditionalDetailsPage(Report report) async {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30),
      build: (pw.Context context) {
        return pw.Column(
          children: [
            _buildPageHeader(report),
            pw.SizedBox(height: 20),

            // Detailed Findings
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _tableBorderColor),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'DETAILED FINDINGS',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    report.findings,
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Corrective Actions
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _tableBorderColor),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'CORRECTIVE ACTIONS',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    report.correctiveActions,
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),

            if (report.additionalNotes?.isNotEmpty == true) ...[
              pw.SizedBox(height: 20),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _tableBorderColor),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'ADDITIONAL NOTES',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      report.additionalNotes!,
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  /// Builds the company header with logo placeholder
  pw.Widget _buildCompanyHeader() {
    return pw.Container(
      child: pw.Column(
        children: [
          // Logo placeholder - you can replace this with actual logo later
          pw.Container(
            width: 300,
            height: 80,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _primaryColor, width: 3),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Center(
              child: pw.Text(
                'INTEGRITY\nSPECIALISTS',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: _primaryColor,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'LLC',
            style: pw.TextStyle(
              fontSize: 12,
              color: _primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the page header for subsequent pages
  pw.Widget _buildPageHeader(Report report) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Container(
          width: 200,
          height: 40,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _primaryColor, width: 2),
          ),
          child: pw.Center(
            child: pw.Text(
              'INTEGRITY\nSPECIALISTS',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: _primaryColor,
              ),
            ),
          ),
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'FINAL Report',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(report.location, style: const pw.TextStyle(fontSize: 12)),
            pw.Text('${report.method}',
                style: const pw.TextStyle(fontSize: 10)),
            pw.Text('${report.pipeDiameter}',
                style: const pw.TextStyle(fontSize: 10)),
            pw.Text('Dig #${report.id.substring(0, 3)}',
                style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }

  /// Builds the project overview table
  pw.Widget _buildProjectOverviewTable(Report report) {
    return pw.Container(
      child: pw.Column(
        children: [
          // Table header
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: _tableHeaderColor,
              border: pw.Border.all(color: _tableBorderColor),
            ),
            child: pw.Center(
              child: pw.Text(
                'PROJECT OVERVIEW',
                style:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ),
          // Table content
          pw.Table(
            border: pw.TableBorder.all(color: _tableBorderColor),
            children: [
              _buildTableRow('Client WO #:', report.id),
              _buildTableRow('Integrity Specialists #:',
                  'WIL-AL-P${report.id.substring(0, 4)}'),
              _buildTableRow('Project Name:', report.location),
              _buildTableRow('Item #:', report.pipeDiameter),
              _buildTableRow('Dig Site:', report.id.substring(0, 3)),
              _buildTableRow('Product Flow:', 'PLN'),
              _buildTableRow(
                  'Excavation Date:', _formatDate(report.inspectionDate)),
              _buildTableRow(
                  'Assessment Date:', _formatDate(report.inspectionDate)),
              _buildTableRow('Report Date:', _formatDate(DateTime.now())),
              _buildTableRow(
                  'Backfill Date:',
                  _formatDate(
                      report.inspectionDate.add(const Duration(days: 1)))),
              _buildTableRow('Reason for Dig:', 'Inspection'),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the pipe static data table
  pw.Widget _buildPipeStaticDataTable(Report report) {
    return pw.Container(
      child: pw.Column(
        children: [
          // Table header
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: _tableHeaderColor,
              border: pw.Border.all(color: _tableBorderColor),
            ),
            child: pw.Center(
              child: pw.Text(
                'PIPE STATIC DATA',
                style:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ),
          // Table content
          pw.Table(
            border: pw.TableBorder.all(color: _tableBorderColor),
            children: [
              pw.TableRow(
                children: [
                  _buildTableCell('Nominal Wall Thickness:', isHeader: false),
                  _buildTableCell(report.wallThickness, isHeader: false),
                  _buildTableCell('SMYS:', isHeader: false),
                  _buildTableCell('X60', isHeader: false),
                  _buildTableCell('Pipe Manufacturer:', isHeader: false),
                  _buildTableCell('Unknown', isHeader: false),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Long Seam Weld Type:', isHeader: false),
                  _buildTableCell('DSAW', isHeader: false),
                  _buildTableCell('MAOP:', isHeader: false),
                  _buildTableCell('800', isHeader: false),
                  _buildTableCell('Install Date:', isHeader: false),
                  _buildTableCell('1972', isHeader: false),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Girth Weld Type:', isHeader: false),
                  _buildTableCell('SMAW', isHeader: false),
                  _buildTableCell('Safety Factor:', isHeader: false),
                  _buildTableCell('0.6', isHeader: false),
                  _buildTableCell('Product:', isHeader: false),
                  _buildTableCell('CNG', isHeader: false),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Pipe Diameter:', isHeader: false),
                  _buildTableCell(report.pipeDiameter, isHeader: false),
                  _buildTableCell('Operating Pressure:', isHeader: false),
                  _buildTableCell('<800', isHeader: false),
                  _buildTableCell('', isHeader: false),
                  _buildTableCell('', isHeader: false),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the findings section
  pw.Widget _buildFindingsSection(Report report) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _tableBorderColor),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'INSPECTION FINDINGS',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Method: ${report.method}',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Technician: ${report.technicianName}',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            report.findings,
            style: const pw.TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  /// Helper method to build table rows
  pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        _buildTableCell(label, isHeader: true),
        _buildTableCell(value, isHeader: false),
      ],
    );
  }

  /// Helper method to build table cells
  pw.Widget _buildTableCell(String text, {required bool isHeader}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  /// Builds the pipe evaluation table
  pw.Widget _buildPipeEvaluationTable(Report report) {
    return pw.Container(
      child: pw.Column(
        children: [
          // Table header
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: _tableHeaderColor,
              border: pw.Border.all(color: _tableBorderColor),
            ),
            child: pw.Center(
              child: pw.Text(
                'PIPE EVALUATION',
                style:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ),
          // Table content
          pw.Table(
            border: pw.TableBorder.all(color: _tableBorderColor),
            children: [
              _buildTableRow('CP System:', report.cpSystem ?? 'N/A'),
              _buildTableRow(
                  'Soil Resistivity:', report.soilResistivity ?? 'N/A'),
              _buildTableRow('Test Type:', report.testType ?? 'N/A'),
              _buildTableRow('Coating Type:', report.coatingType ?? 'N/A'),
              _buildTableRow(
                  'Overall Condition:', report.overallCondition ?? 'N/A'),
              _buildTableRow(
                  'Condition at Anomaly:', report.conditionAtAnomaly ?? 'N/A'),
              _buildTableRow('% Bonded:', report.percentBonded ?? 'N/A'),
              _buildTableRow('% Disbonded:', report.percentDisbonded ?? 'N/A'),
              _buildTableRow('% Bare Pipe:', report.percentBarePipe ?? 'N/A'),
              _buildTableRow(
                  'Evidence of Soil Body Stress:',
                  report.evidenceOfSoilBodyStress == true
                      ? 'Yes'
                      : report.evidenceOfSoilBodyStress == false
                          ? 'No'
                          : 'N/A'),
              _buildTableRow(
                  'Deposits:',
                  report.deposits == true
                      ? 'Yes'
                      : report.deposits == false
                          ? 'No'
                          : 'N/A'),
              _buildTableRow(
                  'Pipe Bend:',
                  report.pipeBend == true
                      ? 'Yes'
                      : report.pipeBend == false
                          ? 'No'
                          : 'N/A'),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the environment table
  pw.Widget _buildEnvironmentTable(Report report) {
    return pw.Container(
      child: pw.Column(
        children: [
          // Table header
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: _tableHeaderColor,
              border: pw.Border.all(color: _tableBorderColor),
            ),
            child: pw.Center(
              child: pw.Text(
                'ENVIRONMENT',
                style:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ),
          // Table content
          pw.Table(
            border: pw.TableBorder.all(color: _tableBorderColor),
            children: [
              _buildTableRow(
                  'Terrain at Dig Site:', report.terrainAtDigSite ?? 'N/A'),
              _buildTableRow('Soil Type at Pipe Level:',
                  report.soilTypeAtPipeLevel ?? 'N/A'),
              _buildTableRow(
                  'Soil Type @ 6:00:', report.soilTypeAtSixOClock ?? 'N/A'),
              _buildTableRow('Depth of Cover:', report.depthOfCover ?? 'N/A'),
              _buildTableRow('Organic Depth:', report.organicDepth ?? 'N/A'),
              _buildTableRow('Usage:', report.usage ?? 'N/A'),
              _buildTableRow(
                  'Pipe Temperature:', report.pipeTemperature ?? 'N/A'),
              _buildTableRow(
                  'Ambient Temperature:', report.ambientTemperature ?? 'N/A'),
              _buildTableRow(
                  'Weather Conditions:', report.weatherConditions ?? 'N/A'),
              _buildTableRow('Drainage:', report.drainage ?? 'N/A'),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the joint and girth weld details table
  pw.Widget _buildJointGirthWeldTable(Report report) {
    return pw.Container(
      child: pw.Column(
        children: [
          // Table header
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: _tableHeaderColor,
              border: pw.Border.all(color: _tableBorderColor),
            ),
            child: pw.Center(
              child: pw.Text(
                'JOINT AND GIRTH WELD DETAILS',
                style:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ),
          // Table content
          pw.Table(
            border: pw.TableBorder.all(color: _tableBorderColor),
            children: [
              _buildTableRow(
                  'Start of Dig ABS/ES:', report.startOfDigAbsEs ?? 'N/A'),
              _buildTableRow(
                  'End of Dig ABS/ES:', report.endOfDigAbsEs ?? 'N/A'),
              _buildTableRow('Length of Pipe Exposed:',
                  report.lengthOfPipeExposed ?? 'N/A'),
              _buildTableRow('Length of Pipe Assessed:',
                  report.lengthOfPipeAssessed ?? 'N/A'),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the defect evaluation table
  pw.Widget _buildDefectEvaluationTable(Report report) {
    String methods = '';
    if (report.methodB31G == true) methods += 'B31G ';
    if (report.methodB31GModified == true) methods += 'B31G Modified ';
    if (report.methodKapa == true) methods += 'Kapa ';
    if (report.methodRstreng == true) methods += 'Rstreng ';
    if (methods.isEmpty) methods = 'N/A';

    return pw.Container(
      child: pw.Column(
        children: [
          // Table header
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: _tableHeaderColor,
              border: pw.Border.all(color: _tableBorderColor),
            ),
            child: pw.Center(
              child: pw.Text(
                'DEFECT EVALUATION',
                style:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ),
          // Table content
          pw.Table(
            border: pw.TableBorder.all(color: _tableBorderColor),
            children: [
              _buildTableRow(
                  'Defect Noted:',
                  report.defectNoted == true
                      ? 'Yes'
                      : report.defectNoted == false
                          ? 'No'
                          : 'N/A'),
              _buildTableRow('Type of Defect:', report.typeOfDefect ?? 'N/A'),
              _buildTableRow(
                  'Burst Pressure Analysis:',
                  report.burstPressureAnalysis == true
                      ? 'Yes'
                      : report.burstPressureAnalysis == false
                          ? 'No'
                          : 'N/A'),
              _buildTableRow('Methods:', methods.trim()),
              _buildTableRow(
                  'Wet MPI Performed:',
                  report.wetMpiPerformed == true
                      ? 'Yes'
                      : report.wetMpiPerformed == false
                          ? 'No'
                          : 'N/A'),
              _buildTableRow(
                  'Start of Wet MPI:', report.startOfWetMpi ?? 'N/A'),
              _buildTableRow('End of Wet MPI:', report.endOfWetMpi ?? 'N/A'),
              _buildTableRow(
                  'Length of Wet MPI:', report.lengthOfWetMpi ?? 'N/A'),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the summary table
  pw.Widget _buildSummaryTable(Report report) {
    return pw.Container(
      child: pw.Column(
        children: [
          // Table header
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: _tableHeaderColor,
              border: pw.Border.all(color: _tableBorderColor),
            ),
            child: pw.Center(
              child: pw.Text(
                'SUMMARY',
                style:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ),
          // Table content
          pw.Table(
            border: pw.TableBorder.all(color: _tableBorderColor),
            children: [
              _buildTableRow('Start of Recoat ABS/ES:',
                  report.startOfRecoatAbsEs ?? 'N/A'),
              _buildTableRow(
                  'End of Recoat ABS/ES:', report.endOfRecoatAbsEs ?? 'N/A'),
              _buildTableRow('Total Length of Recoat:',
                  report.totalLengthOfRecoat ?? 'N/A'),
              _buildTableRow(
                  'Recoat Manufacturer:', report.recoatManufacturer ?? 'N/A'),
              _buildTableRow('Recoat Product:', report.recoatProduct ?? 'N/A'),
              _buildTableRow('Recoat Type:', report.recoatType ?? 'N/A'),
            ],
          ),
        ],
      ),
    );
  }

  /// Downloads the PDF for web platform
  Future<void> downloadPdfWeb(Uint8List pdfBytes, String filename) async {
    if (kIsWeb) {
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = filename;
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    }
  }

  /// Helper methods for date formatting
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month];
  }

  String _getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  /// Gets the proper PDF title for each photo type
  String _getPhotoTypeTitle(String type) {
    switch (type) {
      case 'upstream':
        return 'Upstream View';
      case 'downstream':
        return 'Downstream View';
      case 'soil_strate':
        return 'Soil Strate';
      case 'coating_overview':
        return 'Coating Overview';
      case 'longseam':
        return 'Longseam Documentation';
      case 'deposits':
        return 'Deposits Overview';
      default:
        return 'General Documentation';
    }
  }

  /// Builds a page with a single image using ReportImage type
  Future<pw.Page> _buildImagePageWithType(
      Report report, ReportImage reportImage, int imageNumber) async {
    // Fetch the image from the URL
    final response = await http.get(Uri.parse(reportImage.url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load image: ${response.statusCode}');
    }

    final imageBytes = response.bodyBytes;
    final image = pw.MemoryImage(imageBytes);

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30),
      build: (pw.Context context) {
        return pw.Column(
          children: [
            // Header
            _buildPageHeader(report),
            pw.SizedBox(height: 20),

            // Image title with photo type
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: _tableHeaderColor,
                border: pw.Border.all(color: _tableBorderColor),
              ),
              child: pw.Center(
                child: pw.Text(
                  _getPhotoTypeTitle(reportImage.type).toUpperCase(),
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ),

            pw.SizedBox(height: 20),

            // Image
            pw.Expanded(
              child: pw.Container(
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _tableBorderColor),
                ),
                child: pw.Center(
                  child: pw.Image(
                    image,
                    fit: pw.BoxFit.contain,
                  ),
                ),
              ),
            ),

            pw.SizedBox(height: 10),

            // Image caption
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _tableBorderColor),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Photo Details:',
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Type: ${_getPhotoTypeTitle(reportImage.type)}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    'Location: ${report.location}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    'Method: ${report.method}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    'Date: ${_formatDate(report.inspectionDate)}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    'Technician: ${report.technicianName}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds a page with a single image (legacy method)
  Future<pw.Page> _buildImagePage(
      Report report, String imageUrl, int imageNumber) async {
    // Fetch the image from the URL
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to load image: ${response.statusCode}');
    }

    final imageBytes = response.bodyBytes;
    final image = pw.MemoryImage(imageBytes);

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30),
      build: (pw.Context context) {
        return pw.Column(
          children: [
            // Header
            _buildPageHeader(report),
            pw.SizedBox(height: 20),

            // Image title
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: _tableHeaderColor,
                border: pw.Border.all(color: _tableBorderColor),
              ),
              child: pw.Center(
                child: pw.Text(
                  'INSPECTION PHOTO #$imageNumber',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ),

            pw.SizedBox(height: 20),

            // Image
            pw.Expanded(
              child: pw.Container(
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _tableBorderColor),
                ),
                child: pw.Center(
                  child: pw.Image(
                    image,
                    fit: pw.BoxFit.contain,
                  ),
                ),
              ),
            ),

            pw.SizedBox(height: 10),

            // Image caption
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _tableBorderColor),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Photo Details:',
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Location: ${report.location}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    'Method: ${report.method}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    'Date: ${_formatDate(report.inspectionDate)}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    'Technician: ${report.technicianName}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
