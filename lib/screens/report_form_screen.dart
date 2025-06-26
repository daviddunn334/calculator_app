import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../models/report.dart';
import '../services/report_service.dart';
import '../services/enhanced_pdf_service.dart';
import '../services/image_service.dart';
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
  bool _isGeneratingPdf = false;
  List<String> _imageUrls = [];
  bool _isUploadingImages = false;

  final List<String> _inspectionMethods = [
    'MT',
    'UT',
    'PT',
    'PAUT',
    'Visual',
  ];

  final ReportService _reportService = ReportService();
  final EnhancedPdfService _pdfService = EnhancedPdfService();
  final ImageService _imageService = ImageService();

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
      _imageUrls = List.from(r.imageUrls);
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

  /// Add photos to the report
  Future<void> _addPhotos() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImagesFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Pick multiple images from gallery
  Future<void> _pickImagesFromGallery() async {
    try {
      final List<XFile>? images = await _imageService.pickMultipleImages();
      if (images != null && images.isNotEmpty) {
        await _uploadImages(images);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: $e')),
        );
      }
    }
  }

  /// Take a photo with camera
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _imageService.takePhoto();
      if (photo != null) {
        await _uploadImages([photo]);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e')),
        );
      }
    }
  }

  /// Upload images to Firebase Storage
  Future<void> _uploadImages(List<XFile> images) async {
    setState(() {
      _isUploadingImages = true;
    });

    try {
      final reportId = widget.reportId ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';
      
      for (final image in images) {
        final imageUrl = await _imageService.uploadReportImage(image, reportId);
        if (imageUrl != null) {
          setState(() {
            _imageUrls.add(imageUrl);
          });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${images.length} image(s) uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading images: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImages = false;
        });
      }
    }
  }

  /// Remove an image from the report
  Future<void> _removeImage(int index) async {
    final imageUrl = _imageUrls[index];
    
    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Image'),
          content: const Text('Are you sure you want to remove this image?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _imageUrls.removeAt(index);
      });

      // Delete from Firebase Storage
      try {
        await _imageService.deleteImage(imageUrl);
      } catch (e) {
        print('Error deleting image from storage: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image removed successfully'),
            backgroundColor: Colors.orange,
          ),
        );
      }
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
        imageUrls: _imageUrls,
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
        final reportId = await _reportService.addReport(report);
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
                reportId: reportId,
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

  /// Generate and download a professional PDF report
  Future<void> _generateAndSharePdf() async {
    if (widget.report == null || widget.reportId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please save the report first')),
      );
      return;
    }

    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final pdfBytes = await _pdfService.generateProfessionalReportPdf(widget.report!);
      if (mounted) {
        final filename = 'Integrity_Specialists_Report_${widget.report!.location}_${DateTime.now().millisecondsSinceEpoch}.pdf';
        await _pdfService.downloadPdfWeb(pdfBytes, filename);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Professional PDF report generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
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
    final isEdit = widget.report != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Report' : 'NDT Report Form'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Generate Final Report',
              onPressed: _isGeneratingPdf ? null : _generateAndSharePdf,
            ),
        ],
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
                      
                      // Photos Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Photos (${_imageUrls.length})',
                            style: AppTheme.titleMedium,
                          ),
                          ElevatedButton.icon(
                            onPressed: _isUploadingImages ? null : _addPhotos,
                            icon: _isUploadingImages 
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.add_a_photo),
                            label: Text(_isUploadingImages ? 'Uploading...' : 'Add Photos'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),
                      
                      // Photo Grid
                      if (_imageUrls.isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _imageUrls.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _imageUrls[index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.error),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      
                      if (_imageUrls.isEmpty)
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.photo_library, color: Colors.grey, size: 32),
                                SizedBox(height: 8),
                                Text(
                                  'No photos added yet',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: AppTheme.paddingLarge),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitForm,
                              child: _isSubmitting
                                  ? const CircularProgressIndicator()
                                  : Text(isEdit ? 'Update Report' : 'Save Report'),
                            ),
                          ),
                          if (isEdit) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.picture_as_pdf),
                                label: const Text('Final Report'),
                                onPressed: _isGeneratingPdf ? null : _generateAndSharePdf,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ],
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
