import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';

class KnowledgeBaseScreen extends StatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  State<KnowledgeBaseScreen> createState() => _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends State<KnowledgeBaseScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Bluer navy for knowledge base cards
  static const Color _bluerNavy = Color(0xFF2a4a8c);
  
  final List<Map<String, dynamic>> _knowledgeArticles = [
    {
      'title': 'Common Formulas',
      'summary': 'Quick access to frequently used NDT and pipeline integrity calculations...',
      'icon': Icons.calculate,
      'color': _bluerNavy,
      'tags': ['Calculations', 'Reference', 'Formulas'],
      'route': '/common_formulas',
    },
    {
      'title': 'Field Safety and Compliance',
      'summary': 'Safety guidelines and compliance requirements for field operations',
      'icon': Icons.safety_check,
      'color': _bluerNavy,
      'tags': ['Safety', 'Compliance', 'Guidelines'],
      'route': '/field_safety',
    },
    {
      'title': 'NDT Procedures & Standards',
      'summary': 'Field-ready guidance for NDT inspections and code compliance',
      'icon': Icons.science,
      'color': _bluerNavy,
      'tags': ['Procedures', 'Standards', 'Inspections'],
      'route': '/ndt_procedures',
    },
    {
      'title': 'Defect Types & Identification',
      'summary': 'Comprehensive guide to corrosion, dents, hard spots, cracks, and their classification...',
      'icon': Icons.warning,
      'color': _bluerNavy,
      'tags': ['Defects', 'Identification', 'Classification'],
      'route': '/defect_types',
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredArticles {
    if (_searchQuery.isEmpty) {
      return _knowledgeArticles;
    }
    
    return _knowledgeArticles.where((article) {
      final title = article['title'].toString().toLowerCase();
      final summary = article['summary'].toString().toLowerCase();
      final tags = (article['tags'] as List<String>).join(' ').toLowerCase();
      final query = _searchQuery.toLowerCase();
      
      return title.contains(query) || summary.contains(query) || tags.contains(query);
    }).toList();
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
                    title: 'Knowledge Base',
                    subtitle: 'Your comprehensive field reference guide',
                    icon: Icons.psychology_outlined,
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
                            // Title section for smaller screens
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
                                        Icons.psychology_outlined,
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
                                            'Knowledge Base',
                                            style: AppTheme.titleLarge.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Your comprehensive field reference guide',
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
                            
                            // Search bar
                            Container(
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
                                controller: _searchController,
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search knowledge base...',
                                  hintStyle: TextStyle(color: AppTheme.textSecondary),
                                  prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                                  suffixIcon: _searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            setState(() {
                                              _searchController.clear();
                                              _searchQuery = '';
                                            });
                                          },
                                        )
                                      : null,
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
                            
                            // Articles list
                            Expanded(
                              child: _filteredArticles.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.search_off,
                                            size: 64,
                                            color: AppTheme.textSecondary.withOpacity(0.5),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No articles found',
                                            style: AppTheme.titleMedium.copyWith(
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Try a different search term',
                                            style: AppTheme.bodyMedium.copyWith(
                                              color: AppTheme.textSecondary.withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: _filteredArticles.length,
                                      itemBuilder: (context, index) {
                                        final article = _filteredArticles[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 16),
                                          child: _buildArticleCard(
                                            context,
                                            article['title'],
                                            article['summary'],
                                            article['icon'],
                                            article['color'],
                                            article['tags'],
                                            onTap: () => Navigator.pushNamed(
                                              context,
                                              article['route'],
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(
    BuildContext context,
    String title,
    String summary,
    IconData icon,
    Color color,
    List<String> tags, {
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: LinearGradient(
            colors: [
              Colors.white,
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap ?? () {
              // Fallback if no route provided
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening: $title')),
              );
            },
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
                              summary,
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
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
