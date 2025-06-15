import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/offline_service.dart';

class AbsEsCalculator extends StatefulWidget {
  const AbsEsCalculator({super.key});

  @override
  State<AbsEsCalculator> createState() => _AbsEsCalculatorState();
}

class _AbsEsCalculatorState extends State<AbsEsCalculator> {
  final TextEditingController _absController = TextEditingController();
  final TextEditingController _esController = TextEditingController();
  final TextEditingController _rgwController = TextEditingController();
  final OfflineService _offlineService = OfflineService();
  bool _isOnline = true;

  double? _newAbs;
  double? _newEs;

  @override
  void initState() {
    super.initState();
    // Clear results when any field changes
    _absController.addListener(_clearResults);
    _esController.addListener(_clearResults);
    _rgwController.addListener(_clearResults);
    
    // Load saved data
    _loadSavedData();
    
    // Listen to connectivity changes
    _isOnline = _offlineService.isOnline;
    _offlineService.onConnectivityChanged.listen((online) {
      setState(() {
        _isOnline = online;
      });
    });
  }
  
  // Load saved calculator data
  Future<void> _loadSavedData() async {
    final data = await _offlineService.loadCalculatorData('abs_es_calculator');
    if (data != null) {
      setState(() {
        _absController.text = data['abs'] ?? '';
        _esController.text = data['es'] ?? '';
        _rgwController.text = data['rgw'] ?? '';
        
        if (data['newAbs'] != null) {
          _newAbs = double.tryParse(data['newAbs'].toString());
        }
        
        if (data['newEs'] != null) {
          _newEs = double.tryParse(data['newEs'].toString());
        }
      });
    }
  }
  
  // Save calculator data
  Future<void> _saveData() async {
    final data = {
      'abs': _absController.text,
      'es': _esController.text,
      'rgw': _rgwController.text,
      'newAbs': _newAbs,
      'newEs': _newEs,
    };
    
    await _offlineService.saveCalculatorData('abs_es_calculator', data);
  }

  @override
  void dispose() {
    _absController.dispose();
    _esController.dispose();
    _rgwController.dispose();
    super.dispose();
  }

  void _clearResults() {
    setState(() {
      _newAbs = null;
      _newEs = null;
    });
  }

  void _calculate() {
    if (_absController.text.isEmpty ||
        _esController.text.isEmpty ||
        _rgwController.text.isEmpty) {
      setState(() {
        _newAbs = null;
        _newEs = null;
      });
      return;
    }

    try {
      final abs = double.parse(_absController.text);
      final es = double.parse(_esController.text);
      final rgw = double.parse(_rgwController.text);

      setState(() {
        _newAbs = abs + rgw;
        _newEs = es + rgw;
      });
      
      // Save data for offline use
      _saveData();
    } catch (e) {
      setState(() {
        _newAbs = null;
        _newEs = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Offline indicator
                if (!_isOnline)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.wifi_off, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You are offline. Your calculations will be saved locally.',
                            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                            'ABS + ES Calculator',
                            style: AppTheme.titleLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInputField(_absController, 'ABS', 'Enter ABS value', suffix: 'mm'),
                const SizedBox(height: 16),
                _buildInputField(_esController, 'ES', 'Enter ES value', suffix: 'mm'),
                const SizedBox(height: 16),
                _buildInputField(_rgwController, 'RGW+', 'Enter RGW+ value', suffix: 'mm'),
                const SizedBox(height: 24),
                if (_newAbs != null && _newEs != null) ...[
                  Container(
                    padding: const EdgeInsets.all(32),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Results',
                          style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryBlue),
                        ),
                        const SizedBox(height: 16),
                        _buildResultRow('New ABS', _newAbs!),
                        _buildResultRow('New ES', _newEs!),
                      ],
                    ),
                  ),
                ],
                ElevatedButton.icon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text(
                    'Calculate',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.paddingMedium,
                      horizontal: AppTheme.paddingLarge,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, String hint, {String? suffix, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType ?? const TextInputType.numberWithOptions(decimal: true, signed: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
      ],
    );
  }

  Widget _buildResultRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodyLarge),
          Text(
            value.toStringAsFixed(2),
            style: AppTheme.headlineLarge.copyWith(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
