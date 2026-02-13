import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' show pi;

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
    return Scaffold(
      backgroundColor: const Color(0xFF1E232A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A313B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Color(0xFFEDF9FF)),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                'Time Clock Calculator',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFEDF9FF),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Convert between distance and clock position',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color(0xFFAEBBC8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _odController,
                      style: const TextStyle(color: Color(0xFFEDF9FF)),
                      decoration: InputDecoration(
                        labelText: 'Pipe OD',
                        labelStyle: const TextStyle(color: Color(0xFFAEBBC8)),
                        hintText: 'Enter pipe outside diameter',
                        hintStyle: const TextStyle(color: Color(0xFF7F8A96)),
                        suffixText: 'inches',
                        suffixStyle: const TextStyle(color: Color(0xFFAEBBC8)),
                        prefixIcon: const Icon(Icons.straighten, color: Color(0xFF6C5BFF)),
                        filled: true,
                        fillColor: const Color(0xFF242A33),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF6C5BFF), width: 2),
                        ),
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
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _distanceController,
                      style: const TextStyle(color: Color(0xFFEDF9FF)),
                      decoration: InputDecoration(
                        labelText: 'Distance from TDC',
                        labelStyle: const TextStyle(color: Color(0xFFAEBBC8)),
                        hintText: 'Enter distance from top dead center',
                        hintStyle: const TextStyle(color: Color(0xFF7F8A96)),
                        suffixText: 'inches',
                        suffixStyle: const TextStyle(color: Color(0xFFAEBBC8)),
                        prefixIcon: const Icon(Icons.arrow_forward, color: Color(0xFF00E5A8)),
                        filled: true,
                        fillColor: const Color(0xFF242A33),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF6C5BFF), width: 2),
                        ),
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
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _clockController,
                      style: const TextStyle(color: Color(0xFFEDF9FF)),
                      decoration: InputDecoration(
                        labelText: 'Clock',
                        labelStyle: const TextStyle(color: Color(0xFFAEBBC8)),
                        hintText: 'Enter clock position (e.g., 3:15)',
                        hintStyle: const TextStyle(color: Color(0xFF7F8A96)),
                        prefixIcon: const Icon(Icons.access_time, color: Color(0xFFF8B800)),
                        filled: true,
                        fillColor: const Color(0xFF242A33),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF6C5BFF), width: 2),
                        ),
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
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFE637E).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFFE637E).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFFFE637E), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Color(0xFFFE637E),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    if (_clockPosition != null) ...[
                      Container(
                        padding: const EdgeInsets.all(28),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF242A33),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF00E5A8).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Clock Position',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00E5A8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _clockPosition!,
                              style: const TextStyle(
                                fontSize: 48,
                                color: Color(0xFF00E5A8),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_calculatedDistance != null) ...[
                      Container(
                        padding: const EdgeInsets.all(28),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF242A33),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF6C5BFF).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Distance from TDC',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6C5BFF),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '$_calculatedDistance"',
                              style: const TextStyle(
                                fontSize: 42,
                                color: Color(0xFF6C5BFF),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _calculate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C5BFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Calculate',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
