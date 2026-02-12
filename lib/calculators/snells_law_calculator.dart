import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../theme/app_theme.dart';
import '../services/analytics_service.dart';

class SnellsLawCalculator extends StatefulWidget {
  const SnellsLawCalculator({super.key});

  @override
  State<SnellsLawCalculator> createState() => _SnellsLawCalculatorState();
}

class _SnellsLawCalculatorState extends State<SnellsLawCalculator> {
  final TextEditingController _angleController = TextEditingController();
  final TextEditingController _v1Controller = TextEditingController();
  final TextEditingController _v2Controller = TextEditingController();

  bool _solveForTheta2 = true; // true = solve for θ2, false = solve for θ1
  String? _selectedMaterial1;
  String? _selectedMaterial2;
  
  double? _resultAngle;
  double? _criticalAngle;
  String? _errorMessage;
  String? _statusMessage;

  // Material velocity presets (in m/s)
  final Map<String, double> _materialVelocities = {
    'Custom': 0,
    'Rexolite': 2337,
    'Acrylic': 2730,
    'Water': 1480,
    'Steel (Shear)': 3240,
    'Steel (Longitudinal)': 5920,
  };

  @override
  void dispose() {
    _angleController.dispose();
    _v1Controller.dispose();
    _v2Controller.dispose();
    super.dispose();
  }

  void _onMaterial1Changed(String? value) {
    setState(() {
      _selectedMaterial1 = value;
      if (value != null && value != 'Custom') {
        _v1Controller.text = _materialVelocities[value]!.toString();
      }
    });
  }

  void _onMaterial2Changed(String? value) {
    setState(() {
      _selectedMaterial2 = value;
      if (value != null && value != 'Custom') {
        _v2Controller.text = _materialVelocities[value]!.toString();
      }
    });
  }

  void _calculate() {
    setState(() {
      _errorMessage = null;
      _resultAngle = null;
      _criticalAngle = null;
      _statusMessage = null;
    });

    // Validate inputs
    if (_angleController.text.isEmpty || _v1Controller.text.isEmpty || _v2Controller.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }

    try {
      final angle = double.parse(_angleController.text);
      final v1 = double.parse(_v1Controller.text);
      final v2 = double.parse(_v2Controller.text);

      if (v1 <= 0 || v2 <= 0) {
        setState(() {
          _errorMessage = 'Velocities must be greater than 0';
        });
        return;
      }

      if (angle < 0 || angle >= 90) {
        setState(() {
          _errorMessage = 'Angle must be between 0° and 90°';
        });
        return;
      }

      // Convert angle to radians
      final angleRad = angle * (pi / 180);

      if (_solveForTheta2) {
        // Solve for refracted angle θ2
        _solveForRefractedAngle(angleRad, v1, v2);
      } else {
        // Solve for incident angle θ1
        _solveForIncidentAngle(angleRad, v1, v2);
      }

      // Calculate critical angle if applicable (only when V2 > V1)
      if (v2 > v1) {
        final criticalRatio = v1 / v2;
        if (criticalRatio <= 1.0) {
          _criticalAngle = asin(criticalRatio) * (180 / pi);
        }
      }

      // Log analytics
      AnalyticsService().logCalculatorUsed(
        'Snells Law Calculator',
        inputValues: {
          'solve_mode': _solveForTheta2 ? 'theta2' : 'theta1',
          'input_angle': angle,
          'v1': v1,
          'v2': v2,
          'has_solution': _resultAngle != null,
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Please enter valid numbers';
      });
    }
  }

  void _solveForRefractedAngle(double theta1Rad, double v1, double v2) {
    // sin(θ2) = sin(θ1) × (V2 / V1)
    final ratio = sin(theta1Rad) * (v2 / v1);

    if (ratio.abs() > 1.0) {
      setState(() {
        _errorMessage = 'No refraction possible (beyond critical angle)';
        _statusMessage = 'Total internal reflection occurs';
      });
      return;
    }

    final theta2Rad = asin(ratio);
    final theta2Deg = theta2Rad * (180 / pi);

    setState(() {
      _resultAngle = theta2Deg;
      _statusMessage = 'Valid refraction angle';
    });
  }

  void _solveForIncidentAngle(double theta2Rad, double v1, double v2) {
    // sin(θ1) = sin(θ2) × (V1 / V2)
    final ratio = sin(theta2Rad) * (v1 / v2);

    if (ratio.abs() > 1.0) {
      setState(() {
        _errorMessage = 'No real solution for incident angle';
        _statusMessage = 'Invalid configuration';
      });
      return;
    }

    final theta1Rad = asin(ratio);
    final theta1Deg = theta1Rad * (180 / pi);

    setState(() {
      _resultAngle = theta1Deg;
      _statusMessage = 'Valid incident angle';
    });
  }

  void _clearResults() {
    setState(() {
      _resultAngle = null;
      _criticalAngle = null;
      _errorMessage = null;
      _statusMessage = null;
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
                                '⚡ Snell\'s Law Calculator',
                                style: AppTheme.titleLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ultrasonic Wave Refraction',
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

                    // Mode toggle
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.swap_horiz,
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Solve Mode',
                              style: AppTheme.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ),
                          SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment<bool>(
                                value: true,
                                label: Text('θ₂', style: TextStyle(fontSize: 16)),
                                tooltip: 'Solve for refracted angle',
                              ),
                              ButtonSegment<bool>(
                                value: false,
                                label: Text('θ₁', style: TextStyle(fontSize: 16)),
                                tooltip: 'Solve for incident angle',
                              ),
                            ],
                            selected: {_solveForTheta2},
                            onSelectionChanged: (Set<bool> newSelection) {
                              setState(() {
                                _solveForTheta2 = newSelection.first;
                                _clearResults();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Angle input
                    TextField(
                      controller: _angleController,
                      decoration: InputDecoration(
                        labelText: _solveForTheta2 
                            ? 'Incident Angle (θ₁)' 
                            : 'Refracted Angle (θ₂)',
                        hintText: 'Enter angle',
                        border: const OutlineInputBorder(),
                        suffixText: 'degrees',
                        prefixIcon: const Icon(Icons.adjust),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      onChanged: (_) => _clearResults(),
                    ),
                    const SizedBox(height: 16),

                    // Medium 1 section
                    Text(
                      'Medium 1 (${_solveForTheta2 ? 'Incident' : 'Refracted'})',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedMaterial1,
                      decoration: const InputDecoration(
                        labelText: 'Material Preset',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.layers),
                      ),
                      items: _materialVelocities.keys.map((String material) {
                        return DropdownMenuItem<String>(
                          value: material,
                          child: Text(material),
                        );
                      }).toList(),
                      onChanged: _onMaterial1Changed,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _v1Controller,
                      decoration: const InputDecoration(
                        labelText: 'Velocity V₁',
                        hintText: 'Enter velocity',
                        border: OutlineInputBorder(),
                        suffixText: 'm/s',
                        prefixIcon: Icon(Icons.speed),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      onChanged: (_) {
                        _clearResults();
                        if (_selectedMaterial1 != 'Custom') {
                          setState(() {
                            _selectedMaterial1 = 'Custom';
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Medium 2 section
                    Text(
                      'Medium 2 (${_solveForTheta2 ? 'Refracted' : 'Incident'})',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedMaterial2,
                      decoration: const InputDecoration(
                        labelText: 'Material Preset',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.layers),
                      ),
                      items: _materialVelocities.keys.map((String material) {
                        return DropdownMenuItem<String>(
                          value: material,
                          child: Text(material),
                        );
                      }).toList(),
                      onChanged: _onMaterial2Changed,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _v2Controller,
                      decoration: const InputDecoration(
                        labelText: 'Velocity V₂',
                        hintText: 'Enter velocity',
                        border: OutlineInputBorder(),
                        suffixText: 'm/s',
                        prefixIcon: Icon(Icons.speed),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      onChanged: (_) {
                        _clearResults();
                        if (_selectedMaterial2 != 'Custom') {
                          setState(() {
                            _selectedMaterial2 = 'Custom';
                          });
                        }
                      },
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (_statusMessage != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      _statusMessage!,
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Results
                    if (_resultAngle != null) ...[
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
                              _solveForTheta2 ? 'Refracted Angle (θ₂)' : 'Incident Angle (θ₁)',
                              '${_resultAngle!.toStringAsFixed(3)}°',
                              valueColor: AppTheme.primaryBlue,
                              isLarge: true,
                            ),
                            if (_statusMessage != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _statusMessage!,
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (_criticalAngle != null) ...[
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                'Critical Angle',
                                '${_criticalAngle!.toStringAsFixed(3)}°',
                                valueColor: Colors.orange,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Beyond this angle, total internal reflection occurs',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade700,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
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
                                'About Snell\'s Law',
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
                            'Snell\'s Law describes how ultrasonic waves refract when passing from one medium to another (e.g., Rexolite wedge → Steel). Use this for quick field checks when setting up wedges, probes, and verifying refracted angles.',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Formula: sin(θ₁)/V₁ = sin(θ₂)/V₂',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
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
