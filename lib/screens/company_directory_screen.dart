import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/company_employee.dart';
import '../services/employee_service.dart';
import '../widgets/add_employee_dialog.dart';

class CompanyDirectoryScreen extends StatefulWidget {
  const CompanyDirectoryScreen({super.key});

  @override
  State<CompanyDirectoryScreen> createState() => _CompanyDirectoryScreenState();
}

class _CompanyDirectoryScreenState extends State<CompanyDirectoryScreen> {
  final EmployeeService _employeeService = EmployeeService();
  String _searchQuery = '';
  String? _selectedDepartment;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                      onPressed: () async {
                        final result = await showDialog<CompanyEmployee>(
                          context: context,
                          builder: (context) => const AddEmployeeDialog(),
                        );
                        if (result != null) {
                          try {
                            await _employeeService.addEmployee(result);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Team member added successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error adding team member: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
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
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.filter_list),
                        onSelected: (value) {
                          setState(() {
                            _selectedDepartment = value == 'All' ? null : value;
                          });
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'All',
                            child: Text('All Departments'),
                          ),
                          const PopupMenuItem(
                            value: 'Management',
                            child: Text('Management'),
                          ),
                          const PopupMenuItem(
                            value: 'Field Operations',
                            child: Text('Field Operations'),
                          ),
                          const PopupMenuItem(
                            value: 'Office',
                            child: Text('Office'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                StreamBuilder<List<CompanyEmployee>>(
                  stream: _employeeService.getEmployees(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final employees = snapshot.data!;
                    final filteredEmployees = employees.where((employee) {
                      final matchesSearch = _searchQuery.isEmpty ||
                          ('${employee.firstName} ${employee.lastName}'
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase())) ||
                          (employee.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
                      final matchesDepartment = _selectedDepartment == null ||
                          employee.department == _selectedDepartment;
                      return matchesSearch && matchesDepartment;
                    }).toList();

                    // Group employees by department
                    final Map<String, List<CompanyEmployee>> groupedEmployees = {};
                    for (var employee in filteredEmployees) {
                      final department = employee.department ?? 'Other';
                      groupedEmployees.putIfAbsent(department, () => []);
                      groupedEmployees[department]!.add(employee);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: groupedEmployees.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: AppTheme.titleMedium.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...entry.value.map((employee) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildEmployeeCard(employee),
                                )),
                            const SizedBox(height: 24),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(CompanyEmployee employee) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: BorderSide(
          color: _getStatusColor(employee.status).withOpacity(0.3),
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
                    '${employee.firstName[0]}${employee.lastName[0]}',
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
                        '${employee.firstName} ${employee.lastName}',
                        style: AppTheme.titleMedium.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        employee.position ?? '',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(employee.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusLabel(employee.status),
                    style: TextStyle(
                      color: _getStatusColor(employee.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (employee.email != null) ...[
              _buildContactRow(Icons.email, employee.email!),
              const SizedBox(height: 8),
            ],
            if (employee.phone != null) ...[
              _buildContactRow(Icons.phone, employee.phone!),
              const SizedBox(height: 16),
            ],
            if (employee.certifications.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: employee.certifications.map((cert) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cert,
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'onsite':
        return Colors.orange;
      case 'offsite':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'onsite':
        return 'On Site';
      case 'offsite':
        return 'Off Site';
      default:
        return status;
    }
  }
} 