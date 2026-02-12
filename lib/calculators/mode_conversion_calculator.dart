import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../theme/app_theme.dart';
import '../services/analytics_service.dart';

class ModeConversionCalculator extends StatefulWidget {
  const ModeConversionCalculator({super.key});

  @override
  State<ModeConversionCalculator> createState() => _ModeConversionCalculatorState();
}

class _ModeConversionCalculatorState extends State<ModeConversionCalculator> {
  final TextEditingController _theta1Controller = TextEditingController();
  final TextEditingController _v1Controller = TextEditingController();
  final TextEditingController _vl2Controller = TextEditingController();
  final TextEditingController _vs2Controller = TextEditingController();

  double? _thetaS2;
  double? _thetaL2;
  double? _criticalS;
  double? _criticalL;
  double? _xS; // sin ratio for shear (for debugging)
  double? _xL; // sin ratio for longitudinal (for debugging)
  
  String? _shearStatus;
  String? _longitudinalStatus;
  String? _errorMessage;
  bool _showDetails = false;

  @override
  void dispose() {
    _theta1Controller.dispose();
    _v1Controller.dispose();
    _vl2Controller.dispose();
    _vs2Controller.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _errorMessage = null;
      _thetaS2 = null;
      _thetaL2 = null;
      _criticalS = null;
      _criticalL = null;
      _xS = null;
      _xL = null;
      _shearStatus = null;
      _longitudinalStatus = null;
    });

    // Validate inputs
    if (_theta1Controller.text.isEmpty || 
        _v1Controller.text.isEmpty || 
        _vl2Controller.text.isEmpty || 
        _vs2Controller.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }

    try {
      final theta1Deg = double.parse(_theta1Controller.text);
      final v1 = double.parse(_v1Controller.text);
      final vl2 = double.parse(_vl2Controller.text);
      final vs2 = double.parse(_vs2Controller.text);

      // Validate velocity values
      if (v1 <= 0 || vl2 <= 0 || vs2 <= 0) {
        setState(() {
          _errorMessage = 'All velocities must be greater than 0';
        });
        return;
      }

      // Validate angle range
      if (theta1Deg < 0 || theta1Deg >= 90) {
        setState(() {
          _errorMessage = 'Incident angle must be between 0° and 89°';
        });
        return;
      }

      // Convert angle to radians
      final theta1Rad = theta1Deg * (pi / 180);

      // Calculate refracted shear angle
      final xS = sin(theta1Rad) * (vs2 / v1);
      _xS = xS;

      if (xS.abs() > 1.0) {
        _shearStatus = 'No shear refraction (beyond critical for shear)';
      } else {
        final thetaS2Rad = asin(xS);
        _thetaS2 = thetaS2Rad * (180 / pi);
        _shearStatus = 'OK';
      }

      // Calculate refracted longitudinal angle
      final xL = sin(theta1Rad) * (vl2 / v1);
      _xL = xL;

      if (xL.abs() > 1.0) {
        _longitudinalStatus = 'No longitudinal refraction (beyond critical for longitudinal)';
      } else {
        final thetaL2Rad = asin(xL);
        _thetaL2 = thetaL2Rad * (180 / pi);
        _longitudinalStatus = 'OK';
      }

      // Calculate critical angles (only when V2 > V1)
      if (vs2 > v1) {
        final criticalRatioS = v1 / vs2;
        if (criticalRatioS <= 1.0) {
          _criticalS = asin(criticalRatioS) * (180 / pi);
        }
      }

      if (vl2 > v1) {
        final criticalRatioL = v1 / vl2;
        if (criticalRatioL <= 1.0) {
          _criticalL = asin(criticalRatioL) * (180 / pi);
        }
      }

      // Log analytics
      AnalyticsService().logCalculatorUsed(
        'Mode Conversion Calculator',
        inputValues: {
          'theta1': theta1Deg,
          'v1': v1,
          'vl2': vl2,
          'vs2': vs2,
          'has_shear_solution': _thetaS2 != null,
          'has_longitudinal_solution': _thetaL2 != null,
        },
      );

      setState(() {});
    } catch (e) {
      setState(() {
        _errorMessage = 'Please enter valid numbers';
      });
    }
  }

  void _clearResults() {
    setState(() {
      _thetaS2 = null;
      _thetaL2 = null;
      _criticalS = null;
      _criticalL = null;
      _xS = null;
      _xL = null;
      _shearStatus = null;
      _longitudinalStatus = null;
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
                                'Mode Conversion Calculator',
                                style: AppTheme.titleLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Snell\'s Law for Multiple Wave Modes',
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

                    // Medium 1 section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.layers,
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Medium 1 (Wedge/Couplant)',
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _theta1Controller,
                      decoration: const InputDecoration(
                        labelText: 'Incident Angle (θ₁)',
                        hintText: 'Enter angle in medium 1',
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
                    const SizedBox(height: 12),
                    TextField(
                      controller: _v1Controller,
                      decoration: const InputDecoration(
                        labelText: 'Velocity V₁',
                        hintText: 'Wave velocity in medium 1',
                        border: OutlineInputBorder(),
                        suffixText: 'm/s',
                        prefixIcon: Icon(Icons.speed),
                        helperText: 'Usually longitudinal velocity of wedge',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      onChanged: (_) => _clearResults(),
                    ),
                    const SizedBox(height: 24),

                    // Medium 2 section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.view_module,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Medium 2 (Test Material)',
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _vl2Controller,
                      decoration: const InputDecoration(
                        labelText: 'Longitudinal Velocity (VL₂)',
                        hintText: 'L-wave velocity in material',
                        border: OutlineInputBorder(),
                        suffixText: 'm/s',
                        prefixIcon: Icon(Icons.graphic_eq),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      onChanged: (_) => _clearResults(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _vs2Controller,
                      decoration: const InputDecoration(
                        labelText: 'Shear Velocity (VS₂)',
                        hintText: 'S-wave velocity in material',
                        border: OutlineInputBorder(),
                        suffixText: 'm/s',
                        prefixIcon: Icon(Icons.waves),
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

                    // Results - Shear Mode
                    if (_shearStatus != null) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _thetaS2 != null 
                              ? Colors.purple.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _thetaS2 != null 
                                ? Colors.purple.withOpacity(0.3)
                                : Colors.orange.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _thetaS2 != null ? Icons.check_circle : Icons.block,
                                  color: _thetaS2 != null ? Colors.purple : Colors.orange,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Shear Mode (S-wave)',
                                  style: AppTheme.titleMedium.copyWith(
                                    color: _thetaS2 != null ? Colors.purple : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_thetaS2 != null) ...[
                              _buildResultRow(
                                'Refracted Shear Angle (θS₂)',
                                '${_thetaS2!.toStringAsFixed(3)}°',
                                valueColor: Colors.purple,
                              ),
                            ] else ...[
                              Text(
                                _shearStatus!,
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Results - Longitudinal Mode
                    if (_longitudinalStatus != null) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _thetaL2 != null 
                              ? AppTheme.primaryBlue.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _thetaL2 != null 
                                ? AppTheme.primaryBlue.withOpacity(0.3)
                                : Colors.orange.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _thetaL2 != null ? Icons.check_circle : Icons.block,
                                  color: _thetaL2 != null ? AppTheme.primaryBlue : Colors.orange,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Longitudinal Mode (L-wave)',
                                  style: AppTheme.titleMedium.copyWith(
                                    color: _thetaL2 != null ? AppTheme.primaryBlue : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_thetaL2 != null) ...[
                              _buildResultRow(
                                'Refracted Longitudinal Angle (θL₂)',
                                '${_thetaL2!.toStringAsFixed(3)}°',
                                valueColor: AppTheme.primaryBlue,
                              ),
                            ] else ...[
                              Text(
                                _longitudinalStatus!,
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Critical angles
                    if (_criticalS != null || _criticalL != null) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.warning_amber,
                                  color: Colors.amber.shade700,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Critical Incident Angles',
                                  style: AppTheme.titleMedium.copyWith(
                                    color: Colors.amber.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_criticalS != null)
                              _buildResultRow(
                                'Critical for Shear (θcrit_S)',
                                '${_criticalS!.toStringAsFixed(3)}°',
                                valueColor: Colors.purple,
                              ),
                            if (_criticalS != null && _criticalL != null)
                              const SizedBox(height: 8),
                            if (_criticalL != null)
                              _buildResultRow(
                                'Critical for Longitudinal (θcrit_L)',
                                '${_criticalL!.toStringAsFixed(3)}°',
                                valueColor: AppTheme.primaryBlue,
                              ),
                            const SizedBox(height: 12),
                            Text(
                              'Beyond these angles, total internal reflection occurs for the respective mode',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber.shade800,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Details section (expandable)
                    if (_xS != null || _xL != null) ...[
                      ExpansionTile(
                        title: Text(
                          'Details',
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        initiallyExpanded: _showDetails,
                        onExpansionChanged: (expanded) {
                          setState(() {
                            _showDetails = expanded;
                          });
                        },
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                if (_xS != null)
                                  _buildResultRow(
                                    'Shear ratio (xS = sin(θ₁) × VS₂/V₁)',
                                    _xS!.toStringAsFixed(4),
                                    valueColor: Colors.purple,
                                  ),
                                const SizedBox(height: 8),
                                if (_xL != null)
                                  _buildResultRow(
                                    'Longitudinal ratio (xL = sin(θ₁) × VL₂/V₁)',
                                    _xL!.toStringAsFixed(4),
                                    valueColor: AppTheme.primaryBlue,
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                  'Valid solutions require |x| ≤ 1.0',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Calculate button
                    ElevatedButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate),
                      label: const Text(
                        'Calculate Mode Conversion',
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
                                'About Mode Conversion',
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
                            'This calculator predicts refracted angles for different wave modes (Longitudinal and Shear) when entering a test material from a wedge/couplant. Each mode is treated as a separate Snell\'s Law calculation using the appropriate velocities.',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Disclaimer: Ideal Snell\'s-law prediction; real mode amplitudes depend on interface, wedge design, and coupling.',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 11,
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
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
