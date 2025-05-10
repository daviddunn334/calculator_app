import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class AbsEsCalculator extends StatefulWidget {
  const AbsEsCalculator({super.key});

  @override
  State<AbsEsCalculator> createState() => _AbsEsCalculatorState();
}

class _AbsEsCalculatorState extends State<AbsEsCalculator> {
  final TextEditingController _absController = TextEditingController();
  final TextEditingController _esController = TextEditingController();
  final TextEditingController _rgwController = TextEditingController();

  double? _newAbs;
  double? _newEs;

  @override
  void initState() {
    super.initState();
    // Clear results when any field changes
    _absController.addListener(_clearResults);
    _esController.addListener(_clearResults);
    _rgwController.addListener(_clearResults);
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
                Text(
                  'ABS + ES Calculator',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _absController,
                  decoration: const InputDecoration(
                    labelText: 'ABS',
                    border: OutlineInputBorder(),
                    suffixText: 'mm',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _esController,
                  decoration: const InputDecoration(
                    labelText: 'ES',
                    border: OutlineInputBorder(),
                    suffixText: 'mm',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _rgwController,
                  decoration: const InputDecoration(
                    labelText: 'RGW+',
                    border: OutlineInputBorder(),
                    suffixText: 'mm',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                const Text('New ABS', style: TextStyle(color: AppTheme.primaryBlue)),
                                Text(
                                  _newAbs?.toStringAsFixed(2) ?? '---',
                                  style: AppTheme.headlineLarge.copyWith(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text('New ES', style: TextStyle(color: AppTheme.primaryBlue)),
                                Text(
                                  _newEs?.toStringAsFixed(2) ?? '---',
                                  style: AppTheme.headlineLarge.copyWith(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                ElevatedButton(
                  onPressed: _calculate,
                  child: const Text('Calculate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 