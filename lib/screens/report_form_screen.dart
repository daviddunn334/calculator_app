import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../models/report.dart';
import '../services/report_service.dart';
import 'report_preview_screen.dart';

class ReportFormScreen extends StatefulWidget {
  final Report? report;
  final String? reportId;
  const ReportFormScreen({super.key, this.report, this.reportId});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _technicianNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _pipeDiameterController = TextEditingController();
  final _wallThicknessController = TextEditingController();
  final _findingsController = TextEditingController();
  final _correctiveActionsController = TextEditingController();
  final _additionalNotesController = TextEditingController();
  
  DateTime _inspectionDate = DateTime.now();
  String _selectedMethod = 'MT';
  bool _isSubmitting = false;

  final List<String> _inspectionMethods = [
    'MT',
    'UT',
    'PT',
    'PAUT',
    'Visual',
  ];

  final ReportService _reportService = ReportService();

  @override
  void initState() {
    super.initState();
    if (widget.report != null) {
      final r = widget.report!;
      _technicianNameController.text = r.technicianName;
      _locationController.text = r.location;
      _pipeDiameterController.text = r.pipeDiameter;
      _wallThicknessController.text = r.wallThickness;
      _findingsController.text = r.findings;
      _correctiveActionsController.text = r.correctiveActions;
      _additionalNotesController.text = r.additionalNotes ?? '';
      _inspectionDate = r.inspectionDate;
      _selectedMethod = r.method;
    }
  }

  @override
  void dispose() {
    _technicianNameController.dispose();
    _locationController.dispose();
    _pipeDiameterController.dispose();
    _wallThicknessController.dispose();
    _findingsController.dispose();
    _correctiveActionsController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _inspectionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _inspectionDate) {
      setState(() {
        _inspectionDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final report = Report(
        id: widget.reportId ?? '',
        userId: user.uid,
        technicianName: _technicianNameController.text,
        inspectionDate: _inspectionDate,
        location: _locationController.text,
        pipeDiameter: _pipeDiameterController.text,
        wallThickness: _wallThicknessController.text,
        method: _selectedMethod,
        findings: _findingsController.text,
        correctiveActions: _correctiveActionsController.text,
        additionalNotes: _additionalNotesController.text,
        createdAt: widget.report?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.reportId != null) {
        // Edit mode: update existing report
        await _reportService.updateReport(widget.reportId!, report);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report updated successfully')),
          );
          Navigator.pop(context); // Go back to the reports list
        }
      } else {
        // Create mode: add new report
        await _reportService.addReport(report);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report saved successfully')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportPreviewScreen(
                technicianName: report.technicianName,
                inspectionDate: report.inspectionDate,
                location: report.location,
                pipeDiameter: report.pipeDiameter,
                wallThickness: report.wallThickness,
                method: report.method,
                findings: report.findings,
                correctiveActions: report.correctiveActions,
                additionalNotes: report.additionalNotes,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving report: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.report != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Report' : 'NDT Report Form'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                      // Technician Name
                      TextFormField(
                        controller: _technicianNameController,
                        decoration: const InputDecoration(
                          labelText: 'Technician Name',
                          hintText: 'Enter your name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),
                      // Inspection Date
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Inspection Date',
                            ),
                            controller: TextEditingController(
                              text: '${_inspectionDate.year}-${_inspectionDate.month.toString().padLeft(2, '0')}-${_inspectionDate.day.toString().padLeft(2, '0')}',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),
                      // Location
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          hintText: 'Enter location',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),
                      // Pipe Diameter
                      TextFormField(
                        controller: _pipeDiameterController,
                        decoration: const InputDecoration(
                          labelText: 'Pipe Diameter',
                          hintText: 'e.g. 12 in',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the pipe diameter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),
                      // Wall Thickness
                      TextFormField(
                        controller: _wallThicknessController,
                        decoration: const InputDecoration(
                          labelText: 'Wall Thickness',
                          hintText: 'e.g. 0.375 in',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the wall thickness';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),
                      // Inspection Method
                      DropdownButtonFormField<String>(
                        value: _selectedMethod,
                        decoration: const InputDecoration(
                          labelText: 'Inspection Method',
                        ),
                        items: _inspectionMethods.map((method) {
                          return DropdownMenuItem<String>(
                            value: method,
                            child: Text(method),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedMethod = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),
                      // Findings
                      TextFormField(
                        controller: _findingsController,
                        decoration: const InputDecoration(
                          labelText: 'Findings',
                          hintText: 'Describe findings',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please describe findings';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),
                      // Corrective Actions
                      TextFormField(
                        controller: _correctiveActionsController,
                        decoration: const InputDecoration(
                          labelText: 'Corrective Actions Taken',
                          hintText: 'Describe any corrective actions taken',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please describe corrective actions';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),
                      // Additional Notes
                      TextFormField(
                        controller: _additionalNotesController,
                        decoration: const InputDecoration(
                          labelText: 'Additional Notes',
                          hintText: 'Any additional information or notes',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        child: _isSubmitting
                            ? const CircularProgressIndicator()
                            : Text(isEdit ? 'Update Report' : 'Save Report'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 