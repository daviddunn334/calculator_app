import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CertificationsScreen extends StatelessWidget {
  const CertificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.paddingMedium),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      ),
                      child: const Icon(
                        Icons.verified_user,
                        size: 40,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NDT Certifications',
                            style: AppTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Track and manage certification status',
                            style: AppTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Active Certifications',
                          style: AppTheme.titleLarge,
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement add certification
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add New'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.paddingLarge,
                              vertical: AppTheme.paddingMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Example certification cards
                    _buildCertificationCard(
                      title: 'Magnetic Particle Testing (MT) - Level II',
                      expiryDate: 'Expires: Dec 31, 2024',
                      certNumber: 'Cert #: MT-2023-001',
                      status: CertificationStatus.active,
                    ),
                    const SizedBox(height: 16),
                    _buildCertificationCard(
                      title: 'Ultrasonic Testing (UT) - Level I',
                      expiryDate: 'Expires: Jun 15, 2024',
                      certNumber: 'Cert #: UT-2023-045',
                      status: CertificationStatus.expiringSoon,
                    ),
                    const SizedBox(height: 16),
                    _buildCertificationCard(
                      title: 'Penetrant Testing (PT) - Level II',
                      expiryDate: 'Expired: Jan 01, 2024',
                      certNumber: 'Cert #: PT-2022-112',
                      status: CertificationStatus.expired,
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

  Widget _buildCertificationCard({
    required String title,
    required String expiryDate,
    required String certNumber,
    required CertificationStatus status,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: BorderSide(
          color: status.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingMedium,
                    vertical: AppTheme.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: status.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                  child: Text(
                    status.label,
                    style: AppTheme.bodySmall.copyWith(
                      color: status.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  expiryDate,
                  style: AppTheme.bodyMedium.copyWith(
                    color: status.color,
                  ),
                ),
                Text(
                  certNumber,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum CertificationStatus {
  active(Colors.green, 'Active'),
  expiringSoon(Colors.orange, 'Expiring Soon'),
  expired(Colors.red, 'Expired');

  final Color color;
  final String label;

  const CertificationStatus(this.color, this.label);
} 