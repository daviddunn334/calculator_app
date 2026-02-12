import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../theme/app_theme.dart';
import '../services/analytics_service.dart';

class TofCalculator extends StatefulWidget {
  const TofCalculator({super.key});

  @override
  State<TofCalculator> createState() => _TofCalculatorState();
}

class _TofCalculatorState extends State<TofCalculator> {
  final TextEditingController _velocityController = TextEditingController();
  final TextEditingController _soundPathController = TextEditingController();
  final TextEditingController _tofController = TextEditingController();
  final TextEditingController _angleController = TextEditingController();
  final TextEditingController _depthController = TextEditingController();
  final TextEditingController _surfaceDistanceController = TextEditingController();

  bool _isModeA = true; // Mode A: Sound Path → TOF, Mode B: TOF → Sound Path
  bool _useAngleMode = false; // Optional angle sub-mode for computing Sound Path
  bool _useDepth = true; // true = use Depth, false = use Surface Distance

  double? _resultTof;
  double? _resultTofMicroseconds;
  double? _resultSoundPath;
  double? _computedDepth;
  double? _computedSurfaceDistance;
  String? _errorMessage;

  @override
  void dispose() {
    _velocityController.dispose();
    _soundPathController.dispose();
    _tofController.dispose();
    _angleController.dispose();
    _depthController.dispose();
    _surfaceDistanceController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _errorMessage = null;
      _resultTof = null;
      _resultTofMicroseconds = null;
      _resultSoundPath = null;
      _computedDepth = null;
      _computedSurfaceDistance = null;
    });

    // Validate velocity (always required)
    if (_velocityController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter velocity';
      });
      return;
    }

    try {
      final velocity = double.parse(_velocityController.text);

      if (velocity <= 0) {
        setState(() {
          _errorMessage = 'Velocity must be greater than 0';
        });
        return;
      }

      if (_isModeA) {
        // Mode A: Sound Path → TOF
        if (_useAngleMode) {
          // Sub-mode: Compute Sound Path from angle + depth or surface distance
          _calculateSoundPathFromAngle(velocity);
        } else {
          // Direct Sound Path input
          if (_soundPathController.text.isEmpty) {
            setState(() {
              _errorMessage = 'Please enter sound path';
            });
            return;
          }

          final soundPath = double.parse(_soundPathController.text);

          if (soundPath <= 0) {
            setState(() {
              _errorMessage = 'Sound path must be greater than 0';
            });
            return;
          }

          _computeTofFromSoundPath(soundPath, velocity);
        }
      } else {
        // Mode B: TOF → Sound Path
        if (_tofController.text.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter time-of-flight';
          });
          return;
        }

        final tof = double.parse(_tofController.text);

        if (tof <= 0) {
          setState(() {
            _errorMessage = 'Time-of-flight must be greater than 0';
          });
          return;
        }

        _computeSoundPathFromTof(tof, velocity);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Please enter valid numbers';
      });
    }
  }

  void _calculateSoundPathFromAngle(double velocity) {
    if (_angleController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter probe angle';
      });
      return;
    }

    final angle = double.parse(_angleController.text);

    if (angle < 1 || angle >= 90) {
      setState(() {
        _errorMessage = 'Probe angle must be between 1° and 89°';
      });
      return;
    }

    final angleRad = angle * (pi / 180);

    if (_useDepth) {
      // Given Depth: S = D / cos(θ)
      if (_depthController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter depth';
        });
        return;
      }

      final depth = double.parse(_depthController.text);

      if (depth <= 0) {
        setState(() {
          _errorMessage = 'Depth must be greater than 0';
        });
        return;
      }

      final cosValue = cos(angleRad);
      if (cosValue.abs() < 0.0001) {
        setState(() {
          _errorMessage = 'Angle too close to 90° - calculation unstable';
        });
        return;
      }

      final soundPath = depth / cosValue;
      final surfaceDistance = depth / tan(angleRad);

      setState(() {
        _computedDepth = depth;
        _computedSurfaceDistance = surfaceDistance;
      });

      _computeTofFromSoundPath(soundPath, velocity);
    } else {
      // Given Surface Distance: S = SD / sin(θ)
      if (_surfaceDistanceController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter surface distance';
        });
        return;
      }

      final surfaceDistance = double.parse(_surfaceDistanceController.text);

      if (surfaceDistance <= 0) {
        setState(() {
          _errorMessage = 'Surface distance must be greater than 0';
        });
        return;
      }

      final sinValue = sin(angleRad);
      if (sinValue.abs() < 0.0001) {
        setState(() {
          _errorMessage = 'Angle too close to 0° - calculation unstable';
        });
        return;
      }

      final soundPath = surfaceDistance / sinValue;
      final depth = surfaceDistance * tan(angleRad);

      setState(() {
        _computedDepth = depth;
        _computedSurfaceDistance = surfaceDistance;
      });

      _computeTofFromSoundPath(soundPath, velocity);
    }
  }

  void _computeTofFromSoundPath(double soundPath, double velocity) {
    final tof = soundPath / velocity;
    final tofMicroseconds = tof * 1e6;

    setState(() {
      _resultTof = tof;
      _resultTofMicroseconds = tofMicroseconds;
      _resultSoundPath = soundPath;
    });

    // Log analytics
    AnalyticsService().logCalculatorUsed(
      'Time-of-Flight (TOF) Calculator',
      inputValues: {
        'mode': 'sound_path_to_tof',
        'velocity': velocity,
        'sound_path': soundPath,
        'tof_seconds': tof,
        'use_angle_mode': _useAngleMode,
      },
    );
  }

  void _computeSoundPathFromTof(double tof, double velocity) {
    final soundPath = tof * velocity;
    final tofMicroseconds = tof * 1e6;

    setState(() {
      _resultTof = tof;
      _resultTofMicroseconds = tofMicroseconds;
      _resultSoundPath = soundPath;
    });

    // Log analytics
    AnalyticsService().logCalculatorUsed(
      'Time-of-Flight (TOF) Calculator',
      inputValues: {
        'mode': 'tof_to_sound_path',
        'velocity': velocity,
        'tof_seconds': tof,
        'sound_path': soundPath,
      },
    );
  }

  void _clearResults() {
    setState(() {
      _resultTof = null;
      _resultTofMicroseconds = null;
      _resultSoundPath = null;
      _computedDepth = null;
      _computedSurfaceDistance = null;
      _errorMessage = null;
    });
  }

  void _toggleMode() {
    setState(() {
      _isModeA = !_isModeA;
      _useAngleMode = false; // Reset angle mode when switching
      _clearResults();
      _soundPathController.clear();
      _tofController.clear();
    });
  }

  void _toggleAngleMode() {
    setState(() {
      _useAngleMode = !_useAngleMode;
      _clearResults();
      if (_useAngleMode) {
        _soundPathController.clear();
      }
    });
  }

  void _toggleAngleSubMode() {
    setState(() {
      _useDepth = !_useDepth;
      _clearResults();
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
                                '⏱️ Time-of-Flight (TOF)',
                                style: AppTheme.titleLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ultrasonic Travel Time Calculator',
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
                                label: Text('Path → TOF'),
                                icon: Icon(Icons.trending_flat, size: 16),
                              ),
                              ButtonSegment(
                                value: false,
                                label: Text('TOF → Path'),
                                icon: Icon(Icons.keyboard_return, size: 16),
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

                    // Common input: Velocity
                    TextField(
                      controller: _velocityController,
                      decoration: const InputDecoration(
                        labelText: 'Wave Velocity (V)',
                        hintText: 'Enter wave velocity',
                        border: OutlineInputBorder(),
                        suffixText: 'distance/sec',
                        prefixIcon: Icon(Icons.speed),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      onChanged: (_) => _clearResults(),
                    ),
                    const SizedBox(height: 16),

                    // Mode A: Sound Path → TOF
                    if (_isModeA) ...[
                      // Option to use angle mode
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Use Angle Mode (Optional)',
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Switch(
                            value: _useAngleMode,
                            onChanged: (value) => _toggleAngleMode(),
                            activeColor: AppTheme.primaryBlue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_useAngleMode) ...[
                        // Angle mode: compute Sound Path from angle + depth/surface distance
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

                        // Sub-mode toggle: Depth vs Surface Distance
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Given Parameter',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SegmentedButton<bool>(
                                segments: const [
                                  ButtonSegment(
                                    value: true,
                                    label: Text('Depth'),
                                  ),
                                  ButtonSegment(
                                    value: false,
                                    label: Text('Surface Distance'),
                                  ),
                                ],
                                selected: {_useDepth},
                                onSelectionChanged: (Set<bool> newSelection) {
                                  _toggleAngleSubMode();
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (_useDepth) ...[
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
                        ] else ...[
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
                      ] else ...[
                        // Direct Sound Path input
                        TextField(
                          controller: _soundPathController,
                          decoration: const InputDecoration(
                            labelText: 'Sound Path (S)',
                            hintText: 'Enter sound path length',
                            border: OutlineInputBorder(),
                            suffixText: 'distance',
                            prefixIcon: Icon(Icons.trending_up),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                          onChanged: (_) => _clearResults(),
                        ),
                      ],
                    ],

                    // Mode B: TOF → Sound Path
                    if (!_isModeA) ...[
                      TextField(
                        controller: _tofController,
                        decoration: const InputDecoration(
                          labelText: 'Time-of-Flight (TOF)',
                          hintText: 'Enter TOF',
                          border: OutlineInputBorder(),
                          suffixText: 'seconds',
                          prefixIcon: Icon(Icons.timer),
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
                    if (_resultTof != null) ...[
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

                            // Primary results
                            if (_isModeA) ...[
                              // TOF results (seconds and microseconds)
                              _buildResultCard(
                                'Time-of-Flight',
                                '${_resultTof!.toStringAsFixed(6)} sec',
                                subtitle: '${_resultTofMicroseconds!.toStringAsFixed(2)} μs',
                                isPrimary: true,
                              ),
                              if (_useAngleMode && _computedDepth != null) ...[
                                const SizedBox(height: 12),
                                _buildResultCard(
                                  'Sound Path (Computed)',
                                  '${_resultSoundPath!.toStringAsFixed(3)}"',
                                ),
                                const SizedBox(height: 12),
                                _buildResultCard(
                                  'Depth',
                                  '${_computedDepth!.toStringAsFixed(3)}"',
                                ),
                                const SizedBox(height: 12),
                                _buildResultCard(
                                  'Surface Distance',
                                  '${_computedSurfaceDistance!.toStringAsFixed(3)}"',
                                ),
                              ],
                            ] else ...[
                              // Sound Path result
                              _buildResultCard(
                                'Sound Path',
                                '${_resultSoundPath!.toStringAsFixed(3)} distance units',
                                isPrimary: true,
                              ),
                              const SizedBox(height: 12),
                              _buildResultCard(
                                'Time-of-Flight',
                                '${_resultTof!.toStringAsFixed(6)} sec',
                                subtitle: '${_resultTofMicroseconds!.toStringAsFixed(2)} μs',
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
                            'Calculates ultrasonic wave travel time using sound path distance and wave velocity. Essential for UT timing calibrations and beam path verification.',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Core Formulas:',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• TOF = S / V (seconds)\n'
                            '• TOF (μs) = TOF × 1,000,000\n'
                            '• S = TOF × V\n\n'
                            'Angle Mode (Optional):\n'
                            '• S = D / cos(θ)  [Given Depth]\n'
                            '• S = SD / sin(θ)  [Given Surface Distance]',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 11,
                              height: 1.5,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Units: Ensure velocity units match sound path units. For example, if V is in inches/second, S should be in inches.',
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontSize: 11,
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

  Widget _buildResultCard(
    String label,
    String value, {
    String? subtitle,
    bool isPrimary = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPrimary ? Colors.white : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isPrimary ? 14 : 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isPrimary ? 28 : 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
