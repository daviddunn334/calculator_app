import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FieldSafetyScreen extends StatelessWidget {
  const FieldSafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Field Safety & Compliance'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.paddingMedium),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      ),
                      child: Icon(Icons.health_and_safety, size: 40, color: Colors.red),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Field Safety & Compliance',
                            style: AppTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Promoting safe practices and regulatory compliance',
                            style: AppTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Safe Dig Protocols
                _buildSection(
                  'Safe Dig Protocols',
                  Icons.construction,
                  Colors.orange,
                  [
                    '1. Review pre-dig checklist',
                    '2. Mark all known utilities',
                    '3. Spot and flag hazards',
                    '4. Confirm dig permits',
                    '5. Hold safety briefing',
                    '6. Monitor for changing conditions',
                  ],
                ),
                const SizedBox(height: 20),
                // Lockout/Tagout Procedures
                _buildSection(
                  'Lockout/Tagout Procedures',
                  Icons.lock,
                  Colors.red,
                  [
                    '1. Identify all energy sources',
                    '2. Notify affected personnel',
                    '3. Shut down equipment',
                    '4. Apply locks and tags',
                    '5. Verify isolation',
                    '6. Document LOTO actions',
                    '7. Remove locks/tags only after work is complete',
                  ],
                ),
                const SizedBox(height: 20),
                // Exposure & Permits
                _buildSection(
                  'Exposure & Permits',
                  Icons.warning,
                  Colors.yellow[800]!,
                  [
                    '• Methane exposure limit: < 1% (placeholder)',
                    '• H2S exposure limit: < 10 ppm (placeholder)',
                    '• Hot work permit required for welding/cutting',
                    '• Confined space entry: test air, ventilate, standby attendant',
                    '• Complete permit forms before entry',
                  ],
                ),
                const SizedBox(height: 20),
                // PPE Requirements
                _buildSection(
                  'PPE Requirements',
                  Icons.checklist,
                  Colors.blue,
                  [
                    '• Hard hat, safety glasses, gloves (all jobs)',
                    '• Flame-resistant clothing (welding/hot work)',
                    '• Steel-toe boots (excavation)',
                    '• Hearing protection (loud equipment)',
                    '• Respirator (as required)',
                    'Sample PPE Checklist:',
                    '  - [ ] Hard hat',
                    '  - [ ] Safety glasses',
                    '  - [ ] Gloves',
                    '  - [ ] Steel-toe boots',
                    '  - [ ] FR clothing',
                    '  - [ ] Hearing protection',
                  ],
                ),
                const SizedBox(height: 20),
                // Compliance Guidelines
                _buildSection(
                  'Compliance Guidelines',
                  Icons.rule,
                  Colors.green,
                  [
                    '• OSHA: Always log air monitoring results',
                    '• DOT: Follow pipeline inspection protocols',
                    '• Maintain daily safety logs',
                    '• Report all incidents immediately',
                    '• Placeholder: Review company safety manual',
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Color color, List<String> items) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: BorderSide(color: color.withOpacity(0.5)),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: color, size: 28),
        title: Text(
          title,
          style: AppTheme.titleLarge.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  item,
                  style: AppTheme.bodyMedium.copyWith(fontSize: 18),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
} 