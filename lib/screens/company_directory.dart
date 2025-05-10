import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_theme.dart';

class CompanyDirectory extends StatefulWidget {
  const CompanyDirectory({super.key});

  @override
  State<CompanyDirectory> createState() => _CompanyDirectoryState();
}

class _CompanyDirectoryState extends State<CompanyDirectory> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _positionController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();

  bool _isLoading = true;
  bool _isEditing = false;
  String? _editingId;
  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _filteredEmployees = [];

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _positionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _loadMockData() async {
    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _employees = [
        {
          'id': const Uuid().v4(),
          'name': 'John Doe',
          'position': 'Senior NDT Technician',
          'email': 'john.doe@company.com',
          'phone': '(555) 123-4567',
          'department': 'Field Operations',
        },
        {
          'id': const Uuid().v4(),
          'name': 'Jane Smith',
          'position': 'Quality Control Manager',
          'email': 'jane.smith@company.com',
          'phone': '(555) 234-5678',
          'department': 'Quality Assurance',
        },
        {
          'id': const Uuid().v4(),
          'name': 'Mike Johnson',
          'position': 'NDT Inspector',
          'email': 'mike.johnson@company.com',
          'phone': '(555) 345-6789',
          'department': 'Field Operations',
        },
      ];
      _filteredEmployees = List.from(_employees);
      _isLoading = false;
    });
  }

  void _filterEmployees(String query) {
    setState(() {
      _filteredEmployees = _employees.where((employee) {
        final name = employee['name'].toString().toLowerCase();
        final position = employee['position'].toString().toLowerCase();
        final email = employee['email'].toString().toLowerCase();
        final department = employee['department'].toString().toLowerCase();
        final searchLower = query.toLowerCase();

        return name.contains(searchLower) ||
            position.contains(searchLower) ||
            email.contains(searchLower) ||
            department.contains(searchLower);
      }).toList();
    });
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _positionController.clear();
    _emailController.clear();
    _phoneController.clear();
    _departmentController.clear();
    setState(() {
      _isEditing = false;
      _editingId = null;
    });
  }

  void _editEmployee(Map<String, dynamic> employee) {
    setState(() {
      _isEditing = true;
      _editingId = employee['id'];
      _nameController.text = employee['name'];
      _positionController.text = employee['position'];
      _emailController.text = employee['email'];
      _phoneController.text = employee['phone'];
      _departmentController.text = employee['department'];
    });
  }

  void _deleteEmployee(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: const Text('Are you sure you want to delete this employee?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _employees.removeWhere((employee) => employee['id'] == id);
                _filterEmployees(_searchController.text);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _saveEmployee() {
    if (!_formKey.currentState!.validate()) return;

    final employee = {
      'id': _editingId ?? const Uuid().v4(),
      'name': _nameController.text,
      'position': _positionController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'department': _departmentController.text,
    };

    setState(() {
      if (_isEditing) {
        final index = _employees.indexWhere((e) => e['id'] == _editingId);
        _employees[index] = employee;
      } else {
        _employees.add(employee);
      }
      _filterEmployees(_searchController.text);
      _resetForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Company Directory',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your company\'s employee directory',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1C2E),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Card(
                          child: Container(
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              gradient: AppTheme.cardGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isEditing ? 'Edit Employee' : 'Add New Employee',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Name',
                                      prefixIcon: Icon(Icons.person),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _positionController,
                                    decoration: const InputDecoration(
                                      labelText: 'Position',
                                      prefixIcon: Icon(Icons.work),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a position';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      prefixIcon: Icon(Icons.email),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter an email';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _phoneController,
                                    decoration: const InputDecoration(
                                      labelText: 'Phone',
                                      prefixIcon: Icon(Icons.phone),
                                    ),
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a phone number';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _departmentController,
                                    decoration: const InputDecoration(
                                      labelText: 'Department',
                                      prefixIcon: Icon(Icons.business),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a department';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: _resetForm,
                                        child: const Text('Cancel'),
                                      ),
                                      const SizedBox(width: 16),
                                      ElevatedButton(
                                        onPressed: _saveEmployee,
                                        child: Text(_isEditing ? 'Update' : 'Save'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search employees...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                          ),
                          onChanged: _filterEmployees,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ListView.builder(
                                  itemCount: _filteredEmployees.length,
                                  itemBuilder: (context, index) {
                                    final employee = _filteredEmployees[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: AppTheme.cardGradient,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.all(16),
                                          title: Text(
                                            employee['name'],
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 8),
                                              Text('Position: ${employee['position']}'),
                                              Text('Department: ${employee['department']}'),
                                              Text('Email: ${employee['email']}'),
                                              Text('Phone: ${employee['phone']}'),
                                            ],
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit),
                                                onPressed: () => _editEmployee(employee),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete),
                                                onPressed: () => _deleteEmployee(employee['id']),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 