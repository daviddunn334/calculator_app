import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'company_pdfs_screen.dart';

class NDTProceduresScreen extends StatelessWidget {
  const NDTProceduresScreen({super.key});

  Widget _buildCompanyCard(BuildContext context, String company) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: const BorderSide(color: AppTheme.divider),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompanyPdfsScreen(company: company),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          child: Row(
            children: [
              Icon(
                Icons.folder,
                color: AppTheme.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  company.toUpperCase(),
                  style: AppTheme.titleLarge.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final companies = ['boardwalk', 'integrity', 'williams', 'southernstar'];

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
                            'Company Procedures',
                            style: AppTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Official NDT procedures and standards',
                            style: AppTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Company Selection
                Text(
                  'Select Company',
                  style: AppTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...companies.map((company) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCompanyCard(context, company),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 