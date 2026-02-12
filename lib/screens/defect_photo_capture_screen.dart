import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/defect_identifier_service.dart';
import '../services/analytics_service.dart';

/// Screen for capturing or selecting a defect photo
class DefectPhotoCaptureScreen extends StatefulWidget {
  const DefectPhotoCaptureScreen({Key? key}) : super(key: key);

  @override
  State<DefectPhotoCaptureScreen> createState() => _DefectPhotoCaptureScreenState();
}

class _DefectPhotoCaptureScreenState extends State<DefectPhotoCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  final DefectIdentifierService _identifierService = DefectIdentifierService();
  final AnalyticsService _analyticsService = AnalyticsService();
  
  File? _selectedImage;
  XFile? _selectedXFile;
  bool _isProcessing = false;

  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (photo != null) {
        setState(() {
          _selectedXFile = photo;
          if (!kIsWeb) {
            _selectedImage = File(photo.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        setState(() {
          _selectedXFile = image;
          if (!kIsWeb) {
            _selectedImage = File(image.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _identifyDefect() async {
    if (_selectedImage == null && _selectedXFile == null) return;

    setState(() => _isProcessing = true);

    try {
      // Log analytics
      await _analyticsService.logDefectPhotoIdentificationStarted();

      // Upload photo and create Firestore document (returns immediately)
      final docId = await _identifierService.processDefectPhoto(
        kIsWeb ? _selectedXFile! : _selectedImage!,
      );

      print('Photo identification created: $docId');

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Photo uploaded! Check Photo History for results in 5-10 seconds.',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );

        // Navigate back to landing screen
        Navigator.pop(context);
      }
    } catch (e) {
      // Log error
      await _analyticsService.logDefectPhotoIdentificationFailed(e.toString());

      if (mounted) {
        setState(() => _isProcessing = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading photo: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Capture Defect Photo'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isProcessing
          ? _buildProcessingView()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Photo preview or placeholder
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      border: Border.all(
                        color: AppTheme.divider,
                        width: 2,
                      ),
                    ),
                    child: (_selectedImage != null || _selectedXFile != null)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                            child: kIsWeb
                                ? Image.network(
                                    _selectedXFile!.path,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No photo selected',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  const SizedBox(height: 24),

                  // Camera button
                  ElevatedButton.icon(
                    onPressed: _takePicture,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Gallery button
                  OutlinedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Upload from Gallery'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: AppTheme.primaryBlue,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                    ),
                  ),

                  if (_selectedImage != null || _selectedXFile != null) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Identify button
                    ElevatedButton.icon(
                      onPressed: _identifyDefect,
                      icon: const Icon(Icons.psychology),
                      label: const Text('Identify Defect'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryNavy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Retake button
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                          _selectedXFile = null;
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retake Photo'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Tips section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tips for Best Results',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildTip('Good lighting (natural light is best)'),
                        _buildTip('Close-up view of the defect'),
                        _buildTip('Clear focus on the defect area'),
                        _buildTip('Include some context around the defect'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Uploading Photo...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your photo is being uploaded for AI analysis',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This will only take a few seconds...',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.blue.shade700,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
