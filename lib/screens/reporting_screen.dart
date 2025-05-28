import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ReportingScreen extends StatelessWidget {
  const ReportingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Reporting & Documentation'),
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
                      child: Icon(Icons.description, size: 40, color: AppTheme.primaryBlue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reporting & Documentation',
                            style: AppTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Field guide for clear, accurate, and professional reports',
                            style: AppTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Writing Dig Summaries
                _buildSection(
                  'Writing Dig Summaries',
                  Icons.edit_note,
                  [
                    '• Be concise but complete: cover what, where, how deep, condition, and action taken.',
                    '• Use clear, direct language.',
                    '• Avoid jargon unless defined elsewhere.',
                    'Sample Structure:',
                    '  - What: "Corrosion pit found"',
                    '  - Where: "at 6 o\'clock, 12.5 ft from weld"',
                    '  - How deep: "measured 45 mils"',
                    '  - Condition: "no active leak, wall loss present"',
                    '  - Action: "area cleaned, pit measured, recoated"',
                  ],
                ),
                const SizedBox(height: 20),
                // Example Reports
                _buildSectionWithImage(
                  'Example Reports',
                  Icons.assignment,
                  [
                    'Good Example:',
                    '  "Excavation at 10+25 revealed a single corrosion pit at 3 o\'clock, 15.2 ft from weld. Pit depth measured 38 mils. No active leak. Area cleaned, pit measured, recoated."',
                    'Vague Example:',
                    '  "Found some corrosion. Measured it. No leak."',
                  ],
                ),
                const SizedBox(height: 20),
                // Macros & Dropdowns
                _buildSection(
                  'Macros & Dropdowns',
                  Icons.list_alt,
                  [
                    '• LI – Linear Indication',
                    '• Cap OK – Weld cap is acceptable',
                    '• Backwall Present – Backwall echo detected',
                    '• Use dropdowns for common findings to save time and standardize reports.',
                  ],
                ),
                const SizedBox(height: 20),
                // Coordinate & Measurement Logging
                _buildSection(
                  'Coordinate & Measurement Logging',
                  Icons.pin_drop,
                  [
                    '• GPS: Use decimal degrees (e.g., 29.123456, -95.654321)',
                    '• Pit Depths: Record in mils (e.g., 42 mils)',
                    '• Weld Positions: Use clock orientation (e.g., 9 o\'clock)',
                    'Do/Don\'t Examples:',
                    '  - Do: "GPS: 29.123456, -95.654321"',
                    '  - Don\'t: "GPS: 29°7\'24.4"N 95°39\'15.6"W"',
                  ],
                ),
                const SizedBox(height: 20),
                // Photo Guidelines
                _buildSectionWithImage(
                  'Photo Guidelines',
                  Icons.photo_camera,
                  [
                    '• Take overview and close-up shots.',
                    '• Label photos with FID, depth, and feature.',
                    '• Order photos as they appear in the report.',
                    '• Ensure good lighting and focus.',
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

  Widget _buildSection(String title, IconData icon, List<String> items) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: const BorderSide(color: AppTheme.divider),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: AppTheme.primaryBlue, size: 28),
        title: Text(
          title,
          style: AppTheme.titleLarge.copyWith(fontWeight: FontWeight.bold),
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

  Widget _buildSectionWithImage(String title, IconData icon, List<String> items) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: const BorderSide(color: AppTheme.divider),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: AppTheme.primaryBlue, size: 28),
        title: Text(
          title,
          style: AppTheme.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    item,
                    style: AppTheme.bodyMedium.copyWith(fontSize: 18),
                  ),
                )),
                const SizedBox(height: 16),
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Center(
                    child: Text(
                      'Image Placeholder',
                      style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 