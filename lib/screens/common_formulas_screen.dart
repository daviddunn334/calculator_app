import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CommonFormulasScreen extends StatelessWidget {
  const CommonFormulasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Common Formulas'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: ListView(
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildFormulaCard(
              title: 'Wall Loss Percentage',
              formula: 'Wall Loss (%) = (Original WT - Remaining WT) / Original WT × 100',
              description: 'Used to calculate the percentage of wall thickness lost due to corrosion or other damage.',
              icon: Icons.percent,
            ),
            const SizedBox(height: 16),
            _buildFormulaCard(
              title: 'Maximum Allowable Operating Pressure (MAOP)',
              formula: 'MAOP = 2 × S × t / D',
              description: 'Where S is the specified minimum yield strength, t is the wall thickness, and D is the outside diameter.',
              icon: Icons.speed,
            ),
            const SizedBox(height: 16),
            _buildFormulaCard(
              title: 'Burst Pressure',
              formula: 'Burst Pressure = 2 × S × t / D × Correction Factor',
              description: 'The correction factor accounts for material properties and other variables affecting burst strength.',
              icon: Icons.warning,
            ),
            const SizedBox(height: 16),
            _buildFormulaCard(
              title: 'Remaining Strength Factor (RSF)',
              formula: 'RSF = (1 - d/t) / (1 - d/(t × M))',
              description: 'Where d is the defect depth, t is the wall thickness, and M is the Folias factor.',
              icon: Icons.fitness_center,
            ),
            const SizedBox(height: 16),
            _buildFormulaCard(
              title: 'Folias Factor (M)',
              formula: 'M = √(1 + 0.8 × (L²/Dt))',
              description: 'Where L is the axial length of the defect, D is the outside diameter, and t is the wall thickness.',
              icon: Icons.architecture,
            ),
            const SizedBox(height: 16),
            _buildFormulaCard(
              title: 'Hoop Stress',
              formula: 'Hoop Stress = P × D / (2 × t)',
              description: 'Where P is the internal pressure, D is the outside diameter, and t is the wall thickness.',
              icon: Icons.circle,
            ),
            const SizedBox(height: 16),
            _buildFormulaCard(
              title: 'Corrosion Rate',
              formula: 'Corrosion Rate = (Initial WT - Final WT) / Time',
              description: 'Used to estimate the rate of wall loss over time, typically measured in mils per year (mpy).',
              icon: Icons.timelapse,
            ),
            const SizedBox(height: 16),
            _buildFormulaCard(
              title: 'Pressure Reduction Factor',
              formula: 'PRF = (1 - (d/t × (2/3))) / (1 - (d/t × (2/3) × M⁻¹))',
              description: 'Used in ASME B31G to calculate the safe pressure reduction for a corroded pipe.',
              icon: Icons.arrow_downward,
            ),
            const SizedBox(height: 16),
            _buildFormulaCard(
              title: 'Pipe Ovality',
              formula: 'Ovality (%) = (Dmax - Dmin) / Dnom × 100',
              description: 'Where Dmax is the maximum measured diameter, Dmin is the minimum measured diameter, and Dnom is the nominal diameter.',
              icon: Icons.change_history,
            ),
            const SizedBox(height: 16),
            _buildFormulaCard(
              title: 'Bend Radius',
              formula: 'Bend Radius = D / (2 × sin(θ/2))',
              description: 'Where D is the pipe diameter and θ is the bend angle in radians.',
              icon: Icons.rotate_90_degrees_ccw,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
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
                Icons.functions,
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
                    'Pipeline Integrity Formulas',
                    style: AppTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Common calculations used in pipeline integrity assessments',
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulaCard({
    required String title,
    required String formula,
    required String description,
    required IconData icon,
  }) {
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Text(
                formula,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
