import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../models/defect_entry.dart';
import '../models/defect_type.dart';
import '../services/defect_service.dart';
import '../services/defect_type_service.dart';
import '../services/pdf_management_service.dart';
import '../services/analytics_service.dart';

class LogDefectScreen extends StatefulWidget {
  const LogDefectScreen({Key? key}) : super(key: key);

  @override
  State<LogDefectScreen> createState() => _LogDefectScreenState();
}

class _LogDefectScreenState extends State<LogDefectScreen> {
  final _formKey = GlobalKey<FormState>();
  final DefectService _defectService = DefectService();
  final DefectTypeService _defectTypeService = DefectTypeService();
  final PdfManagementService _pdfManagementService = PdfManagementService();
  final AnalyticsService _analyticsService = AnalyticsService();
  
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _depthController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  String? _selectedDefectType;
  String? _selectedClient;
  List<DefectType> _defectTypes = [];
  List<String> _clients = [];
  bool _isLoading = false;
  bool _isLoadingTypes = true;
  bool _isLoadingClients = true;

  @override
  void initState() {
    super.initState();
    _loadDefectTypes();
    _loadClients();
  }

  Future<void> _loadDefectTypes() async {
    setState(() => _isLoadingTypes = true);
    // Listen to defect types stream
    _defectTypeService.getActiveDefectTypes().listen((types) {
      setState(() {
        _defectTypes = types;
        _isLoadingTypes = false;
      });
    });
  }

  Future<void> _loadClients() async {
    setState(() => _isLoadingClients = true);
    try {
      final clients = await _pdfManagementService.getCompanies();
      setState(() {
        _clients = clients;
        _isLoadingClients = false;
      });
    } catch (e) {
      print('Error loading clients: $e');
      setState(() => _isLoadingClients = false);
    }
  }

  bool get _isHardspot => 
      _selectedDefectType?.toLowerCase().contains('hardspot') ?? false;

  String get _depthLabel => _isHardspot ? 'Max HB' : 'Depth (in)';

  @override
  void dispose() {
    _lengthController.dispose();
    _widthController.dispose();
    _depthController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitDefect() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDefectType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a defect type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a client'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final defectEntry = DefectEntry(
        id: '', // Will be set by service
        userId: userId,
        defectType: _selectedDefectType!,
        length: double.parse(_lengthController.text),
        width: double.parse(_widthController.text),
        depth: double.parse(_depthController.text),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        clientName: _selectedClient!,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );

      final newDefectId = await _defectService.addDefectEntry(defectEntry);

      // Log analytics event
      await _analyticsService.logDefectLogged(
        _selectedDefectType!,
        _selectedClient!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Defect logged successfully! AI analysis starting...'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging defect: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Log New Defect'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: (_isLoadingTypes || _isLoadingClients)
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'All measurements should be entered in inches',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Defect Type Dropdown
                    const Text(
                      'Defect Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedDefectType,
                      decoration: InputDecoration(
                        hintText: 'Select defect type',
                        prefixIcon: const Icon(Icons.category),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          borderSide: const BorderSide(color: AppTheme.divider),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          borderSide: const BorderSide(color: AppTheme.divider),
                        ),
                      ),
                      items: _defectTypes.map((defectType) {
                        return DropdownMenuItem<String>(
                          value: defectType.name,
                          child: Text(defectType.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDefectType = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a defect type';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Length Field
                    const Text(
                      'Length (in)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _lengthController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Enter length',
                        prefixIcon: const Icon(Icons.straighten),
                        suffixText: 'in',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter length';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Length must be greater than 0';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Width Field
                    const Text(
                      'Width (in)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _widthController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Enter width',
                        prefixIcon: const Icon(Icons.width_normal),
                        suffixText: 'in',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter width';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Width must be greater than 0';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Depth/Max HB Field
                    Text(
                      _depthLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _depthController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      decoration: InputDecoration(
                        hintText: _isHardspot ? 'Enter Max HB value' : 'Enter depth',
                        prefixIcon: const Icon(Icons.height),
                        suffixText: _isHardspot ? 'HB' : 'in',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter ${_isHardspot ? 'Max HB' : 'depth'}';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return '${_isHardspot ? 'Max HB' : 'Depth'} must be greater than 0';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Notes Field
                    const Text(
                      'Notes (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Add any additional notes or observations...',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 60),
                          child: Icon(Icons.note),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Client Selection Dropdown
                    const Text(
                      'Client',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedClient,
                      decoration: InputDecoration(
                        hintText: 'Select client company',
                        prefixIcon: const Icon(Icons.business),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          borderSide: const BorderSide(color: AppTheme.divider),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          borderSide: const BorderSide(color: AppTheme.divider),
                        ),
                      ),
                      items: _clients.map((client) {
                        return DropdownMenuItem<String>(
                          value: client,
                          child: Text(client.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedClient = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a client';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitDefect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Log Defect',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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
