import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' show pi;
import '../theme/app_theme.dart';

class TimeClockCalculator extends StatefulWidget {
  const TimeClockCalculator({super.key});

  @override
  State<TimeClockCalculator> createState() => _TimeClockCalculatorState();
}

class _TimeClockCalculatorState extends State<TimeClockCalculator> {
  final TextEditingController _odController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();

  String? _clockPosition;
  String? _errorMessage;

  @override
  void dispose() {
    _odController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _clockPosition = null;
      _errorMessage = null;
    });

    if (_odController.text.isEmpty || _distanceController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both OD and distance values';
      });
      return;
    }

    try {
      final od = double.parse(_odController.text);
      final distance = double.parse(_distanceController.text);

      if (od <= 0) {
        setState(() {
          _errorMessage = 'Pipe OD must be greater than 0';
        });
        return;
      }

      if (distance < 0) {
        setState(() {
          _errorMessage = 'Distance cannot be negative';
        });
        return;
      }

      // Calculate circumference
      final circumference = pi * od;

      // Convert to clock position
      final clockFraction = (distance / circumference) * 12;
      final hours = clockFraction.floor();
      final minutes = ((clockFraction % 1) * 60).round();

      // Format final hour (use 12 if result is 0)
      final finalHour = hours % 12 == 0 ? 12 : hours % 12;

      // Format as HH:MM
      setState(() {
        _clockPosition = '${finalHour.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Please enter valid numbers';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.cardGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.access_time,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Time Clock Calculator',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: _odController,
                            decoration: const InputDecoration(
                              labelText: 'Pipe OD',
                              suffixText: 'inches',
                              prefixIcon: Icon(Icons.straighten),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _distanceController,
                            decoration: const InputDecoration(
                              labelText: 'Distance from TDC',
                              suffixText: 'inches',
                              prefixIcon: Icon(Icons.arrow_forward),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          if (_clockPosition != null) ...[
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.1),
                                    Colors.white.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Clock Position',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _clockPosition!,
                                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                          Container(
                            decoration: BoxDecoration(
                              gradient: AppTheme.buttonGradient,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: ElevatedButton(
                              onPressed: _calculate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text(
                                'Calculate',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 