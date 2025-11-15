import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' show sqrt, pow;
import '../theme/app_theme.dart';

class B31GCalculator extends StatefulWidget {
  const B31GCalculator({super.key});

  @override
  State<B31GCalculator> createState() => _B31GCalculatorState();
}

class _B31GCalculatorState extends State<B31GCalculator> {
  final _formKey = GlobalKey<FormState>();
  final _diameterController = TextEditingController();
  final _wallThicknessController = TextEditingController();
  
  List<B31GCalculationRow> _calculationResults = [];
  String? _errorMessage;
  bool _hasCalculated = false;

  @override
  void dispose() {
    _diameterController.dispose();
    _wallThicknessController.dispose();
    super.dispose();
  }

  double _calculateDepthRatio(double d, double t) {
    return d / t;
  }

  double _calculateBRaw(double x) {
    if (x < 0.10) return double.nan; // #NUM! for shallow pits
    return sqrt(pow(x / (1.1 * x - 0.15), 2) - 1);
  }

  double _clampB(double x, double bRaw) {
    if (x < 0.10) return 4.0; // B = 4.0 for shallow pits
    
    if (x >= 0.10 && x <= 0.175) {
      return 4.0; // B must be 4.0 between 10% and 17.5%
    }
    
    // For x > 0.175, B = min(4.0, B_raw)
    if (bRaw.isNaN || bRaw.isInfinite) return 4.0;
    return bRaw > 4.0 ? 4.0 : bRaw;
  }

  double _calculateMaxLength(double D, double t, double B) {
    return 1.12 * B * sqrt(D * t);
  }

  String _formatAllowableLength(double x, double length) {
    if (x < 0.10) return "Unlimited";
    if (x > 0.80) return "N/A, >80%";
    return length.toStringAsFixed(2);
  }

  String _formatBRaw(double x, double bRaw) {
    if (x < 0.10) return "#NUM!";
    if (bRaw.isNaN || bRaw.isInfinite) return "#NUM!";
    return bRaw.toStringAsFixed(2);
  }

  void _calculate() {
    setState(() {
      _calculationResults = [];
      _errorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      try {
        final D = double.parse(_diameterController.text);
        final t = double.parse(_wallThicknessController.text);

        if (D <= 0 || t <= 0) {
          setState(() {
            _errorMessage = 'Diameter and wall thickness must be positive values';
          });
          return;
        }

        // Generate pit depths from 0 to 0.80*t in 0.005" increments
        List<B31GCalculationRow> results = [];
        double maxDepth = 0.80 * t;
        double increment = 0.005;
        
        for (double d = 0; d <= maxDepth + increment/2; d += increment) {
          // Ensure we don't exceed the 80% limit due to floating point precision
          if (d > maxDepth) d = maxDepth;
          
          double x = _calculateDepthRatio(d, t);
          double percentDepth = x * 100;
          double bRaw = _calculateBRaw(x);
          double B = _clampB(x, bRaw);
          double L = _calculateMaxLength(D, t, B);
          String allowableLength = _formatAllowableLength(x, L);
          String bRawFormatted = _formatBRaw(x, bRaw);

          results.add(B31GCalculationRow(
            pitDepth: d,
            depthRatio: x,
            percentDepth: percentDepth,
            bRawFormatted: bRawFormatted,
            B: B,
            L: L,
            allowableLength: allowableLength,
          ));
          
          // Break if we've reached the maximum depth
          if (d >= maxDepth) break;
        }

        setState(() {
          _calculationResults = results;
        });
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
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with inputs
              Card(
                margin: const EdgeInsets.all(AppTheme.paddingLarge),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  side: const BorderSide(color: AppTheme.divider),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingLarge),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                    'ASME B31G Calculator',
                                    style: AppTheme.titleLarge.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Maximum Allowable Longitudal Extent of Corrosion',
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
                        const SizedBox(height: AppTheme.paddingLarge),
                        
                        // Input fields for D and t
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _diameterController,
                                decoration: const InputDecoration(
                                  labelText: 'OD',
                                  hintText: 'Enter diameter',
                                  prefixIcon: Icon(Icons.straighten),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter diameter';
                                  }
                                  final parsed = double.tryParse(value);
                                  if (parsed == null || parsed <= 0) {
                                    return 'Must be a positive number';
                                  }
                                  return null;
                                },
                                onChanged: (_) {
                                  // Clear results when input changes
                                  setState(() {
                                    _hasCalculated = false;
                                    _calculationResults = [];
                                    _errorMessage = null;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: AppTheme.paddingMedium),
                            Expanded(
                              child: TextFormField(
                                controller: _wallThicknessController,
                                decoration: const InputDecoration(
                                  labelText: 'NWT',
                                  hintText: 'Enter thickness',
                                  prefixIcon: Icon(Icons.height),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter wall thickness';
                                  }
                                  final parsed = double.tryParse(value);
                                  if (parsed == null || parsed <= 0) {
                                    return 'Must be a positive number';
                                  }
                                  return null;
                                },
                                onChanged: (_) {
                                  // Clear results when input changes
                                  setState(() {
                                    _hasCalculated = false;
                                    _calculationResults = [];
                                    _errorMessage = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        if (_errorMessage != null) ...[
                          const SizedBox(height: AppTheme.paddingMedium),
                          Container(
                            padding: const EdgeInsets.all(AppTheme.paddingMedium),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: AppTheme.paddingMedium),
                        Center(
                          child: Text(
                            'B must not exceed 4 and if metal loss is between 10% and 17.5%, use B=4.0',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: AppTheme.paddingLarge),
                        ElevatedButton.icon(
                          onPressed: (_diameterController.text.isNotEmpty && _wallThicknessController.text.isNotEmpty) 
                            ? _calculate 
                            : null,
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
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.paddingMedium,
                              horizontal: AppTheme.paddingLarge,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Results table
              if (_calculationResults.isNotEmpty)
                Card(
                  margin: const EdgeInsets.fromLTRB(
                    AppTheme.paddingLarge,
                    0,
                    AppTheme.paddingLarge,
                    AppTheme.paddingLarge,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    side: const BorderSide(color: AppTheme.divider),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Calculation Results',
                          style: AppTheme.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppTheme.paddingMedium),
                        _buildResultsTable(),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsTable() {
    return DataTable(
      columnSpacing: 16,
      dataRowHeight: 32,
      headingRowHeight: 40,
      dividerThickness: 1,
      border: TableBorder.all(
        color: AppTheme.divider,
        width: 1,
      ),
      columns: const [
        DataColumn(
          label: Text(
            'Pit Depth\n(d)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          numeric: true,
        ),
        DataColumn(
          label: Text(
            '% Depth',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          numeric: true,
        ),
        DataColumn(
          label: Text(
            'Allowable\nLength',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          numeric: false,
        ),
      ],
      rows: _calculationResults.map((row) {
        Color? rowColor;
        if (row.depthRatio < 0.10) {
          rowColor = Colors.green.withOpacity(0.1);
        } else if (row.depthRatio > 0.80) {
          rowColor = Colors.red.withOpacity(0.1);
        } else if (row.depthRatio >= 0.10 && row.depthRatio <= 0.175) {
          rowColor = Colors.blue.withOpacity(0.1);
        }

        return DataRow(
          color: MaterialStateProperty.all(rowColor),
          cells: [
            DataCell(
              Text(
                row.pitDepth.toStringAsFixed(3),
                style: const TextStyle(fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
            DataCell(
              Text(
                row.percentDepth.toStringAsFixed(1),
                style: const TextStyle(fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
            DataCell(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: row.allowableLength == "Unlimited"
                        ? Colors.green.withOpacity(0.2)
                        : row.allowableLength == "N/A, >80%"
                            ? Colors.red.withOpacity(0.2)
                            : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    row.allowableLength,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: row.allowableLength == "Unlimited"
                          ? Colors.green[700]
                          : row.allowableLength == "N/A, >80%"
                              ? Colors.red[700]
                              : AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class B31GCalculationRow {
  final double pitDepth;
  final double depthRatio;
  final double percentDepth;
  final String bRawFormatted;
  final double B;
  final double L;
  final String allowableLength;

  B31GCalculationRow({
    required this.pitDepth,
    required this.depthRatio,
    required this.percentDepth,
    required this.bRawFormatted,
    required this.B,
    required this.L,
    required this.allowableLength,
  });
}
