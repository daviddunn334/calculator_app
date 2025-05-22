import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class InspectionChecklistScreen extends StatefulWidget {
  const InspectionChecklistScreen({super.key});

  @override
  State<InspectionChecklistScreen> createState() => _InspectionChecklistScreenState();
}

class _InspectionChecklistScreenState extends State<InspectionChecklistScreen> {
  final List<ChecklistItem> _checklistItems = [
    ChecklistItem(id: 'item_1', text: 'Verify excavation permits'),
    ChecklistItem(id: 'item_2', text: 'Check for underground utilities'),
    ChecklistItem(id: 'item_3', text: 'Set up safety barriers'),
    ChecklistItem(id: 'item_4', text: 'Inspect weld cap'),
    ChecklistItem(id: 'item_5', text: 'Log GPS location'),
    ChecklistItem(id: 'item_6', text: 'Measure pipe depth'),
    ChecklistItem(id: 'item_7', text: 'Take soil samples'),
    ChecklistItem(id: 'item_8', text: 'Check coating condition'),
    ChecklistItem(id: 'item_9', text: 'Perform ultrasonic testing'),
    ChecklistItem(id: 'item_10', text: 'Document corrosion findings'),
    ChecklistItem(id: 'item_11', text: 'Take photographs of site'),
    ChecklistItem(id: 'item_12', text: 'Measure pit dimensions'),
    ChecklistItem(id: 'item_13', text: 'Apply temporary coating'),
    ChecklistItem(id: 'item_14', text: 'Complete inspection report'),
    ChecklistItem(id: 'item_15', text: 'Verify backfill requirements'),
  ];

  @override
  void initState() {
    super.initState();
    _loadChecklistState();
  }

  Future<void> _loadChecklistState() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      for (var item in _checklistItems) {
        item.isChecked = prefs.getBool(item.id) ?? false;
      }
    });
  }

  Future<void> _saveChecklistState() async {
    final prefs = await SharedPreferences.getInstance();
    
    for (var item in _checklistItems) {
      await prefs.setBool(item.id, item.isChecked);
    }
  }

  void _resetChecklist() {
    setState(() {
      for (var item in _checklistItems) {
        item.isChecked = false;
      }
    });
    _saveChecklistState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Dig Site Inspection Checklist'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                side: const BorderSide(color: AppTheme.divider),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.paddingMedium),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: const Icon(
                        Icons.assignment,
                        size: 32,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: AppTheme.paddingLarge),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pipeline Dig Inspection',
                            style: AppTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Complete all items before closing the dig site',
                            style: AppTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          _buildProgressIndicator(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Checklist
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  side: const BorderSide(color: AppTheme.divider),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  itemCount: _checklistItems.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = _checklistItems[index];
                    return CheckboxListTile(
                      title: Text(
                        item.text,
                        style: TextStyle(
                          decoration: item.isChecked ? TextDecoration.lineThrough : null,
                          color: item.isChecked ? AppTheme.textSecondary : AppTheme.textPrimary,
                        ),
                      ),
                      value: item.isChecked,
                      activeColor: AppTheme.primaryBlue,
                      onChanged: (bool? value) {
                        setState(() {
                          item.isChecked = value ?? false;
                        });
                        _saveChecklistState();
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingMedium,
                        vertical: 4,
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Reset Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _resetChecklist,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Checklist'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final completedCount = _checklistItems.where((item) => item.isChecked).length;
    final totalCount = _checklistItems.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress: $completedCount of $totalCount complete',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppTheme.divider,
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
      ],
    );
  }
}

class ChecklistItem {
  final String id;
  final String text;
  bool isChecked;

  ChecklistItem({
    required this.id,
    required this.text,
    this.isChecked = false,
  });
}
