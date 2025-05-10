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
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pit Depth Calculator',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nominalController,
              decoration: const InputDecoration(
                labelText: 'Nominal Wall Thickness',
                border: OutlineInputBorder(),
                suffixText: 'inches',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pitDepthController,
              decoration: const InputDecoration(
                labelText: 'Pit Depth',
                border: OutlineInputBorder(),
                suffixText: 'inches',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _remainingController,
              decoration: const InputDecoration(
                labelText: 'Remaining Wall Thickness',
                border: OutlineInputBorder(),
                suffixText: 'inches',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            if (_calculatedPitDepth != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Results',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildResultRow('Pit Depth', '${_calculatedPitDepth!.toStringAsFixed(3)} inches'),
                    const SizedBox(height: 8),
                    _buildResultRow('Remaining Thickness', '${_calculatedRemaining!.toStringAsFixed(3)} inches'),
                    const SizedBox(height: 8),
                    _buildResultRow('Material Loss', '${_materialLoss!.toStringAsFixed(2)}%'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            ElevatedButton(
              onPressed: _calculate,
              child: const Text('Calculate'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
} 