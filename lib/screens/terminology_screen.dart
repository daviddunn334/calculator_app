import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TerminologyScreen extends StatelessWidget {
  const TerminologyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Terminology & Definitions'),
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
                      child: Icon(Icons.menu_book, size: 40, color: AppTheme.primaryBlue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Terminology & Definitions',
                            style: AppTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Quick-reference glossary for field technicians',
                            style: AppTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Glossary of Terms (A-Z)
                _buildGlossarySection(),
                const SizedBox(height: 32),
                // Field Shorthand
                _buildSimpleSection(
                  'Field Shorthand',
                  Icons.short_text,
                  [
                    _buildTermDefinition('TDC', 'Top Dead Center'),
                    _buildTermDefinition('SOC', 'Start of Coating'),
                    _buildTermDefinition('EOC', 'End of Coating'),
                  ],
                ),
                const SizedBox(height: 24),
                // Acronyms & Abbreviations
                _buildSimpleSection(
                  'Acronyms & Abbreviations',
                  Icons.abc,
                  [
                    _buildTermDefinition('UT', 'Ultrasonic Testing'),
                    _buildTermDefinition('MT', 'Magnetic Particle Testing'),
                    _buildTermDefinition('PT', 'Penetrant Testing'),
                    _buildTermDefinition('VT', 'Visual Testing'),
                    _buildTermDefinition('LOF', 'Lack of Fusion'),
                    _buildTermDefinition('LI', 'Linear Indication'),
                  ],
                ),
                const SizedBox(height: 24),
                // Naming Conventions
                _buildSimpleSection(
                  'Naming Conventions',
                  Icons.label,
                  [
                    _buildTermDefinition('Dents', 'Label by clock position and distance from weld (placeholder)'),
                    _buildTermDefinition('Welds', 'Use unique weld IDs and location references (placeholder)'),
                    _buildTermDefinition('Anomalies', 'Assign sequential numbers or codes (placeholder)'),
                    _buildTermDefinition('Repair Types', 'Use standard abbreviations (e.g., CL for clamp, SLV for sleeve)'),
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

  Widget _buildGlossarySection() {
    final Map<String, List<Map<String, String>>> glossary = {
      'A': [
        {'A-Scan': 'A type of ultrasonic display showing amplitude vs. time.'},
      ],
      'B': [
        {'Backwall Echo': 'The reflection from the far side of the test object.'},
      ],
      'C': [
        {'CML (Condition Monitoring Location)': 'A designated spot for repeated measurements.'},
      ],
      'W': [
        {'Weld Cap': 'The raised portion of a completed weld.'},
      ],
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: glossary.entries.map((entry) {
        return _buildGlossaryLetter(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildGlossaryLetter(String letter, List<Map<String, String>> terms) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: const BorderSide(color: AppTheme.divider),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
          child: Text(letter, style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryBlue)),
        ),
        title: Text('Terms: $letter', style: AppTheme.titleMedium),
        children: terms.map((termMap) {
          final term = termMap.keys.first;
          final definition = termMap.values.first;
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: _buildTermDefinition(term, definition),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTermDefinition(String term, String definition) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          term,
          style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          definition,
          style: AppTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSimpleSection(String title, IconData icon, List<Widget> children) {
    return Card(
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
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryBlue, size: 24),
                const SizedBox(width: 8),
                Text(title, style: AppTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
} 