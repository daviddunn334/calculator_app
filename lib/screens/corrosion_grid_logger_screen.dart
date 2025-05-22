import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
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
    var excel = Excel.createExcel();
    
    // Delete the default Sheet1
    excel.delete('Sheet1');
    
    // Create and use only the Corrosion Grid sheet
    Sheet sheetObject = excel['Corrosion Grid'];

    // Add headers
    sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = 'PipeIncrement';
    sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = 'PitDepth';

    // Add data
    for (var i = 0; i < _readings.length; i++) {
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = _readings[i]['pipeIncrement'];
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value = _readings[i]['pitDepth'];
    }

    // Add final row with PitDepth: 0
    final lastIncrement = _readings.length;
    sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: _readings.length + 1)).value = lastIncrement;
    sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: _readings.length + 1)).value = 0;

    // Get temporary directory
    final directory = await getTemporaryDirectory();
    final String filePath = '${directory.path}/${_filenameController.text}.xlsx';

    // Save the file
    final File file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    // Share the file
    await Share.shareXFiles([XFile(filePath)], text: 'Corrosion Grid Data');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Corrosion Grid Logger'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          children: [
            // Action Buttons at the top
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _deleteLastReading,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Delete Last Row'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showExportDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Export to Excel'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Data Table in the middle
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  side: const BorderSide(color: AppTheme.divider),
                ),
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Pipe Increment')),
                      DataColumn(label: Text('Pit Depth (mils)')),
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
            ),
            const SizedBox(height: 16),

            // Input Section at the bottom (closer to keyboard)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                side: const BorderSide(color: AppTheme.divider),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _pitDepthController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Pit Depth (mils)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _addReading,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                      child: const Text('Add'),
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

  @override
  void dispose() {
    _pitDepthController.dispose();
    _filenameController.dispose();
    super.dispose();
  }
} 