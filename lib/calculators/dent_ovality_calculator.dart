import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DentOvalityCalculator extends StatefulWidget {
  const DentOvalityCalculator({super.key});

  @override
  State<DentOvalityCalculator> createState() => _DentOvalityCalculatorState();
}

class _DentOvalityCalculatorState extends State<DentOvalityCalculator> {
  final TextEditingController _odController = TextEditingController();
  final TextEditingController _depthController = TextEditingController();

  double? _ovality;
  String? _errorMessage;

  void _calculate() {
    setState(() {
      _errorMessage = null;
      _ovality = null;
    });
    try {
      final od = double.parse(_odController.text);
      final depth = double.parse(_depthController.text);
      if (od <= 0 || depth <= 0) {
        _errorMessage = 'Both values must be positive numbers.';
        return;
      }
      _ovality = (depth / od) * 100;
    } catch (e) {
      setState(() {
        _errorMessage = 'Please enter valid numbers in both fields.';
      });
    }
  }

  void _clearResults() {
    setState(() {
      _ovality = null;
      _errorMessage = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _odController.addListener(_clearResults);
    _depthController.addListener(_clearResults);
  }

  @override
  void dispose() {
    _odController.dispose();
    _depthController.dispose();
    super.dispose();
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
                              'Dent Ovality Calculator',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFEDF9FF),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Calculate dent ovality percentage',
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
                  _buildInputField(_odController, 'Pipe Diameter (OD)', 'Enter pipe OD', suffix: 'in'),
                  const SizedBox(height: 20),
                  _buildInputField(_depthController, 'Dent Depth', 'Enter dent depth', suffix: 'in'),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFE637E).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFFE637E).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Color(0xFFFE637E), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Color(0xFFFE637E),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  if (_ovality != null)
                    Container(
                      padding: const EdgeInsets.all(32),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF242A33),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _ovality! > 6 
                              ? const Color(0xFFFE637E).withOpacity(0.3)
                              : const Color(0xFF00E5A8).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Dent Ovality',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _ovality! > 6 
                                  ? const Color(0xFFFE637E)
                                  : const Color(0xFF00E5A8),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '${_ovality!.toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontSize: 56,
                              color: _ovality! > 6 
                                  ? const Color(0xFFFE637E)
                                  : const Color(0xFF00E5A8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_ovality! > 6) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFE637E).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.warning, color: Color(0xFFFE637E), size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    'Exceeds 6% threshold',
                                    style: TextStyle(
                                      color: Color(0xFFFE637E),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
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

  Widget _buildInputField(TextEditingController controller, String label, String hint, {String? suffix}) {
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
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
    );
  }
}
