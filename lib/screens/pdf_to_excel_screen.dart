import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/pdf_to_excel_service.dart';
import '../theme/app_theme.dart';

class PdfToExcelScreen extends StatefulWidget {
  const PdfToExcelScreen({super.key});

  @override
  State<PdfToExcelScreen> createState() => _PdfToExcelScreenState();
}

class _PdfToExcelScreenState extends State<PdfToExcelScreen> {
  final PdfToExcelService _pdfToExcelService = PdfToExcelService();
  
  bool _isProcessing = false;
  List<PdfFileData> _selectedPdfFiles = [];
  List<HardnessValue>? _extractedValues;
  String _statusMessage = '';
  ExcelFileData? _generatedExcelFile;
  double? _shiftValue;

  @override
  Widget build(BuildContext context) {
    final displayedValues = _shiftValue == null
        ? _extractedValues
        : _extractedValues?.map((v) {
            return HardnessValue(
              sequenceNumber: v.sequenceNumber,
              hardnessValue: v.hardnessValue + _shiftValue!,
              pageNumber: v.pageNumber,
              rawText: v.rawText,
            );
          }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('PDF to Excel Converter'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      size: 64,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Hardness PDF to Excel Converter',
                      style: AppTheme.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Extract hardness values from PDF files and convert them to Excel format',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Step 1: Select PDF File
            _buildStepCard(
              stepNumber: 1,
              title: 'Select PDF File',
              description: 'Choose a PDF file containing hardness test data',
              child: Column(
                children: [
                  if (_selectedPdfFiles.isEmpty)
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _selectPdfFiles,
                      icon: const Icon(Icons.file_upload),
                      label: const Text('Select PDF Files'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        Container(
                          height: 150, // Adjust height as needed
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ListView.builder(
                            itemCount: _selectedPdfFiles.length,
                            itemBuilder: (context, index) {
                              final file = _selectedPdfFiles[index];
                              return ListTile(
                                leading: const Icon(Icons.picture_as_pdf, color: AppTheme.primaryBlue),
                                title: Text(file.name, style: const TextStyle(fontSize: 14)),
                                dense: true,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton.icon(
                              onPressed: _isProcessing ? null : _selectPdfFiles,
                              icon: const Icon(Icons.add_circle_outline),
                              label: const Text('Add More'),
                            ),
                            TextButton.icon(
                              onPressed: _isProcessing ? null : _clearSelection,
                              icon: const Icon(Icons.cancel_outlined),
                              label: const Text('Clear All'),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Step 2: Extract Data
            _buildStepCard(
              stepNumber: 2,
              title: 'Extract Hardness Data',
              description: 'Process the PDF to extract hardness values',
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: (_selectedPdfFiles.isNotEmpty && !_isProcessing)
                            ? _showShiftDialog
                            : null,
                        icon: const Icon(Icons.add),
                        label: const Text('Apply a Shift?'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accent2,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: (_selectedPdfFiles.isNotEmpty && !_isProcessing)
                            ? _extractHardnessData
                            : null,
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.analytics),
                        label: Text(_isProcessing ? 'Processing...' : 'Extract Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accent2,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_statusMessage.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _extractedValues != null && _extractedValues!.isNotEmpty
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statusMessage,
                        style: TextStyle(
                          color: _extractedValues != null && _extractedValues!.isNotEmpty
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Step 3: Preview Data
            if (displayedValues != null && displayedValues.isNotEmpty)
              _buildStepCard(
                stepNumber: 3,
                title: 'Preview Extracted Data',
                description: 'Review the hardness values found in the PDF',
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_shiftValue != null) ...[
                        Text(
                          'Shift Applied: $_shiftValue HB',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        'Found ${displayedValues.length} hardness values:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
                        child: ListView.builder(
                          itemCount: displayedValues.length > 10
                              ? 10
                              : displayedValues.length,
                          itemBuilder: (context, index) {
                            final value = displayedValues[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                '${value.sequenceNumber}. ${value.hardnessValue.toStringAsFixed(1)} HB (Page ${value.pageNumber})',
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          },
                        ),
                      ),
                      if (displayedValues.length > 10)
                        Text(
                          '... and ${displayedValues.length - 10} more values',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (displayedValues.isNotEmpty) ...[
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'Total',
                              '${displayedValues.length}',
                              Icons.format_list_numbered,
                            ),
                            _buildStatItem(
                              'Average',
                              '${(displayedValues.map((v) => v.hardnessValue).reduce((a, b) => a + b) / displayedValues.length).toStringAsFixed(1)} HB',
                              Icons.analytics,
                            ),
                            _buildStatItem(
                              'Highest',
                              '${displayedValues.map((v) => v.hardnessValue).reduce((a, b) => a > b ? a : b).toStringAsFixed(1)}',
                              Icons.arrow_upward,
                            ),
                            _buildStatItem(
                              'Range',
                              '${(displayedValues.map((v) => v.hardnessValue).reduce((a, b) => a > b ? a : b) - displayedValues.map((v) => v.hardnessValue).reduce((a, b) => a < b ? a : b)).toStringAsFixed(1)}',
                              Icons.straighten,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _copyDataForTemplate,
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy Equotip Data for Template'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accent2,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Step 4: Generate Excel
            if (displayedValues != null && displayedValues.isNotEmpty)
              _buildStepCard(
                stepNumber: 4,
                title: 'Generate Excel File',
                description: 'Create an Excel file with the extracted data',
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _generateExcelFile,
                      icon: const Icon(Icons.table_chart),
                      label: const Text('Generate Excel File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    if (_generatedExcelFile != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Excel file generated successfully!',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _shareExcelFile,
                                  icon: const Icon(Icons.share),
                                  label: const Text('Download'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryBlue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _resetConverter,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Convert Another'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required int stepNumber,
    required String title,
    required String description,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$stepNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
                        title,
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        description,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryBlue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Future<void> _selectPdfFiles() async {
    try {
      final files = await _pdfToExcelService.pickPdfFiles();
      if (files.isNotEmpty) {
        setState(() {
          _selectedPdfFiles.addAll(files);
          _extractedValues = null;
          _generatedExcelFile = null;
          _statusMessage = '';
        });
      }
    } catch (e) {
      _showErrorDialog('Error selecting files: $e');
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedPdfFiles.clear();
      _extractedValues = null;
      _generatedExcelFile = null;
      _statusMessage = '';
    });
  }

  Future<void> _extractHardnessData() async {
    if (_selectedPdfFiles.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Processing ${_selectedPdfFiles.length} PDF file(s)...';
    });

    try {
      final values = await _pdfToExcelService.extractHardnessValues(_selectedPdfFiles);
      
      setState(() {
        _extractedValues = values;
        _isProcessing = false;
        if (values.isEmpty) {
          _statusMessage = 'No hardness values found in the selected PDFs. Please check if the files contain hardness test data in a supported format.';
        } else {
          _statusMessage = 'Successfully extracted ${values.length} total hardness values from ${_selectedPdfFiles.length} PDF(s).';
        }
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Error processing PDF: $e';
      });
      _showErrorDialog('Error extracting data: $e');
    }
  }

  Future<void> _generateExcelFile() async {
    if (_extractedValues == null || _extractedValues!.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final valuesToExport = _shiftValue == null
          ? _extractedValues!
          : _extractedValues!.map((v) {
              return HardnessValue(
                sequenceNumber: v.sequenceNumber,
                hardnessValue: v.hardnessValue + _shiftValue!,
                pageNumber: v.pageNumber,
                rawText: v.rawText,
              );
            }).toList();

      final baseFileName = _selectedPdfFiles.isNotEmpty ? _selectedPdfFiles.first.name : 'Combined';
      final excelFile = await _pdfToExcelService.convertToExcel(valuesToExport, baseFileName);
      
      setState(() {
        _generatedExcelFile = excelFile;
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Excel file generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorDialog('Error generating Excel file: $e');
    }
  }

  Future<void> _showShiftDialog() async {
    final shiftController = TextEditingController();
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply a Shift'),
        content: TextField(
          controller: shiftController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Shift Value',
            hintText: 'Enter a number to add to each value',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(shiftController.text);
              if (value != null) {
                Navigator.of(context).pop(value);
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _shiftValue = result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Shift of $_shiftValue applied.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _shareExcelFile() async {
    if (_generatedExcelFile == null) return;

    try {
      await _pdfToExcelService.shareExcelFile(_generatedExcelFile!);
    } catch (e) {
      _showErrorDialog('Error sharing file: $e');
    }
  }

  Future<void> _copyDataForTemplate() async {
    final valuesToCopy = _shiftValue == null
        ? _extractedValues
        : _extractedValues?.map((v) {
            return HardnessValue(
              sequenceNumber: v.sequenceNumber,
              hardnessValue: v.hardnessValue + _shiftValue!,
              pageNumber: v.pageNumber,
              rawText: v.rawText,
            );
          }).toList();

    if (valuesToCopy == null || valuesToCopy.isEmpty) return;

    try {
      final buffer = StringBuffer();
      
      // First 84 values in two-column format
      int twoColumnLimit = valuesToCopy.length > 84 ? 84 : valuesToCopy.length;
      List<String> leftColumn = [];
      List<String> rightColumn = [];

      for (int i = 0; i < twoColumnLimit; i++) {
        final value = valuesToCopy[i];
        final hardnessStr = value.hardnessValue.toStringAsFixed(1);
        if (i < 42) {
          leftColumn.add('${value.sequenceNumber}\t${value.sequenceNumber}\t$hardnessStr\t$hardnessStr\t---\t---');
        } else {
          rightColumn.add('${value.sequenceNumber}\t${value.sequenceNumber}\t$hardnessStr\t$hardnessStr\t---\t---');
        }
      }

      for (int i = 0; i < 42; i++) {
        String row = leftColumn.length > i ? leftColumn[i] : '\t\t\t\t\t';
        row += '\t'; // Separator between sections
        row += rightColumn.length > i ? rightColumn[i] : '';
        buffer.writeln(row);
      }

      // Rest of the values in single-column format
      if (valuesToCopy.length > 84) {
        for (int i = 84; i < valuesToCopy.length; i++) {
          final value = valuesToCopy[i];
          buffer.writeln('${value.sequenceNumber}\t\t${value.hardnessValue.toStringAsFixed(1)}');
        }
      }

      await Clipboard.setData(ClipboardData(text: buffer.toString()));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data copied to clipboard!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      _showErrorDialog('Error copying data: $e');
    }
  }

  void _resetConverter() {
    setState(() {
      _selectedPdfFiles.clear();
      _extractedValues = null;
      _generatedExcelFile = null;
      _statusMessage = '';
      _isProcessing = false;
      _shiftValue = null;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
