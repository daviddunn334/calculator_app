import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EquipmentGuidesScreen extends StatelessWidget {
  const EquipmentGuidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Equipment Guides'),
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
                      child: Icon(Icons.build, size: 40, color: AppTheme.primaryBlue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Equipment Guides',
                            style: AppTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Quick-reference guides for NDT equipment',
                            style: AppTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Calibration Procedures Section
                _buildSection(
                  'Calibration Procedures',
                  Icons.tune,
                  [
                    _buildExpandableCard(
                      'Thickness Gauges',
                      [
                        '1. Power on device and allow warm-up',
                        '2. Select calibration mode',
                        '3. Apply couplant to calibration block',
                        '4. Take reference measurements',
                        '5. Verify accuracy with known standards',
                        '6. Document calibration results',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'PAUT Sets',
                      [
                        '1. System initialization',
                        '2. Probe connection check',
                        '3. Wedge calibration',
                        '4. Velocity calibration',
                        '5. Delay calibration',
                        '6. Sensitivity calibration',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'UT Meters',
                      [
                        '1. Zero calibration',
                        '2. Velocity calibration',
                        '3. Material calibration',
                        '4. Angle beam calibration',
                        '5. Sensitivity adjustment',
                        '6. Verification measurements',
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Troubleshooting Section
                _buildSection(
                  'Troubleshooting Tips',
                  Icons.bug_report,
                  [
                    _buildExpandableCard(
                      'Startup Issues',
                      [
                        '• Check battery level and connections',
                        '• Verify probe connections',
                        '• Check for software updates',
                        '• Reset device if needed',
                        '• Contact support if persistent',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'Unstable Readings',
                      [
                        '• Check couplant application',
                        '• Verify surface preparation',
                        '• Check probe condition',
                        '• Verify calibration',
                        '• Check for interference',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'Display Problems',
                      [
                        '• Adjust brightness settings',
                        '• Check for screen damage',
                        '• Verify power supply',
                        '• Reset display settings',
                        '• Update firmware if needed',
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Maintenance Section
                _buildSection(
                  'Maintenance & Battery Care',
                  Icons.battery_charging_full,
                  [
                    _buildExpandableCard(
                      'Battery Handling',
                      [
                        '• Store at room temperature',
                        '• Avoid complete discharge',
                        '• Use manufacturer chargers',
                        '• Check for swelling',
                        '• Replace when capacity drops',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'Probe Care',
                      [
                        '• Clean after each use',
                        '• Check for wear',
                        '• Store in protective case',
                        '• Avoid dropping',
                        '• Regular inspection',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'Device Storage',
                      [
                        '• Clean before storage',
                        '• Remove batteries',
                        '• Use protective case',
                        '• Store in dry location',
                        '• Regular maintenance check',
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Brand Specific Guides Section
                _buildSection(
                  'Brand/Model Specific Guides',
                  Icons.devices,
                  [
                    _buildExpandableCard(
                      'Olympus 38DL',
                      [
                        '• Menu navigation guide',
                        '• Common error codes',
                        '• Calibration procedure',
                        '• Data export steps',
                        '• Maintenance schedule',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'GE Krautkramer',
                      [
                        '• System setup guide',
                        '• Calibration steps',
                        '• Error resolution',
                        '• Data management',
                        '• Maintenance tips',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'Epoch 650',
                      [
                        '• Quick start guide',
                        '• Calibration procedure',
                        '• Common issues',
                        '• Data transfer',
                        '• Maintenance guide',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'Proceq UT8000',
                      [
                        '• System overview',
                        '• Calibration steps',
                        '• Troubleshooting guide',
                        '• Data export',
                        '• Maintenance schedule',
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