import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class PitDepthCalculator extends StatefulWidget {
  // Test comment for GitHub Actions deployment
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
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                                'Pit Depth Calculator',
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
                    TextField(
                      controller: _nominalController,
                      decoration: const InputDecoration(
                        labelText: 'Nominal Wall Thickness',
                        border: OutlineInputBorder(),
                        suffixText: 'inches',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _pitDepthController,
                      decoration: const InputDecoration(
                        labelText: 'Pit Depth',
                        border: OutlineInputBorder(),
                        suffixText: 'inches',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _remainingController,
                      decoration: const InputDecoration(
                        labelText: 'Remaining Thickness',
                        border: OutlineInputBorder(),
                        suffixText: 'inches',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 24),
                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_calculatedPitDepth != null) ...[
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
                            _buildResultRow(
                              'Pit Depth',
                              '${_calculatedPitDepth!.toStringAsFixed(3)} inches',
                              valueColor: AppTheme.primaryBlue,
                            ),
                            const SizedBox(height: 8),
                            _buildResultRow(
                              'Remaining Thickness',
                              '${_calculatedRemaining!.toStringAsFixed(3)} inches',
                              valueColor: AppTheme.primaryBlue,
                            ),
                            const SizedBox(height: 8),
                            _buildResultRow(
                              'Material Loss',
                              '${_materialLoss!.toStringAsFixed(2)}%',
                              valueColor: AppTheme.primaryBlue,
                            ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
        ),
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