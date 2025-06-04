import 'package:flutter/material.dart';
import '../models/mile_entry.dart';
import '../services/auth_service.dart';

class MileEntryDialog extends StatefulWidget {
  final DateTime date;
  final MileEntry? existingEntry;

  const MileEntryDialog({
    super.key,
    required this.date,
    this.existingEntry,
  });

  @override
  State<MileEntryDialog> createState() => _MileEntryDialogState();
}

class _MileEntryDialogState extends State<MileEntryDialog> {
  final _milesController = TextEditingController();
  final _hoursController = TextEditingController();
  final _jobSiteController = TextEditingController();
  final _purposeController = TextEditingController();
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      _milesController.text = widget.existingEntry!.miles.toString();
      _hoursController.text = widget.existingEntry!.hours.toString();
      _jobSiteController.text = widget.existingEntry!.jobSite;
      _purposeController.text = widget.existingEntry!.purpose;
    }
  }

  @override
  void dispose() {
    _milesController.dispose();
    _hoursController.dispose();
    _jobSiteController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingEntry == null ? 'Add Mile Entry' : 'Update Mile Entry'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _milesController,
              decoration: const InputDecoration(
                labelText: 'Miles',
                hintText: 'Enter miles driven',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _hoursController,
              decoration: const InputDecoration(
                labelText: 'Hours',
                hintText: 'Enter hours worked',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _jobSiteController,
              decoration: const InputDecoration(
                labelText: 'Job Site',
                hintText: 'Enter job site location',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _purposeController,
              decoration: const InputDecoration(
                labelText: 'Purpose',
                hintText: 'Enter purpose of trip',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (_milesController.text.isEmpty ||
                _hoursController.text.isEmpty ||
                _jobSiteController.text.isEmpty ||
                _purposeController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill in all fields')),
              );
              return;
            }

            try {
              final miles = double.parse(_milesController.text);
              final hours = double.parse(_hoursController.text);
              final userId = _authService.currentUser?.uid;
              
              if (userId == null) {
                throw Exception('User not authenticated');
              }
              
              print('Creating entry with user ID: $userId');
              print('Current user email: ${_authService.currentUser?.email}');
              
              final entry = MileEntry(
                id: widget.existingEntry?.id,
                userId: userId,
                date: widget.date,
                miles: miles,
                hours: hours,
                jobSite: _jobSiteController.text,
                purpose: _purposeController.text,
              );
              
              print('Created entry: ${entry.toMap()}');
              Navigator.pop(context, entry);
            } catch (e) {
              print('Error creating entry: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Text(widget.existingEntry == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
} 