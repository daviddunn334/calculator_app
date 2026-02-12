import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../theme/app_theme.dart';
import '../services/analytics_service.dart';

class WedgeDelayTimeCalculator extends StatefulWidget {
  const WedgeDelayTimeCalculator({super.key});

  @override
  State<WedgeDelayTimeCalculator> createState() => _WedgeDelayTimeCalculatorState();
}

class _WedgeDelayTimeCalculatorState extends State<WedgeDelayTimeCalculator> {
  // Mode selection
  bool _isModeBPathComputed = false;

  // Common inputs
  final TextEditingController _vwController = TextEditingController();

  // Mode A inputs
  final TextEditingController _swController = TextEditingController();

  // Mode B inputs
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _angleController = TextEditingController();

  // Optional reflector inputs
  final TextEditingController _smController = TextEditingController();
  final TextEditingController _vmController = TextEditingController();

  // Results
  double? _wedgePathLength;
  double? _wedgeDelaySec;
  double? _wedgeDelayUs;
  double? _totalTimeSec;
  double? _totalTimeUs;
  String? _errorMessage;

  @override
  void dispose() {
    _vwController.dispose();
    _swController.dispose();
    _heightController.dispose();
    _angleController.dispose();
    _smController.dispose();
    _vmController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _errorMessage = null;
      _wedgePathLength = null;
      _wedgeDelaySec = null;
      _wedgeDelayUs = null;
      _totalTimeSec = null;
      _totalTimeUs = null;
    });

    // Validate common input
    if (_vwController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter wedge velocity';
      });
      return;
    }

    try {
      final vw = double.parse(_vwController.text);

      if (vw <= 0) {
        setState(() {
          _errorMessage = 'Wedge velocity must be greater than 0';
        });
        return;
      }

      double sw;

      if (_isModeBPathComputed) {
        // Mode B: Calculate from height and angle
        if (_heightController.text.isEmpty || _angleController.text.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter wedge height and angle';
          });
          return;
        }

        final h = double.parse(_heightController.text);
        final angleDeg = double.parse(_angleController.text);

        if (h <= 0) {
          setState(() {
            _errorMessage = 'Wedge height must be greater than 0';
          });
          return;
        }

        if (angleDeg < 0 || angleDeg >= 90) {
          setState(() {
            _errorMessage = 'Wedge angle must be between 0° and 89°';
          });
          return;
        }

        final angleRad = angleDeg * (pi / 180);
        final cosAngle = cos(angleRad);

        if (cosAngle.abs() < 0.0001) {
          setState(() {
            _errorMessage = 'Angle too close to 90°; path length is infinite';
          });
          return;
        }

        sw = h / cosAngle;
      } else {
        // Mode A: Direct path length input
        if (_swController.text.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter wedge path length';
          });
          return;
        }

        sw = double.parse(_swController.text);

        if (sw <= 0) {
          setState(() {
            _errorMessage = 'Wedge path length must be greater than 0';
          });
          return;
        }
      }

      // Calculate wedge delay time
      _wedgePathLength = sw;
      _wedgeDelaySec = sw / vw;
      _wedgeDelayUs = _wedgeDelaySec! * 1e6;

      // Calculate total time if reflector inputs are provided
      if (_smController.text.isNotEmpty && _vmController.text.isNotEmpty) {
        final sm = double.parse(_smController.text);
        final vm = double.parse(_vmController.text);

        if (sm > 0 && vm > 0) {
          _totalTimeSec = _wedgeDelaySec! + (sm / vm);
          _totalTimeUs = _totalTimeSec! * 1e6;
        }
      }

      // Log analytics
      AnalyticsService().logCalculatorUsed(
        'Wedge Delay Time Calculator',
        inputValues: {
          'mode': _isModeBPathComputed ? 'compute_from_height_angle' : 'known_path_length',
          'wedge_velocity': vw,
          'wedge_path_length': sw,
          'has_reflector_calculation': _totalTimeSec != null,
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
      _wedgePathLength = null;
      _wedgeDelaySec = null;
      _wedgeDelayUs = null;
      _totalTimeSec = null;
      _totalTimeUs = null;
      _errorMessage = null;
    });
  }

  void _switchMode(bool isModeB) {
    setState(() {
      _isModeBPathComputed = isModeB;
      _clearResults();
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
                                'Wedge Delay Time',
                                style: AppTheme.titleLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Calculate ultrasonic transit time through wedge',
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
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _switchMode(false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !_isModeBPathComputed
                                      ? AppTheme.primaryBlue
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                ),
                                child: Center(
                                  child: Text(
                                    'Known Path Length',
                                    style: TextStyle(
                                      color: !_isModeBPathComputed
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _switchMode(true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _isModeBPathComputed
                                      ? AppTheme.primaryBlue
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                ),
                                child: Center(
                                  child: Text(
                                    'Height + Angle',
                                    style: TextStyle(
                                      color: _isModeBPathComputed
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Common inputs
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.straighten,
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Wedge Properties',
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
                      controller: _vwController,
                      decoration: const InputDecoration(
                        labelText: 'Wedge Velocity (Vw)',
                        hintText: 'Sound velocity in wedge material',
                        border: OutlineInputBorder(),
                        suffixText: 'm/s',
                        prefixIcon: Icon(Icons.speed),
                        helperText: 'e.g., Rexolite: 2337 m/s, Acrylic: 2730 m/s',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      onChanged: (_) => _clearResults(),
                    ),
                    const SizedBox(height: 24),

                    // Mode-specific inputs
                    if (!_isModeBPathComputed) ...[
                      // Mode A: Direct path length
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timeline,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Mode A: Direct Input',
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
                        controller: _swController,
                        decoration: const InputDecoration(
                          labelText: 'Wedge Path Length (Sw)',
                          hintText: 'Distance sound travels in wedge',
                          border: OutlineInputBorder(),
                          suffixText: 'mm',
                          prefixIcon: Icon(Icons.straighten),
                          helperText: 'Measured or specified wedge path',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        onChanged: (_) => _clearResults(),
                      ),
                    ] else ...[
                      // Mode B: Height and angle
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calculate,
                              color: Colors.purple.shade700,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Mode B: Compute Path Length',
                              style: AppTheme.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.purple.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _heightController,
                        decoration: const InputDecoration(
                          labelText: 'Wedge Height (h)',
                          hintText: 'Normal distance from element to contact',
                          border: OutlineInputBorder(),
                          suffixText: 'mm',
                          prefixIcon: Icon(Icons.height),
                          helperText: 'Vertical standoff distance',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        onChanged: (_) => _clearResults(),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _angleController,
                        decoration: const InputDecoration(
                          labelText: 'Wedge Angle (θ₁)',
                          hintText: 'Incident angle from normal',
                          border: OutlineInputBorder(),
                          suffixText: '°',
                          prefixIcon: Icon(Icons.rotate_right),
                          helperText: 'Angle inside wedge (0-89°)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        onChanged: (_) => _clearResults(),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Optional reflector section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Optional: Total Time to Reflector',
                              style: AppTheme.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _smController,
                      decoration: const InputDecoration(
                        labelText: 'Sound Path in Material (Sm)',
                        hintText: 'Distance from entry to reflector',
                        border: OutlineInputBorder(),
                        suffixText: 'mm',
                        prefixIcon: Icon(Icons.straighten),
                        helperText: 'Optional: Leave empty to skip',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      onChanged: (_) => _clearResults(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _vmController,
                      decoration: const InputDecoration(
                        labelText: 'Material Velocity (Vm)',
                        hintText: 'Wave velocity in test material',
                        border: OutlineInputBorder(),
                        suffixText: 'm/s',
                        prefixIcon: Icon(Icons.speed),
                        helperText: 'e.g., Steel S-wave: 3240 m/s',
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
                    if (_wedgeDelaySec != null) ...[
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
                                  Icons.timer,
                                  color: AppTheme.primaryBlue,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Wedge Delay Results',
                                  style: AppTheme.titleLarge.copyWith(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.primaryBlue.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildResultRow(
                                    'Wedge Path Length (Sw)',
                                    '${_wedgePathLength!.toStringAsFixed(3)} mm',
                                  ),
                                  const Divider(height: 24),
                                  _buildResultRow(
                                    'Wedge Delay Time',
                                    '${(_wedgeDelaySec! * 1e6).toStringAsFixed(3)} µs',
                                    valueColor: AppTheme.primaryBlue,
                                    isLarge: true,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildResultRow(
                                    'Wedge Delay (seconds)',
                                    '${_wedgeDelaySec!.toStringAsExponential(4)} s',
                                    valueColor: AppTheme.textSecondary,
                                  ),
                                ],
                              ),
                            ),

                            // Total time results if calculated
                            if (_totalTimeSec != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.orange.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.insights,
                                          color: Colors.orange.shade700,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Total Time to Reflector',
                                          style: AppTheme.bodyLarge.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 20),
                                    _buildResultRow(
                                      'Total Transit Time',
                                      '${(_totalTimeSec! * 1e6).toStringAsFixed(3)} µs',
                                      valueColor: Colors.orange.shade700,
                                      isLarge: true,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildResultRow(
                                      'Total Time (seconds)',
                                      '${_totalTimeSec!.toStringAsExponential(4)} s',
                                      valueColor: AppTheme.textSecondary,
                                    ),
                                  ],
                                ),
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
                        'Calculate Wedge Delay',
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
                                'About Wedge Delay',
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
                            'Wedge delay is the time ultrasonic sound takes to travel through the wedge before entering the test material. This helps technicians estimate initial delay or zero offset.',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Formulas:',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• Mode A: tw = Sw / Vw\n• Mode B: Sw = h / cos(θ₁), then tw = Sw / Vw\n• Total: t_total = (Sw / Vw) + (Sm / Vm)',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 12),
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
                                    'This is a geometric estimate; actual wedge delay is best set by calibration on a known reflector.',
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
