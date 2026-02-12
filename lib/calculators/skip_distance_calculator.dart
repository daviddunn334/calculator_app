import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../theme/app_theme.dart';
import '../services/analytics_service.dart';

class SkipDistanceCalculator extends StatefulWidget {
  const SkipDistanceCalculator({super.key});

  @override
  State<SkipDistanceCalculator> createState() => _SkipDistanceCalculatorState();
}

class _SkipDistanceCalculatorState extends State<SkipDistanceCalculator> {
  final TextEditingController _angleController = TextEditingController();
  final TextEditingController _thicknessController = TextEditingController();

  double? _halfSkipDistance;
  double? _fullSkipDistance;
  List<Map<String, dynamic>>? _legTable;
  String? _errorMessage;

  @override
  void dispose() {
    _angleController.dispose();
    _thicknessController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _errorMessage = null;
      _halfSkipDistance = null;
      _fullSkipDistance = null;
      _legTable = null;
    });

    // Validate inputs
    if (_angleController.text.isEmpty || _thicknessController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }

    try {
      final angle = double.parse(_angleController.text);
      final thickness = double.parse(_thicknessController.text);

      // Validation
      if (angle <= 0 || angle >= 90) {
        setState(() {
          _errorMessage = 'Probe angle must be between 1° and 89°';
        });
        return;
      }

      if (thickness <= 0) {
        setState(() {
          _errorMessage = 'Thickness must be greater than 0';
        });
        return;
      }

      // Convert angle to radians
      final angleRad = angle * (pi / 180);
      final tanValue = tan(angleRad);

      // Calculate half skip distance
      final hs = thickness * tanValue;

      // Calculate full skip distance
      final fs = 2 * hs;

      // Generate leg table for legs 1-5
      final legTable = <Map<String, dynamic>>[];
      for (int k = 1; k <= 5; k++) {
        legTable.add({
          'leg': k,
          'surfaceDistance': k * hs,
          'reflectionSurface': k % 2 == 1 ? 'Bottom' : 'Top',
        });
      }

      setState(() {
        _halfSkipDistance = hs;
        _fullSkipDistance = fs;
        _legTable = legTable;
      });

      // Log analytics
      AnalyticsService().logCalculatorUsed(
        'Skip Distance Table Calculator',
        inputValues: {
          'probe_angle': angle,
          'thickness': thickness,
          'half_skip': hs,
          'full_skip': fs,
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Please enter valid numbers';
      });
    }
  }

  void _clearResults() {
    setState(() {
      _halfSkipDistance = null;
      _fullSkipDistance = null;
      _legTable = null;
      _errorMessage = null;
    });
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
                    // Header
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
                                '📏 Skip Distance Table',
                                style: AppTheme.titleLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Shear Wave UT - Legs 1-5',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Input fields
                    TextField(
                      controller: _angleController,
                      decoration: const InputDecoration(
                        labelText: 'Probe Angle (θ)',
                        hintText: 'Enter probe angle',
                        border: OutlineInputBorder(),
                        suffixText: 'degrees',
                        prefixIcon: Icon(Icons.adjust),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      onChanged: (_) => _clearResults(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _thicknessController,
                      decoration: const InputDecoration(
                        labelText: 'Thickness (T)',
                        hintText: 'Enter material thickness',
                        border: OutlineInputBorder(),
                        suffixText: 'inches',
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      onChanged: (_) => _clearResults(),
                    ),
                    const SizedBox(height: 24),

                    // Error message
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          border: Border.all(color: Colors.red.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Results - HS and FS
                    if (_halfSkipDistance != null) ...[
                      Container(
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.primaryBlue.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: AppTheme.primaryBlue,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Skip Distances',
                                  style: AppTheme.titleLarge.copyWith(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildResultRow(
                              'Half Skip (HS)',
                              '${_halfSkipDistance!.toStringAsFixed(3)} inches',
                              valueColor: AppTheme.primaryBlue,
                              isLarge: true,
                            ),
                            const SizedBox(height: 12),
                            _buildResultRow(
                              'Full Skip (FS)',
                              '${_fullSkipDistance!.toStringAsFixed(3)} inches',
                              valueColor: AppTheme.primaryBlue,
                              isLarge: true,
                            ),
                          ],
                        ),
                      ),

                      // Leg table
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.table_chart,
                                  color: Colors.green.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Surface Distance Table',
                                  style: TextStyle(
                                    color: Colors.green.shade900,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Table header
                            Row(
                              children: [
                                SizedBox(
                                  width: 50,
                                  child: Text(
                                    'Leg #',
                                    style: TextStyle(
                                      color: Colors.green.shade900,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Surface Distance',
                                    style: TextStyle(
                                      color: Colors.green.shade900,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    'Reflection',
                                    style: TextStyle(
                                      color: Colors.green.shade900,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            // Table rows
                            ..._legTable!.map((entry) {
                              final leg = entry['leg'] as int;
                              final surfaceDistance = entry['surfaceDistance'] as double;
                              final reflection = entry['reflectionSurface'] as String;
                              final isOdd = leg % 2 == 1;
                              
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 50,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isOdd 
                                              ? Colors.orange.shade100 
                                              : Colors.blue.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '$leg',
                                          style: TextStyle(
                                            color: isOdd 
                                                ? Colors.orange.shade900 
                                                : Colors.blue.shade900,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${surfaceDistance.toStringAsFixed(3)}"',
                                        style: TextStyle(
                                          color: Colors.green.shade900,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 80,
                                      child: Text(
                                        reflection,
                                        style: TextStyle(
                                          color: Colors.green.shade800,
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ],

                    // Calculate button
                    ElevatedButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate),
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

                    // Info section
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'About This Tool',
                                style: TextStyle(
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Quick reference for shear-wave UT surface distances in flat plates. Shows where each leg\'s beam reflection point falls on the surface.',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Key Formulas:',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Half Skip (HS) = T × tan(θ)\n'
                            'Full Skip (FS) = 2 × HS\n'
                            'Leg k Surface Distance = k × HS',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 11,
                              height: 1.4,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Reflection Pattern:',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• Odd legs (1, 3, 5): End at Bottom surface\n'
                            '• Even legs (2, 4): End at Top surface',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
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

  Widget _buildResultRow(
    String label,
    String value, {
    Color? valueColor,
    bool isLarge = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? 16 : 14,
              fontWeight: isLarge ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
            fontSize: isLarge ? 22 : 16,
          ),
        ),
      ],
    );
  }
}
