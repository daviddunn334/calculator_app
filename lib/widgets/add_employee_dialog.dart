import 'package:flutter/material.dart';
import '../models/company_employee.dart';
import '../theme/app_theme.dart';

class AddEmployeeDialog extends StatefulWidget {
  final CompanyEmployee? employee;

  const AddEmployeeDialog({super.key, this.employee});

  @override
  State<AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<AddEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _positionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
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

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _firstNameController.text = widget.employee!.firstName;
      _lastNameController.text = widget.employee!.lastName;
      _positionController.text = widget.employee!.position;
      _departmentController.text = widget.employee!.department;
      _emailController.text = widget.employee!.email;
      _phoneController.text = widget.employee!.phone;
      _selectedStatus = widget.employee!.status;
      _selectedCertifications.addAll(widget.employee!.certifications);
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.employee == null ? 'Add Employee' : 'Edit Employee'),
      content: SingleChildScrollView(
        child: Form(
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final employee = CompanyEmployee(
                id: widget.employee?.id,
                firstName: _firstNameController.text,
                lastName: _lastNameController.text,
                position: _positionController.text,
                department: _departmentController.text,
                email: _emailController.text,
                phone: _phoneController.text,
                status: _selectedStatus,
                certifications: _selectedCertifications,
              );
              Navigator.pop(context, employee);
            }
          },
          child: Text(widget.employee == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
} 