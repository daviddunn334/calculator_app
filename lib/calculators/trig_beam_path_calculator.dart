import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../theme/app_theme.dart';
import '../services/analytics_service.dart';

class TrigBeamPathCalculator extends StatefulWidget {
  const TrigBeamPathCalculator({super.key});

  @override
  State<TrigBeamPathCalculator> createState() => _TrigBeamPathCalculatorState();
}

class _TrigBeamPathCalculatorState extends State<TrigBeamPathCalculator> {
  final TextEditingController _angleController = TextEditingController();
  final TextEditingController _thicknessController = TextEditingController();
  final TextEditingController _surfaceDistanceController = TextEditingController();

  double? _depth;
  int? _legNumber;
  double? _distanceIntoLeg;
  double? _fullSkipDistance;
  double? _halfSkipDistance;
  List<Map<String, double>>? _skipTable;
  String? _errorMessage;

  @override
  void dispose() {
    _angleController.dispose();
    _thicknessController.dispose();
    _surfaceDistanceController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _errorMessage = null;
      _depth = null;
      _legNumber = null;
      _distanceIntoLeg = null;
      _fullSkipDistance = null;
      _halfSkipDistance = null;
      _skipTable = null;
    });

    // Validate inputs
    if (_angleController.text.isEmpty || 
        _thicknessController.text.isEmpty || 
        _surfaceDistanceController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }

    try {
      final angle = double.parse(_angleController.text);
      final thickness = double.parse(_thicknessController.text);
      final surfaceDistance = double.parse(_surfaceDistanceController.text);

      // Validation
      if (angle <= 0 || angle >= 90) {
        setState(() {
          _errorMessage = 'Angle must be between 1° and 89°';
        });
        return;
      }

      if (thickness <= 0) {
        setState(() {
          _errorMessage = 'Thickness must be greater than 0';
        });
        return;
      }

      if (surfaceDistance < 0) {
        setState(() {
          _errorMessage = 'Surface distance cannot be negative';
        });
        return;
      }

      // Convert angle to radians
      final angleRad = angle * (pi / 180);
      final tanAngle = tan(angleRad);

      // Calculate Half Skip Distance
      final hs = thickness * tanAngle;

      // Calculate Full Skip Distance
      final fs = 2 * thickness * tanAngle;

      // Calculate Leg Number
      final legNum = (surfaceDistance / hs).floor() + 1;

      // Calculate Position in Current Leg
      final legPosition = surfaceDistance % hs;

      // Calculate Depth
      double depth;
      if (legNum % 2 == 1) {
        // Odd leg: traveling down
        depth = legPosition * tanAngle;
      } else {
        // Even leg: traveling up
        depth = thickness - (legPosition * tanAngle);
      }

      // Clamp depth between 0 and thickness
      depth = depth.clamp(0.0, thickness);

      // Generate skip distance table for first 4 legs
      final skipTable = <Map<String, double>>[];
      for (int i = 1; i <= 4; i++) {
        skipTable.add({
          'leg': i.toDouble(),
          'distance': i * hs,
        });
      }

      setState(() {
        _depth = depth;
        _legNumber = legNum;
        _distanceIntoLeg = legPosition;
        _fullSkipDistance = fs;
        _halfSkipDistance = hs;
        _skipTable = skipTable;
      });

      // Log analytics
      AnalyticsService().logCalculatorUsed(
        'Trig Beam Path Calculator',
        inputValues: {
          'probe_angle': angle,
          'thickness': thickness,
          'surface_distance': surfaceDistance,
          'leg_number': legNum,
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
      _depth = null;
      _legNumber = null;
      _distanceIntoLeg = null;
      _fullSkipDistance = null;
      _halfSkipDistance = null;
      _skipTable = null;
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
                                '📐 Trigonometric Beam Path Tool',
                                style: AppTheme.titleLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Shear Wave UT Beam Path Calculator',
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
                        hintText: 'Enter angle',
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
                        labelText: 'Material Thickness (T)',
                        hintText: 'Enter thickness',
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
                    const SizedBox(height: 16),
                    TextField(
                      controller: _surfaceDistanceController,
                      decoration: const InputDecoration(
                        labelText: 'Surface Distance (SD)',
                        hintText: 'Enter surface distance',
                        border: OutlineInputBorder(),
                        suffixText: 'inches',
                        prefixIcon: Icon(Icons.linear_scale),
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

                    // Results
                    if (_depth != null) ...[
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
                                  'Results',
                                  style: AppTheme.titleLarge.copyWith(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildResultRow(
                              'Calculated Depth (D)',
                              '${_depth!.toStringAsFixed(3)} inches',
                              valueColor: AppTheme.primaryBlue,
                              isLarge: true,
                            ),
                            const SizedBox(height: 12),
                            _buildResultRow(
                              'Leg Number (L)',
                              '$_legNumber',
                              valueColor: AppTheme.primaryBlue,
                            ),
                            const SizedBox(height: 8),
                            _buildResultRow(
                              'Distance into Current Leg',
                              '${_distanceIntoLeg!.toStringAsFixed(3)} inches',
                              valueColor: AppTheme.primaryBlue,
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 12),
                            _buildResultRow(
                              'Full Skip Distance (FS)',
                              '${_fullSkipDistance!.toStringAsFixed(3)} inches',
                              valueColor: Colors.orange,
                            ),
                            const SizedBox(height: 8),
                            _buildResultRow(
                              'Half Skip Distance (HS)',
                              '${_halfSkipDistance!.toStringAsFixed(3)} inches',
                              valueColor: Colors.orange,
                            ),
                          ],
                        ),
                      ),

                      // Skip Distance Table
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.table_chart,
                                  color: Colors.orange.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Skip Distance Table',
                                  style: TextStyle(
                                    color: Colors.orange.shade900,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ..._skipTable!.map((entry) {
                              final legNum = entry['leg']!.toInt();
                              final distance = entry['distance']!;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Leg $legNum Skip:',
                                      style: TextStyle(
                                        color: Colors.orange.shade900,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${distance.toStringAsFixed(3)} inches',
                                      style: TextStyle(
                                        color: Colors.orange.shade900,
                                        fontWeight: FontWeight.bold,
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
                            'This tool calculates beam path geometry for shear wave UT inspections on flat plates using basic right-triangle trigonometry.',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Assumptions:',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• Angle is already refracted inside material\n'
                            '• Flat plate geometry (no curvature)\n'
                            '• Pure trigonometry (no velocity calculations)',
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
                            'Leg Number = floor(SD / HS) + 1\n'
                            'Depth (odd leg) = LegPosition × tan(θ)\n'
                            'Depth (even leg) = T - (LegPosition × tan(θ))',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 11,
                              height: 1.4,
                              fontFamily: 'monospace',
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
            fontSize: isLarge ? 24 : 16,
          ),
        ),
      ],
    );
  }
}
