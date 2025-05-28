import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../theme/app_theme.dart';

class MileTrackerScreen extends StatefulWidget {
  const MileTrackerScreen({super.key});

  @override
  State<MileTrackerScreen> createState() => _MileTrackerScreenState();
}

class _MileTrackerScreenState extends State<MileTrackerScreen> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  final _milesController = TextEditingController();
  final _hoursController = TextEditingController();
  Map<String, Map<String, double>> _trackerData = {};
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _loadData();
  }

  @override
  void dispose() {
    _milesController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _prefs = await SharedPreferences.getInstance();
    String? data = _prefs.getString('tracker_data');
    if (data != null) {
      Map<String, dynamic> jsonData = json.decode(data);
      setState(() {
        _trackerData = Map.from(jsonData.map((key, value) =>
            MapEntry(key, Map<String, double>.from(value.cast<String, dynamic>()))));
        _loadSelectedDayData();
      });
    }
  }

  void _loadSelectedDayData() {
    String dateKey = _selectedDay.toIso8601String().split('T')[0];
    if (_trackerData.containsKey(dateKey)) {
      _milesController.text = _trackerData[dateKey]!['miles']?.toString() ?? '';
      _hoursController.text = _trackerData[dateKey]!['hours']?.toString() ?? '';
    } else {
      _milesController.clear();
      _hoursController.clear();
    }
  }

  Future<void> _saveData() async {
    String dateKey = _selectedDay.toIso8601String().split('T')[0];
    double? miles = double.tryParse(_milesController.text);
    double? hours = double.tryParse(_hoursController.text);

    if (miles != null || hours != null) {
      _trackerData[dateKey] = {
        'miles': miles ?? 0,
        'hours': hours ?? 0,
      };
    } else {
      _trackerData.remove(dateKey);
    }

    await _prefs.setString('tracker_data', json.encode(_trackerData));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data saved for ${_selectedDay.month}/${_selectedDay.day}'),
          backgroundColor: AppTheme.primaryBlue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: Icon(
                      Icons.directions_car,
                      size: 40,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mile Tracker',
                          style: AppTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Log your miles and hours',
                          style: AppTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 4,
                      child: TableCalendar(
                        firstDay: DateTime.utc(2023, 1, 1),
                        lastDay: DateTime.utc(2025, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                            _loadSelectedDayData();
                          });
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
                            String dateKey = date.toIso8601String().split('T')[0];
                            if (_trackerData.containsKey(dateKey)) {
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
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Entry for ${_selectedDay.month}/${_selectedDay.day}/${_selectedDay.year}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _milesController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Miles Driven',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.directions_car),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _hoursController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Hours Worked',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.access_time),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _saveData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accent1,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('Save Entry'),
                              ),
                            ),
                          ],
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
                        itemCount: _trackerData.length,
                        itemBuilder: (context, index) {
                          String dateKey = _trackerData.keys.toList()[index];
                          Map<String, double> dayData = _trackerData[dateKey]!;
                          DateTime date = DateTime.parse(dateKey);
                          return ListTile(
                            title: Text(
                              '${date.month}/${date.day}/${date.year}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${dayData['miles']?.toStringAsFixed(1)} mi, ${dayData['hours']?.toStringAsFixed(1)} hrs',
                            ),
                            leading: const Icon(Icons.calendar_today),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 