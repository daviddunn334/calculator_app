import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../theme/app_theme.dart';
import '../services/analytics_service.dart';

class SoundPathLengthCalculator extends StatefulWidget {
  const SoundPathLengthCalculator({super.key});

  @override
  State<SoundPathLengthCalculator> createState() => _SoundPathLengthCalculatorState();
}

class _SoundPathLengthCalculatorState extends State<SoundPathLengthCalculator> {
  final TextEditingController _angleController = TextEditingController();
  final TextEditingController _depthController = TextEditingController();
  final TextEditingController _surfaceDistanceController = TextEditingController();

  bool _isModeA = true; // Mode A: Depth → Sound Path, Mode B: Surface Distance → Sound Path

  double? _soundPath;
  double? _relatedDepth;
  double? _relatedSurfaceDistance;
  String? _errorMessage;

  @override
  void dispose() {
    _angleController.dispose();
    _depthController.dispose();
    _surfaceDistanceController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _errorMessage = null;
      _soundPath = null;
      _relatedDepth = null;
      _relatedSurfaceDistance = null;
    });

    // Validate angle input (always required)
    if (_angleController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter probe angle';
      });
      return;
    }

    // Validate mode-specific input
    if (_isModeA && _depthController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter depth';
      });
      return;
    }

    if (!_isModeA && _surfaceDistanceController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter surface distance';
      });
      return;
    }

    try {
      final angle = double.parse(_angleController.text);

      // Validation: angle must be 1-89 degrees
      if (angle < 1 || angle >= 90) {
        setState(() {
          _errorMessage = 'Probe angle must be between 1° and 89°';
        });
        return;
      }

      // Convert angle to radians
      final angleRad = angle * (pi / 180);

      // Check for divide-by-zero cases
      final cosValue = cos(angleRad);
      final sinValue = sin(angleRad);
      final tanValue = tan(angleRad);

      if (cosValue.abs() < 0.0001 || sinValue.abs() < 0.0001 || tanValue.abs() < 0.0001) {
        setState(() {
          _errorMessage = 'Angle too close to 0° or 90° - calculations unstable';
        });
        return;
      }

      if (_isModeA) {
        // Mode A: Given Depth, compute Sound Path and Surface Distance
        final depth = double.parse(_depthController.text);

        if (depth <= 0) {
          setState(() {
            _errorMessage = 'Depth must be greater than 0';
          });
          return;
        }

        // SoundPath = Depth / cos(θ)
        final soundPath = depth / cosValue;

        // SurfaceDistance = Depth / tan(θ)
        final surfaceDistance = depth / tanValue;

        setState(() {
          _soundPath = soundPath;
          _relatedDepth = depth;
          _relatedSurfaceDistance = surfaceDistance;
        });

        // Log analytics
        AnalyticsService().logCalculatorUsed(
          'Sound Path Length Calculator',
          inputValues: {
            'mode': 'depth_to_sound_path',
            'probe_angle': angle,
            'depth': depth,
            'sound_path': soundPath,
          },
        );
      } else {
        // Mode B: Given Surface Distance, compute Sound Path and Depth
        final surfaceDistance = double.parse(_surfaceDistanceController.text);

        if (surfaceDistance <= 0) {
          setState(() {
            _errorMessage = 'Surface distance must be greater than 0';
          });
          return;
        }

        // Depth = SurfaceDistance × tan(θ)
        final depth = surfaceDistance * tanValue;

        // SoundPath = SurfaceDistance / sin(θ)
        final soundPath = surfaceDistance / sinValue;

        setState(() {
          _soundPath = soundPath;
          _relatedDepth = depth;
          _relatedSurfaceDistance = surfaceDistance;
        });

        // Log analytics
        AnalyticsService().logCalculatorUsed(
          'Sound Path Length Calculator',
          inputValues: {
            'mode': 'surface_distance_to_sound_path',
            'probe_angle': angle,
            'surface_distance': surfaceDistance,
            'sound_path': soundPath,
          },
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Please enter valid numbers';
      });
    }
  }

  void _clearResults() {
    setState(() {
      _soundPath = null;
      _relatedDepth = null;
      _relatedSurfaceDistance = null;
      _errorMessage = null;
    });
  }

  void _toggleMode() {
    setState(() {
      _isModeA = !_isModeA;
      _clearResults();
      // Clear the mode-specific input field
      _depthController.clear();
      _surfaceDistanceController.clear();
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
                                '📏 Sound Path Length',
                                style: AppTheme.titleLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'True Beam Path Through Material',
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

                    // Mode Toggle
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Calculation Mode',
                            style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment(
                                value: true,
                                label: Text('Depth → Path'),
                                icon: Icon(Icons.arrow_downward, size: 16),
                              ),
                              ButtonSegment(
                                value: false,
                                label: Text('Surface → Path'),
                                icon: Icon(Icons.arrow_forward, size: 16),
                              ),
                            ],
                            selected: {_isModeA},
                            onSelectionChanged: (Set<bool> newSelection) {
                              _toggleMode();
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return AppTheme.primaryBlue;
                                  }
                                  return Colors.white;
                                },
                              ),
                              foregroundColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return Colors.white;
                                  }
                                  return AppTheme.textPrimary;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Common input: Probe Angle
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

                    // Mode A: Depth input
                    if (_isModeA) ...[
                      TextField(
                        controller: _depthController,
                        decoration: const InputDecoration(
                          labelText: 'Depth (D)',
                          hintText: 'Enter depth',
                          border: OutlineInputBorder(),
                          suffixText: 'inches',
                          prefixIcon: Icon(Icons.height),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        onChanged: (_) => _clearResults(),
                      ),
                    ],

                    // Mode B: Surface Distance input
                    if (!_isModeA) ...[
                      TextField(
                        controller: _surfaceDistanceController,
                        decoration: const InputDecoration(
                          labelText: 'Surface Distance (SD)',
                          hintText: 'Enter surface distance',
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
                    ],
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
                    if (_soundPath != null) ...[
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
                            // Sound Path (primary result)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Sound Path Length',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${_soundPath!.toStringAsFixed(3)}"',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Related values
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Complete Reference',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildResultRow(
                                    'Depth',
                                    '${_relatedDepth!.toStringAsFixed(3)}"',
                                  ),
                                  const Divider(height: 20),
                                  _buildResultRow(
                                    'Surface Distance',
                                    '${_relatedSurfaceDistance!.toStringAsFixed(3)}"',
                                  ),
                                  const Divider(height: 20),
                                  _buildResultRow(
                                    'Sound Path',
                                    '${_soundPath!.toStringAsFixed(3)}"',
                                  ),
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
                            'Calculates the true sound path (beam path length) through the material for shear-wave UT in flat plates.',
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
                            'Mode A (Given Depth):\n'
                            '  Sound Path = Depth / cos(θ)\n'
                            '  Surface Distance = Depth / tan(θ)\n\n'
                            'Mode B (Given Surface Distance):\n'
                            '  Depth = Surface Distance × tan(θ)\n'
                            '  Sound Path = Surface Distance / sin(θ)',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 11,
                              height: 1.5,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Right Triangle Relationships:',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• cos(θ) = Depth / Sound Path\n'
                            '• sin(θ) = Surface Distance / Sound Path\n'
                            '• tan(θ) = Depth / Surface Distance',
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

  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
