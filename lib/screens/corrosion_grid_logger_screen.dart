import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as excel_pkg;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';

class CorrosionGridLoggerScreen extends StatefulWidget {
  const CorrosionGridLoggerScreen({super.key});

  @override
  State<CorrosionGridLoggerScreen> createState() => _CorrosionGridLoggerScreenState();
}

class _CorrosionGridLoggerScreenState extends State<CorrosionGridLoggerScreen> {
  final List<Map<String, dynamic>> _readings = [
    {'pipeIncrement': 0, 'pitDepth': 0},
  ];
  final TextEditingController _pitDepthController = TextEditingController();
  final TextEditingController _filenameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set default filename with current date
    _filenameController.text = 'CorrosionGrid_${DateTime.now().toString().split(' ')[0]}';
  }

  @override
  void dispose() {
    _pitDepthController.dispose();
    _filenameController.dispose();
    super.dispose();
  }

  void _addReading() {
    if (_pitDepthController.text.isEmpty) return;

    setState(() {
      _readings.add({
        'pipeIncrement': _readings.length,
        'pitDepth': double.parse(_pitDepthController.text),
      });
      _pitDepthController.clear();
    });
  }

  void _deleteLastReading() {
    if (_readings.length > 1) {
      setState(() {
        _readings.removeLast();
      });
    }
  }

  Future<void> _showExportDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export to Excel'),
        content: TextField(
          controller: _filenameController,
          decoration: const InputDecoration(
            labelText: 'File Name',
            hintText: 'Enter file name (without extension)',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _exportToExcel();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToExcel() async {
    try {
      var excel = excel_pkg.Excel.createExcel();
      
      // Delete the default Sheet1
      excel.delete('Sheet1');
      
      // Create and use only the Corrosion Grid sheet
      excel_pkg.Sheet sheetObject = excel['Corrosion Grid'];

      // Add headers
      sheetObject.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = 'PipeIncrement';
      sheetObject.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = 'PitDepth';

      // Add data
      for (var i = 0; i < _readings.length; i++) {
        sheetObject.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = _readings[i]['pipeIncrement'];
        sheetObject.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value = _readings[i]['pitDepth'];
      }

      // Add final row with PitDepth: 0
      final lastIncrement = _readings.length;
      sheetObject.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: _readings.length + 1)).value = lastIncrement;
      sheetObject.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: _readings.length + 1)).value = 0;

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final String filePath = '${directory.path}/${_filenameController.text}.xlsx';

      // Save the file
      final File file = File(filePath);
      await file.writeAsBytes(excel.encode()!);

      // Share the file
      await Share.shareXFiles([XFile(filePath)], text: 'Corrosion Grid Data');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Excel file exported successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header with back button and title
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                          color: AppTheme.textPrimary,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Corrosion Grid Logger',
                                style: AppTheme.titleLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Log grid data for RSTRENG export',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Data Table
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.divider),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: SingleChildScrollView(
                        child: DataTable(
                          columnSpacing: 40,
                          headingRowColor: MaterialStateProperty.all(
                            AppTheme.primaryBlue.withOpacity(0.1),
                          ),
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Pipe Increment',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Pit Depth (mils)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: _readings.map((reading) {
                            return DataRow(
                              cells: [
                                DataCell(Text(reading['pipeIncrement'].toString())),
                                DataCell(Text(reading['pitDepth'].toString())),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Input Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Add New Reading',
                            style: AppTheme.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _pitDepthController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Pit Depth (mils)',
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: _addReading,
                                icon: const Icon(Icons.add),
                                label: const Text('Add'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryBlue,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _deleteLastReading,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Delete Last Row'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showExportDialog,
                            icon: const Icon(Icons.file_download),
                            label: const Text('Export Excel'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Info Section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Export creates an Excel file ready for RSTRENG analysis',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
