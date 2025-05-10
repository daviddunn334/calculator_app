import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    // Add listeners to update calculations when text changes
    _absController.addListener(_calculate);
    _esController.addListener(_calculate);
    _rgwController.addListener(_calculate);
  }

  @override
  void dispose() {
    _absController.dispose();
    _esController.dispose();
    _rgwController.dispose();
    super.dispose();
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
    return Card(
      margin: const EdgeInsets.all(16.0),
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
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const Text('New ABS'),
                          Text(
                            _newAbs?.toStringAsFixed(2) ?? '---',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('New ES'),
                          Text(
                            _newEs?.toStringAsFixed(2) ?? '---',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _calculate,
              child: const Text('Calculate'),
            ),
          ],
        ),
      ),
    );
  }
} 