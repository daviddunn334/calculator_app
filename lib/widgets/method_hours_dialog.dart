import 'package:flutter/material.dart';
import '../models/method_hours_entry.dart';
import '../models/company_employee.dart';
import '../services/employee_service.dart';

class MethodHoursDialog extends StatefulWidget {
  final DateTime date;
  final MethodHoursEntry? existingEntry;

  const MethodHoursDialog({
    super.key,
    required this.date,
    this.existingEntry,
  });

  @override
  State<MethodHoursDialog> createState() => _MethodHoursDialogState();
}

class _MethodHoursDialogState extends State<MethodHoursDialog> {
  final _formKey = GlobalKey<FormState>();
  final EmployeeService _employeeService = EmployeeService();
  late TextEditingController _locationController;
  String? _selectedSupervisingTechnician;
  final List<TextEditingController> _methodHoursControllers = [];
  final List<InspectionMethod> _selectedMethods = [];
  List<CompanyEmployee> _employees = [];

  // New Color System
  static const Color _mainBackground = Color(0xFF1E232A);
  static const Color _elevatedSurface = Color(0xFF242A33);
  static const Color _cardSurface = Color(0xFF2A313B);
  static const Color _primaryText = Color(0xFFEDF9FF);
  static const Color _secondaryText = Color(0xFFAEBBC8);
  static const Color _mutedText = Color(0xFF7F8A96);
  static const Color _primaryAccent = Color(0xFF6C5BFF);
  static const Color _successAccent = Color(0xFF00E5A8);
  static const Color _alertAccent = Color(0xFFFE637E);
  static const Color _yellowAccent = Color(0xFFF8B800);

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: widget.existingEntry?.location ?? '');
    _selectedSupervisingTechnician = widget.existingEntry?.supervisingTechnician;
    
    if (widget.existingEntry != null) {
      for (var mh in widget.existingEntry!.methodHours) {
        _methodHoursControllers.add(TextEditingController(text: mh.hours.toString()));
        _selectedMethods.add(mh.method);
      }
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    for (var controller in _methodHoursControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addMethodHours() {
    if (_methodHoursControllers.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Maximum 4 methods allowed'),
          backgroundColor: _alertAccent,
        ),
      );
      return;
    }
    
    setState(() {
      _methodHoursControllers.add(TextEditingController());
      _selectedMethods.add(InspectionMethod.mt);
    });
  }

  void _removeMethodHours(int index) {
    setState(() {
      _methodHoursControllers[index].dispose();
      _methodHoursControllers.removeAt(index);
      _selectedMethods.removeAt(index);
    });
  }

  double _calculateTotalHours() {
    double total = 0;
    for (var controller in _methodHoursControllers) {
      final value = double.tryParse(controller.text);
      if (value != null) {
        total += value;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final totalHours = _calculateTotalHours();
    final isOverLimit = totalHours > 10;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: _cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
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
                color: _elevatedSurface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _primaryAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.engineering_rounded,
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
                          widget.existingEntry != null ? 'Edit Entry' : 'Add Entry',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _primaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(widget.date),
                          style: TextStyle(
                            fontSize: 14,
                            color: _secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: _mutedText),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location Field
                      _buildLabel('Location'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _locationController,
                        style: TextStyle(color: _primaryText),
                        decoration: _buildInputDecoration(
                          hintText: 'Enter location',
                          prefixIcon: Icons.location_on_outlined,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Supervising Technician
                      _buildLabel('Supervising Technician'),
                      const SizedBox(height: 8),
                      StreamBuilder<List<CompanyEmployee>>(
                        stream: _employeeService.getEmployees(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final allowedGroups = [
                              'Directors',
                              'Project Managers',
                              'Advanced NDE Technicians',
                              'Senior Technicians',
                            ];
                            
                            _employees = snapshot.data!
                                .where((employee) => allowedGroups.contains(employee.group))
                                .toList();
                          }
                          
                          return DropdownButtonFormField<String>(
                            value: _selectedSupervisingTechnician,
                            dropdownColor: _cardSurface,
                            style: TextStyle(color: _primaryText),
                            decoration: _buildInputDecoration(
                              hintText: 'Select a technician',
                              prefixIcon: Icons.person_outline,
                            ),
                            items: _employees.map((employee) {
                              final fullName = '${employee.firstName} ${employee.lastName}';
                              return DropdownMenuItem<String>(
                                value: fullName,
                                child: Text(fullName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSupervisingTechnician = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a supervising technician';
                              }
                              return null;
                            },
                            isExpanded: true,
                            menuMaxHeight: 300,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Method Hours Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Method Hours',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _primaryText,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isOverLimit 
                                  ? _alertAccent.withOpacity(0.15)
                                  : _successAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isOverLimit 
                                    ? _alertAccent.withOpacity(0.5)
                                    : _successAccent.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              'Total: ${totalHours.toStringAsFixed(1)} hrs',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isOverLimit ? _alertAccent : _successAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Method Hours Entries
                      ...List.generate(_methodHoursControllers.length, (index) {
                        return _buildMethodHourRow(index);
                      }),
                      
                      // Add Method Button
                      if (_methodHoursControllers.length < 4)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: InkWell(
                            onTap: _addMethodHours,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _elevatedSurface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _primaryAccent.withOpacity(0.3),
                                  style: BorderStyle.solid,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add, color: _primaryAccent, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Add Method Hours',
                                    style: TextStyle(
                                      color: _primaryAccent,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      
                      if (_methodHoursControllers.isEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _yellowAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _yellowAccent.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: _yellowAccent, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Add at least one method hour entry',
                                  style: TextStyle(
                                    color: _yellowAccent,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                color: _elevatedSurface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: _secondaryText,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveEntry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _secondaryText,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: _mutedText),
      prefixIcon: Icon(prefixIcon, color: _mutedText, size: 20),
      filled: true,
      fillColor: _elevatedSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _primaryAccent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _alertAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _alertAccent, width: 1.5),
      ),
      errorStyle: TextStyle(color: _alertAccent),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildMethodHourRow(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _elevatedSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<InspectionMethod>(
              value: _selectedMethods[index],
              dropdownColor: _cardSurface,
              style: TextStyle(color: _primaryText, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Method',
                labelStyle: TextStyle(color: _mutedText, fontSize: 12),
                filled: true,
                fillColor: _mainBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _primaryAccent),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                isDense: true,
              ),
              items: InspectionMethod.values.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedMethods[index] = value;
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _methodHoursControllers[index],
              style: TextStyle(color: _primaryText),
              decoration: InputDecoration(
                labelText: 'Hours',
                labelStyle: TextStyle(color: _mutedText, fontSize: 12),
                filled: true,
                fillColor: _mainBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _primaryAccent),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _alertAccent),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _alertAccent),
                ),
                errorStyle: TextStyle(color: _alertAccent, fontSize: 11),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                if (double.tryParse(value) == null) {
                  return 'Invalid';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.delete_outline, color: _alertAccent),
            onPressed: () => _removeMethodHours(index),
            tooltip: 'Remove',
            style: IconButton.styleFrom(
              backgroundColor: _alertAccent.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      if (_methodHoursControllers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please add at least one method hour entry'),
            backgroundColor: _alertAccent,
          ),
        );
        return;
      }

      final totalHours = _calculateTotalHours();
      if (totalHours > 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Total hours cannot exceed 10'),
            backgroundColor: _alertAccent,
          ),
        );
        return;
      }

      final methodHours = List.generate(
        _methodHoursControllers.length,
        (index) => MethodHours(
          hours: double.parse(_methodHoursControllers[index].text),
          method: _selectedMethods[index],
        ),
      );

      final entry = MethodHoursEntry(
        id: widget.existingEntry?.id ?? '',
        userId: widget.existingEntry?.userId ?? '',
        date: widget.date,
        location: _locationController.text,
        supervisingTechnician: _selectedSupervisingTechnician ?? '',
        methodHours: methodHours,
        createdAt: widget.existingEntry?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      Navigator.of(context).pop(entry);
    }
  }
}
