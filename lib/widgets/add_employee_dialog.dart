import 'package:flutter/material.dart';
import '../models/company_employee.dart';

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

  // New Dark Color System
  static const Color _backgroundColor = Color(0xFF1E232A);
  static const Color _surfaceColor = Color(0xFF242A33);
  static const Color _cardColor = Color(0xFF2A313B);
  static const Color _primaryText = Color(0xFFEDF9FF);
  static const Color _secondaryText = Color(0xFFAEBBC8);
  static const Color _mutedText = Color(0xFF7F8A96);
  static const Color _primaryAccent = Color(0xFF6C5BFF);
  static const Color _secondaryAccent = Color(0xFF00E5A8);
  static const Color _accentAlert = Color(0xFFFE637E);

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
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 700,
        ),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.05),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _primaryAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _primaryAccent.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      widget.employee == null ? Icons.person_add : Icons.edit,
                      color: _primaryAccent,
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
                          style: TextStyle(
                            color: _primaryText,
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
                            color: _secondaryText,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: _secondaryText),
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

                      const SizedBox(height: 24),

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
                        validator: (value) =>
                            value == null ? 'Please select a group' : null,
                      ),

                      const SizedBox(height: 16),

                      // Title Section
                      _buildTextField(
                        controller: _titleController,
                        label: _useCustomTitle ? 'Custom Title' : 'Title',
                        icon: Icons.work_outline,
                        enabled: _useCustomTitle,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),

                      const SizedBox(height: 8),

                      Container(
                        decoration: BoxDecoration(
                          color: _surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                            width: 1,
                          ),
                        ),
                        child: CheckboxListTile(
                          title: Text(
                            'Use custom title',
                            style: TextStyle(color: _primaryText, fontSize: 14),
                          ),
                          subtitle: Text(
                            _useCustomTitle
                                ? 'Enter your own title above'
                                : 'Use selected group as title',
                            style: TextStyle(color: _mutedText, fontSize: 12),
                          ),
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
                          activeColor: _primaryAccent,
                          checkColor: _primaryText,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        ),
                      ),

                      const SizedBox(height: 16),

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

                      const SizedBox(height: 24),

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

                      const SizedBox(height: 16),

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
                color: _surfaceColor,
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.05),
                    width: 1,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: _secondaryText,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.employee == null ? Icons.add : Icons.save,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(widget.employee == null
                            ? 'Add Employee'
                            : 'Save Changes'),
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
            color: _primaryAccent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _primaryAccent.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: _primaryAccent,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _primaryText,
            fontSize: 16,
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
      style: TextStyle(
        color: enabled ? _primaryText : _mutedText,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: enabled ? _secondaryText : _mutedText,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: enabled ? _secondaryText : _mutedText,
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryAccent, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _accentAlert, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _accentAlert, width: 2),
        ),
        filled: true,
        fillColor: enabled ? _surfaceColor : _surfaceColor.withOpacity(0.5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      dropdownColor: _cardColor,
      style: TextStyle(color: _primaryText, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _secondaryText, fontSize: 14),
        prefixIcon: Icon(icon, color: _secondaryText, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _accentAlert, width: 1),
        ),
        filled: true,
        fillColor: _surfaceColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item, style: TextStyle(color: _primaryText)),
        );
      }).toList(),
      onChanged: onChanged,
      icon: Icon(Icons.arrow_drop_down, color: _secondaryText),
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
