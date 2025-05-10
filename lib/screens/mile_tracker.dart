import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/mile_entry.dart';
import '../services/mile_tracker_service.dart';

class MileTracker extends StatefulWidget {
  const MileTracker({super.key});

  @override
  State<MileTracker> createState() => _MileTrackerState();
}

class _MileTrackerState extends State<MileTracker> {
  final MileTrackerService _service = MileTrackerService();
  final _milesController = TextEditingController();
  final _jobSiteController = TextEditingController();
  final _purposeController = TextEditingController();
  
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<MileEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    _milesController.dispose();
    _jobSiteController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    try {
      final entries = await _service.getMileEntries();
      setState(() {
        _entries = entries;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading entries: $e')),
        );
      }
    }
  }

  Future<void> _addOrUpdateEntry(DateTime date) async {
    final existingEntry = await _service.getMileEntryForDate(date);
    
    if (existingEntry != null) {
      _milesController.text = existingEntry.miles.toString();
      _jobSiteController.text = existingEntry.jobSite;
      _purposeController.text = existingEntry.purpose;
    } else {
      _milesController.clear();
      _jobSiteController.clear();
      _purposeController.clear();
    }

    final result = await showDialog<MileEntry>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingEntry == null ? 'Add Mile Entry' : 'Update Mile Entry'),
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
                  _jobSiteController.text.isEmpty ||
                  _purposeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields')),
                );
                return;
              }

              try {
                final miles = double.parse(_milesController.text);
                final entry = MileEntry(
                  id: existingEntry?.id,
                  userId: '', // This will be set by the service
                  date: date,
                  miles: miles,
                  jobSite: _jobSiteController.text,
                  purpose: _purposeController.text,
                );

                if (existingEntry == null) {
                  await _service.addMileEntry(entry);
                } else {
                  await _service.updateMileEntry(entry);
                }

                if (mounted) {
                  Navigator.pop(context, entry);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: Text(existingEntry == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _loadEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _addOrUpdateEntry(selectedDay);
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}',
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Miles: ${entry.miles}'),
                        Text('Job Site: ${entry.jobSite}'),
                        Text('Purpose: ${entry.purpose}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        if (entry.id != null) {
                          await _service.deleteMileEntry(entry.id!);
                          await _loadEntries();
                        }
                      },
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
} 