import 'package:flutter/material.dart';
import '../calculators/abs_es_calculator.dart';
import '../calculators/pit_depth_calculator.dart';
import '../calculators/time_clock_calculator.dart';
import '../calculators/dent_ovality_calculator.dart';
import '../calculators/b31g_calculator.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/offline_indicator.dart';
import '../services/offline_service.dart';
import 'corrosion_grid_logger_screen.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final OfflineService _offlineService = OfflineService();
  bool _isOnline = true;
  
  final List<Map<String, dynamic>> _calculators = [
    {
      'title': 'ABS + ES Calculator',
      'icon': Icons.calculate_outlined,
      'description': 'Calculate ABS and ES values',
      'tags': ['Offset', 'Distance', 'RGW'],
      'color': Color(0xFF3F51B5), // Indigo
      'route': const AbsEsCalculator(),
    },
    {
      'title': 'Pit Depth Calculator',
      'icon': Icons.height_outlined,
      'description': 'Calculate pit depths and measurements',
      'tags': ['Corrosion', 'Wall Loss', 'Remaining'],
      'color': Color(0xFF009688), // Teal
      'route': const PitDepthCalculator(),
    },
    {
      'title': 'Time Clock Calculator',
      'icon': Icons.access_time_outlined,
      'description': 'Track and calculate work hours',
      'tags': ['Clock Position', 'Distance', 'Conversion'],
      'color': Color(0xFF673AB7), // Deep Purple
      'route': const TimeClockCalculator(),
    },
    {
      'title': 'Dent Ovality Calculator',
      'icon': Icons.circle_outlined,
      'description': 'Calculate dent ovality percentage',
      'tags': ['Dent', 'Deformation', 'Percentage'],
      'color': Color(0xFFE91E63), // Pink
      'route': const DentOvalityCalculator(),
    },
    {
      'title': 'B31G Calculator',
      'icon': Icons.engineering_outlined,
      'description': 'Calculate pipe defect assessment using B31G method',
      'tags': ['Corrosion', 'Assessment', 'ASME'],
      'color': Color(0xFF2196F3), // Blue
      'route': const B31GCalculator(),
    },
    {
      'title': 'Corrosion Grid Logger',
      'icon': Icons.grid_on_outlined,
      'description': 'Log and export corrosion grid data for RSTRENG',
      'tags': ['Grid', 'RSTRENG', 'Export'],
      'color': Color(0xFFFF9800), // Orange
      'route': const CorrosionGridLoggerScreen(),
    },
  ];

  @override
  void initState() {
    super.initState();
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
    
    // Check online status
    _isOnline = _offlineService.isOnline;
    _offlineService.onConnectivityChanged.listen((online) {
      if (mounted) {
        setState(() {
          _isOnline = online;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
                // Offline indicator
                OfflineIndicator(
                  message: 'You are offline. Calculator tools will work without internet.',
                ),
                if (MediaQuery.of(context).size.width >= 1200)
                  const AppHeader(
                    title: 'NDT Tools',
                    subtitle: 'Professional calculation tools for pipeline inspection',
                    icon: Icons.build,
                  ),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.paddingLarge),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title section
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
                                        Icons.build_rounded,
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
                                            'NDT Tools',
                                            style: AppTheme.titleLarge.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Professional calculation tools for pipeline inspection',
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
                            
                            // Search bar with offline indicator
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Search tools...',
                                        hintStyle: TextStyle(color: AppTheme.textSecondary),
                                        prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                if (!_isOnline)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8, bottom: 24),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const OfflineIndicator(
                                        compact: true,
                                        backgroundColor: Colors.orange,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            
                            // Tools grid
                            Expanded(
                              child: GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: MediaQuery.of(context).size.width > 900 ? 2 : 1,
                                  childAspectRatio: 2.2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: _calculators.length,
                                itemBuilder: (context, index) {
                                  final calculator = _calculators[index];
                                  return _buildCalculatorCard(
                                    context,
                                    calculator['title'],
                                    calculator['icon'],
                                    calculator['description'],
                                    calculator['tags'],
                                    calculator['color'],
                                    () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => calculator['route'],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildCalculatorCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    List<String> tags,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: BorderSide(color: AppTheme.divider, width: 1.5),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        child: Icon(
                          icon,
                          size: 24,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTheme.titleMedium.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: color,
                      ),
                    ],
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags.map((tag) => _buildTag(tag, color)).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
