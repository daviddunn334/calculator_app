import 'package:flutter/material.dart';
import '../calculators/abs_es_calculator.dart';
import '../calculators/pit_depth_calculator.dart';
import '../calculators/time_clock_calculator.dart';
import '../calculators/dent_ovality_calculator.dart';
import '../calculators/b31g_calculator.dart';
import '../calculators/depth_percentages_calculator.dart';
import '../theme/app_theme.dart';
import 'corrosion_grid_logger_screen.dart';
import 'pdf_to_excel_screen.dart';

class PipelineSpecificCategoryScreen extends StatelessWidget {
  const PipelineSpecificCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pipeline-Specific',
                          style: AppTheme.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pipeline integrity and corrosion assessment tools',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tool cards
              _buildToolCard(
                context,
                title: '📐 ABS + ES Calculator',
                description: 'Calculate ABS (Absolute) and ES (Equalize Surface) values for offset and distance measurements',
                tags: ['Offset', 'Distance', 'RGW'],
                color: const Color(0xFF3F51B5), // Indigo
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AbsEsCalculator(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildToolCard(
                context,
                title: '📏 Pit Depth Calculator',
                description: 'Calculate pit depths, wall loss, and remaining thickness for corrosion assessment',
                tags: ['Corrosion', 'Wall Loss', 'Remaining'],
                color: const Color(0xFF009688), // Teal
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PitDepthCalculator(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildToolCard(
                context,
                title: '🕐 Time Clock Calculator',
                description: 'Convert clock positions to distances around pipe circumference for defect location',
                tags: ['Clock Position', 'Distance', 'Conversion'],
                color: const Color(0xFF673AB7), // Deep Purple
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TimeClockCalculator(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildToolCard(
                context,
                title: '⭕ Dent Ovality Calculator',
                description: 'Calculate dent ovality percentage and deformation measurements for pipeline integrity',
                tags: ['Dent', 'Deformation', 'Percentage'],
                color: const Color(0xFFE91E63), // Pink
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DentOvalityCalculator(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildToolCard(
                context,
                title: '🔧 B31G Calculator',
                description: 'Calculate pipe defect assessment using ASME B31G standard for corrosion evaluation',
                tags: ['Corrosion', 'Assessment', 'ASME'],
                color: const Color(0xFF2196F3), // Blue
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const B31GCalculator(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildToolCard(
                context,
                title: '📊 Corrosion Grid Logger',
                description: 'Log and export corrosion grid data for RSTRENG analysis and reporting',
                tags: ['Grid', 'RSTRENG', 'Export'],
                color: const Color(0xFFFF9800), // Orange
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CorrosionGridLoggerScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildToolCard(
                context,
                title: '📄 PDF to Excel Converter',
                description: 'Convert hardness test PDF files to Excel format for data analysis and reporting',
                tags: ['PDF', 'Excel', 'Hardness', 'Convert'],
                color: const Color(0xFF4CAF50), // Green
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PdfToExcelScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildToolCard(
                context,
                title: '📈 Depth Percentages Chart',
                description: 'Visualize and analyze depth percentages for inspection data and corrosion patterns',
                tags: ['Charts', 'Analysis', 'Visualization', 'Depth'],
                color: const Color(0xFF9C27B0), // Purple
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DepthPercentagesCalculator(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required String description,
    required List<String> tags,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: BorderSide(color: AppTheme.divider, width: 1.5),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTheme.titleMedium.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: color,
                      ),
                    ],
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags.map((tag) => _buildTag(tag, color)).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
