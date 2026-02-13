import 'package:flutter/material.dart';
import '../calculators/abs_es_calculator.dart';
import '../calculators/pit_depth_calculator.dart';
import '../calculators/time_clock_calculator.dart';
import '../calculators/dent_ovality_calculator.dart';
import '../calculators/b31g_calculator.dart';
import '../calculators/depth_percentages_calculator.dart';
import '../widgets/app_header.dart';
import '../widgets/offline_indicator.dart';
import '../services/offline_service.dart';
import 'corrosion_grid_logger_screen.dart';
import 'pdf_to_excel_screen.dart';

class MostUsedToolsScreen extends StatefulWidget {
  const MostUsedToolsScreen({super.key});

  @override
  State<MostUsedToolsScreen> createState() => _MostUsedToolsScreenState();
}

class _MostUsedToolsScreenState extends State<MostUsedToolsScreen> with SingleTickerProviderStateMixin {
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
      'color': Color(0xFF6C5BFF), // Primary accent
      'route': const AbsEsCalculator(),
    },
    {
      'title': 'Pit Depth Calculator',
      'icon': Icons.height_outlined,
      'description': 'Calculate pit depths and measurements',
      'tags': ['Corrosion', 'Wall Loss', 'Remaining'],
      'color': Color(0xFF00E5A8), // Secondary accent
      'route': const PitDepthCalculator(),
    },
    {
      'title': 'Time Clock Calculator',
      'icon': Icons.access_time_outlined,
      'description': 'Track and calculate work hours',
      'tags': ['Clock Position', 'Distance', 'Conversion'],
      'color': Color(0xFF6C5BFF), // Primary accent
      'route': const TimeClockCalculator(),
    },
    {
      'title': 'Dent Ovality Calculator',
      'icon': Icons.circle_outlined,
      'description': 'Calculate dent ovality percentage',
      'tags': ['Dent', 'Deformation', 'Percentage'],
      'color': Color(0xFFFE637E), // Accessory accent
      'route': const DentOvalityCalculator(),
    },
    {
      'title': 'B31G Calculator',
      'icon': Icons.engineering_outlined,
      'description': 'Calculate pipe defect assessment using B31G method',
      'tags': ['Corrosion', 'Assessment', 'ASME'],
      'color': Color(0xFF00E5A8), // Secondary accent
      'route': const B31GCalculator(),
    },
    {
      'title': 'Corrosion Grid Logger',
      'icon': Icons.grid_on_outlined,
      'description': 'Log and export corrosion grid data for RSTRENG',
      'tags': ['Grid', 'RSTRENG', 'Export'],
      'color': Color(0xFFF8B800), // Accessory accent
      'route': const CorrosionGridLoggerScreen(),
    },
    {
      'title': 'PDF to Excel Converter',
      'icon': Icons.picture_as_pdf_outlined,
      'description': 'Convert hardness PDF files to Excel format',
      'tags': ['PDF', 'Excel', 'Hardness', 'Convert'],
      'color': Color(0xFF00E5A8), // Secondary accent
      'route': const PdfToExcelScreen(),
    },
    {
      'title': 'Depth Percentages Chart',
      'icon': Icons.analytics_outlined,
      'description': 'Visualize and analyze depth percentages for inspection data',
      'tags': ['Charts', 'Analysis', 'Visualization', 'Depth'],
      'color': Color(0xFF6C5BFF), // Primary accent
      'route': const DepthPercentagesCalculator(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.02),
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
      backgroundColor: const Color(0xFF1E232A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offline indicator
            OfflineIndicator(
              message: 'You are offline. Calculator tools will work without internet.',
            ),
            if (MediaQuery.of(context).size.width >= 1200)
              const AppHeader(
                title: 'Most Used Tools',
                subtitle: 'Most frequently used NDT calculation tools',
                icon: Icons.star,
              ),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title section for mobile
                        if (MediaQuery.of(context).size.width < 1200)
                          Container(
                            padding: const EdgeInsets.all(24),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A313B),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.05),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6C5BFF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.star_rounded,
                                    size: 28,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Most Used Tools',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFEDF9FF),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Most frequently used NDT calculation tools',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFFAEBBC8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A313B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: color.withOpacity(0.3),
                          width: 1,
                        ),
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
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFFEDF9FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFAEBBC8),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
