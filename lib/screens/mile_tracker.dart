import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_theme.dart';

class MileTracker extends StatefulWidget {
  const MileTracker({super.key});

  @override
  State<MileTracker> createState() => _MileTrackerState();
}

class _MileTrackerState extends State<MileTracker> {
  final _formKey = GlobalKey<FormState>();
  final _milesController = TextEditingController();
  final _searchController = TextEditingController();
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _mileEntries = [];
  List<Map<String, dynamic>> _filteredEntries = [];

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  @override
  void dispose() {
    _milesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMockData() async {
    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _mileEntries = [
        {
          'id': const Uuid().v4(),
          'date': DateTime.now().subtract(const Duration(days: 1)),
          'miles': 45.5,
          'job_site': 'Downtown Refinery',
          'purpose': 'Routine Inspection',
        },
        {
          'id': const Uuid().v4(),
          'date': DateTime.now().subtract(const Duration(days: 2)),
          'miles': 32.0,
          'job_site': 'North Plant',
          'purpose': 'Emergency Call',
        },
        {
          'id': const Uuid().v4(),
          'date': DateTime.now().subtract(const Duration(days: 3)),
          'miles': 28.5,
          'job_site': 'South Facility',
          'purpose': 'Scheduled Maintenance',
        },
      ];
      _filteredEntries = List.from(_mileEntries);
      _isLoading = false;
    });
  }

  void _filterEntries(String query) {
    setState(() {
      _filteredEntries = _mileEntries.where((entry) {
        final jobSite = entry['job_site'].toString().toLowerCase();
        final purpose = entry['purpose'].toString().toLowerCase();
        final searchLower = query.toLowerCase();

        return jobSite.contains(searchLower) ||
            purpose.contains(searchLower);
      }).toList();
    });
  }

  double _calculateTotalMiles() {
    return _mileEntries.fold(0, (sum, entry) => sum + (entry['miles'] as double));
  }

  double _calculateLast7DaysMiles() {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return _mileEntries
        .where((entry) => (entry['date'] as DateTime).isAfter(sevenDaysAgo))
        .fold(0, (sum, entry) => sum + (entry['miles'] as double));
  }

  double _calculateMonthlyMiles() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    return _mileEntries
        .where((entry) => (entry['date'] as DateTime).isAfter(firstDayOfMonth))
        .fold(0, (sum, entry) => sum + (entry['miles'] as double));
  }

  void _addMileEntry() {
    if (!_formKey.currentState!.validate()) return;

    final entry = {
      'id': const Uuid().v4(),
      'date': DateTime.now(),
      'miles': double.parse(_milesController.text),
      'job_site': 'Current Job Site', // These would be input fields in a real app
      'purpose': 'Current Purpose',   // These would be input fields in a real app
    };

    setState(() {
      _mileEntries.add(entry);
      _filterEntries(_searchController.text);
      _milesController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mile Tracker',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your driving miles for work',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1C2E),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Stats Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Today',
                                '${_mileEntries.isNotEmpty && _mileEntries.first['date'].day == DateTime.now().day ? _mileEntries.first['miles'] : 0.0}',
                                Icons.today,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'Last 7 Days',
                                _calculateLast7DaysMiles().toStringAsFixed(1),
                                Icons.calendar_today,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'This Month',
                                _calculateMonthlyMiles().toStringAsFixed(1),
                                Icons.calendar_month,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'Total',
                                _calculateTotalMiles().toStringAsFixed(1),
                                Icons.speed,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Add Miles Form
                        Card(
                          child: Container(
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              gradient: AppTheme.cardGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Add Miles',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _milesController,
                                    decoration: const InputDecoration(
                                      labelText: 'Miles Driven',
                                      prefixIcon: Icon(Icons.speed),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter miles driven';
                                      }
                                      if (double.tryParse(value) == null) {
                                        return 'Please enter a valid number';
                                      }
                                      if (double.parse(value) <= 0) {
                                        return 'Miles must be greater than 0';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _addMileEntry,
                                      child: const Text('Add Miles'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Search and List
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search by job site or purpose...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                          ),
                          onChanged: _filterEntries,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ListView.builder(
                                  itemCount: _filteredEntries.length,
                                  itemBuilder: (context, index) {
                                    final entry = _filteredEntries[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: AppTheme.cardGradient,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.all(16),
                                          title: Text(
                                            entry['job_site'],
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 8),
                                              Text('Date: ${entry['date'].toString().split(' ')[0]}'),
                                              Text('Miles: ${entry['miles']}'),
                                              Text('Purpose: ${entry['purpose']}'),
                                            ],
                                          ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              '$value mi',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
} 