import 'package:flutter/material.dart';
import '../models/company_employee.dart';
import '../services/employee_service.dart';
import '../services/user_service.dart';

class CompanyDirectory extends StatefulWidget {
  const CompanyDirectory({super.key});

  @override
  State<CompanyDirectory> createState() => _CompanyDirectoryState();
}

class _CompanyDirectoryState extends State<CompanyDirectory> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _titleController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _employeeService = EmployeeService();
  final _userService = UserService();
  List<CompanyEmployee> _employees = [];
  bool _isLoading = true;
  bool _isAdmin = false;
  String _selectedGroup = 'Directors';
  String? _selectedDivision;

  final List<String> _availableGroups = [
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

  final List<String> _availableDivisions = [
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
    _loadEmployees();
    _checkAdminStatus();
  }

  void _checkAdminStatus() async {
    final isAdmin = await _userService.isCurrentUserAdmin();
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
      });
    }
  }

  Future<void> _loadEmployees() async {
    try {
      _employeeService.getEmployees().listen((employees) {
        setState(() {
          _employees = employees;
          _isLoading = false;
        });
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
          title: _titleController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          group: _selectedGroup,
          division: _selectedDivision,
        );

        await _employeeService.addEmployee(employee);
        _clearForm();
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
      await _employeeService.updateEmployee(employee.id!, employee);
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
      await _employeeService.deleteEmployee(id);
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
    _titleController.clear();
    _emailController.clear();
    _phoneController.clear();
    setState(() {
      _selectedGroup = 'Directors';
      _selectedDivision = null;
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
                // Only show add employee form for admins
                if (_isAdmin) 
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
                            controller: _titleController,
                            decoration: const InputDecoration(labelText: 'Title'),
                            validator: (value) =>
                                value?.isEmpty ?? true ? 'Please enter title' : null,
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
                            value: _selectedGroup,
                            decoration: const InputDecoration(labelText: 'Group'),
                            items: _availableGroups.map((group) {
                              return DropdownMenuItem(
                                value: group,
                                child: Text(group),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedGroup = value);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String?>(
                            value: _selectedDivision,
                            decoration: const InputDecoration(labelText: 'Division (Optional)'),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('No Division'),
                              ),
                              ..._availableDivisions.map((division) {
                                return DropdownMenuItem<String?>(
                                  value: division,
                                  child: Text(division),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() => _selectedDivision = value);
                            },
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
                              Text(employee.title),
                              Text('Group: ${employee.group}'),
                              if (employee.division != null)
                                Text('Division: ${employee.division}'),
                            ],
                          ),
                          trailing: _isAdmin ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditDialog(employee),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _showDeleteDialog(employee),
                              ),
                            ],
                          ) : null,
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
    _titleController.text = employee.title;
    _emailController.text = employee.email;
    _phoneController.text = employee.phone;
    setState(() {
      _selectedGroup = employee.group;
      _selectedDivision = employee.division;
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
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter title' : null,
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
                value: _selectedGroup,
                decoration: const InputDecoration(labelText: 'Group'),
                items: _availableGroups.map((group) {
                  return DropdownMenuItem(
                    value: group,
                    child: Text(group),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedGroup = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                value: _selectedDivision,
                decoration: const InputDecoration(labelText: 'Division (Optional)'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('No Division'),
                  ),
                  ..._availableDivisions.map((division) {
                    return DropdownMenuItem<String?>(
                      value: division,
                      child: Text(division),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() => _selectedDivision = value);
                },
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
      final updatedEmployee = CompanyEmployee(
        id: employee.id,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        title: _titleController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        group: _selectedGroup,
        division: _selectedDivision,
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
    _titleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
