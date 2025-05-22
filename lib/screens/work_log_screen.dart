import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/work_log_entry.dart';
import '../services/work_log_service.dart';

class WorkLogScreen extends StatefulWidget {
  const WorkLogScreen({super.key});

  @override
  State<WorkLogScreen> createState() => _WorkLogScreenState();
}

class _WorkLogScreenState extends State<WorkLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _workLogService = WorkLogService();
  final _digNumberController = TextEditingController();
  final _locationController = TextEditingController();
  final _crewController = TextEditingController();
  final _hoursController = TextEditingController();
  final _notesController = TextEditingController();
  List<WorkLogEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    await _workLogService.init();
    _loadEntries();
  }

  void _loadEntries() {
    setState(() {
      _entries = _workLogService.getAllEntries();
    });
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      final entry = WorkLogEntry(
        digNumber: _digNumberController.text,
        location: _locationController.text,
        crew: _crewController.text,
        hoursWorked: double.parse(_hoursController.text),
        notes: _notesController.text,
      );

      await _workLogService.addEntry(entry);
      _loadEntries();
      _clearForm();
    }
  }

  void _clearForm() {
    _digNumberController.clear();
    _locationController.clear();
    _crewController.clear();
    _hoursController.clear();
    _notesController.clear();
  }

  Future<void> _exportToCsv() async {
    final csvData = await _workLogService.exportToCsv();
    final fileName = 'DailyLog_${DateTime.now().toString().split(' ')[0]}.csv';
    await Share.share(csvData, subject: fileName);
  }

  Future<void> _exportToPdf() async {
    final pdfData = await _workLogService.exportToPdf();
    final fileName = 'DailyLog_${DateTime.now().toString().split(' ')[0]}.pdf';
    await Share.share(pdfData, subject: fileName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Work Log'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _digNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Dig #',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a dig number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _crewController,
                      decoration: const InputDecoration(
                        labelText: 'Crew',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter crew information';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _hoursController,
                      decoration: const InputDecoration(
                        labelText: 'Hours Worked',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter hours worked';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveEntry,
                      child: const Text('Save Entry'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _exportToCsv,
                          child: const Text('Export to CSV'),
                        ),
                        ElevatedButton(
                          onPressed: _exportToPdf,
                          child: const Text('Export to PDF'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                return Card(
                  child: ListTile(
                    title: Text('Dig #${entry.digNumber} - ${entry.location}'),
                    subtitle: Text(
                      'Crew: ${entry.crew}\nHours: ${entry.hoursWorked}\n${entry.timestamp.toString().split('.')[0]}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await _workLogService.deleteEntry(index);
                        _loadEntries();
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _digNumberController.dispose();
    _locationController.dispose();
    _crewController.dispose();
    _hoursController.dispose();
    _notesController.dispose();
    super.dispose();
  }
} 