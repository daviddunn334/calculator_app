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

  // DIG Information controllers
  final _digNumberController = TextEditingController();
  final _gformNumberController = TextEditingController();
  final _clientWoNumberController = TextEditingController();
  final _integritySpecialistsNumberController = TextEditingController();
  final _rfsNumberController = TextEditingController();
  final _reasonForDigController = TextEditingController();
  final _stateController = TextEditingController();
  final _countyController = TextEditingController();
  final _districtController = TextEditingController();
  final _sectionController = TextEditingController();
  final _rangeController = TextEditingController();
  final _twsController = TextEditingController();
  final _mpController = TextEditingController();
  final _projectNameController = TextEditingController();
  final _lineNumberController = TextEditingController();
  final _digSiteController = TextEditingController();
  final _productFlowController = TextEditingController();
  final _commentsController = TextEditingController();

  // ILI Tool Information controllers
  final _iliToolProviderController = TextEditingController();
  final _toolsRanController = TextEditingController();
  final _pigLauncherController = TextEditingController();
  final _pigReceiverController = TextEditingController();
  final _toolFlowController = TextEditingController();
  final _totalMilesController = TextEditingController();
  final _iliCommentsController = TextEditingController();

  // Pipe Static Data controllers
  final _nominalWallThicknessController = TextEditingController();
  final _pipeStaticDiameterController = TextEditingController();
  final _longseamWeldTypeController = TextEditingController();
  final _girthWeldTypeController = TextEditingController();
  final _smysController = TextEditingController();
  final _maopController = TextEditingController();
  final _safetyFactorController = TextEditingController();
  final _operatingPsiController = TextEditingController();
  final _pipeManufacturerController = TextEditingController();
  final _productController = TextEditingController();
  final _pipeStaticCommentsController = TextEditingController();

  // Pipe Evaluation controllers
  final _cpSystemController = TextEditingController();
  final _soilResistivityController = TextEditingController();
  final _testTypeController = TextEditingController();
  final _coatingTypeController = TextEditingController();
  final _percentBondedController = TextEditingController();
  final _percentDisbondedController = TextEditingController();
  final _percentBarePipeController = TextEditingController();
  final _locationOfDepositsController = TextEditingController();
  final _descriptionOfDepositsController = TextEditingController();
  final _pipeToSoilDCController = TextEditingController();
  final _pipeToSoilACController = TextEditingController();
  final _phOnPipeController = TextEditingController();
  final _phAtAnomalyController = TextEditingController();
  final _phOfSoilController = TextEditingController();
  final _degreeOfBendController = TextEditingController();
  final _absEsOfBendController = TextEditingController();
  final _pipeSlopeController = TextEditingController();
  final _pipeEvaluationCommentsController = TextEditingController();

  // Environment controllers
  final _terrainAtDigSiteController = TextEditingController();
  final _soilTypeAtPipeLevelController = TextEditingController();
  final _soilTypeAtSixOClockController = TextEditingController();
  final _depthOfCoverController = TextEditingController();
  final _organicDepthController = TextEditingController();
  final _usageController = TextEditingController();
  final _pipeTemperatureController = TextEditingController();
  final _ambientTemperatureController = TextEditingController();
  final _weatherConditionsController = TextEditingController();
  final _environmentCommentsController = TextEditingController();

  // Joint and Girth Weld Details controllers
  final _startOfDigAbsEsController = TextEditingController();
  final _endOfDigAbsEsController = TextEditingController();
  final _lengthOfPipeExposedController = TextEditingController();
  final _lengthOfPipeAssessedController = TextEditingController();

  // Defect Evaluation controllers
  final _typeOfDefectController = TextEditingController();
  final _startOfWetMpiController = TextEditingController();
  final _endOfWetMpiController = TextEditingController();
  final _lengthOfWetMpiController = TextEditingController();
  final _defectEvaluationCommentsController = TextEditingController();

  // Summary controllers
  final _startOfRecoatAbsEsController = TextEditingController();
  final _endOfRecoatAbsEsController = TextEditingController();
  final _totalLengthOfRecoatController = TextEditingController();
  final _recoatManufacturerController = TextEditingController();
  final _recoatProductController = TextEditingController();
  final _recoatTypeController = TextEditingController();

  DateTime _inspectionDate = DateTime.now();
  DateTime? _excavationDate;
  DateTime? _assessmentDate;
  DateTime? _reportDate;
  DateTime? _backfillDate;
  DateTime? _toolRunDate;
  DateTime? _installDate;
  bool? _liveLine;

  // Pipe Evaluation boolean and dropdown variables
  String? _overallCondition;
  String? _conditionAtAnomaly;
  bool? _evidenceOfSoilBodyStress;
  bool? _deposits;
  bool? _pipeBend;

  // Environment dropdown variable
  String? _drainage;

  // Defect Evaluation boolean variables
  bool? _defectNoted;
  bool? _burstPressureAnalysis;
  bool? _methodB31G;
  bool? _methodB31GModified;
  bool? _methodKapa;
  bool? _methodRstreng;
  bool? _wetMpiPerformed;

  String _selectedMethod = 'MT';
  bool _isSubmitting = false;
  bool _isGeneratingPdf = false;
  List<String> _imageUrls = [];
  List<ReportImage> _reportImages = [];
  bool _isUploadingImages = false;
  
  // Quick Test Mode
  bool _isQuickTestMode = false;

  // Photo type definitions
  final List<Map<String, dynamic>> _photoTypes = [
    {
      'type': 'upstream',
      'label': 'Take Upstream Photo',
      'icon': Icons.arrow_upward,
      'color': Colors.blue,
    },
    {
      'type': 'downstream',
      'label': 'Take Downstream Photo',
      'icon': Icons.arrow_downward,
      'color': Colors.green,
    },
    {
      'type': 'soil_strate',
      'label': 'Take Soil Strate Photo',
      'icon': Icons.landscape,
      'color': Colors.brown,
    },
    {
      'type': 'coating_overview',
      'label': 'Take Coating Overview Photo',
      'icon': Icons.format_paint,
      'color': Colors.orange,
    },
    {
      'type': 'longseam',
      'label': 'Take Longseam Photo',
      'icon': Icons.linear_scale,
      'color': Colors.purple,
    },
    {
      'type': 'deposits',
      'label': 'Take Deposits Photo',
      'icon': Icons.layers,
      'color': Colors.indigo,
    },
  ];

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
      _reportImages = List.from(r.images);

      // Initialize DIG Information fields
      _digNumberController.text = r.digNumber ?? '';
      _gformNumberController.text = r.gformNumber ?? '';
      _clientWoNumberController.text = r.clientWoNumber ?? '';
      _integritySpecialistsNumberController.text =
          r.integritySpecialistsNumber ?? '';
      _rfsNumberController.text = r.rfsNumber ?? '';
      _reasonForDigController.text = r.reasonForDig ?? '';
      _stateController.text = r.state ?? '';
      _countyController.text = r.county ?? '';
      _districtController.text = r.district ?? '';
      _sectionController.text = r.section ?? '';
      _rangeController.text = r.range ?? '';
      _twsController.text = r.tws ?? '';
      _mpController.text = r.mp ?? '';
      _projectNameController.text = r.projectName ?? '';
      _lineNumberController.text = r.lineNumber ?? '';
      _digSiteController.text = r.digSite ?? '';
      _productFlowController.text = r.productFlow ?? '';
      _commentsController.text = r.comments ?? '';
      _excavationDate = r.excavationDate;
      _assessmentDate = r.assessmentDate;
      _reportDate = r.reportDate;
      _backfillDate = r.backfillDate;

      // Initialize ILI Tool Information fields
      _iliToolProviderController.text = r.iliToolProvider ?? '';
      _toolsRanController.text = r.toolsRan ?? '';
      _pigLauncherController.text = r.pigLauncher ?? '';
      _pigReceiverController.text = r.pigReceiver ?? '';
      _toolFlowController.text = r.toolFlow ?? '';
      _totalMilesController.text = r.totalMiles ?? '';
      _iliCommentsController.text = r.iliComments ?? '';
      _toolRunDate = r.toolRunDate;
      _liveLine = r.liveLine;

      // Initialize Pipe Static Data fields
      _nominalWallThicknessController.text = r.nominalWallThickness ?? '';
      _pipeStaticDiameterController.text = r.pipeStaticDiameter ?? '';
      _longseamWeldTypeController.text = r.longseamWeldType ?? '';
      _girthWeldTypeController.text = r.girthWeldType ?? '';
      _smysController.text = r.smys ?? '';
      _maopController.text = r.maop ?? '';
      _safetyFactorController.text = r.safetyFactor ?? '';
      _operatingPsiController.text = r.operatingPsi ?? '';
      _pipeManufacturerController.text = r.pipeManufacturer ?? '';
      _productController.text = r.product ?? '';
      _pipeStaticCommentsController.text = r.pipeStaticComments ?? '';
      _installDate = r.installDate;

      // Initialize Pipe Evaluation fields
      _cpSystemController.text = r.cpSystem ?? '';
      _soilResistivityController.text = r.soilResistivity ?? '';
      _testTypeController.text = r.testType ?? '';
      _coatingTypeController.text = r.coatingType ?? '';
      _percentBondedController.text = r.percentBonded ?? '';
      _percentDisbondedController.text = r.percentDisbonded ?? '';
      _percentBarePipeController.text = r.percentBarePipe ?? '';
      _locationOfDepositsController.text = r.locationOfDeposits ?? '';
      _descriptionOfDepositsController.text = r.descriptionOfDeposits ?? '';
      _pipeToSoilDCController.text = r.pipeToSoilDC ?? '';
      _pipeToSoilACController.text = r.pipeToSoilAC ?? '';
      _phOnPipeController.text = r.phOnPipe ?? '';
      _phAtAnomalyController.text = r.phAtAnomaly ?? '';
      _phOfSoilController.text = r.phOfSoil ?? '';
      _degreeOfBendController.text = r.degreeOfBend ?? '';
      _absEsOfBendController.text = r.absEsOfBend ?? '';
      _pipeSlopeController.text = r.pipeSlope ?? '';
      _pipeEvaluationCommentsController.text = r.pipeEvaluationComments ?? '';
      _overallCondition = r.overallCondition;
      _conditionAtAnomaly = r.conditionAtAnomaly;
      _evidenceOfSoilBodyStress = r.evidenceOfSoilBodyStress;
      _deposits = r.deposits;
      _pipeBend = r.pipeBend;

      // Initialize Environment fields
      _terrainAtDigSiteController.text = r.terrainAtDigSite ?? '';
      _soilTypeAtPipeLevelController.text = r.soilTypeAtPipeLevel ?? '';
      _soilTypeAtSixOClockController.text = r.soilTypeAtSixOClock ?? '';
      _depthOfCoverController.text = r.depthOfCover ?? '';
      _organicDepthController.text = r.organicDepth ?? '';
      _usageController.text = r.usage ?? '';
      _pipeTemperatureController.text = r.pipeTemperature ?? '';
      _ambientTemperatureController.text = r.ambientTemperature ?? '';
      _weatherConditionsController.text = r.weatherConditions ?? '';
      _environmentCommentsController.text = r.environmentComments ?? '';
      _drainage = r.drainage;

      // Initialize Joint and Girth Weld Details fields
      _startOfDigAbsEsController.text = r.startOfDigAbsEs ?? '';
      _endOfDigAbsEsController.text = r.endOfDigAbsEs ?? '';
      _lengthOfPipeExposedController.text = r.lengthOfPipeExposed ?? '';
      _lengthOfPipeAssessedController.text = r.lengthOfPipeAssessed ?? '';

      // Initialize Defect Evaluation fields
      _defectNoted = r.defectNoted;
      _typeOfDefectController.text = r.typeOfDefect ?? '';
      _burstPressureAnalysis = r.burstPressureAnalysis;
      _methodB31G = r.methodB31G;
      _methodB31GModified = r.methodB31GModified;
      _methodKapa = r.methodKapa;
      _methodRstreng = r.methodRstreng;
      _wetMpiPerformed = r.wetMpiPerformed;
      _startOfWetMpiController.text = r.startOfWetMpi ?? '';
      _endOfWetMpiController.text = r.endOfWetMpi ?? '';
      _lengthOfWetMpiController.text = r.lengthOfWetMpi ?? '';
      _defectEvaluationCommentsController.text =
          r.defectEvaluationComments ?? '';

      // Initialize Summary fields
      _startOfRecoatAbsEsController.text = r.startOfRecoatAbsEs ?? '';
      _endOfRecoatAbsEsController.text = r.endOfRecoatAbsEs ?? '';
      _totalLengthOfRecoatController.text = r.totalLengthOfRecoat ?? '';
      _recoatManufacturerController.text = r.recoatManufacturer ?? '';
      _recoatProductController.text = r.recoatProduct ?? '';
      _recoatTypeController.text = r.recoatType ?? '';
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

    // Dispose DIG Information controllers
    _digNumberController.dispose();
    _gformNumberController.dispose();
    _clientWoNumberController.dispose();
    _integritySpecialistsNumberController.dispose();
    _rfsNumberController.dispose();
    _reasonForDigController.dispose();
    _stateController.dispose();
    _countyController.dispose();
    _districtController.dispose();
    _sectionController.dispose();
    _rangeController.dispose();
    _twsController.dispose();
    _mpController.dispose();
    _projectNameController.dispose();
    _lineNumberController.dispose();
    _digSiteController.dispose();
    _productFlowController.dispose();
    _commentsController.dispose();

    // Dispose ILI Tool Information controllers
    _iliToolProviderController.dispose();
    _toolsRanController.dispose();
    _pigLauncherController.dispose();
    _pigReceiverController.dispose();
    _toolFlowController.dispose();
    _totalMilesController.dispose();
    _iliCommentsController.dispose();

    // Dispose Pipe Static Data controllers
    _nominalWallThicknessController.dispose();
    _pipeStaticDiameterController.dispose();
    _longseamWeldTypeController.dispose();
    _girthWeldTypeController.dispose();
    _smysController.dispose();
    _maopController.dispose();
    _safetyFactorController.dispose();
    _operatingPsiController.dispose();
    _pipeManufacturerController.dispose();
    _productController.dispose();
    _pipeStaticCommentsController.dispose();

    // Dispose Pipe Evaluation controllers
    _cpSystemController.dispose();
    _soilResistivityController.dispose();
    _testTypeController.dispose();
    _coatingTypeController.dispose();
    _percentBondedController.dispose();
    _percentDisbondedController.dispose();
    _percentBarePipeController.dispose();
    _locationOfDepositsController.dispose();
    _descriptionOfDepositsController.dispose();
    _pipeToSoilDCController.dispose();
    _pipeToSoilACController.dispose();
    _phOnPipeController.dispose();
    _phAtAnomalyController.dispose();
    _phOfSoilController.dispose();
    _degreeOfBendController.dispose();
    _absEsOfBendController.dispose();
    _pipeSlopeController.dispose();
    _pipeEvaluationCommentsController.dispose();

    // Dispose Environment controllers
    _terrainAtDigSiteController.dispose();
    _soilTypeAtPipeLevelController.dispose();
    _soilTypeAtSixOClockController.dispose();
    _depthOfCoverController.dispose();
    _organicDepthController.dispose();
    _usageController.dispose();
    _pipeTemperatureController.dispose();
    _ambientTemperatureController.dispose();
    _weatherConditionsController.dispose();
    _environmentCommentsController.dispose();

    // Dispose Joint and Girth Weld Details controllers
    _startOfDigAbsEsController.dispose();
    _endOfDigAbsEsController.dispose();
    _lengthOfPipeExposedController.dispose();
    _lengthOfPipeAssessedController.dispose();

    // Dispose Defect Evaluation controllers
    _typeOfDefectController.dispose();
    _startOfWetMpiController.dispose();
    _endOfWetMpiController.dispose();
    _lengthOfWetMpiController.dispose();
    _defectEvaluationCommentsController.dispose();

    // Dispose Summary controllers
    _startOfRecoatAbsEsController.dispose();
    _endOfRecoatAbsEsController.dispose();
    _totalLengthOfRecoatController.dispose();
    _recoatManufacturerController.dispose();
    _recoatProductController.dispose();
    _recoatTypeController.dispose();

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

  /// Take a photo for a specific type
  Future<void> _takePhotoForType(String photoType, String label) async {
    setState(() {
      _isUploadingImages = true;
    });

    try {
      final XFile? photo = await _imageService.takePhotoForType(photoType);
      if (photo != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('User not authenticated');
        }

        final imageUrl = await _imageService.uploadReportImageWithType(
            photo, user.uid, photoType);
        if (imageUrl != null) {
          final reportImage = ReportImage(
            url: imageUrl,
            type: photoType,
            timestamp: DateTime.now(),
          );

          setState(() {
            // Remove existing image of the same type if it exists
            _reportImages.removeWhere((img) => img.type == photoType);
            // Add new image
            _reportImages.add(reportImage);
            // Also add to legacy imageUrls for backward compatibility
            _imageUrls.add(imageUrl);
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label taken successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e')),
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

  /// Add photos to the report (legacy method for gallery)
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

  /// Upload images to Firebase Storage (legacy method)
  Future<void> _uploadImages(List<XFile> images) async {
    setState(() {
      _isUploadingImages = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      for (final image in images) {
        final imageUrl = await _imageService.uploadReportImage(image, user.uid);
        if (imageUrl != null) {
          final reportImage = ReportImage(
            url: imageUrl,
            type: 'general',
            timestamp: DateTime.now(),
          );

          setState(() {
            _imageUrls.add(imageUrl);
            _reportImages.add(reportImage);
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
    final sortedImages = _getSortedImages();
    if (index >= sortedImages.length) return;

    final imageToRemove = sortedImages[index];

    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Image'),
          content: Text(
              'Are you sure you want to remove this ${_getPhotoTypeLabel(imageToRemove.type)} image?'),
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
        _reportImages.removeWhere((img) => img.url == imageToRemove.url);
        _imageUrls.remove(imageToRemove.url);
      });

      // Delete from Firebase Storage
      try {
        await _imageService.deleteImage(imageToRemove.url);
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

  /// Get sorted images for display
  List<ReportImage> _getSortedImages() {
    final typeOrder = [
      'upstream',
      'downstream',
      'soil_strate',
      'coating_overview',
      'longseam',
      'deposits'
    ];
    final sorted = List<ReportImage>.from(_reportImages);

    sorted.sort((a, b) {
      final aIndex = typeOrder.indexOf(a.type);
      final bIndex = typeOrder.indexOf(b.type);

      // If both types are in the priority list, sort by priority
      if (aIndex != -1 && bIndex != -1) {
        return aIndex.compareTo(bIndex);
      }

      // If only one is in the priority list, prioritize it
      if (aIndex != -1) return -1;
      if (bIndex != -1) return 1;

      // If neither is in the priority list, sort by timestamp
      return a.timestamp.compareTo(b.timestamp);
    });

    return sorted;
  }

  /// Get photo type label for display
  String _getPhotoTypeLabel(String type) {
    switch (type) {
      case 'upstream':
        return 'Upstream';
      case 'downstream':
        return 'Downstream';
      case 'soil_strate':
        return 'Soil Strate';
      case 'coating_overview':
        return 'Coating Overview';
      case 'longseam':
        return 'Longseam';
      case 'deposits':
        return 'Deposits';
      default:
        return 'General';
    }
  }

  /// Check if a photo type has been taken
  bool _hasPhotoType(String type) {
    return _reportImages.any((img) => img.type == type);
  }

  /// Generate sample data for quick testing
  void _generateSampleData() {
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    final sampleLocations = [
      'Pipeline Station ${random}A',
      'Compressor Station ${random}B', 
      'Valve Station ${random}C',
      'Meter Station ${random}D',
      'Pig Launcher ${random}E'
    ];
    final sampleTechnicians = [
      'John Smith',
      'Sarah Johnson', 
      'Mike Wilson',
      'Lisa Brown',
      'David Miller'
    ];
    final sampleFindings = [
      'No significant defects detected. Coating in good condition.',
      'Minor surface corrosion observed at 6 o\'clock position. Within acceptable limits.',
      'Small area of coating disbondment noted. Requires monitoring.',
      'Excellent pipe condition. No defects or anomalies found.',
      'Slight metal loss detected. Calculated remaining life exceeds 20 years.'
    ];
    final sampleActions = [
      'No immediate action required. Continue routine monitoring.',
      'Applied temporary coating repair. Schedule follow-up inspection in 6 months.',
      'Documented findings for trending analysis. No immediate repair needed.',
      'Pipe meets all safety requirements. Continue normal operations.',
      'Increased inspection frequency recommended. Monitor for progression.'
    ];

    setState(() {
      // Basic required fields
      _technicianNameController.text = sampleTechnicians[random % sampleTechnicians.length];
      _locationController.text = sampleLocations[random % sampleLocations.length];
      _pipeDiameterController.text = '${12 + (random % 20)} in';
      _wallThicknessController.text = '0.${250 + (random % 250)} in';
      _selectedMethod = _inspectionMethods[random % _inspectionMethods.length];
      _findingsController.text = sampleFindings[random % sampleFindings.length];
      _correctiveActionsController.text = sampleActions[random % sampleActions.length];
      _additionalNotesController.text = 'Generated test data for quick testing purposes.';

      // DIG Information
      _digNumberController.text = 'DIG-${2024}-${(random % 999).toString().padLeft(3, '0')}';
      _gformNumberController.text = 'GF-${(random % 9999).toString().padLeft(4, '0')}';
      _clientWoNumberController.text = 'WO-${(random % 99999).toString().padLeft(5, '0')}';
      _integritySpecialistsNumberController.text = 'IS-${(random % 999).toString().padLeft(3, '0')}';
      _rfsNumberController.text = 'RFS-${(random % 9999).toString().padLeft(4, '0')}';
      _reasonForDigController.text = 'ILI anomaly verification and assessment';
      _stateController.text = 'Texas';
      _countyController.text = 'Harris';
      _projectNameController.text = 'Pipeline Integrity Assessment Project';
      _lineNumberController.text = 'Line-${random % 10}';

      // Pipe Static Data
      _nominalWallThicknessController.text = '0.${250 + (random % 250)} in';
      _pipeStaticDiameterController.text = '${12 + (random % 20)} in';
      _longseamWeldTypeController.text = 'ERW';
      _girthWeldTypeController.text = 'SMAW';
      _smysController.text = '${35000 + (random % 30000)} psi';
      _maopController.text = '${800 + (random % 400)} psi';
      _safetyFactorController.text = '0.72';
      _operatingPsiController.text = '${600 + (random % 200)} psi';
      _pipeManufacturerController.text = 'US Steel';
      _productController.text = 'Natural Gas';

      // Pipe Evaluation
      _cpSystemController.text = 'Impressed Current';
      _soilResistivityController.text = '${1000 + (random % 5000)} ohms/cm²';
      _testTypeController.text = 'Close Interval Survey';
      _coatingTypeController.text = 'Fusion Bonded Epoxy';
      _overallCondition = 'Fair';
      _conditionAtAnomaly = 'Disbonded';
      _percentBondedController.text = '${70 + (random % 25)}';
      _percentDisbondedController.text = '${10 + (random % 15)}';
      _percentBarePipeController.text = '${random % 10}';

      // Environment
      _terrainAtDigSiteController.text = 'Rural farmland';
      _soilTypeAtPipeLevelController.text = 'Clay';
      _soilTypeAtSixOClockController.text = 'Sandy clay';
      _depthOfCoverController.text = '${3 + (random % 4)} ft';
      _organicDepthController.text = '${6 + (random % 12)} in';
      _usageController.text = 'Agricultural';
      _pipeTemperatureController.text = '${60 + (random % 40)}';
      _ambientTemperatureController.text = '${70 + (random % 30)}';
      _weatherConditionsController.text = 'Clear and dry';
      _drainage = 'Well Drained';

      // Set some dates
      final now = DateTime.now();
      _excavationDate = now.subtract(Duration(days: random % 30));
      _assessmentDate = now.subtract(Duration(days: (random % 30) + 1));
      _reportDate = now;
      _backfillDate = now.add(Duration(days: 1));

      // Set some boolean values
      _liveLine = random % 2 == 0;
      _evidenceOfSoilBodyStress = random % 3 == 0;
      _deposits = random % 4 == 0;
      _pipeBend = random % 5 == 0;
      _defectNoted = random % 3 == 0;
      _burstPressureAnalysis = _defectNoted == true;
      _wetMpiPerformed = random % 2 == 0;
    });

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sample data generated! Form is ready for quick testing.'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
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
        images: _reportImages,
        createdAt: widget.report?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        // DIG Information fields
        digNumber: _digNumberController.text.isEmpty
            ? null
            : _digNumberController.text,
        gformNumber: _gformNumberController.text.isEmpty
            ? null
            : _gformNumberController.text,
        clientWoNumber: _clientWoNumberController.text.isEmpty
            ? null
            : _clientWoNumberController.text,
        integritySpecialistsNumber:
            _integritySpecialistsNumberController.text.isEmpty
                ? null
                : _integritySpecialistsNumberController.text,
        rfsNumber: _rfsNumberController.text.isEmpty
            ? null
            : _rfsNumberController.text,
        excavationDate: _excavationDate,
        assessmentDate: _assessmentDate,
        reportDate: _reportDate,
        backfillDate: _backfillDate,
        reasonForDig: _reasonForDigController.text.isEmpty
            ? null
            : _reasonForDigController.text,
        state: _stateController.text.isEmpty ? null : _stateController.text,
        county: _countyController.text.isEmpty ? null : _countyController.text,
        district:
            _districtController.text.isEmpty ? null : _districtController.text,
        section:
            _sectionController.text.isEmpty ? null : _sectionController.text,
        range: _rangeController.text.isEmpty ? null : _rangeController.text,
        tws: _twsController.text.isEmpty ? null : _twsController.text,
        mp: _mpController.text.isEmpty ? null : _mpController.text,
        projectName: _projectNameController.text.isEmpty
            ? null
            : _projectNameController.text,
        lineNumber: _lineNumberController.text.isEmpty
            ? null
            : _lineNumberController.text,
        digSite:
            _digSiteController.text.isEmpty ? null : _digSiteController.text,
        productFlow: _productFlowController.text.isEmpty
            ? null
            : _productFlowController.text,
        comments:
            _commentsController.text.isEmpty ? null : _commentsController.text,
        // ILI Tool Information fields
        iliToolProvider: _iliToolProviderController.text.isEmpty
            ? null
            : _iliToolProviderController.text,
        toolsRan:
            _toolsRanController.text.isEmpty ? null : _toolsRanController.text,
        toolRunDate: _toolRunDate,
        pigLauncher: _pigLauncherController.text.isEmpty
            ? null
            : _pigLauncherController.text,
        pigReceiver: _pigReceiverController.text.isEmpty
            ? null
            : _pigReceiverController.text,
        toolFlow:
            _toolFlowController.text.isEmpty ? null : _toolFlowController.text,
        totalMiles: _totalMilesController.text.isEmpty
            ? null
            : _totalMilesController.text,
        liveLine: _liveLine,
        iliComments: _iliCommentsController.text.isEmpty
            ? null
            : _iliCommentsController.text,
        // Pipe Static Data fields
        nominalWallThickness: _nominalWallThicknessController.text.isEmpty
            ? null
            : _nominalWallThicknessController.text,
        pipeStaticDiameter: _pipeStaticDiameterController.text.isEmpty
            ? null
            : _pipeStaticDiameterController.text,
        longseamWeldType: _longseamWeldTypeController.text.isEmpty
            ? null
            : _longseamWeldTypeController.text,
        girthWeldType: _girthWeldTypeController.text.isEmpty
            ? null
            : _girthWeldTypeController.text,
        smys: _smysController.text.isEmpty ? null : _smysController.text,
        maop: _maopController.text.isEmpty ? null : _maopController.text,
        safetyFactor: _safetyFactorController.text.isEmpty
            ? null
            : _safetyFactorController.text,
        operatingPsi: _operatingPsiController.text.isEmpty
            ? null
            : _operatingPsiController.text,
        pipeManufacturer: _pipeManufacturerController.text.isEmpty
            ? null
            : _pipeManufacturerController.text,
        installDate: _installDate,
        product:
            _productController.text.isEmpty ? null : _productController.text,
        pipeStaticComments: _pipeStaticCommentsController.text.isEmpty
            ? null
            : _pipeStaticCommentsController.text,
        // Pipe Evaluation fields
        cpSystem:
            _cpSystemController.text.isEmpty ? null : _cpSystemController.text,
        soilResistivity: _soilResistivityController.text.isEmpty
            ? null
            : _soilResistivityController.text,
        testType:
            _testTypeController.text.isEmpty ? null : _testTypeController.text,
        coatingType: _coatingTypeController.text.isEmpty
            ? null
            : _coatingTypeController.text,
        overallCondition: _overallCondition,
        conditionAtAnomaly: _conditionAtAnomaly,
        percentBonded: _percentBondedController.text.isEmpty
            ? null
            : _percentBondedController.text,
        percentDisbonded: _percentDisbondedController.text.isEmpty
            ? null
            : _percentDisbondedController.text,
        percentBarePipe: _percentBarePipeController.text.isEmpty
            ? null
            : _percentBarePipeController.text,
        evidenceOfSoilBodyStress: _evidenceOfSoilBodyStress,
        deposits: _deposits,
        locationOfDeposits: _locationOfDepositsController.text.isEmpty
            ? null
            : _locationOfDepositsController.text,
        descriptionOfDeposits: _descriptionOfDepositsController.text.isEmpty
            ? null
            : _descriptionOfDepositsController.text,
        pipeToSoilDC: _pipeToSoilDCController.text.isEmpty
            ? null
            : _pipeToSoilDCController.text,
        pipeToSoilAC: _pipeToSoilACController.text.isEmpty
            ? null
            : _pipeToSoilACController.text,
        phOnPipe:
            _phOnPipeController.text.isEmpty ? null : _phOnPipeController.text,
        phAtAnomaly: _phAtAnomalyController.text.isEmpty
            ? null
            : _phAtAnomalyController.text,
        phOfSoil:
            _phOfSoilController.text.isEmpty ? null : _phOfSoilController.text,
        pipeBend: _pipeBend,
        degreeOfBend: _degreeOfBendController.text.isEmpty
            ? null
            : _degreeOfBendController.text,
        absEsOfBend: _absEsOfBendController.text.isEmpty
            ? null
            : _absEsOfBendController.text,
        pipeSlope: _pipeSlopeController.text.isEmpty
            ? null
            : _pipeSlopeController.text,
        pipeEvaluationComments: _pipeEvaluationCommentsController.text.isEmpty
            ? null
            : _pipeEvaluationCommentsController.text,
        // Environment fields
        terrainAtDigSite: _terrainAtDigSiteController.text.isEmpty
            ? null
            : _terrainAtDigSiteController.text,
        soilTypeAtPipeLevel: _soilTypeAtPipeLevelController.text.isEmpty
            ? null
            : _soilTypeAtPipeLevelController.text,
        soilTypeAtSixOClock: _soilTypeAtSixOClockController.text.isEmpty
            ? null
            : _soilTypeAtSixOClockController.text,
        depthOfCover: _depthOfCoverController.text.isEmpty
            ? null
            : _depthOfCoverController.text,
        organicDepth: _organicDepthController.text.isEmpty
            ? null
            : _organicDepthController.text,
        usage: _usageController.text.isEmpty ? null : _usageController.text,
        pipeTemperature: _pipeTemperatureController.text.isEmpty
            ? null
            : _pipeTemperatureController.text,
        ambientTemperature: _ambientTemperatureController.text.isEmpty
            ? null
            : _ambientTemperatureController.text,
        weatherConditions: _weatherConditionsController.text.isEmpty
            ? null
            : _weatherConditionsController.text,
        drainage: _drainage,
        environmentComments: _environmentCommentsController.text.isEmpty
            ? null
            : _environmentCommentsController.text,
        // Joint and Girth Weld Details fields
        startOfDigAbsEs: _startOfDigAbsEsController.text.isEmpty
            ? null
            : _startOfDigAbsEsController.text,
        endOfDigAbsEs: _endOfDigAbsEsController.text.isEmpty
            ? null
            : _endOfDigAbsEsController.text,
        lengthOfPipeExposed: _lengthOfPipeExposedController.text.isEmpty
            ? null
            : _lengthOfPipeExposedController.text,
        lengthOfPipeAssessed: _lengthOfPipeAssessedController.text.isEmpty
            ? null
            : _lengthOfPipeAssessedController.text,
        // Defect Evaluation fields
        defectNoted: _defectNoted,
        typeOfDefect: _typeOfDefectController.text.isEmpty
            ? null
            : _typeOfDefectController.text,
        burstPressureAnalysis: _burstPressureAnalysis,
        methodB31G: _methodB31G,
        methodB31GModified: _methodB31GModified,
        methodKapa: _methodKapa,
        methodRstreng: _methodRstreng,
        wetMpiPerformed: _wetMpiPerformed,
        startOfWetMpi: _startOfWetMpiController.text.isEmpty
            ? null
            : _startOfWetMpiController.text,
        endOfWetMpi: _endOfWetMpiController.text.isEmpty
            ? null
            : _endOfWetMpiController.text,
        lengthOfWetMpi: _lengthOfWetMpiController.text.isEmpty
            ? null
            : _lengthOfWetMpiController.text,
        defectEvaluationComments:
            _defectEvaluationCommentsController.text.isEmpty
                ? null
                : _defectEvaluationCommentsController.text,
        // Summary fields
        startOfRecoatAbsEs: _startOfRecoatAbsEsController.text.isEmpty
            ? null
            : _startOfRecoatAbsEsController.text,
        endOfRecoatAbsEs: _endOfRecoatAbsEsController.text.isEmpty
            ? null
            : _endOfRecoatAbsEsController.text,
        totalLengthOfRecoat: _totalLengthOfRecoatController.text.isEmpty
            ? null
            : _totalLengthOfRecoatController.text,
        recoatManufacturer: _recoatManufacturerController.text.isEmpty
            ? null
            : _recoatManufacturerController.text,
        recoatProduct: _recoatProductController.text.isEmpty
            ? null
            : _recoatProductController.text,
        recoatType: _recoatTypeController.text.isEmpty
            ? null
            : _recoatTypeController.text,
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
      final pdfBytes =
          await _pdfService.generateProfessionalReportPdf(widget.report!);
      if (mounted) {
      final filename =
          'NDT_Report_${widget.report!.location}_${DateTime.now().millisecondsSinceEpoch}.pdf';
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
              // Quick Test Mode Toggle
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  side: BorderSide(color: _isQuickTestMode ? Colors.orange : AppTheme.divider),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.speed,
                            color: _isQuickTestMode ? Colors.orange : AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Quick Test Mode',
                            style: AppTheme.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _isQuickTestMode ? Colors.orange : AppTheme.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: _isQuickTestMode,
                            onChanged: (value) {
                              setState(() {
                                _isQuickTestMode = value;
                              });
                            },
                            activeColor: Colors.orange,
                          ),
                        ],
                      ),
                      if (_isQuickTestMode) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Quick Test Mode is enabled. Most fields are now optional for faster testing.',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.orange.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _generateSampleData,
                            icon: const Icon(Icons.auto_fix_high),
                            label: const Text('Generate Sample Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.paddingLarge),

              // DIG Information Card
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
                        'DIG Information',
                        style: AppTheme.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),

                      // DIG # and GFORM # (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _digNumberController,
                              decoration: const InputDecoration(
                                labelText: 'DIG #',
                                hintText: 'Enter DIG number',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _gformNumberController,
                              decoration: const InputDecoration(
                                labelText: 'GFORM #',
                                hintText: 'Enter GFORM number',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Client WO # and Integrity Specialists # (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _clientWoNumberController,
                              decoration: const InputDecoration(
                                labelText: 'Client WO #',
                                hintText: 'Enter Client WO number',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _integritySpecialistsNumberController,
                              decoration: const InputDecoration(
                                labelText: 'Company WO #',
                                hintText: 'Enter company WO number',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // RFS #
                      TextFormField(
                        controller: _rfsNumberController,
                        decoration: const InputDecoration(
                          labelText: 'RFS #',
                          hintText: 'Enter RFS number',
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),

                      // Dates Section
                      Text(
                        'Important Dates',
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Excavation Date and Assessment Date (Row)
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      _excavationDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _excavationDate = picked;
                                  });
                                }
                              },
                              child: AbsorbPointer(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Excavation Date',
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  controller: TextEditingController(
                                    text: _excavationDate != null
                                        ? '${_excavationDate!.year}-${_excavationDate!.month.toString().padLeft(2, '0')}-${_excavationDate!.day.toString().padLeft(2, '0')}'
                                        : '',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      _assessmentDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _assessmentDate = picked;
                                  });
                                }
                              },
                              child: AbsorbPointer(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Assessment Date',
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  controller: TextEditingController(
                                    text: _assessmentDate != null
                                        ? '${_assessmentDate!.year}-${_assessmentDate!.month.toString().padLeft(2, '0')}-${_assessmentDate!.day.toString().padLeft(2, '0')}'
                                        : '',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Report Date and Backfill Date (Row)
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _reportDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _reportDate = picked;
                                  });
                                }
                              },
                              child: AbsorbPointer(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Report Date',
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  controller: TextEditingController(
                                    text: _reportDate != null
                                        ? '${_reportDate!.year}-${_reportDate!.month.toString().padLeft(2, '0')}-${_reportDate!.day.toString().padLeft(2, '0')}'
                                        : '',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _backfillDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _backfillDate = picked;
                                  });
                                }
                              },
                              child: AbsorbPointer(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Backfill Date',
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  controller: TextEditingController(
                                    text: _backfillDate != null
                                        ? '${_backfillDate!.year}-${_backfillDate!.month.toString().padLeft(2, '0')}-${_backfillDate!.day.toString().padLeft(2, '0')}'
                                        : '',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Reason for Dig
                      TextFormField(
                        controller: _reasonForDigController,
                        decoration: const InputDecoration(
                          labelText: 'Reason for Dig',
                          hintText: 'Enter reason for dig',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),

                      // Location Information Section
                      Text(
                        'Location Information',
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // State and County (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _stateController,
                              decoration: const InputDecoration(
                                labelText: 'State',
                                hintText: 'Enter state',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _countyController,
                              decoration: const InputDecoration(
                                labelText: 'County',
                                hintText: 'Enter county',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // District and Section (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _districtController,
                              decoration: const InputDecoration(
                                labelText: 'District',
                                hintText: 'Enter district',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _sectionController,
                              decoration: const InputDecoration(
                                labelText: 'Section',
                                hintText: 'Enter section',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Range and TWS (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _rangeController,
                              decoration: const InputDecoration(
                                labelText: 'Range',
                                hintText: 'Enter range',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _twsController,
                              decoration: const InputDecoration(
                                labelText: 'TWS',
                                hintText: 'Enter TWS',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // MP and Project Name (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _mpController,
                              decoration: const InputDecoration(
                                labelText: 'MP',
                                hintText: 'Enter MP',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _projectNameController,
                              decoration: const InputDecoration(
                                labelText: 'Project Name',
                                hintText: 'Enter project name',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Line # and Dig Site (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _lineNumberController,
                              decoration: const InputDecoration(
                                labelText: 'Line #',
                                hintText: 'Enter line number',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _digSiteController,
                              decoration: const InputDecoration(
                                labelText: 'Dig Site',
                                hintText: 'Enter dig site',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Product Flow
                      TextFormField(
                        controller: _productFlowController,
                        decoration: const InputDecoration(
                          labelText: 'Product Flow',
                          hintText: 'Enter product flow information',
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Comments
                      TextFormField(
                        controller: _commentsController,
                        decoration: const InputDecoration(
                          labelText: 'Comments',
                          hintText: 'Enter any additional comments',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.paddingLarge),

              // ILI Tool Information Card
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
                        'ILI Tool Information',
                        style: AppTheme.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),

                      // ILI Tool Provider and Tool(s) Ran (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _iliToolProviderController,
                              decoration: const InputDecoration(
                                labelText: 'ILI Tool Provider',
                                hintText: 'Enter tool provider',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _toolsRanController,
                              decoration: const InputDecoration(
                                labelText: 'Tool(s) Ran',
                                hintText: 'Enter tools ran',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Tool Run Date
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _toolRunDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() {
                              _toolRunDate = picked;
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Tool Run Date',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            controller: TextEditingController(
                              text: _toolRunDate != null
                                  ? '${_toolRunDate!.year}-${_toolRunDate!.month.toString().padLeft(2, '0')}-${_toolRunDate!.day.toString().padLeft(2, '0')}'
                                  : '',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Pig Launcher and Pig Receiver (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _pigLauncherController,
                              decoration: const InputDecoration(
                                labelText: 'Pig Launcher',
                                hintText: 'Enter pig launcher',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _pigReceiverController,
                              decoration: const InputDecoration(
                                labelText: 'Pig Receiver',
                                hintText: 'Enter pig receiver',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Tool Flow and Total Miles (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _toolFlowController,
                              decoration: const InputDecoration(
                                labelText: 'Tool Flow',
                                hintText: 'Enter tool flow',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _totalMilesController,
                              decoration: const InputDecoration(
                                labelText: 'Total Miles (pig run)',
                                hintText: 'Enter total miles',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Live Line Yes/No
                      Row(
                        children: [
                          Text(
                            'Live Line:',
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Row(
                            children: [
                              Radio<bool>(
                                value: true,
                                groupValue: _liveLine,
                                onChanged: (value) {
                                  setState(() {
                                    _liveLine = value;
                                  });
                                },
                              ),
                              const Text('Yes'),
                              const SizedBox(width: AppTheme.paddingMedium),
                              Radio<bool>(
                                value: false,
                                groupValue: _liveLine,
                                onChanged: (value) {
                                  setState(() {
                                    _liveLine = value;
                                  });
                                },
                              ),
                              const Text('No'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // ILI Comments
                      TextFormField(
                        controller: _iliCommentsController,
                        decoration: const InputDecoration(
                          labelText: 'Comments',
                          hintText: 'Enter any additional comments',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.paddingLarge),

              // Pipe Static Data Card
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
                        'Pipe Static Data',
                        style: AppTheme.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),

                      // Nominal Wall Thickness and Pipe Diameter (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nominalWallThicknessController,
                              decoration: const InputDecoration(
                                labelText: 'Nominal Wall Thickness',
                                hintText: 'Enter nominal wall thickness',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _pipeStaticDiameterController,
                              decoration: const InputDecoration(
                                labelText: 'Pipe Diameter',
                                hintText: 'Enter pipe diameter',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Longseam Weld Type and Girth Weld Type (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _longseamWeldTypeController,
                              decoration: const InputDecoration(
                                labelText: 'Longseam Weld Type',
                                hintText: 'Enter longseam weld type',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _girthWeldTypeController,
                              decoration: const InputDecoration(
                                labelText: 'Girth Weld Type',
                                hintText: 'Enter girth weld type',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // SMYS and MAOP (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _smysController,
                              decoration: const InputDecoration(
                                labelText: 'SMYS',
                                hintText: 'Enter SMYS',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _maopController,
                              decoration: const InputDecoration(
                                labelText: 'MAOP',
                                hintText: 'Enter MAOP',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Safety Factor and Operating psi (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _safetyFactorController,
                              decoration: const InputDecoration(
                                labelText: 'Safety Factor',
                                hintText: 'Enter safety factor',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _operatingPsiController,
                              decoration: const InputDecoration(
                                labelText: 'Operating psi',
                                hintText: 'Enter operating psi',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Pipe Manufacturer
                      TextFormField(
                        controller: _pipeManufacturerController,
                        decoration: const InputDecoration(
                          labelText: 'Pipe Manufacturer',
                          hintText: 'Enter pipe manufacturer',
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Install Date
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _installDate ?? DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() {
                              _installDate = picked;
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Install Date',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            controller: TextEditingController(
                              text: _installDate != null
                                  ? '${_installDate!.year}-${_installDate!.month.toString().padLeft(2, '0')}-${_installDate!.day.toString().padLeft(2, '0')}'
                                  : '',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Product
                      TextFormField(
                        controller: _productController,
                        decoration: const InputDecoration(
                          labelText: 'Product',
                          hintText: 'Enter product type',
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Comments
                      TextFormField(
                        controller: _pipeStaticCommentsController,
                        decoration: const InputDecoration(
                          labelText: 'Comments',
                          hintText: 'Enter any additional comments',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.paddingLarge),

              // Pipe Evaluation Card
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
                        'Pipe Evaluation',
                        style: AppTheme.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),

                      // CP System and Soil Resistivity (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cpSystemController,
                              decoration: const InputDecoration(
                                labelText: 'CP System',
                                hintText: 'Enter CP system',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _soilResistivityController,
                              decoration: const InputDecoration(
                                labelText: 'Soil Resistivity (ohms/cm²)',
                                hintText: 'Enter soil resistivity',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Test Type and Coating Type (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _testTypeController,
                              decoration: const InputDecoration(
                                labelText: 'Test Type',
                                hintText: 'Enter test type',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _coatingTypeController,
                              decoration: const InputDecoration(
                                labelText: 'Coating Type',
                                hintText: 'Enter coating type',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Overall Condition
                      Text(
                        'Overall Condition:',
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingSmall),
                      Wrap(
                        spacing: 16,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                value: 'Bare',
                                groupValue: _overallCondition,
                                onChanged: (value) {
                                  setState(() {
                                    _overallCondition = value;
                                  });
                                },
                              ),
                              const Text('Bare'),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                value: 'Poor',
                                groupValue: _overallCondition,
                                onChanged: (value) {
                                  setState(() {
                                    _overallCondition = value;
                                  });
                                },
                              ),
                              const Text('Poor'),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                value: 'Fair',
                                groupValue: _overallCondition,
                                onChanged: (value) {
                                  setState(() {
                                    _overallCondition = value;
                                  });
                                },
                              ),
                              const Text('Fair'),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                value: 'Bonded',
                                groupValue: _overallCondition,
                                onChanged: (value) {
                                  setState(() {
                                    _overallCondition = value;
                                  });
                                },
                              ),
                              const Text('Bonded'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Condition at Anomaly
                      Text(
                        'Condition at Anomaly:',
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingSmall),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Disbonded',
                            groupValue: _conditionAtAnomaly,
                            onChanged: (value) {
                              setState(() {
                                _conditionAtAnomaly = value;
                              });
                            },
                          ),
                          const Text('Disbonded'),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Radio<String>(
                            value: 'Bonded',
                            groupValue: _conditionAtAnomaly,
                            onChanged: (value) {
                              setState(() {
                                _conditionAtAnomaly = value;
                              });
                            },
                          ),
                          const Text('Bonded'),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Percentages Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _percentBondedController,
                              decoration: const InputDecoration(
                                labelText: '% Bonded',
                                hintText: 'Enter % bonded',
                                suffixText: '%',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _percentDisbondedController,
                              decoration: const InputDecoration(
                                labelText: '% Disbonded',
                                hintText: 'Enter % disbonded',
                                suffixText: '%',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _percentBarePipeController,
                              decoration: const InputDecoration(
                                labelText: '% Bare Pipe',
                                hintText: 'Enter % bare pipe',
                                suffixText: '%',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Evidence of Soil Body Stress Yes/No
                      Row(
                        children: [
                          Text(
                            'Evidence of Soil Body Stress:',
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Radio<bool>(
                            value: true,
                            groupValue: _evidenceOfSoilBodyStress,
                            onChanged: (value) {
                              setState(() {
                                _evidenceOfSoilBodyStress = value;
                              });
                            },
                          ),
                          const Text('Yes'),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Radio<bool>(
                            value: false,
                            groupValue: _evidenceOfSoilBodyStress,
                            onChanged: (value) {
                              setState(() {
                                _evidenceOfSoilBodyStress = value;
                              });
                            },
                          ),
                          const Text('No'),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Deposits Yes/No
                      Row(
                        children: [
                          Text(
                            'Deposits:',
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Radio<bool>(
                            value: true,
                            groupValue: _deposits,
                            onChanged: (value) {
                              setState(() {
                                _deposits = value;
                              });
                            },
                          ),
                          const Text('Yes'),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Radio<bool>(
                            value: false,
                            groupValue: _deposits,
                            onChanged: (value) {
                              setState(() {
                                _deposits = value;
                              });
                            },
                          ),
                          const Text('No'),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Location and Description of Deposits (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _locationOfDepositsController,
                              decoration: const InputDecoration(
                                labelText: 'Location of Deposit(s)',
                                hintText: 'Enter location',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _descriptionOfDepositsController,
                              decoration: const InputDecoration(
                                labelText: 'Description of Deposit(s)',
                                hintText: 'Enter description',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Pipe to Soil measurements (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _pipeToSoilDCController,
                              decoration: const InputDecoration(
                                labelText: 'Pipe to Soil @6:00 (DC)',
                                hintText: 'Enter DC value',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _pipeToSoilACController,
                              decoration: const InputDecoration(
                                labelText: 'Pipe to Soil @6:00 (AC)',
                                hintText: 'Enter AC value',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // pH measurements (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phOnPipeController,
                              decoration: const InputDecoration(
                                labelText: 'pH on Pipe',
                                hintText: 'Enter pH value',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _phAtAnomalyController,
                              decoration: const InputDecoration(
                                labelText: 'pH at Anomaly',
                                hintText: 'Enter pH value',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _phOfSoilController,
                              decoration: const InputDecoration(
                                labelText: 'pH of Soil',
                                hintText: 'Enter pH value',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Pipe Bend Yes/No
                      Row(
                        children: [
                          Text(
                            'Pipe Bend:',
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Radio<bool>(
                            value: true,
                            groupValue: _pipeBend,
                            onChanged: (value) {
                              setState(() {
                                _pipeBend = value;
                              });
                            },
                          ),
                          const Text('Yes'),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Radio<bool>(
                            value: false,
                            groupValue: _pipeBend,
                            onChanged: (value) {
                              setState(() {
                                _pipeBend = value;
                              });
                            },
                          ),
                          const Text('No'),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Degree of Bend and ABS/ES of Bend (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _degreeOfBendController,
                              decoration: const InputDecoration(
                                labelText: 'Degree of Bend',
                                hintText: 'Enter degree of bend',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _absEsOfBendController,
                              decoration: const InputDecoration(
                                labelText: 'ABS/ES of Bend',
                                hintText: 'Enter ABS/ES of bend',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Pipe Slope
                      TextFormField(
                        controller: _pipeSlopeController,
                        decoration: const InputDecoration(
                          labelText: 'Pipe Slope',
                          hintText: 'Enter pipe slope',
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Pipe Evaluation Comments
                      TextFormField(
                        controller: _pipeEvaluationCommentsController,
                        decoration: const InputDecoration(
                          labelText: 'Comments',
                          hintText: 'Enter any additional comments',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.paddingLarge),

              // Environment Card
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
                        'Environment',
                        style: AppTheme.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),

                      // Terrain at Dig Site and Soil Type at Pipe Level (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _terrainAtDigSiteController,
                              decoration: const InputDecoration(
                                labelText: 'Terrain at Dig Site',
                                hintText: 'Enter terrain type',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _soilTypeAtPipeLevelController,
                              decoration: const InputDecoration(
                                labelText: 'Soil Type at Pipe Level',
                                hintText: 'Enter soil type',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Soil Type @ 6:00 and Depth of Cover (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _soilTypeAtSixOClockController,
                              decoration: const InputDecoration(
                                labelText: 'Soil Type @ 6:00',
                                hintText: 'Enter soil type at 6:00',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _depthOfCoverController,
                              decoration: const InputDecoration(
                                labelText: 'Depth of Cover',
                                hintText: 'Enter depth of cover',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Organic Depth and Usage (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _organicDepthController,
                              decoration: const InputDecoration(
                                labelText: 'Organic Depth',
                                hintText: 'Enter organic depth',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _usageController,
                              decoration: const InputDecoration(
                                labelText: 'Usage',
                                hintText: 'Enter land usage',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Pipe Temperature and Ambient Temperature (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _pipeTemperatureController,
                              decoration: const InputDecoration(
                                labelText: 'Pipe Temperature',
                                hintText: 'Enter pipe temperature',
                                suffixText: '°F',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _ambientTemperatureController,
                              decoration: const InputDecoration(
                                labelText: 'Ambient Temperature',
                                hintText: 'Enter ambient temperature',
                                suffixText: '°F',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Weather Conditions
                      TextFormField(
                        controller: _weatherConditionsController,
                        decoration: const InputDecoration(
                          labelText: 'Weather Conditions',
                          hintText: 'Enter weather conditions',
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Drainage
                      Text(
                        'Drainage:',
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingSmall),
                      Wrap(
                        spacing: 16,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                value: 'Dry',
                                groupValue: _drainage,
                                onChanged: (value) {
                                  setState(() {
                                    _drainage = value;
                                  });
                                },
                              ),
                              const Text('Dry'),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                value: 'Well Drained',
                                groupValue: _drainage,
                                onChanged: (value) {
                                  setState(() {
                                    _drainage = value;
                                  });
                                },
                              ),
                              const Text('Well Drained'),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                value: 'Poorly Drained',
                                groupValue: _drainage,
                                onChanged: (value) {
                                  setState(() {
                                    _drainage = value;
                                  });
                                },
                              ),
                              const Text('Poorly Drained'),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                value: 'Very Poorly Drained',
                                groupValue: _drainage,
                                onChanged: (value) {
                                  setState(() {
                                    _drainage = value;
                                  });
                                },
                              ),
                              const Text('Very Poorly Drained'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Environment Comments
                      TextFormField(
                        controller: _environmentCommentsController,
                        decoration: const InputDecoration(
                          labelText: 'Comments',
                          hintText: 'Enter any additional comments',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.paddingLarge),

              // Joint and Girth Weld Details Card
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
                        'Joint and Girth Weld Details',
                        style: AppTheme.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),

                      // Start of Dig ABS/ES and End of Dig ABS/ES (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _startOfDigAbsEsController,
                              decoration: const InputDecoration(
                                labelText: 'Start of Dig ABS/ES',
                                hintText: 'Enter start of dig ABS/ES',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _endOfDigAbsEsController,
                              decoration: const InputDecoration(
                                labelText: 'End of Dig ABS/ES',
                                hintText: 'Enter end of dig ABS/ES',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Length of Pipe Exposed and Length of Pipe Assessed (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _lengthOfPipeExposedController,
                              decoration: const InputDecoration(
                                labelText: 'Length of Pipe Exposed',
                                hintText: 'Enter length of pipe exposed',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _lengthOfPipeAssessedController,
                              decoration: const InputDecoration(
                                labelText: 'Length of Pipe Assessed',
                                hintText: 'Enter length of pipe assessed',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.paddingLarge),

              // Defect Evaluation Card
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
                        'Defect Evaluation',
                        style: AppTheme.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),

                      // Defect Noted Yes/No
                      Row(
                        children: [
                          Text(
                            'Defect Noted:',
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Radio<bool>(
                            value: true,
                            groupValue: _defectNoted,
                            onChanged: (value) {
                              setState(() {
                                _defectNoted = value;
                              });
                            },
                          ),
                          const Text('Yes'),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Radio<bool>(
                            value: false,
                            groupValue: _defectNoted,
                            onChanged: (value) {
                              setState(() {
                                _defectNoted = value;
                              });
                            },
                          ),
                          const Text('No'),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Type of Defect
                      TextFormField(
                        controller: _typeOfDefectController,
                        decoration: const InputDecoration(
                          labelText: 'Type of Defect',
                          hintText: 'Enter type of defect',
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Burst Pressure Analysis Yes/No
                      Row(
                        children: [
                          Text(
                            'Burst Pressure Analysis:',
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Radio<bool>(
                            value: true,
                            groupValue: _burstPressureAnalysis,
                            onChanged: (value) {
                              setState(() {
                                _burstPressureAnalysis = value;
                              });
                            },
                          ),
                          const Text('Yes'),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Radio<bool>(
                            value: false,
                            groupValue: _burstPressureAnalysis,
                            onChanged: (value) {
                              setState(() {
                                _burstPressureAnalysis = value;
                              });
                            },
                          ),
                          const Text('No'),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Method Checkboxes
                      Text(
                        'Method:',
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingSmall),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: _methodB31G ?? false,
                                onChanged: (value) {
                                  setState(() {
                                    _methodB31G = value;
                                  });
                                },
                              ),
                              const Text('B31G'),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: _methodB31GModified ?? false,
                                onChanged: (value) {
                                  setState(() {
                                    _methodB31GModified = value;
                                  });
                                },
                              ),
                              const Text('B31G Modified'),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: _methodKapa ?? false,
                                onChanged: (value) {
                                  setState(() {
                                    _methodKapa = value;
                                  });
                                },
                              ),
                              const Text('Kapa'),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: _methodRstreng ?? false,
                                onChanged: (value) {
                                  setState(() {
                                    _methodRstreng = value;
                                  });
                                },
                              ),
                              const Text('Rstreng'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Wet MPI Performed Yes/No
                      Row(
                        children: [
                          Text(
                            'Wet MPI Performed:',
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Radio<bool>(
                            value: true,
                            groupValue: _wetMpiPerformed,
                            onChanged: (value) {
                              setState(() {
                                _wetMpiPerformed = value;
                              });
                            },
                          ),
                          const Text('Yes'),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Radio<bool>(
                            value: false,
                            groupValue: _wetMpiPerformed,
                            onChanged: (value) {
                              setState(() {
                                _wetMpiPerformed = value;
                              });
                            },
                          ),
                          const Text('No'),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Start of Wet MPI and End of Wet MPI (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _startOfWetMpiController,
                              decoration: const InputDecoration(
                                labelText: 'Start of Wet MPI',
                                hintText: 'Enter start of wet MPI',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _endOfWetMpiController,
                              decoration: const InputDecoration(
                                labelText: 'End of Wet MPI',
                                hintText: 'Enter end of wet MPI',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Length of Wet MPI
                      TextFormField(
                        controller: _lengthOfWetMpiController,
                        decoration: const InputDecoration(
                          labelText: 'Length of Wet MPI',
                          hintText: 'Enter length of wet MPI',
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Defect Evaluation Comments
                      TextFormField(
                        controller: _defectEvaluationCommentsController,
                        decoration: const InputDecoration(
                          labelText: 'Comments',
                          hintText: 'Enter any additional comments',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.paddingLarge),

              // Summary Card
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
                        'Summary',
                        style: AppTheme.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),

                      // Start of Recoat ABS/ES and End of Recoat ABS/ES (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _startOfRecoatAbsEsController,
                              decoration: const InputDecoration(
                                labelText: 'Start of Recoat ABS/ES',
                                hintText: 'Enter start of recoat ABS/ES',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _endOfRecoatAbsEsController,
                              decoration: const InputDecoration(
                                labelText: 'End of Recoat ABS/ES',
                                hintText: 'Enter end of recoat ABS/ES',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Total Length of Recoat
                      TextFormField(
                        controller: _totalLengthOfRecoatController,
                        decoration: const InputDecoration(
                          labelText: 'Total Length of Recoat',
                          hintText: 'Enter total length of recoat',
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Recoat Manufacturer and Recoat Product (Row)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _recoatManufacturerController,
                              decoration: const InputDecoration(
                                labelText: 'Recoat Manufacturer',
                                hintText: 'Enter recoat manufacturer',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _recoatProductController,
                              decoration: const InputDecoration(
                                labelText: 'Recoat Product',
                                hintText: 'Enter recoat product',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Recoat Type
                      TextFormField(
                        controller: _recoatTypeController,
                        decoration: const InputDecoration(
                          labelText: 'Recoat Type',
                          hintText: 'Enter recoat type',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.paddingLarge),

              // NDT Report Form Card
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
                          if (!_isQuickTestMode && (value == null || value.isEmpty)) {
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
                              text:
                                  '${_inspectionDate.year}-${_inspectionDate.month.toString().padLeft(2, '0')}-${_inspectionDate.day.toString().padLeft(2, '0')}',
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

                      // Photo Type Buttons Section
                      Text(
                        'Take Photos',
                        style: AppTheme.titleMedium,
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Photo Type Buttons Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.5,
                        ),
                        itemCount: _photoTypes.length,
                        itemBuilder: (context, index) {
                          final photoType = _photoTypes[index];
                          final hasPhoto = _hasPhotoType(photoType['type']);

                          return ElevatedButton.icon(
                            onPressed: _isUploadingImages
                                ? null
                                : () => _takePhotoForType(
                                      photoType['type'],
                                      photoType['label'],
                                    ),
                            icon: hasPhoto
                                ? const Icon(Icons.check_circle, size: 20)
                                : Icon(photoType['icon'], size: 20),
                            label: Text(
                              photoType['label'],
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hasPhoto
                                  ? Colors.green.withOpacity(0.8)
                                  : photoType['color'],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: AppTheme.paddingLarge),

                      // Photos Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Photos (${_reportImages.length})',
                            style: AppTheme.titleMedium,
                          ),
                          ElevatedButton.icon(
                            onPressed: _isUploadingImages ? null : _addPhotos,
                            icon: _isUploadingImages
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.add_a_photo),
                            label: Text(_isUploadingImages
                                ? 'Uploading...'
                                : 'Add from Gallery'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),

                      // Photo Grid
                      if (_reportImages.isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _getSortedImages().length,
                          itemBuilder: (context, index) {
                            final sortedImages = _getSortedImages();
                            final image = sortedImages[index];

                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    image.url,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
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
                                // Photo type label
                                Positioned(
                                  bottom: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _getPhotoTypeLabel(image.type),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                // Remove button
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

                      if (_reportImages.isEmpty)
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
                                Icon(Icons.photo_library,
                                    color: Colors.grey, size: 32),
                                SizedBox(height: 8),
                                Text(
                                  'No photos added yet',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  'Use the buttons above to take photos',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
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
                                  : Text(
                                      isEdit ? 'Update Report' : 'Save Report'),
                            ),
                          ),
                          if (isEdit) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.picture_as_pdf),
                                label: const Text('Final Report'),
                                onPressed: _isGeneratingPdf
                                    ? null
                                    : _generateAndSharePdf,
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
