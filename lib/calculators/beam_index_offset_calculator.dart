import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../theme/app_theme.dart';
import '../services/analytics_service.dart';

class BeamIndexOffsetCalculator extends StatefulWidget {
  const BeamIndexOffsetCalculator({super.key});

  @override
  State<BeamIndexOffsetCalculator> createState() => _BeamIndexOffsetCalculatorState();
}

class _BeamIndexOffsetCalculatorState extends State<BeamIndexOffsetCalculator> {
  final TextEditingController _standoffController = TextEditingController();
  final TextEditingController _theta1Controller = TextEditingController();
  final TextEditingController _theta2Controller = TextEditingController();
  final TextEditingController _v1Controller = TextEditingController();
  final TextEditingController _v2Controller = TextEditingController();

  bool _useKnownAngle = true; // true = Mode A, false = Mode B
  String? _selectedMaterial1;
  String? _selectedMaterial2;
  
  double? _beamIndexOffset;
  double? _computedTheta1;
  String? _errorMessage;
  String? _warningMessage;

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
    _standoffController.dispose();
    _theta1Controller.dispose();
    _theta2Controller.dispose();
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
      _warningMessage = null;
      _beamIndexOffset = null;
      _computedTheta1 = null;
    });

    // Validate standoff height
    if (_standoffController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter standoff height';
      });
      return;
    }

    try {
      final h = double.parse(_standoffController.text);

      if (h <= 0) {
        setState(() {
          _errorMessage = 'Standoff height must be greater than 0';
        });
        return;
      }

      double theta1Deg;

      if (_useKnownAngle) {
        // Mode A: Known wedge angle
        if (_theta1Controller.text.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter wedge angle';
          });
          return;
        }

        theta1Deg = double.parse(_theta1Controller.text);

        if (theta1Deg < 0 || theta1Deg >= 90) {
          setState(() {
            _errorMessage = 'Wedge angle must be between 0° and 89°';
          });
          return;
        }
      } else {
        // Mode B: Solve wedge angle from Snell's Law
        if (_theta2Controller.text.isEmpty || 
            _v1Controller.text.isEmpty || 
            _v2Controller.text.isEmpty) {
          setState(() {
            _errorMessage = 'Please fill in all fields for Snell\'s Law calculation';
          });
          return;
        }

        final theta2Deg = double.parse(_theta2Controller.text);
        final v1 = double.parse(_v1Controller.text);
        final v2 = double.parse(_v2Controller.text);

        if (v1 <= 0 || v2 <= 0) {
          setState(() {
            _errorMessage = 'Velocities must be greater than 0';
          });
          return;
        }

        if (theta2Deg < 0 || theta2Deg >= 90) {
          setState(() {
            _errorMessage = 'Refracted angle must be between 0° and 89°';
          });
          return;
        }

        // Solve for θ1 using Snell's Law: sin(θ1) / V1 = sin(θ2) / V2
        final theta2Rad = theta2Deg * (pi / 180);
        final ratio = (v1 / v2) * sin(theta2Rad);

        // Clamp to prevent domain errors
        final clampedRatio = ratio.clamp(-1.0, 1.0);

        if (ratio.abs() > 1.0) {
          setState(() {
            _errorMessage = 'No real solution for θ1';
            _warningMessage = 'The velocity ratio and refracted angle produce an impossible configuration (|sin(θ1)| > 1)';
          });
          return;
        }

        final theta1Rad = asin(clampedRatio);
        theta1Deg = theta1Rad * (180 / pi);
        
        setState(() {
          _computedTheta1 = theta1Deg;
        });
      }

      // Prevent tan blowup near 90°
      if (theta1Deg >= 89.0) {
        setState(() {
          _errorMessage = 'Angle too close to 90° (tan approaches infinity)';
        });
        return;
      }

      // Calculate beam index offset: X = h × tan(θ1)
      final theta1Rad = theta1Deg * (pi / 180);
      final x = h * tan(theta1Rad);

      setState(() {
        _beamIndexOffset = x;
      });

      // Log analytics
      AnalyticsService().logCalculatorUsed(
        'Beam Index Offset Calculator',
        inputValues: {
          'mode': _useKnownAngle ? 'known_angle' : 'snell_law',
          'standoff_height': h,
          'theta1': theta1Deg,
          'beam_index_offset': x,
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
      _beamIndexOffset = null;
      _computedTheta1 = null;
      _errorMessage = null;
      _warningMessage = null;
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
                                '📏 Beam Index Offset',
                                style: AppTheme.titleLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Angle-Beam Wedge Geometry',
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.swap_horiz,
                                color: AppTheme.primaryBlue,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Calculation Mode',
                                  style: AppTheme.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment<bool>(
                                value: true,
                                label: Text('Known θ₁', style: TextStyle(fontSize: 14)),
                                tooltip: 'Use known wedge angle',
                              ),
                              ButtonSegment<bool>(
                                value: false,
                                label: Text('Solve θ₁ (Snell)', style: TextStyle(fontSize: 14)),
                                tooltip: 'Solve wedge angle from refracted angle',
                              ),
                            ],
                            selected: {_useKnownAngle},
                            onSelectionChanged: (Set<bool> newSelection) {
                              setState(() {
                                _useKnownAngle = newSelection.first;
                                _clearResults();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Common input: Standoff height
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.green.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'h is the normal (perpendicular) distance from element/virtual origin to the contact surface',
                              style: TextStyle(
                                color: Colors.green.shade900,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _standoffController,
                      decoration: const InputDecoration(
                        labelText: 'Standoff Height (h)',
                        hintText: 'Enter standoff height',
                        border: OutlineInputBorder(),
                        suffixText: 'units',
                        prefixIcon: Icon(Icons.height),
                        helperText: 'Perpendicular distance to contact surface',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      onChanged: (_) => _clearResults(),
                    ),
                    const SizedBox(height: 24),

                    // Mode-specific inputs
                    if (_useKnownAngle) ...[
                      // Mode A: Known wedge angle
                      Text(
                        'Known Wedge Angle',
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _theta1Controller,
                        decoration: const InputDecoration(
                          labelText: 'Wedge Angle (θ₁)',
                          hintText: 'Enter wedge angle',
                          border: OutlineInputBorder(),
                          suffixText: 'degrees',
                          prefixIcon: Icon(Icons.adjust),
                          helperText: 'Angle inside wedge relative to surface normal',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        onChanged: (_) => _clearResults(),
                      ),
                    ] else ...[
                      // Mode B: Solve θ1 from Snell's Law
                      Text(
                        'Solve Wedge Angle using Snell\'s Law',
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _theta2Controller,
                        decoration: const InputDecoration(
                          labelText: 'Refracted Angle in Material (θ₂)',
                          hintText: 'Enter refracted angle',
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
                      Text(
                        'Wedge Material',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
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
                          labelText: 'Wedge Velocity (V₁)',
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
                      Text(
                        'Test Material',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
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
                          labelText: 'Material Velocity (V₂)',
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
                    ],
                    const SizedBox(height: 24),

                    // Error/Warning messages
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          border: Border.all(color: Colors.red.withOpacity(0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
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
                            if (_warningMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _warningMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Results
                    if (_beamIndexOffset != null) ...[
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
                              'Beam Index Offset (X)',
                              '${_beamIndexOffset!.toStringAsFixed(3)} units',
                              valueColor: AppTheme.primaryBlue,
                              isLarge: true,
                            ),
                            if (_computedTheta1 != null) ...[
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                'Computed Wedge Angle (θ₁)',
                                '${_computedTheta1!.toStringAsFixed(3)}°',
                                valueColor: Colors.green,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Calculated using Snell\'s Law',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade700,
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
                                'About Beam Index Offset',
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
                            'This calculator estimates the horizontal offset (X) from the probe element (or virtual origin) to the beam exit point (index point) on the test surface for angle-beam wedge setups. This is essential for proper probe positioning.',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Formula:',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'X = h × tan(θ₁)',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Where:\n'
                            '• h = Standoff height (perpendicular distance)\n'
                            '• θ₁ = Wedge angle (inside wedge material)\n'
                            '• X = Horizontal offset to beam exit point',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 11,
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
            fontSize: isLarge ? 24 : 16,
          ),
        ),
      ],
    );
  }
}
