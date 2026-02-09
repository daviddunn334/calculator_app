import 'package:flutter/material.dart';
import '../models/method_hours_entry.dart';
import '../theme/app_theme.dart';

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
  late TextEditingController _locationController;
  late TextEditingController _supervisingTechnicianController;
  final List<TextEditingController> _methodHoursControllers = [];
  final List<InspectionMethod> _selectedMethods = [];

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: widget.existingEntry?.location ?? '');
    _supervisingTechnicianController = TextEditingController(text: widget.existingEntry?.supervisingTechnician ?? '');
    
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
    _supervisingTechnicianController.dispose();
    for (var controller in _methodHoursControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addMethodHours() {
    if (_methodHoursControllers.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 4 methods allowed')),
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
    return AlertDialog(
      title: Text(
        'Add Entry',
        style: AppTheme.titleLarge,
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _supervisingTechnicianController,
                decoration: const InputDecoration(
                  labelText: 'Supervising Technician',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter supervising technician';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Method Hours',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Total: ${_calculateTotalHours().toStringAsFixed(1)} hrs',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _calculateTotalHours() > 10 ? Colors.red : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...List.generate(_methodHoursControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<InspectionMethod>(
                          value: _selectedMethods[index],
                          decoration: const InputDecoration(
                            labelText: 'Method',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _methodHoursControllers[index],
                          decoration: const InputDecoration(
                            labelText: 'Hours',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}), // Update total
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
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _removeMethodHours(index),
                      ),
                    ],
                  ),
                );
              }),
              if (_methodHoursControllers.length < 4)
                TextButton.icon(
                  onPressed: _addMethodHours,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Method Hours'),
                ),
              if (_methodHoursControllers.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Add at least one method hour entry',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (_methodHoursControllers.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please add at least one method hour entry')),
                );
                return;
              }

              final totalHours = _calculateTotalHours();
              if (totalHours > 10) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Total hours cannot exceed 10')),
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
                supervisingTechnician: _supervisingTechnicianController.text,
                methodHours: methodHours,
                createdAt: widget.existingEntry?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );

              Navigator.of(context).pop(entry);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
