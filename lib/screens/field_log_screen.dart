import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../theme/app_theme.dart';
import '../models/field_log_entry.dart';
import '../services/field_log_service.dart';
import '../widgets/field_log_entry_dialog.dart';
import '../widgets/app_header.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FieldLogScreen extends StatefulWidget {
  const FieldLogScreen({super.key});

  @override
  State<FieldLogScreen> createState() => _FieldLogScreenState();
}

class _FieldLogScreenState extends State<FieldLogScreen> with SingleTickerProviderStateMixin {
  final FieldLogService _service = FieldLogService();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<FieldLogEntry> _allEntries = [];
  bool _isLoading = false;
  Set<DateTime> _daysWithEntries = {};
  bool _showAllTime = true; // Toggle between All Time and Current Year
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadAllEntries();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAllEntries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DateTime startDate;
      if (_showAllTime) {
        // Load all entries (from beginning of time)
        startDate = DateTime(2020, 1, 1);
      } else {
        // Load current year only
        startDate = DateTime(DateTime.now().year, 1, 1);
      }
      
      final endDate = DateTime.now();
      final entries = await _service.getEntriesForDateRange(startDate, endDate);
      
      setState(() {
        _allEntries = entries;
        // Update days with entries for calendar highlighting
        _daysWithEntries = entries.map((e) => DateTime(
          e.localDate.year,
          e.localDate.month,
          e.localDate.day,
        )).toSet();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading entries: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<InspectionMethod, double> _calculateMethodTotals() {
    final totals = <InspectionMethod, double>{};
    
    // Initialize all methods with 0
    for (var method in InspectionMethod.values) {
      totals[method] = 0;
    }
    
    // Sum up hours per method
    for (var entry in _allEntries) {
      for (var mh in entry.methodHours) {
        totals[mh.method] = (totals[mh.method] ?? 0) + mh.hours;
      }
    }
    
    return totals;
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
          location: result.location,
          supervisingTechnician: result.supervisingTechnician,
          methodHours: result.methodHours,
          createdAt: result.createdAt,
          updatedAt: result.updatedAt,
        );

        if (existingEntry != null) {
          await _service.updateEntry(entry);
        } else {
          await _service.addEntry(entry);
        }
        
        await _loadAllEntries(); // Reload all entries
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving entry: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteEntry(FieldLogEntry entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await _service.deleteEntry(entry.id);
      await _loadAllEntries();
    }
  }

  Future<void> _exportToExcel() async {
    try {
      // Show year picker dialog
      final year = await showDialog<int>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Year'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Current Year'),
                onTap: () => Navigator.pop(context, DateTime.now().year),
              ),
              ListTile(
                title: const Text('Last Year'),
                onTap: () => Navigator.pop(context, DateTime.now().year - 1),
              ),
            ],
          ),
        ),
      );

      if (year != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Generating Excel file...')),
        );
        
        await _service.exportToExcel(year);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Excel file generated successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final methodTotals = _calculateMethodTotals();
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Background design elements
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryBlue.withOpacity(0.03),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accent2.withOpacity(0.05),
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (MediaQuery.of(context).size.width >= 1200)
                  const AppHeader(
                    title: 'Method Hours',
                    subtitle: 'Track your daily inspection method hours',
                    icon: Icons.engineering,
                  ),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.paddingLarge),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title section for mobile
                              if (MediaQuery.of(context).size.width < 1200)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppTheme.paddingLarge,
                                    vertical: AppTheme.paddingMedium,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(AppTheme.paddingMedium),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppTheme.primaryBlue,
                                              AppTheme.primaryBlue.withOpacity(0.8),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.primaryBlue.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.engineering_rounded,
                                          size: 32,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: AppTheme.paddingLarge),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Method Hours',
                                              style: AppTheme.titleLarge.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Track your daily inspection method hours',
                                              style: AppTheme.bodyMedium.copyWith(
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              
                              // Calendar section
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Calendar',
                                          style: AppTheme.titleMedium.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            _buildFormatButton(CalendarFormat.month, 'Month'),
                                            const SizedBox(width: 8),
                                            _buildFormatButton(CalendarFormat.twoWeeks, '2 Weeks'),
                                            const SizedBox(width: 8),
                                            _buildFormatButton(CalendarFormat.week, 'Week'),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
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
                                        todayDecoration: BoxDecoration(
                                          color: AppTheme.primaryBlue.withOpacity(0.7),
                                          shape: BoxShape.circle,
                                        ),
                                        selectedDecoration: const BoxDecoration(
                                          color: AppTheme.primaryBlue,
                                          shape: BoxShape.circle,
                                        ),
                                        markerDecoration: const BoxDecoration(
                                          color: AppTheme.accent2,
                                          shape: BoxShape.circle,
                                        ),
                                        weekendTextStyle: const TextStyle(color: Color(0xFFFF5252)),
                                        outsideTextStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5)),
                                      ),
                                      headerStyle: HeaderStyle(
                                        titleTextStyle: AppTheme.titleMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        formatButtonVisible: false,
                                        leftChevronIcon: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryBlue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.chevron_left,
                                            color: AppTheme.primaryBlue,
                                            size: 20,
                                          ),
                                        ),
                                        rightChevronIcon: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryBlue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.chevron_right,
                                            color: AppTheme.primaryBlue,
                                            size: 20,
                                          ),
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
                                                decoration: BoxDecoration(
                                                  color: AppTheme.accent2,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppTheme.accent2.withOpacity(0.3),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Stats Card
                              _buildStatsCard(methodTotals),
                              
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _addOrUpdateEntry(DateTime.now());
        },
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add),
        label: const Text('New Entry'),
        elevation: 2,
      ),
    );
  }

  Widget _buildFormatButton(CalendarFormat format, String label) {
    final isSelected = _calendarFormat == format;
    return InkWell(
      onTap: () {
        setState(() {
          _calendarFormat = format;
        });
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.divider,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(Map<InspectionMethod, double> methodTotals) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Method Hours Summary',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _buildTimeRangeButton('All Time', _showAllTime),
                  _buildTimeRangeButton('Current Year', !_showAllTime),
                  IconButton(
                    icon: const Icon(Icons.file_download_outlined),
                    onPressed: _exportToExcel,
                    tooltip: 'Export to Excel',
                    color: AppTheme.primaryBlue,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_allEntries.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'No entries yet',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            )
          else
            Column(
              children: InspectionMethod.values.map((method) {
                final hours = methodTotals[method] ?? 0;
                return _buildMethodStatRow(method, hours);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeButton(String label, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _showAllTime = label == 'All Time';
        });
        _loadAllEntries();
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.divider,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildMethodStatRow(InspectionMethod method, double hours) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.divider.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Method name with light blue gradient bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.15),
                  AppTheme.primaryBlue.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              method.name.toUpperCase(),
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Spacer(),
          // Hours value
          Text(
            '${hours.toStringAsFixed(1)} hrs',
            style: AppTheme.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
