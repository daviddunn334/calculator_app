import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NDTProceduresScreen extends StatelessWidget {
  const NDTProceduresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('NDT Procedures & Standards'),
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
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      ),
                      child: Icon(Icons.science, size: 40, color: AppTheme.primaryBlue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NDT Procedures & Standards',
                            style: AppTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Field-ready guidance for NDT inspections',
                            style: AppTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // NDT Method Procedures Section
                _buildSection(
                  'NDT Method Procedures',
                  Icons.build,
                  [
                    _buildExpandableCard(
                      'Ultrasonic Testing (UT)',
                      [
                        '1. Surface Preparation',
                        '2. Calibration',
                        '3. Scanning Procedure',
                        '4. Data Recording',
                        '5. Interpretation',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'Magnetic Particle Testing (MT)',
                      [
                        '1. Surface Preparation',
                        '2. Magnetization',
                        '3. Particle Application',
                        '4. Inspection',
                        '5. Demagnetization',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'Penetrant Testing (PT)',
                      [
                        '1. Surface Preparation',
                        '2. Penetrant Application',
                        '3. Dwell Time',
                        '4. Developer Application',
                        '5. Inspection',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'Visual Testing (VT)',
                      [
                        '1. Surface Preparation',
                        '2. Lighting Setup',
                        '3. Inspection',
                        '4. Documentation',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'Phased Array Ultrasonic Testing (PAUT)',
                      [
                        '1. Surface Preparation',
                        '2. Calibration',
                        '3. Setup',
                        '4. Scanning',
                        '5. Data Analysis',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'Eddy Current Testing (ECT)',
                      [
                        '1. Surface Preparation',
                        '2. Calibration',
                        '3. Probe Selection',
                        '4. Scanning',
                        '5. Data Analysis',
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Code Summaries Section
                _buildSection(
                  'Code Summaries',
                  Icons.description,
                  [
                    _buildExpandableCard(
                      'ASME B31G',
                      [
                        '• Pipeline defect assessment',
                        '• Remaining strength calculation',
                        '• Corrosion evaluation',
                        '• Repair criteria',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'API 5L',
                      [
                        '• Pipe specifications',
                        '• Material requirements',
                        '• Testing requirements',
                        '• Marking requirements',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'API 1104',
                      [
                        '• Welding requirements',
                        '• Inspection criteria',
                        '• Acceptance standards',
                        '• Testing procedures',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'RSTRENG Method',
                      [
                        '• Advanced corrosion assessment',
                        '• Complex defect evaluation',
                        '• Remaining strength calculation',
                        '• Safety factor consideration',
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Acceptance Criteria Section
                _buildSection(
                  'Acceptance Criteria',
                  Icons.check_circle,
                  [
                    _buildExpandableCard(
                      'Corrosion',
                      [
                        '• Maximum depth: 80% of wall thickness',
                        '• Maximum length: 12 inches',
                        '• Maximum width: 1/3 of circumference',
                        '• Minimum remaining wall: 0.8t',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'Dents',
                      [
                        '• Maximum depth: 6% of diameter',
                        '• No sharp edges',
                        '• No stress risers',
                        '• No cracks present',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'Cracks',
                      [
                        '• No cracks allowed',
                        '• No stress corrosion cracking',
                        '• No fatigue cracks',
                        '• No environmental cracking',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'Weld Flaws',
                      [
                        '• No incomplete fusion',
                        '• No undercut > 1/32"',
                        '• No porosity clusters',
                        '• No slag inclusions',
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Field Interpretation Tips Section
                _buildSection(
                  'Field Interpretation Tips',
                  Icons.lightbulb,
                  [
                    _buildExpandableCard(
                      'Applying Standards',
                      [
                        '• Always verify code edition',
                        '• Consider field conditions',
                        '• Document deviations',
                        '• Consult supervisor for unclear cases',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'Limited Tools',
                      [
                        '• Use calibrated references',
                        '• Document limitations',
                        '• Take multiple measurements',
                        '• Use conservative estimates',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'Borderline Cases',
                      [
                        '• Document all measurements',
                        '• Take photos if possible',
                        '• Consult with team',
                        '• Consider safety first',
                      ],
                    ),
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

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryBlue, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildExpandableCard(String title, List<String> items) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: const BorderSide(color: AppTheme.divider),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: AppTheme.titleMedium,
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
                  style: AppTheme.bodyMedium,
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
} 