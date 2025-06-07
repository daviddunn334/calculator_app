import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/news_updates_section.dart';

class NewsUpdatesScreen extends StatefulWidget {
  const NewsUpdatesScreen({super.key});

  @override
  State<NewsUpdatesScreen> createState() => _NewsUpdatesScreenState();
}

class _NewsUpdatesScreenState extends State<NewsUpdatesScreen> {
  // Sample updates - in a real app, these would come from a backend
  // Using the same sample data from NewsUpdatesSection for consistency
  final List<NewsUpdate> allUpdates = [
    ...NewsUpdatesSection.updates,
    // Additional updates for the full page view
    NewsUpdate(
      title: 'Equipment Maintenance Schedule',
      description: 'Updated maintenance schedule for Q3 2024',
      date: DateTime.now().subtract(const Duration(days: 3)),
      category: NewsCategory.company,
      icon: Icons.build_circle,
    ),
    NewsUpdate(
      title: 'New Safety Regulations',
      description: 'Important updates to confined space entry procedures',
      date: DateTime.now().subtract(const Duration(days: 4)),
      category: NewsCategory.protocol,
      icon: Icons.health_and_safety,
    ),
    NewsUpdate(
      title: 'Team Building Event',
      description: 'Annual company picnic scheduled for July 15th',
      date: DateTime.now().subtract(const Duration(days: 5)),
      category: NewsCategory.company,
      icon: Icons.groups,
    ),
    NewsUpdate(
      title: 'Certification Reminder',
      description: 'NACE certification renewals due next month',
      date: DateTime.now().subtract(const Duration(days: 6)),
      category: NewsCategory.training,
      icon: Icons.card_membership,
    ),
    NewsUpdate(
      title: 'Industry Webinar',
      description: 'Free webinar on advanced ultrasonic testing techniques',
      date: DateTime.now().subtract(const Duration(days: 7)),
      category: NewsCategory.industry,
      icon: Icons.computer,
    ),
  ];

  // Filter state
  String _searchQuery = '';
  NewsCategory? _selectedCategory;

  List<NewsUpdate> get _filteredUpdates {
    return allUpdates.where((update) {
      // Apply category filter
      if (_selectedCategory != null && update.category != _selectedCategory) {
        return false;
      }
      
      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        return update.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               update.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      
      return true;
    }).toList();
  }

  Color _getCategoryColor(NewsCategory category) {
    switch (category) {
      case NewsCategory.company:
        return AppTheme.accent1;
      case NewsCategory.industry:
        return AppTheme.accent2;
      case NewsCategory.protocol:
        return AppTheme.accent3;
      case NewsCategory.training:
        return AppTheme.accent4;
    }
  }

  String _getCategoryLabel(NewsCategory category) {
    switch (category) {
      case NewsCategory.company:
        return 'Company';
      case NewsCategory.industry:
        return 'Industry';
      case NewsCategory.protocol:
        return 'Protocol';
      case NewsCategory.training:
        return 'Training';
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _getFormattedDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with search
            Container(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.newspaper, color: AppTheme.accent5, size: 28),
                      const SizedBox(width: AppTheme.paddingMedium),
                      Text(
                        'News & Updates',
                        style: AppTheme.titleLarge.copyWith(
                          color: AppTheme.accent5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  Text(
                    'Stay informed with the latest company announcements, industry news, and important updates',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingLarge),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search updates...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                      filled: true,
                      fillColor: AppTheme.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(null, 'All'),
                        const SizedBox(width: 8),
                        _buildFilterChip(NewsCategory.company, 'Company'),
                        const SizedBox(width: 8),
                        _buildFilterChip(NewsCategory.industry, 'Industry'),
                        const SizedBox(width: 8),
                        _buildFilterChip(NewsCategory.protocol, 'Protocol'),
                        const SizedBox(width: 8),
                        _buildFilterChip(NewsCategory.training, 'Training'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Updates list
            Expanded(
              child: _filteredUpdates.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppTheme.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No updates found',
                            style: AppTheme.titleMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search or filters',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppTheme.paddingLarge),
                      itemCount: _filteredUpdates.length,
                      separatorBuilder: (context, index) => const Divider(height: 32),
                      itemBuilder: (context, index) {
                        final update = _filteredUpdates[index];
                        return _buildUpdateItem(update);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(NewsCategory? category, String label) {
    final bool isSelected = _selectedCategory == category;
    final Color chipColor = category == null 
        ? AppTheme.primaryBlue 
        : _getCategoryColor(category);
    
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : chipColor,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: chipColor.withOpacity(0.1),
      selectedColor: chipColor,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        side: BorderSide(
          color: chipColor.withOpacity(isSelected ? 0 : 0.3),
        ),
      ),
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
        });
      },
    );
  }

  Widget _buildUpdateItem(NewsUpdate update) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getCategoryColor(update.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(
                  update.icon,
                  color: _getCategoryColor(update.category),
                  size: 28,
                ),
              ),
              const SizedBox(width: AppTheme.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      update.title,
                      style: AppTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(update.category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getCategoryLabel(update.category),
                            style: AppTheme.bodySmall.copyWith(
                              color: _getCategoryColor(update.category),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getFormattedDate(update.date),
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _getTimeAgo(update.date),
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Text(
            update.description,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  // TODO: Implement read more functionality
                },
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('Read More'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingMedium,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
