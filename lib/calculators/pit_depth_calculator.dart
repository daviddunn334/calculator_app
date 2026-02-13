import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PitDepthCalculator extends StatefulWidget {
  const PitDepthCalculator({super.key});

  @override
  State<PitDepthCalculator> createState() => _PitDepthCalculatorState();
}

class _PitDepthCalculatorState extends State<PitDepthCalculator> {
  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _pitDepthController = TextEditingController();
  final TextEditingController _remainingController = TextEditingController();

  double? _calculatedPitDepth;
  double? _calculatedRemaining;
  double? _materialLoss;
  String? _errorMessage;

  @override
  void dispose() {
    _nominalController.dispose();
    _pitDepthController.dispose();
    _remainingController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _errorMessage = null;
      _calculatedPitDepth = null;
      _calculatedRemaining = null;
      _materialLoss = null;
    });

    if (_nominalController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter nominal wall thickness';
      });
      return;
    }

    try {
      final nominal = double.parse(_nominalController.text);
      
      if (nominal <= 0) {
        setState(() {
          _errorMessage = 'Nominal thickness must be greater than 0';
        });
        return;
      }

      if (_pitDepthController.text.isNotEmpty) {
        // Calculate using pit depth
        final pitDepth = double.parse(_pitDepthController.text);
        if (pitDepth < 0) {
          setState(() {
            _errorMessage = 'Pit depth cannot be negative';
          });
          return;
        }
        if (pitDepth > nominal) {
          setState(() {
            _errorMessage = 'Pit depth cannot be greater than nominal thickness';
          });
          return;
        }

        setState(() {
          _calculatedPitDepth = pitDepth;
          _calculatedRemaining = nominal - pitDepth;
          _materialLoss = (pitDepth / nominal) * 100;
        });
      } else if (_remainingController.text.isNotEmpty) {
        // Calculate using remaining thickness
        final remaining = double.parse(_remainingController.text);
        if (remaining < 0) {
          setState(() {
            _errorMessage = 'Remaining thickness cannot be negative';
          });
          return;
        }
        if (remaining > nominal) {
          setState(() {
            _errorMessage = 'Remaining thickness cannot be greater than nominal thickness';
          });
          return;
        }

        setState(() {
          _calculatedPitDepth = nominal - remaining;
          _calculatedRemaining = remaining;
          _materialLoss = (_calculatedPitDepth! / nominal) * 100;
        });
      } else {
        setState(() {
          _errorMessage = 'Please enter either pit depth or remaining thickness';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Please enter valid numbers';
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
                              'Pit Depth Calculator',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFEDF9FF),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Calculate wall loss and remaining thickness',
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
                  _buildInputField(_nominalController, 'Nominal Wall Thickness', 'inches'),
                  const SizedBox(height: 20),
                  _buildInputField(_pitDepthController, 'Pit Depth', 'inches'),
                  const SizedBox(height: 20),
                  _buildInputField(_remainingController, 'Remaining Thickness', 'inches'),
                  const SizedBox(height: 24),
                  if (_errorMessage != null) ...[
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
                    const SizedBox(height: 20),
                  ],
                  if (_calculatedPitDepth != null) ...[
                    Container(
                      padding: const EdgeInsets.all(28),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF242A33),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF00E5A8).withOpacity(0.3),
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
                              color: Color(0xFF00E5A8),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildResultRow(
                            'Pit Depth',
                            '${_calculatedPitDepth!.toStringAsFixed(3)} inches',
                            const Color(0xFF6C5BFF),
                          ),
                          const SizedBox(height: 12),
                          _buildResultRow(
                            'Remaining Thickness',
                            '${_calculatedRemaining!.toStringAsFixed(3)} inches',
                            const Color(0xFF00E5A8),
                          ),
                          const SizedBox(height: 12),
                          _buildResultRow(
                            'Material Loss',
                            '${_materialLoss!.toStringAsFixed(2)}%',
                            _materialLoss! > 50 ? const Color(0xFFFE637E) : const Color(0xFFF8B800),
                          ),
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

  Widget _buildInputField(TextEditingController controller, String label, String suffix) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Color(0xFFEDF9FF)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFAEBBC8)),
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
    );
  }

  Widget _buildResultRow(String label, String value, Color valueColor) {
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
            value,
            style: TextStyle(
              fontSize: 20,
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
