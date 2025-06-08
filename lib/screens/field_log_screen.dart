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
  List<FieldLogEntry> _entries = [];
  List<FieldLogEntry> _recentEntries = [];
  bool _isLoading = false;
  Set<DateTime> _daysWithEntries = {};
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadEntries();
    _loadRecentEntries();
    
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
                    title: 'Field Log',
                    subtitle: 'Track your daily work hours and mileage',
                    icon: Icons.note_alt,
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
                                          Icons.note_alt_rounded,
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
                                              'Field Log',
                                              style: AppTheme.titleLarge.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Track your daily work hours and mileage',
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
                              
                              // Recent entries section
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Recent Entries',
                                    style: AppTheme.titleMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      // TODO: Navigate to all entries view
                                    },
                                    icon: const Icon(Icons.visibility_outlined, size: 18),
                                    label: const Text('View All'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppTheme.primaryBlue,
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Entries list
                              _isLoading
                                  ? _buildLoadingState()
                                  : _recentEntries.isEmpty
                                      ? _buildEmptyState()
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: _recentEntries.length,
                                          itemBuilder: (context, index) {
                                            final entry = _recentEntries[index];
                                            return _buildEntryCard(entry, index);
                                          },
                                        ),
                              // Add some bottom padding for better spacing with FAB
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

  Widget _buildEntryCard(FieldLogEntry entry, int index) {
    final date = entry.localDate;
    final formattedDate = '${date.month}/${date.day}/${date.year}';
    
    // Calculate total method hours
    double totalMethodHours = 0;
    for (var mh in entry.methodHours) {
      totalMethodHours += mh.hours;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        child: InkWell(
          onTap: () {
            _addOrUpdateEntry(entry.localDate);
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.projectName,
                            style: AppTheme.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formattedDate,
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                          onPressed: () {
                            _addOrUpdateEntry(entry.localDate);
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red.shade400,
                            size: 20,
                          ),
                          onPressed: () async {
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
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            
                            if (confirm == true) {
                              await _service.deleteEntry(entry.id);
                              await _loadEntries();
                              await _loadRecentEntries();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'Miles',
                        entry.miles.toString(),
                        Icons.directions_car_outlined,
                        AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        'Hours',
                        entry.hours.toString(),
                        Icons.access_time_outlined,
                        AppTheme.accent1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        'Method Hours',
                        totalMethodHours.toString(),
                        Icons.engineering_outlined,
                        AppTheme.accent2,
                      ),
                    ),
                  ],
                ),
                if (entry.methodHours.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Method Hours Breakdown',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entry.methodHours.map((mh) => _buildMethodTag(
                      mh.method.name.toUpperCase(),
                      mh.hours.toString(),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodTag(String method, String hours) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppTheme.accent2.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.accent2.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            method,
            style: TextStyle(
              color: AppTheme.accent2,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$hours hrs',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.note_alt_outlined,
              size: 48,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No entries yet',
            style: AppTheme.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first field log entry',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _addOrUpdateEntry(DateTime.now());
            },
            icon: const Icon(Icons.add),
            label: const Text('New Entry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading entries...',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
