import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      backgroundColor: const Color(0xFF1E232A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A313B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Offline indicator
                  if (!_isOnline)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8B800).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFF8B800).withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.wifi_off, color: Color(0xFFF8B800), size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'You are offline. Your calculations will be saved locally.',
                              style: TextStyle(
                                color: Color(0xFFF8B800),
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Header
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFFEDF9FF)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'ABS + ES Calculator',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFEDF9FF),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Calculate adjusted beam positions',
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color(0xFFAEBBC8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildInputField(_absController, 'ABS', 'Enter ABS value', suffix: 'mm'),
                  const SizedBox(height: 20),
                  _buildInputField(_esController, 'ES', 'Enter ES value', suffix: 'mm'),
                  const SizedBox(height: 20),
                  _buildInputField(_rgwController, 'RGW+', 'Enter RGW+ value', suffix: 'mm'),
                  const SizedBox(height: 32),
                  if (_newAbs != null && _newEs != null) ...[
                    Container(
                      padding: const EdgeInsets.all(28),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF242A33),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF6C5BFF).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Results',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6C5BFF),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildResultRow('New ABS', _newAbs!),
                          const SizedBox(height: 12),
                          _buildResultRow('New ES', _newEs!),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _calculate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5BFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Calculate',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, String hint, {String? suffix, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Color(0xFFEDF9FF)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFAEBBC8)),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF7F8A96)),
        suffixText: suffix,
        suffixStyle: const TextStyle(color: Color(0xFFAEBBC8)),
        filled: true,
        fillColor: const Color(0xFF242A33),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFF6C5BFF),
            width: 2,
          ),
        ),
      ),
      keyboardType: keyboardType ?? const TextInputType.numberWithOptions(decimal: true, signed: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
      ],
    );
  }

  Widget _buildResultRow(String label, double value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A313B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFFAEBBC8),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${value.toStringAsFixed(2)} mm',
            style: const TextStyle(
              fontSize: 24,
              color: Color(0xFF00E5A8),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
