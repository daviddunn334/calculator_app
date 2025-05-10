import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class SocEocCalculator extends StatefulWidget {
  const SocEocCalculator({super.key});

  @override
  State<SocEocCalculator> createState() => _SocEocCalculatorState();
}

class _SocEocCalculatorState extends State<SocEocCalculator> {
  final TextEditingController _absController = TextEditingController();
  final TextEditingController _esController = TextEditingController();
  final TextEditingController _socController = TextEditingController();
  final TextEditingController _eocController = TextEditingController();

  double? _socAbs, _socEs, _eocAbs, _eocEs;
  String? _errorMessage;

  void _calculate() {
    setState(() {
      _errorMessage = null;
      _socAbs = _socEs = _eocAbs = _eocEs = null;
    });
    try {
      final abs = double.parse(_absController.text);
      final es = double.parse(_esController.text);
      final soc = double.parse(_socController.text);
      final eoc = double.parse(_eocController.text);
      setState(() {
        _socAbs = abs + soc;
        _socEs = es + soc;
        _eocAbs = abs + eoc;
        _eocEs = es + eoc;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Please enter valid numbers in all fields.';
      });
    }
  }

  void _clearResults() {
    setState(() {
      _socAbs = _socEs = _eocAbs = _eocEs = null;
      _errorMessage = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _absController.addListener(_clearResults);
    _esController.addListener(_clearResults);
    _socController.addListener(_clearResults);
    _eocController.addListener(_clearResults);
  }

  @override
  void dispose() {
    _absController.dispose();
    _esController.dispose();
    _socController.dispose();
    _eocController.dispose();
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
                  Text(
                    'SOC & EOC Calculator',
                    style: AppTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.paddingLarge),
                  _buildInputField(_absController, 'ABS', 'Enter ABS', suffix: 'ft'),
                  const SizedBox(height: AppTheme.paddingMedium),
                  _buildInputField(_esController, 'ES', 'Enter ES', suffix: 'ft'),
                  const SizedBox(height: AppTheme.paddingMedium),
                  _buildInputField(_socController, 'SOC (RGW ±)', 'Start of Coating Offset', suffix: 'ft', keyboardType: TextInputType.text),
                  const SizedBox(height: AppTheme.paddingMedium),
                  _buildInputField(_eocController, 'EOC (RGW ±)', 'End of Coating Offset', suffix: 'ft', keyboardType: TextInputType.text),
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
                    child: ElevatedButton(
                      onPressed: () {
                        if (_absController.text.isEmpty ||
                            _esController.text.isEmpty ||
                            _socController.text.isEmpty ||
                            _eocController.text.isEmpty) {
                          setState(() {
                            _errorMessage = 'All fields are required.';
                          });
                          return;
                        }
                        _calculate();
                      },
                      child: const Text('Calculate'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_socAbs != null && _socEs != null && _eocAbs != null && _eocEs != null)
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
                          'Start of Coating',
                          style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryBlue),
                        ),
                        const SizedBox(height: 8),
                        _buildResultRow('ABS', _socAbs!),
                        _buildResultRow('ES', _socEs!),
                        const SizedBox(height: 24),
                        Text(
                          'End of Coating',
                          style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryBlue),
                        ),
                        const SizedBox(height: 8),
                        _buildResultRow('ABS', _eocAbs!),
                        _buildResultRow('ES', _eocEs!),
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