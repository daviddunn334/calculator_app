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
  final _formKey = GlobalKey<FormState>();
  final _odController = TextEditingController();
  final _distanceController = TextEditingController();
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

    if (_formKey.currentState!.validate()) {
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
                      'Time Clock Calculator',
                      style: AppTheme.titleLarge,
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),
                    TextFormField(
                      controller: _odController,
                      decoration: const InputDecoration(
                        labelText: 'Pipe OD',
                        hintText: 'Enter pipe outside diameter',
                        suffixText: 'inches',
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter pipe OD';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    TextFormField(
                      controller: _distanceController,
                      decoration: const InputDecoration(
                        labelText: 'Distance from TDC',
                        hintText: 'Enter distance from top dead center',
                        suffixText: 'inches',
                        prefixIcon: Icon(Icons.arrow_forward),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter distance from TDC';
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
                    if (_clockPosition != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppTheme.paddingLarge),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Clock Position',
                              style: AppTheme.titleLarge.copyWith(
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: AppTheme.paddingMedium),
                            Text(
                              _clockPosition!,
                              style: AppTheme.headlineLarge.copyWith(
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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