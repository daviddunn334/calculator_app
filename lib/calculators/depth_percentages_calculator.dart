import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/offline_service.dart';

class DepthPercentagesCalculator extends StatefulWidget {
  const DepthPercentagesCalculator({super.key});

  @override
  State<DepthPercentagesCalculator> createState() => _DepthPercentagesCalculatorState();
}

class _DepthPercentagesCalculatorState extends State<DepthPercentagesCalculator> {
  final OfflineService _offlineService = OfflineService();
  bool _isOnline = true;
  final TextEditingController _wallThicknessController = TextEditingController();
  String? _errorMessage;
  List<Map<String, dynamic>> _tableData = [];
  double? _wallThickness;

  @override
  void initState() {
    super.initState();
    
    // Listen to connectivity changes
    _isOnline = _offlineService.isOnline;
    _offlineService.onConnectivityChanged.listen((online) {
      if (mounted) {
        setState(() {
          _isOnline = online;
        });
      }
    });
    
    // Load saved data
    _loadSavedData();
    
    // Listen to input changes
    _wallThicknessController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _wallThicknessController.dispose();
    super.dispose();
  }

  // Load saved calculator data
  Future<void> _loadSavedData() async {
    final data = await _offlineService.loadCalculatorData('depth_percentages_calculator');
    if (data != null && data['wallThickness'] != null) {
      setState(() {
        _wallThicknessController.text = data['wallThickness'].toString();
        _onInputChanged();
      });
    }
  }
  
  // Save calculator data
  Future<void> _saveData() async {
    if (_wallThickness != null) {
      final data = {
        'wallThickness': _wallThickness,
      };
      await _offlineService.saveCalculatorData('depth_percentages_calculator', data);
    }
  }

  void _onInputChanged() {
    setState(() {
      _validateInput();
    });
  }

  void _validateInput() {
    final input = _wallThicknessController.text.trim();
    
    if (input.isEmpty) {
      _errorMessage = 'Enter a positive wall thickness in inches, e.g., 0.325';
      _wallThickness = null;
      _tableData.clear(); // Clear table when input is empty
      return;
    }

    final parsed = double.tryParse(input);
    if (parsed == null || parsed <= 0) {
      _errorMessage = 'Enter a positive wall thickness in inches, e.g., 0.325';
      _wallThickness = null;
      _tableData.clear(); // Clear table when input is invalid
      return;
    }

    _errorMessage = null;
    _wallThickness = parsed;
    // Note: Don't regenerate table automatically, let user click Generate button
  }

  double _truncateTo3Decimals(double value) {
    // Truncate to 3 decimal places (not round)
    return (value * 1000).truncateToDouble() / 1000;
  }

  String _formatValue(double value) {
    return '${value.toStringAsFixed(3)}"';
  }

  void _generateTable() {
    if (_wallThickness == null) return;
    
    final data = <Map<String, dynamic>>[];
    
    for (int percent = 5; percent <= 100; percent += 5) {
      final raw = _wallThickness! * (percent / 100);
      final truncated = _truncateTo3Decimals(raw);
      
      data.add({
        'percent': percent,
        'value': truncated,
        'formatted': _formatValue(truncated),
      });
    }
    
    setState(() {
      _tableData = data;
    });
    
    // Save data for offline use
    _saveData();
  }

  void _clearTable() {
    setState(() {
      _wallThicknessController.clear();
      _tableData.clear();
      _wallThickness = null;
      _errorMessage = null;
    });
  }

  void _copyAsCSV() {
    if (_tableData.isEmpty) return;
    
    final csvData = StringBuffer();
    csvData.writeln('Percent,Value (in)');
    
    for (final row in _tableData) {
      csvData.writeln('${row['percent']},${row['value'].toStringAsFixed(3)}');
    }
    
    Clipboard.setData(ClipboardData(text: csvData.toString()));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Table copied to clipboard as CSV'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isInputValid = _wallThickness != null && _errorMessage == null;
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
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
                        'Depth Percentages Chart',
                        style: AppTheme.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Shows wall amount at each 5% of original thickness (truncated to 0.001")',
                        style: AppTheme.bodySmall.copyWith(
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
          ),
          
          // Offline indicator
          if (!_isOnline)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You are offline. Your calculations will be saved locally.',
                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          
          // Input section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _wallThicknessController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\.?\d*\.?\d*$')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Wall Thickness (in)',
                    hintText: 'e.g., 0.325',
                    errorText: _errorMessage,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixText: 'in',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isInputValid ? _generateTable : null,
                        icon: const Icon(Icons.table_chart),
                        label: const Text('Generate Table'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _clearTable,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Results section
          if (_tableData.isNotEmpty)
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Summary header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'WT: ${_wallThickness!.toStringAsFixed(3)} in',
                            style: AppTheme.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _copyAsCSV,
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Copy as CSV'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Table header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Percent',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Value (in)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Table data
                    Expanded(
                      child: ListView.builder(
                        itemCount: _tableData.length,
                        itemBuilder: (context, index) {
                          final row = _tableData[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade200),
                              ),
                              color: index.isEven ? Colors.grey.shade50 : Colors.white,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${row['percent']}%',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    row['formatted'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
