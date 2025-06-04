import 'package:flutter/material.dart';
import '../models/field_log_entry.dart';
import '../theme/app_theme.dart';

class FieldLogEntryDialog extends StatefulWidget {
  final DateTime date;
  final FieldLogEntry? existingEntry;

  const FieldLogEntryDialog({
    super.key,
    required this.date,
    this.existingEntry,
  });

  @override
  State<FieldLogEntryDialog> createState() => _FieldLogEntryDialogState();
}

class _FieldLogEntryDialogState extends State<FieldLogEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _projectNameController;
  late TextEditingController _milesController;
  late TextEditingController _hoursController;
  final List<MethodHours> _methodHours = [];
  final List<TextEditingController> _methodHoursControllers = [];
  final List<InspectionMethod> _selectedMethods = [];

  @override
  void initState() {
    super.initState();
    _projectNameController = TextEditingController(text: widget.existingEntry?.projectName ?? '');
    _milesController = TextEditingController(text: widget.existingEntry?.miles.toString() ?? '');
    _hoursController = TextEditingController(text: widget.existingEntry?.hours.toString() ?? '');
    
    if (widget.existingEntry != null) {
      _methodHours.addAll(widget.existingEntry!.methodHours);
      for (var mh in widget.existingEntry!.methodHours) {
        _methodHoursControllers.add(TextEditingController(text: mh.hours.toString()));
        _selectedMethods.add(mh.method);
      }
    }
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _milesController.dispose();
    _hoursController.dispose();
    for (var controller in _methodHoursControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addMethodHours() {
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existingEntry != null ? 'Edit Entry' : 'Add Entry',
        style: AppTheme.titleLarge,
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _projectNameController,
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a project name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _milesController,
                decoration: const InputDecoration(
                  labelText: 'Miles',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter miles';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hoursController,
                decoration: const InputDecoration(
                  labelText: 'Hours Worked',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter hours';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Method Hours',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(_methodHoursControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _methodHoursControllers[index],
                          decoration: const InputDecoration(
                            labelText: 'Hours',
                          ),
                          keyboardType: TextInputType.number,
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
                      Expanded(
                        child: DropdownButtonFormField<InspectionMethod>(
                          value: _selectedMethods[index],
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
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: () => _removeMethodHours(index),
                      ),
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: _addMethodHours,
                icon: const Icon(Icons.add),
                label: const Text('Add Method Hours'),
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
              final methodHours = List.generate(
                _methodHoursControllers.length,
                (index) => MethodHours(
                  hours: double.parse(_methodHoursControllers[index].text),
                  method: _selectedMethods[index],
                ),
              );

              final entry = FieldLogEntry(
                id: widget.existingEntry?.id ?? '',
                userId: widget.existingEntry?.userId ?? '',
                date: widget.date,
                projectName: _projectNameController.text,
                miles: double.parse(_milesController.text),
                hours: double.parse(_hoursController.text),
                methodHours: methodHours,
                createdAt: widget.existingEntry?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );

              Navigator.of(context).pop(entry);
            }
          },
          child: Text(widget.existingEntry != null ? 'Update' : 'Add'),
        ),
      ],
    );
  }
} 