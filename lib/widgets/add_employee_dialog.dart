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
  final _titleController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedGroup;
  String? _selectedDivision;
  bool _useCustomTitle = false;

  // Employee groups as per requirements
  final List<String> _employeeGroups = [
    'Directors',
    'Project Managers', 
    'Advanced NDE Technicians',
    'Senior Technicians',
    'Junior Technicians',
    'Assistants',
    'Account Managers',
    'Business Development',
    'Admin / HR',
  ];

  // Division options as per requirements  
  final List<String> _divisions = [
    'NWP',
    'MountainWest Pipe',
    'Cypress', 
    'Atlanta',
    'Charlottesville',
    'Princeton',
    'Southern Star',
    'Stations',
    'Boardwalk',
    'Not Working',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _firstNameController.text = widget.employee!.firstName;
      _lastNameController.text = widget.employee!.lastName;
      _titleController.text = widget.employee!.title;
      _emailController.text = widget.employee!.email;
      _phoneController.text = widget.employee!.phone;
      _selectedGroup = widget.employee!.group;
      _selectedDivision = widget.employee!.division;
      
      // Check if title matches group name exactly
      _useCustomTitle = _titleController.text != _selectedGroup;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _titleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 700,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue,
                    AppTheme.primaryBlue.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.employee == null ? Icons.person_add : Icons.edit,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.employee == null
                              ? 'Add Employee'
                              : 'Edit Employee',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.employee == null
                              ? 'Create a new employee profile'
                              : 'Update employee information',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal Information Section
                      _buildSectionHeader('Personal Information', Icons.person),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _firstNameController,
                              label: 'First Name',
                              icon: Icons.person_outline,
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _lastNameController,
                              label: 'Last Name',
                              icon: Icons.person_outline,
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Job Information Section
                      _buildSectionHeader('Job Information', Icons.work),
                      const SizedBox(height: 16),

                      // Group Selection
                      _buildDropdownField(
                        value: _selectedGroup,
                        label: 'Employee Group',
                        icon: Icons.groups,
                        items: _employeeGroups,
                        onChanged: (value) {
                          setState(() {
                            _selectedGroup = value;
                            if (!_useCustomTitle && value != null) {
                              _titleController.text = value;
                            }
                          });
                        },
                        validator: (value) => value == null ? 'Please select a group' : null,
                      ),

                      const SizedBox(height: 20),

                      // Title Section
                      Row(
                        children: [
                          Expanded(
                            child: _useCustomTitle 
                              ? _buildTextField(
                                  controller: _titleController,
                                  label: 'Custom Title',
                                  icon: Icons.work_outline,
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? 'Required' : null,
                                )
                              : _buildTextField(
                                  controller: _titleController,
                                  label: 'Title',
                                  icon: Icons.work_outline,
                                  enabled: false,
                                ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),

                      CheckboxListTile(
                        title: const Text('Use custom title'),
                        subtitle: Text(_useCustomTitle 
                          ? 'Enter your own title above'
                          : 'Use selected group as title'),
                        value: _useCustomTitle,
                        onChanged: (value) {
                          setState(() {
                            _useCustomTitle = value ?? false;
                            if (!_useCustomTitle && _selectedGroup != null) {
                              _titleController.text = _selectedGroup!;
                            } else if (_useCustomTitle) {
                              _titleController.clear();
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),

                      const SizedBox(height: 20),

                      // Division Selection (Optional)
                      _buildDropdownField(
                        value: _selectedDivision,
                        label: 'Division (Optional)', 
                        icon: Icons.business,
                        items: _divisions,
                        onChanged: (value) {
                          setState(() {
                            _selectedDivision = value;
                          });
                        },
                      ),

                      const SizedBox(height: 32),

                      // Contact Information Section
                      _buildSectionHeader('Contact Information', Icons.contact_phone),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required';
                          if (!value!.contains('@')) return 'Invalid email';
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.background,
                border: Border(
                  top: BorderSide(color: AppTheme.divider, width: 1),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.employee == null ? Icons.add : Icons.save,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(widget.employee == null ? 'Add Employee' : 'Save Changes'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryBlue,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: enabled ? AppTheme.textSecondary : Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade50,
        labelStyle: TextStyle(color: enabled ? AppTheme.textSecondary : Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: AppTheme.bodyMedium.copyWith(
        color: enabled ? AppTheme.textPrimary : Colors.grey,
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: AppTheme.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      style: AppTheme.bodyMedium,
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final employee = CompanyEmployee(
        id: widget.employee?.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        title: _titleController.text.trim(),
        group: _selectedGroup!,
        division: _selectedDivision,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      Navigator.pop(context, employee);
    }
  }
}
