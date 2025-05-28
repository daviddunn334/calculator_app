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
  final _clockController = TextEditingController();
  String? _clockPosition;
  String? _calculatedDistance;
  String? _errorMessage;

  @override
  void dispose() {
    _odController.dispose();
    _distanceController.dispose();
    _clockController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _clockPosition = null;
      _calculatedDistance = null;
      _errorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      try {
        final od = double.parse(_odController.text);
        
        if (od <= 0) {
          setState(() {
            _errorMessage = 'Pipe OD must be greater than 0';
          });
          return;
        }

        // Calculate circumference
        final circumference = pi * od;

        // If distance is provided, use it to calculate clock position
        if (_distanceController.text.isNotEmpty) {
          final distance = double.parse(_distanceController.text);
          
          if (distance < 0) {
            setState(() {
              _errorMessage = 'Distance cannot be negative';
            });
            return;
          }

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
        }
        // If clock position is provided, use it to calculate distance
        else if (_clockController.text.isNotEmpty) {
          // Parse clock position (format: H:MM or HH:MM)
          final clockParts = _clockController.text.split(':');
          if (clockParts.length != 2) {
            setState(() {
              _errorMessage = 'Invalid clock format. Use H:MM or HH:MM';
            });
            return;
          }

          final hours = int.parse(clockParts[0]);
          final minutes = int.parse(clockParts[1]);

          if (hours < 0 || hours > 12 || minutes < 0 || minutes >= 60) {
            setState(() {
              _errorMessage = 'Invalid clock position';
            });
            return;
          }

          // Calculate distance from clock position
          final clockFraction = (hours % 12 + minutes / 60) / 12;
          final distance = clockFraction * circumference;

          setState(() {
            _calculatedDistance = distance.toStringAsFixed(2);
          });
        }
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
                                'Time Clock Calculator',
                                style: AppTheme.titleLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  _buildTag('Clock Position', AppTheme.primaryBlue),
                                  _buildTag('Distance', AppTheme.primaryBlue),
                                  _buildTag('Conversion', AppTheme.primaryBlue),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
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
                        if (_clockController.text.isEmpty && (value == null || value.isEmpty)) {
                          return 'Please enter either distance or clock position';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    TextFormField(
                      controller: _clockController,
                      decoration: const InputDecoration(
                        labelText: 'Clock',
                        hintText: 'Enter clock position (e.g., 3:15)',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      validator: (value) {
                        if (_distanceController.text.isEmpty && (value == null || value.isEmpty)) {
                          return 'Please enter either distance or clock position';
                        }
                        if (value != null && value.isNotEmpty) {
                          if (!RegExp(r'^\d{1,2}:\d{2}$').hasMatch(value)) {
                            return 'Use format H:MM or HH:MM';
                          }
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppTheme.paddingLarge),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Clock Position',
                                  style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryBlue),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppTheme.paddingMedium),
                                Text(
                                  _clockPosition!,
                                  style: AppTheme.headlineLarge.copyWith(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),
                    ],
                    if (_calculatedDistance != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppTheme.paddingLarge),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Distance from TDC',
                                  style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryBlue),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppTheme.paddingMedium),
                                Text(
                                  '$_calculatedDistance inches',
                                  style: AppTheme.headlineLarge.copyWith(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),
                    ],
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
          ),
        ],
      ),
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