import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class KnowledgeBaseScreen extends StatelessWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Knowledge Base'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: Icon(Icons.book, size: 40, color: AppTheme.primaryBlue),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Integrity Specialists Knowledge Base',
                          style: AppTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pipeline integrity procedures and standards',
                          style: AppTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Knowledge Articles List
              Expanded(
                child: ListView(
                  children: [
                    _buildArticleCard(
                      context,
                      'Common Formulas',
                      'Quick access to frequently used NDT and pipeline integrity calculations...',
                      Icons.calculate,
                      AppTheme.primaryBlue,
                      onTap: () => Navigator.pushNamed(context, '/common_formulas'),
                    ),
                    const SizedBox(height: 12),
                    _buildArticleCard(
                      context,
                      'Field Safety and Compliance',
                      'Safety guidelines and compliance requirements for field operations',
                      Icons.safety_check,
                      Colors.orange,
                      onTap: () => Navigator.pushNamed(context, '/field_safety'),
                    ),
                    const SizedBox(height: 12),
                    _buildArticleCard(
                      context,
                      'NDT Procedures & Standards',
                      'Field-ready guidance for NDT inspections and code compliance',
                      Icons.science,
                      Colors.purple,
                      onTap: () => Navigator.pushNamed(context, '/ndt_procedures'),
                    ),
                    const SizedBox(height: 12),
                    _buildArticleCard(
                      context,
                      'Defect Types & Identification',
                      'Comprehensive guide to corrosion, dents, hard spots, cracks, and their classification...',
                      Icons.warning,
                      AppTheme.primaryBlue,
                      onTap: () => Navigator.pushNamed(context, '/defect_types'),
                    ),
                    const SizedBox(height: 12),
                    _buildArticleCard(
                      context,
                      'Equipment Guides',
                      'Calibration steps and usage tips for UT, MT, PAUT, and other NDT equipment...',
                      Icons.build,
                      AppTheme.primaryBlue,
                      onTap: () => Navigator.pushNamed(context, '/equipment_guides'),
                    ),
                    const SizedBox(height: 12),
                    _buildArticleCard(
                      context,
                      'Terminology/Definitions',
                      'Common terms and definitions used in pipeline integrity',
                      Icons.menu_book,
                      Colors.green,
                      onTap: () => Navigator.pushNamed(context, '/terminology'),
                    ),
                    const SizedBox(height: 12),
                    _buildArticleCard(
                      context,
                      'Reporting & Documentation',
                      'Best practices for writing reports and understanding common codes and field shorthand...',
                      Icons.description,
                      AppTheme.primaryBlue,
                      onTap: () => Navigator.pushNamed(context, '/reporting'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, String title, String summary, IconData icon, Color color, {VoidCallback? onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: InkWell(
        onTap: onTap ?? () {
          // TODO: Navigate to article detail screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening: $title')),
          );
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summary,
                      style: AppTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
} 