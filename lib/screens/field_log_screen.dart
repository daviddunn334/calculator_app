import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../theme/app_theme.dart';
import '../models/field_log_entry.dart';
import '../services/field_log_service.dart';
import '../widgets/field_log_entry_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FieldLogScreen extends StatefulWidget {
  const FieldLogScreen({super.key});

  @override
  State<FieldLogScreen> createState() => _FieldLogScreenState();
}

class _FieldLogScreenState extends State<FieldLogScreen> {
  final FieldLogService _service = FieldLogService();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<FieldLogEntry> _entries = [];
  List<FieldLogEntry> _recentEntries = [];
  bool _isLoading = false;
  Set<DateTime> _daysWithEntries = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadEntries();
    _loadRecentEntries();
  }

  Future<void> _loadRecentEntries() async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 14));
      
      final entries = await _service.getEntriesForDateRange(startDate, endDate);
      setState(() {
        _recentEntries = entries;
        // Update days with entries for calendar highlighting
        _daysWithEntries = entries.map((e) => DateTime(
          e.localDate.year,
          e.localDate.month,
          e.localDate.day,
        )).toSet();
      });
    } catch (e) {
      print('Error loading recent entries: $e');
    }
  }

  Future<void> _loadEntries() async {
    if (_selectedDay == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final entries = await _service.getEntriesForDate(_selectedDay!);
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading entries: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading entries: $e')),
        );
      }
    }
  }

  Future<void> _addOrUpdateEntry(DateTime date) async {
    // Always use local midnight for the selected date
    final localDate = DateTime(date.year, date.month, date.day);
    // Check if there's an existing entry for this date
    final existingEntries = await _service.getEntriesForDate(localDate);
    final existingEntry = existingEntries.isNotEmpty ? existingEntries.first : null;

    final result = await showDialog<FieldLogEntry>(
      context: context,
      builder: (context) => FieldLogEntryDialog(
        date: localDate,
        existingEntry: existingEntry,
      ),
    );

    if (result != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to add entries')),
        );
        return;
      }

      try {
        final entry = FieldLogEntry(
          id: result.id,
          userId: user.uid,
          date: result.date,
          projectName: result.projectName,
          miles: result.miles,
          hours: result.hours,
          methodHours: result.methodHours,
          createdAt: result.createdAt,
          updatedAt: result.updatedAt,
        );

        await _service.addEntry(entry);
        await _loadEntries();
        await _loadRecentEntries(); // Reload recent entries to update calendar
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding entry: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Field Log',
                style: AppTheme.headlineMedium.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.paddingLarge),
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
                    _selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
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
                  todayDecoration: const BoxDecoration(
                    color: AppTheme.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppTheme.accent1,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppTheme.accent2,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (_daysWithEntries.contains(DateTime(
                      date.year,
                      date.month,
                      date.day,
                    ))) {
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.accent2,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: AppTheme.paddingLarge),
              Text(
                'Recent Entries',
                style: AppTheme.titleLarge.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _recentEntries.isEmpty
                        ? Center(
                            child: Text(
                              'No recent entries',
                              style: AppTheme.bodyLarge.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _recentEntries.length,
                            itemBuilder: (context, index) {
                              final entry = _recentEntries[index];
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                entry.projectName,
                                                style: AppTheme.titleMedium.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '${entry.localDate.month}/${entry.localDate.day}/${entry.localDate.year}',
                                                style: AppTheme.bodySmall.copyWith(
                                                  color: AppTheme.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () async {
                                              await _service.deleteEntry(entry.id);
                                              await _loadEntries();
                                              await _loadRecentEntries();
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text('Miles: ${entry.miles}'),
                                      Text('Hours: ${entry.hours}'),
                                      if (entry.methodHours.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Method Hours:',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        ...entry.methodHours.map((mh) => Text(
                                              '${mh.hours} hours - ${mh.method.name.toUpperCase()}',
                                            )),
                                      ],
                                    ],
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
    );
  }
} 