import 'package:flutter/material.dart';
import '../models/company_employee.dart';
import '../services/company_directory_service.dart';

class CompanyDirectory extends StatefulWidget {
  const CompanyDirectory({super.key});

  @override
  State<CompanyDirectory> createState() => _CompanyDirectoryState();
}

class _CompanyDirectoryState extends State<CompanyDirectory> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _positionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyDirectoryService = CompanyDirectoryService();
  List<CompanyEmployee> _employees = [];
  bool _isLoading = true;
  String _selectedStatus = 'active';
  final List<String> _selectedCertifications = [];

  final List<String> _availableCertifications = [
    'API 510',
    'API 570',
    'API 653',
    'CWI',
    'NACE',
    'ASNT Level II',
    'ASNT Level III',
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      case 'on_leave':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'on_leave':
        return 'On Leave';
      default:
        return 'Unknown';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    try {
      final employees = await _companyDirectoryService.getEmployees();
      setState(() {
        _employees = employees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading employees: $e')),
        );
      }
    }
  }

  Future<void> _addEmployee() async {
    if (_formKey.currentState!.validate()) {
      try {
        final employee = CompanyEmployee(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          position: _positionController.text,
          department: _departmentController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          status: _selectedStatus,
          certifications: _selectedCertifications,
        );

        await _companyDirectoryService.addEmployee(employee);
        _clearForm();
        _loadEmployees();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding employee: $e')),
          );
        }
      }
    }
  }

  Future<void> _updateEmployee(CompanyEmployee employee) async {
    try {
      await _companyDirectoryService.updateEmployee(employee);
      _loadEmployees();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating employee: $e')),
        );
      }
    }
  }

  Future<void> _deleteEmployee(String id) async {
    try {
      await _companyDirectoryService.deleteEmployee(id);
      _loadEmployees();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting employee: $e')),
        );
      }
    }
  }

  void _clearForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _positionController.clear();
    _departmentController.clear();
    _emailController.clear();
    _phoneController.clear();
    setState(() {
      _selectedStatus = 'active';
      _selectedCertifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Directory'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(labelText: 'First Name'),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Please enter first name' : null,
                        ),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(labelText: 'Last Name'),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Please enter last name' : null,
                        ),
                        TextFormField(
                          controller: _positionController,
                          decoration: const InputDecoration(labelText: 'Position'),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Please enter position' : null,
                        ),
                        TextFormField(
                          controller: _departmentController,
                          decoration: const InputDecoration(labelText: 'Department'),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Please enter department' : null,
                        ),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Please enter email' : null,
                        ),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(labelText: 'Phone'),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Please enter phone' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: const InputDecoration(labelText: 'Status'),
                          items: const [
                            DropdownMenuItem(value: 'active', child: Text('Active')),
                            DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                            DropdownMenuItem(value: 'on_leave', child: Text('On Leave')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedStatus = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          children: _availableCertifications.map((cert) {
                            final isSelected = _selectedCertifications.contains(cert);
                            return FilterChip(
                              label: Text(cert),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedCertifications.add(cert);
                                  } else {
                                    _selectedCertifications.remove(cert);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _addEmployee,
                          child: const Text('Add Employee'),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _employees.length,
                    itemBuilder: (context, index) {
                      final employee = _employees[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text('${employee.firstName} ${employee.lastName}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(employee.position),
                              Text(employee.department),
                              if (employee.certifications.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 4,
                                  children: employee.certifications.map((cert) {
                                    return Chip(
                                      label: Text(cert),
                                      backgroundColor: _getStatusColor(employee.status).withOpacity(0.1),
                                      labelStyle: TextStyle(
                                        color: _getStatusColor(employee.status),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(employee.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getStatusLabel(employee.status),
                                  style: TextStyle(
                                    color: _getStatusColor(employee.status),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditDialog(employee),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _showDeleteDialog(employee),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _showEditDialog(CompanyEmployee employee) async {
    _firstNameController.text = employee.firstName;
    _lastNameController.text = employee.lastName;
    _positionController.text = employee.position;
    _departmentController.text = employee.department;
    _emailController.text = employee.email;
    _phoneController.text = employee.phone;
    setState(() {
      _selectedStatus = employee.status;
      _selectedCertifications.clear();
      _selectedCertifications.addAll(employee.certifications);
    });

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Employee'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter first name' : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter last name' : null,
              ),
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(labelText: 'Position'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter position' : null,
              ),
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(labelText: 'Department'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter department' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter email' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter phone' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                  DropdownMenuItem(value: 'on_leave', child: Text('On Leave')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedStatus = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: _availableCertifications.map((cert) {
                  final isSelected = _selectedCertifications.contains(cert);
                  return FilterChip(
                    label: Text(cert),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCertifications.add(cert);
                        } else {
                          _selectedCertifications.remove(cert);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && _formKey.currentState!.validate()) {
      final updatedEmployee = employee.copyWith(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        position: _positionController.text,
        department: _departmentController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        status: _selectedStatus,
        certifications: _selectedCertifications,
      );
      await _updateEmployee(updatedEmployee);
    }
    _clearForm();
  }

  Future<void> _showDeleteDialog(CompanyEmployee employee) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text(
            'Are you sure you want to delete ${employee.firstName} ${employee.lastName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true && employee.id != null) {
      await _deleteEmployee(employee.id!);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _positionController.dispose();
    _departmentController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
} 