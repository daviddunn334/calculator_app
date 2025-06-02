import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              side: const BorderSide(color: AppTheme.divider),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                              'Dent Ovality Calculator',
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
                  const SizedBox(height: AppTheme.paddingLarge),
                  _buildInputField(_odController, 'Pipe Diameter (OD)', 'Enter pipe OD', suffix: 'in'),
                  const SizedBox(height: AppTheme.paddingMedium),
                  _buildInputField(_depthController, 'Dent Depth', 'Enter dent depth', suffix: 'in'),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: AppTheme.paddingMedium),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: AppTheme.paddingLarge),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
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
                  ),
                ],
              ),
            ),
          ),
          if (_ovality != null)
            Padding(
              padding: const EdgeInsets.only(top: AppTheme.paddingLarge),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Dent Ovality',
                          style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryBlue),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${_ovality!.toStringAsFixed(2)}%',
                          style: AppTheme.headlineLarge.copyWith(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, String hint, {String? suffix}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
} 