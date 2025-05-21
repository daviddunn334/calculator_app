import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' show sqrt, pow;
import '../theme/app_theme.dart';

class B31GCalculator extends StatefulWidget {
  const B31GCalculator({super.key});

  @override
  State<B31GCalculator> createState() => _B31GCalculatorState();
}

class _B31GCalculatorState extends State<B31GCalculator> {
  final _formKey = GlobalKey<FormState>();
  final _pitDepthController = TextEditingController();
  final _pitLengthController = TextEditingController();
  
  String? _result;
  String? _errorMessage;
  double? _criticalLength;
  
  // Dropdown options
  final List<String> _odOptions = ['30"', '36"', '42"', '48"'];
  final List<String> _wallThicknessOptions = ['0.312"', '0.325"', '0.375"', '0.400"', '0.406"'];
  
  // Selected values
  String? _selectedOD;
  String? _selectedWallThickness;

  @override
  void dispose() {
    _pitDepthController.dispose();
    _pitLengthController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _result = null;
      _errorMessage = null;
      _criticalLength = null;
    });

    if (_formKey.currentState!.validate()) {
      try {
        // Convert selected values to numbers (remove the " and convert to double)
        final od = double.parse(_selectedOD!.replaceAll('"', ''));
        final wallThickness = double.parse(_selectedWallThickness!.replaceAll('"', ''));
        final pitDepth = double.parse(_pitDepthController.text);
        final pitLength = double.parse(_pitLengthController.text);

        // Validate inputs
        if (pitDepth <= 0 || pitLength <= 0) {
          setState(() {
            _errorMessage = 'All values must be greater than 0';
          });
          return;
        }

        if (pitDepth >= wallThickness) {
          setState(() {
            _errorMessage = 'Pit depth must be less than wall thickness';
          });
          return;
        }

        // Calculate ratios
        final dOverT = pitDepth / wallThickness;
        final percentDepth = (pitDepth / wallThickness) * 100;

        // Determine result based on depth percentage
        if (percentDepth <= 10) {
          setState(() {
            _result = 'Pass';
            _criticalLength = null; // No critical length for very shallow pits
          });
          return;
        }

        if (percentDepth > 80) {
          setState(() {
            _result = 'Fail';
            _criticalLength = null;
          });
          return;
        }

        // Calculate B value
        double b;
        try {
          b = pow(dOverT / (1.1 * (dOverT - 0.15)), 2) - 1;
          b = b.clamp(0, 4.0); // Cap B at 4.0
        } catch (e) {
          setState(() {
            _result = 'Fail';
            _errorMessage = 'Invalid B value calculation';
            _criticalLength = null;
          });
          return;
        }

        // Calculate L value
        final l = 1.12 * sqrt(b * od / wallThickness);

        // Final determination
        setState(() {
          _result = pitLength <= l ? 'Pass' : 'Fail';
          if (_result == 'Pass') {
            _criticalLength = l;
          }
        });

      } catch (e) {
        setState(() {
          _errorMessage = 'Please enter valid numbers';
          _criticalLength = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              side: const BorderSide(color: AppTheme.divider),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'B31G Calculator',
                      style: AppTheme.titleLarge,
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),
                    DropdownButtonFormField<String>(
                      value: _selectedOD,
                      decoration: const InputDecoration(
                        labelText: 'Pipe OD',
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      items: _odOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedOD = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select pipe OD';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    DropdownButtonFormField<String>(
                      value: _selectedWallThickness,
                      decoration: const InputDecoration(
                        labelText: 'Nominal Wall Thickness',
                        prefixIcon: Icon(Icons.height),
                      ),
                      items: _wallThicknessOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedWallThickness = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select wall thickness';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    TextFormField(
                      controller: _pitDepthController,
                      decoration: const InputDecoration(
                        labelText: 'Pit Depth',
                        hintText: 'Enter pit depth',
                        suffixText: 'inches',
                        prefixIcon: Icon(Icons.vertical_align_bottom),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter pit depth';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    TextFormField(
                      controller: _pitLengthController,
                      decoration: const InputDecoration(
                        labelText: 'Pit Length',
                        hintText: 'Enter pit length',
                        suffixText: 'inches',
                        prefixIcon: Icon(Icons.arrow_forward),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter pit length';
                        }
                        return null;
                      },
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: AppTheme.paddingMedium),
                      Container(
                        padding: const EdgeInsets.all(AppTheme.paddingMedium),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppTheme.paddingLarge),
                    if (_result != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width - (AppTheme.paddingLarge * 6),
                            padding: const EdgeInsets.all(AppTheme.paddingMedium),
                            decoration: BoxDecoration(
                              color: _result == 'Pass' 
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Result',
                                  style: AppTheme.titleLarge.copyWith(
                                    color: _result == 'Pass' ? Colors.green : Colors.red,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppTheme.paddingMedium),
                                Text(
                                  _result!,
                                  style: AppTheme.headlineLarge.copyWith(
                                    color: _result == 'Pass' ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (_result == 'Pass' && _criticalLength != null) ...[
                                  const SizedBox(height: AppTheme.paddingMedium),
                                  Text(
                                    'Critical Length:\n${_criticalLength!.toStringAsFixed(2)} inches',
                                    style: AppTheme.titleLarge.copyWith(
                                      color: Colors.red.withOpacity(0.7),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _calculate,
                        child: const Text('Calculate'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 