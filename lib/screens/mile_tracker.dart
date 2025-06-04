import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/mile_entry.dart';
import '../services/mile_tracker_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/mile_entry_dialog.dart';

class MileTracker extends StatefulWidget {
  const MileTracker({super.key});

  @override
  State<MileTracker> createState() => _MileTrackerState();
}

class _MileTrackerState extends State<MileTracker> {
  final MileTrackerService _service = MileTrackerService();
  final AuthService _authService = AuthService();
  final _milesController = TextEditingController();
  final _hoursController = TextEditingController();
  final _jobSiteController = TextEditingController();
  final _purposeController = TextEditingController();
  
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = false;
  String? _error;
  List<MileEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
    print('MileTracker initialized');
    print('Current user: ${_authService.currentUser?.email}');
    print('Current user ID: ${_authService.currentUser?.uid}');
  }

  @override
  void dispose() {
    _milesController.dispose();
    _hoursController.dispose();
    _jobSiteController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('Loading entries');
      print('Current user: ${_authService.currentUser?.email}');
      print('Current user ID: ${_authService.currentUser?.uid}');
      
      // Test data storage
      await _service.testDataStorage();
      
      _service.getMileEntries().listen(
        (entries) {
          print('Received ${entries.length} entries');
          for (var entry in entries) {
            print('Entry: ${entry.toMap()}');
            print('Entry user ID: ${entry.userId}');
            print('Current user ID: ${_authService.currentUser?.uid}');
          }
          if (mounted) {
            setState(() {
              _entries = entries;
              _isLoading = false;
            });
          }
        },
        onError: (error) {
          print('Error loading entries: $error');
          if (mounted) {
            setState(() {
              _error = error.toString();
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      print('Error in _loadEntries: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addOrUpdateEntry(DateTime date) async {
    if (!mounted) return;
    
    try {
      print('Adding/updating entry for date: $date');
      print('Current user: ${_authService.currentUser?.email}');
      print('Current user ID: ${_authService.currentUser?.uid}');
      
      final existingEntry = await _service.getMileEntryForDate(date);
      print('Existing entry: ${existingEntry?.toMap()}');
      
      if (existingEntry != null) {
        print('Updating existing entry');
        print('Entry user ID: ${existingEntry.userId}');
        print('Current user ID: ${_authService.currentUser?.uid}');
        
        _milesController.text = existingEntry.miles.toString();
        _hoursController.text = existingEntry.hours.toString();
        _jobSiteController.text = existingEntry.jobSite;
        _purposeController.text = existingEntry.purpose;
      } else {
        print('Creating new entry');
        _milesController.clear();
        _hoursController.clear();
        _jobSiteController.clear();
        _purposeController.clear();
      }

      final result = await showDialog<MileEntry>(
        context: context,
        builder: (context) => MileEntryDialog(
          date: date,
          existingEntry: existingEntry,
        ),
      );

      if (result != null) {
        print('Dialog result: ${result.toMap()}');
        print('Result user ID: ${result.userId}');
        print('Current user ID: ${_authService.currentUser?.uid}');
        
        if (existingEntry != null) {
          await _service.updateMileEntry(result);
        } else {
          await _service.addMileEntry(result);
        }
        _loadEntries();
      }
    } catch (e) {
      print('Error in _addOrUpdateEntry: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_authService.isSignedIn) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: const Center(
          child: Text(
            'Please sign in to access the mile tracker',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(
              title: 'Mile Tracker',
              subtitle: 'Log your miles and hours',
              icon: Icons.directions_car,
            ),
            Expanded(
              child: StreamBuilder<List<MileEntry>>(
                stream: _service.getMileEntries(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final entries = snapshot.data!;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppTheme.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          elevation: 4,
                          child: TableCalendar(
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
                            calendarStyle: CalendarStyle(
                              selectedDecoration: BoxDecoration(
                                color: AppTheme.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                              todayDecoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                            calendarBuilders: CalendarBuilders(
                              markerBuilder: (context, date, events) {
                                final hasEntry = entries.any(
                                  (entry) => isSameDay(entry.date, date),
                                );
                                if (hasEntry) {
                                  return Positioned(
                                    bottom: 1,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryBlue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppTheme.primaryBlue,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        'Done',
                                        style: TextStyle(
                                          color: AppTheme.primaryBlue,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'History',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          elevation: 4,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: entries.length,
                            itemBuilder: (context, index) {
                              final entry = entries[index];
                              return ListTile(
                                title: Text(
                                  '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Miles: ${entry.miles.toStringAsFixed(1)}'),
                                    Text('Hours: ${entry.hours.toStringAsFixed(1)}'),
                                    Text('Job Site: ${entry.jobSite}'),
                                    Text('Purpose: ${entry.purpose}'),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    if (entry.id != null) {
                                      await _service.deleteMileEntry(entry.id!);
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 