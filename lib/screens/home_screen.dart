import 'package:flutter/material.dart';
import '../calculators/abs_es_calculator.dart';
import '../calculators/pit_depth_calculator.dart';
import '../calculators/time_clock_calculator.dart';
import '../calculators/b31g_calculator.dart';
import '../screens/company_directory.dart';
import '../theme/app_theme.dart';
import '../calculators/soc_eoc_calculator.dart';
import '../calculators/dent_ovality_calculator.dart';
import '../widgets/weather_widget.dart';
import '../widgets/safety_banner.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 1200;
    
    return Scaffold(
      backgroundColor: const Color(0xFF1E232A), // Main background
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(isLargeScreen ? 32.0 : 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dashboard',
                          style: TextStyle(
                            fontSize: isLargeScreen ? 36 : 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFEDF9FF), // Primary text
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome to your NDT inspection toolkit',
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFFAEBBC8), // Secondary text
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Quick Actions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 32.0 : 24.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFEDF9FF), // Primary text
                          ),
                        ),
                        const SizedBox(height: 16),
                        isLargeScreen
                            ? Row(
                                children: [
                                  Expanded(
                                    child: _buildQuickActionCard(
                                      context,
                                      'Time Clock',
                                      Icons.access_time_outlined,
                                      const Color(0xFF6C5BFF), // Primary accent
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const TimeClockCalculator(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildQuickActionCard(
                                      context,
                                      'Pit Depth',
                                      Icons.height_outlined,
                                      const Color(0xFF00E5A8), // Secondary accent
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const PitDepthCalculator(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildQuickActionCard(
                                      context,
                                      'B31G',
                                      Icons.engineering_outlined,
                                      const Color(0xFFFE637E), // Accessory accent
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const B31GCalculator(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildQuickActionCard(
                                    context,
                                    'Time Clock',
                                    Icons.access_time_outlined,
                                    const Color(0xFF6C5BFF), // Primary accent
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const TimeClockCalculator(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildQuickActionCard(
                                    context,
                                    'Pit Depth',
                                    Icons.height_outlined,
                                    const Color(0xFF00E5A8), // Secondary accent
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const PitDepthCalculator(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildQuickActionCard(
                                    context,
                                    'B31G',
                                    Icons.engineering_outlined,
                                    const Color(0xFFFE637E), // Accessory accent
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const B31GCalculator(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                
                // Essential Resources
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 32.0 : 24.0,
                    ),
                    child: Text(
                      'Essential Resources',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFEDF9FF), // Primary text
                      ),
                    ),
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                
                // Resource Cards Grid
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 32.0 : 24.0,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isLargeScreen ? 2 : 1,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: isLargeScreen ? 2.5 : 3.5,
                    ),
                    delegate: SliverChildListDelegate([
                      _buildResourceCard(
                        context,
                        'ABS + ES Calculator',
                        'Calculate ABS and ES values',
                        Icons.calculate_outlined,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AbsEsCalculator(),
                          ),
                        ),
                      ),
                      _buildResourceCard(
                        context,
                        'SOC & EOC',
                        'Start/End of Coating calculations',
                        Icons.straighten,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SocEocCalculator(),
                          ),
                        ),
                      ),
                      _buildResourceCard(
                        context,
                        'Dent Ovality',
                        'Calculate dent ovality percentage',
                        Icons.circle_outlined,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DentOvalityCalculator(),
                          ),
                        ),
                      ),
                      _buildResourceCard(
                        context,
                        'Company Directory',
                        'Access company contacts',
                        Icons.people_outline,
                        () => Navigator.pushNamed(context, '/company_directory'),
                      ),
                    ]),
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color accentColor,
    VoidCallback onTap,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2A313B), // Card surface
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
                  size: 28,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEDF9FF), // Primary text
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: const Color(0xFF7F8A96), // Muted text
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2A313B), // Card surface
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5BFF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6C5BFF).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: const Color(0xFF6C5BFF), // Primary accent
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEDF9FF), // Primary text
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFFAEBBC8), // Secondary text
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
                color: const Color(0xFF7F8A96), // Muted text
              ),
            ],
          ),
        ),
      ),
    );
  }
}
