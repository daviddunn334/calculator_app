import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../theme/app_theme.dart';
import '../services/analytics_service.dart';

class CriticalAngleCalculator extends StatefulWidget {
  const CriticalAngleCalculator({super.key});

  @override
  State<CriticalAngleCalculator> createState() => _CriticalAngleCalculatorState();
}

class _CriticalAngleCalculatorState extends State<CriticalAngleCalculator> {
  final TextEditingController _v1Controller = TextEditingController();
  final TextEditingController _vl2Controller = TextEditingController();
  final TextEditingController _vs2Controller = TextEditingController();

  double? _criticalL;
  double? _criticalS;
  double? _ratioL;
  double? _ratioS;
  String? _errorMessage;

  @override
  void dispose() {
    _v1Controller.dispose();
    _vl2Controller.dispose();
    _vs2Controller.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _errorMessage = null;
      _criticalL = null;
      _criticalS = null;
      _ratioL = null;
      _ratioS = null;
    });

    // Validate inputs
    if (_v1Controller.text.isEmpty || 
        _vl2Controller.text.isEmpty || 
        _vs2Controller.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all velocity fields';
      });
      return;
    }

    try {
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

      // Calculate velocity ratios
      _ratioL = v1 / vl2;
      _ratioS = v1 / vs2;

      // Calculate critical angle for L-wave
      if (_ratioL! <= 1.0 && vl2 > v1) {
        _criticalL = asin(_ratioL!) * (180 / pi);
      }

      // Calculate critical angle for S-wave
      if (_ratioS! <= 1.0 && vs2 > v1) {
        _criticalS = asin(_ratioS!) * (180 / pi);
      }

      // Log analytics
      AnalyticsService().logCalculatorUsed(
        'Critical Angle Calculator',
        inputValues: {
          'v1': v1,
          'vl2': vl2,
          'vs2': vs2,
          'has_l_wave_critical': _criticalL != null,
          'has_s_wave_critical': _criticalS != null,
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
      _criticalL = null;
      _criticalS = null;
      _ratioL = null;
      _ratioS = null;
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
                                'Critical Angle Calculator',
                                style: AppTheme.titleLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'L-wave & S-wave Critical Angles',
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
                            'Medium 1 (Incident Side)',
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
                      controller: _v1Controller,
                      decoration: const InputDecoration(
                        labelText: 'Velocity V₁',
                        hintText: 'Wave velocity in wedge/couplant',
                        border: OutlineInputBorder(),
                        suffixText: 'm/s',
                        prefixIcon: Icon(Icons.speed),
                        helperText: 'e.g., Rexolite: 2337 m/s',
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
                        helperText: 'e.g., Steel: 5920 m/s',
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
                        helperText: 'e.g., Steel: 3240 m/s',
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
                    if (_ratioL != null && _ratioS != null) ...[
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
                                  Icons.analytics,
                                  color: AppTheme.primaryBlue,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Critical Angles',
                                  style: AppTheme.titleLarge.copyWith(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // L-wave critical angle
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _criticalL != null 
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
                                        _criticalL != null ? Icons.check_circle : Icons.block,
                                        color: _criticalL != null ? AppTheme.primaryBlue : Colors.orange,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Longitudinal Wave (L-wave)',
                                        style: AppTheme.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: _criticalL != null ? AppTheme.primaryBlue : Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildResultRow(
                                    'Velocity Ratio (rL)',
                                    _ratioL!.toStringAsFixed(4),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildResultRow(
                                    'Critical Angle (θcrit_L)',
                                    _criticalL != null 
                                        ? '${_criticalL!.toStringAsFixed(3)}°'
                                        : 'N/A',
                                    valueColor: _criticalL != null ? AppTheme.primaryBlue : Colors.orange,
                                    isLarge: true,
                                  ),
                                  if (_criticalL == null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'No critical angle (VL₂ must be > V₁)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange.shade700,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // S-wave critical angle
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _criticalS != null 
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
                                        _criticalS != null ? Icons.check_circle : Icons.block,
                                        color: _criticalS != null ? Colors.purple : Colors.orange,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Shear Wave (S-wave)',
                                        style: AppTheme.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: _criticalS != null ? Colors.purple : Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildResultRow(
                                    'Velocity Ratio (rS)',
                                    _ratioS!.toStringAsFixed(4),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildResultRow(
                                    'Critical Angle (θcrit_S)',
                                    _criticalS != null 
                                        ? '${_criticalS!.toStringAsFixed(3)}°'
                                        : 'N/A',
                                    valueColor: _criticalS != null ? Colors.purple : Colors.orange,
                                    isLarge: true,
                                  ),
                                  if (_criticalS == null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'No critical angle (VS₂ must be > V₁)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange.shade700,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Calculate button
                    ElevatedButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate),
                      label: const Text(
                        'Calculate Critical Angles',
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
                                'About Critical Angles',
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
                            'The critical angle is the incident angle in Medium 1 where the refracted wave in Medium 2 reaches 90°. Beyond this angle, there is no refracted wave for that mode (total internal reflection occurs).',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Formula: θcrit = asin(V₁ / V₂)',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade600),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber,
                                  color: Colors.amber.shade900,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Critical angle exists only when V₂ (mode velocity in Medium 2) is greater than V₁.',
                                    style: TextStyle(
                                      color: Colors.amber.shade900,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
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
              fontSize: isLarge ? 14 : 12,
              fontWeight: isLarge ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppTheme.textPrimary,
            fontSize: isLarge ? 20 : 14,
          ),
        ),
      ],
    );
  }
}
