import 'package:flutter/material.dart';
import '../services/offline_service.dart';
import 'beam_geometry_category_screen.dart';
import 'snells_law_suite_category_screen.dart';
import 'array_geometry_category_screen.dart';
import 'pipeline_specific_category_screen.dart';
import 'field_productivity_category_screen.dart';

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
  
  // New Dark Color System
  static const Color _bgMain = Color(0xFF1E232A);
  static const Color _bgElevated = Color(0xFF242A33);
  static const Color _bgCard = Color(0xFF2A313B);
  static const Color _textPrimary = Color(0xFFEDF9FF);
  static const Color _textSecondary = Color(0xFFAEBBC8);
  static const Color _textMuted = Color(0xFF7F8A96);
  static const Color _accentPrimary = Color(0xFF6C5BFF);
  static const Color _accentSuccess = Color(0xFF00E5A8);
  static const Color _accentAlert = Color(0xFFFE637E);
  static const Color _accentYellow = Color(0xFFF8B800);
  
  final List<Map<String, dynamic>> _toolCategories = [
    {
      'title': 'Beam Geometry',
      'icon': Icons.explore_outlined,
      'description': 'Beam path calculations and visualization tools',
      'tags': ['Beam Path', 'Skip Distance', 'Angles'],
      'color': Color(0xFF6C5BFF), // Primary accent
    },
    {
      'title': 'Snell\'s Law Suite',
      'icon': Icons.waves_outlined,
      'description': 'Refraction angle and velocity calculations',
      'tags': ['Refraction', 'Wedge', 'Velocity'],
      'color': Color(0xFF00E5A8), // Success accent
    },
    {
      'title': 'Array Geometry',
      'icon': Icons.grid_4x4_outlined,
      'description': 'Phased array probe and element calculations',
      'tags': ['Phased Array', 'Elements', 'Pitch'],
      'color': Color(0xFF6C5BFF),
    },
    {
      'title': 'Focal Law Tools',
      'icon': Icons.center_focus_strong_outlined,
      'description': 'Focal law generation and delay calculations',
      'tags': ['Focal Laws', 'Delays', 'PAUT'],
      'color': Color(0xFFF8B800), // Yellow accent
    },
    {
      'title': 'Advanced',
      'icon': Icons.science_outlined,
      'description': 'Advanced NDT calculations and analysis',
      'tags': ['Advanced', 'Complex', 'Analysis'],
      'color': Color(0xFF6C5BFF),
    },
    {
      'title': 'Amplitude / dB Tools',
      'icon': Icons.graphic_eq_outlined,
      'description': 'Amplitude, decibel, and signal calculations',
      'tags': ['Amplitude', 'dB', 'Signal'],
      'color': Color(0xFF00E5A8),
    },
    {
      'title': 'Magnetic Particle',
      'icon': Icons.grain_outlined,
      'description': 'MT inspection tools and reference materials',
      'tags': ['MT', 'Magnetic', 'Surface'],
      'color': Color(0xFFFE637E), // Alert accent
    },
    {
      'title': 'Field Productivity Tools',
      'icon': Icons.work_outline,
      'description': 'Time-saving tools and utilities for field work',
      'tags': ['Productivity', 'Field', 'Utilities'],
      'color': Color(0xFFF8B800),
    },
    {
      'title': 'Radiography',
      'icon': Icons.camera_outlined,
      'description': 'RT inspection tools and reference materials',
      'tags': ['RT', 'X-Ray', 'Film'],
      'color': Color(0xFF6C5BFF),
    },
    {
      'title': 'Materials & Metallurgy Tools',
      'icon': Icons.category_outlined,
      'description': 'Material properties and metallurgy references',
      'tags': ['Materials', 'Metallurgy', 'Properties'],
      'color': Color(0xFF00E5A8),
    },
    {
      'title': 'Pipeline-Specific',
      'icon': Icons.linear_scale_outlined,
      'description': 'Pipeline integrity and corrosion tools',
      'tags': ['Pipeline', 'Corrosion', 'Integrity'],
      'color': Color(0xFFF8B800),
    },
    {
      'title': 'Geometry & Math Reference',
      'icon': Icons.functions_outlined,
      'description': 'Mathematical formulas and geometry tools',
      'tags': ['Math', 'Geometry', 'Formulas'],
      'color': Color(0xFF6C5BFF),
    },
    {
      'title': 'Code & Standard Reference',
      'icon': Icons.menu_book_outlined,
      'description': 'ASME, API, and other code references',
      'tags': ['Codes', 'Standards', 'ASME', 'API'],
      'color': Color(0xFFFE637E),
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
      begin: const Offset(0, 0.03),
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
      backgroundColor: _bgMain,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offline indicator (updated styling)
            if (!_isOnline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: _accentYellow.withOpacity(0.15),
                  border: Border(
                    bottom: BorderSide(
                      color: _accentYellow.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.wifi_off, color: _accentYellow, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You are offline. Calculator tools will work without internet.',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
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
                        // Header Section
                        _buildHeader(context),
                        const SizedBox(height: 32),
                        
                        // Tools Grid
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final crossAxisCount = constraints.maxWidth > 900 ? 2 : 1;
                              final cardWidth = (constraints.maxWidth - 20) / crossAxisCount;
                              final cardHeight = cardWidth / (constraints.maxWidth > 900 ? 2.8 : 2.5);
                              
                              return GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: constraints.maxWidth > 900 ? 2.8 : 2.5,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                ),
                                itemCount: _toolCategories.length,
                                itemBuilder: (context, index) {
                                  final category = _toolCategories[index];
                                  return _buildToolCategoryCard(
                                    context,
                                    category['title'],
                                    category['icon'],
                                    category['description'],
                                    category['tags'],
                                    category['color'],
                                    () => _handleCategoryTap(context, index, category),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container with subtle glow
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _accentPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _accentPrimary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.build_rounded,
              size: 32,
              color: _accentPrimary,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NDT Tools',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Professional calculation tools for pipeline inspection',
                  style: TextStyle(
                    fontSize: 14,
                    color: _textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          // Optional: Add a yellow accent element
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: _accentYellow,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCategoryCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    List<String> tags,
    Color accentColor,
    VoidCallback onTap,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            hoverColor: Colors.white.withOpacity(0.02),
            splashColor: accentColor.withOpacity(0.1),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header row with icon and arrow
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accentColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          icon,
                          size: 24,
                          color: accentColor,
                        ),
                      ),
                      const Spacer(),
                      // Arrow indicator
                      Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: _textMuted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Title and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Flexible(
                          child: Text(
                            description,
                            style: TextStyle(
                              fontSize: 12,
                              color: _textSecondary,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Tags
                  if (tags.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: tags.take(3).map((tag) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildTag(tag, accentColor),
                        )).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: accentColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accentColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  void _handleCategoryTap(BuildContext context, int index, Map<String, dynamic> category) {
    if (index == 0) {
      // Beam Geometry
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BeamGeometryCategoryScreen(),
        ),
      );
    } else if (index == 1) {
      // Snell's Law Suite
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SnellsLawSuiteCategoryScreen(),
        ),
      );
    } else if (index == 2) {
      // Array Geometry
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ArrayGeometryCategoryScreen(),
        ),
      );
    } else if (index == 7) {
      // Field Productivity Tools
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FieldProductivityCategoryScreen(),
        ),
      );
    } else if (index == 10) {
      // Pipeline-Specific
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PipelineSpecificCategoryScreen(),
        ),
      );
    } else {
      // Other categories - coming soon
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${category['title']} - Coming soon!',
            style: const TextStyle(
              color: Color(0xFFEDF9FF),
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: const Color(0xFF2A313B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
