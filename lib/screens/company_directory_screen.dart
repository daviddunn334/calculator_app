import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CompanyDirectoryScreen extends StatelessWidget {
  const CompanyDirectoryScreen({super.key});

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
                        Icons.people_alt,
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
                            'Company Directory',
                            style: AppTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Contact information and employee details',
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
                          'Team Members',
                          style: AppTheme.titleLarge,
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement add team member
                          },
                          icon: const Icon(Icons.person_add),
                          label: const Text('Add Member'),
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
                    const SizedBox(height: 16),
                    // Search and filter bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingMedium,
                        vertical: AppTheme.paddingSmall,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppTheme.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Search directory...',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: AppTheme.bodyMedium,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.filter_list),
                            onPressed: () {
                              // TODO: Implement department filters
                            },
                            color: AppTheme.textSecondary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Departments
                    _buildDepartmentSection('Management', [
                      _buildEmployeeCard(
                        name: 'John Smith',
                        title: 'Operations Manager',
                        department: 'Management',
                        email: 'john.smith@company.com',
                        phone: '+1 (555) 123-4567',
                        certifications: ['API 653', 'API 570'],
                        status: EmployeeStatus.active,
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildDepartmentSection('Field Inspectors', [
                      _buildEmployeeCard(
                        name: 'Sarah Johnson',
                        title: 'Senior NDT Technician',
                        department: 'Field Operations',
                        email: 'sarah.j@company.com',
                        phone: '+1 (555) 234-5678',
                        certifications: ['UT Level II', 'MT Level II', 'PT Level II'],
                        status: EmployeeStatus.onsite,
                      ),
                      _buildEmployeeCard(
                        name: 'Mike Davis',
                        title: 'NDT Technician',
                        department: 'Field Operations',
                        email: 'mike.d@company.com',
                        phone: '+1 (555) 345-6789',
                        certifications: ['UT Level I', 'MT Level II'],
                        status: EmployeeStatus.offsite,
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildDepartmentSection('Office Staff', [
                      _buildEmployeeCard(
                        name: 'Lisa Chen',
                        title: 'Administrative Assistant',
                        department: 'Office',
                        email: 'lisa.c@company.com',
                        phone: '+1 (555) 456-7890',
                        certifications: [],
                        status: EmployeeStatus.active,
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.titleMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: item,
            )),
      ],
    );
  }

  Widget _buildEmployeeCard({
    required String name,
    required String title,
    required String department,
    required String email,
    required String phone,
    required List<String> certifications,
    required EmployeeStatus status,
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
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                  child: Text(
                    name.split(' ').map((e) => e[0]).join(''),
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTheme.titleMedium.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
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
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            email,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            phone,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (certifications.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: certifications.map((cert) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    cert,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum EmployeeStatus {
  active(Colors.green, 'Active'),
  onsite(Colors.blue, 'On Site'),
  offsite(Colors.orange, 'Off Site'),
  leave(Colors.red, 'On Leave');

  final Color color;
  final String label;

  const EmployeeStatus(this.color, this.label);
} 