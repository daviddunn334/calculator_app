import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/method_hours_entry.dart';
import '../services/method_hours_service.dart';
import '../widgets/method_hours_dialog.dart';
import '../widgets/app_header.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MethodHoursScreen extends StatefulWidget {
  const MethodHoursScreen({super.key});

  @override
  State<MethodHoursScreen> createState() => _MethodHoursScreenState();
}

class _MethodHoursScreenState extends State<MethodHoursScreen> with SingleTickerProviderStateMixin {
  final MethodHoursService _service = MethodHoursService();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<MethodHoursEntry> _allEntries = [];
  bool _isLoading = false;
  Set<DateTime> _daysWithEntries = {};
  bool _showAllTime = true;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _selectedDay = DateTime.now();
    _loadAllEntries();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.03),
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

  Future<void> _loadAllEntries({bool forceServerFetch = false}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      DateTime startDate;
      DateTime endDate;
      
      if (_showAllTime) {
        startDate = DateTime(2020, 1, 1);
        endDate = DateTime(DateTime.now().year + 1, 12, 31);
      } else {
        startDate = DateTime(DateTime.now().year, 1, 1);
        endDate = DateTime(DateTime.now().year, 12, 31);
      }
      
      final entries = await _service.getEntriesForDateRange(startDate, endDate, forceServerFetch: forceServerFetch);
      
      setState(() {
        _allEntries = entries;
        _daysWithEntries = entries.map((e) => e.normalizedDate).toSet();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<InspectionMethod, double> _calculateMethodTotals() {
    final totals = <InspectionMethod, double>{};
    
    for (var method in InspectionMethod.values) {
      totals[method] = 0;
    }
    
    for (var entry in _allEntries) {
      for (var mh in entry.methodHours) {
        totals[mh.method] = (totals[mh.method] ?? 0) + mh.hours;
      }
    }
    
    return totals;
  }

  Future<void> _addOrUpdateEntry(DateTime date) async {
    final localDate = DateTime(date.year, date.month, date.day);
    final existingEntries = await _service.getEntriesForDate(localDate);
    final existingEntry = existingEntries.isNotEmpty ? existingEntries.first : null;

    final result = await showDialog<MethodHoursEntry>(
      context: context,
      builder: (context) => MethodHoursDialog(
        date: localDate,
        existingEntry: existingEntry,
      ),
    );

    if (result != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please sign in to add entries'),
              backgroundColor: _alertAccent,
            ),
          );
        }
        return;
      }

      try {
        final entry = MethodHoursEntry(
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
        
        await Future.delayed(const Duration(milliseconds: 200));
        await _loadAllEntries(forceServerFetch: true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving entry: $e'),
              backgroundColor: _alertAccent,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteEntry(MethodHoursEntry entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Entry',
          style: TextStyle(color: _primaryText, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this entry?',
          style: TextStyle(color: _secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: _secondaryText)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _alertAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await _service.deleteEntry(entry.id);
      await Future.delayed(const Duration(milliseconds: 200));
      await _loadAllEntries(forceServerFetch: true);
    }
  }

  Future<void> _exportToExcel() async {
    try {
      final currentYear = DateTime.now().year;
      final lastYear = currentYear - 1;
      
      final year = await showDialog<int>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: _cardSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Select Year to Export',
            style: TextStyle(color: _primaryText, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildYearOption(currentYear, 'Export $currentYear Method Hours'),
              const SizedBox(height: 8),
              _buildYearOption(lastYear, 'Export $lastYear Method Hours'),
            ],
          ),
        ),
      );

      if (year != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Generating Excel file from template...'),
              backgroundColor: _primaryAccent,
            ),
          );
        }
        
        await _service.exportToExcel(year);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Excel file generated successfully!'),
              backgroundColor: _successAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting: $e'),
            backgroundColor: _alertAccent,
          ),
        );
      }
    }
  }

  Widget _buildYearOption(int year, String text) {
    return InkWell(
      onTap: () => Navigator.pop(context, year),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: _elevatedSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: _primaryText,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final methodTotals = _calculateMethodTotals();
    
    return Scaffold(
      backgroundColor: _mainBackground,
      body: SafeArea(
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
                    padding: const EdgeInsets.all(24.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title section for mobile
                          if (MediaQuery.of(context).size.width < 1200)
                            _buildMobileHeader(),
                          
                          const SizedBox(height: 24),
                          
                          // Calendar section
                          _buildCalendarCard(),
                          
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrUpdateEntry(DateTime.now()),
        backgroundColor: _primaryAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Entry', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 2,
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _primaryAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.engineering_rounded,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Method Hours',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track your daily inspection method hours',
                  style: TextStyle(
                    fontSize: 14,
                    color: _secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Calendar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryText,
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
          const SizedBox(height: 20),
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
                color: _yellowAccent,
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(
                color: Color(0xFF1E232A),
                fontWeight: FontWeight.bold,
              ),
              selectedDecoration: BoxDecoration(
                color: _primaryAccent,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              defaultTextStyle: TextStyle(color: _primaryText),
              weekendTextStyle: TextStyle(color: _alertAccent),
              outsideTextStyle: TextStyle(color: _mutedText),
              markerDecoration: BoxDecoration(
                color: _successAccent,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              titleTextStyle: TextStyle(
                color: _primaryText,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(Icons.chevron_left, color: _secondaryText),
              rightChevronIcon: Icon(Icons.chevron_right, color: _secondaryText),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: _secondaryText, fontWeight: FontWeight.w600),
              weekendStyle: TextStyle(color: _alertAccent, fontWeight: FontWeight.w600),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (_daysWithEntries.contains(DateTime(date.year, date.month, date.day))) {
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _successAccent,
                        shape: BoxShape.circle,
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _primaryAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? _primaryAccent : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : _secondaryText,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(Map<InspectionMethod, double> methodTotals) {
    return Container(
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Method Hours Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryText,
                ),
              ),
              IconButton(
                icon: Icon(Icons.file_download_outlined, color: _yellowAccent),
                onPressed: _exportToExcel,
                tooltip: 'Export to Excel',
                style: IconButton.styleFrom(
                  backgroundColor: _yellowAccent.withOpacity(0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTimeRangeButton('All Time', _showAllTime),
              const SizedBox(width: 8),
              _buildTimeRangeButton('Current Year', !_showAllTime),
            ],
          ),
          const SizedBox(height: 24),
          
          if (_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: _primaryAccent),
              ),
            )
          else if (_allEntries.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    Icon(Icons.engineering_outlined, size: 48, color: _mutedText),
                    const SizedBox(height: 12),
                    Text(
                      'No entries yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: _mutedText,
                      ),
                    ),
                  ],
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
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _primaryAccent : _elevatedSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _primaryAccent : Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : _secondaryText,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildMethodStatRow(InspectionMethod method, double hours) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _elevatedSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _primaryAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _primaryAccent.withOpacity(0.3), width: 1),
            ),
            child: Text(
              method.name.toUpperCase(),
              style: TextStyle(
                color: _primaryAccent,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '${hours.toStringAsFixed(1)} hrs',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _primaryText,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
