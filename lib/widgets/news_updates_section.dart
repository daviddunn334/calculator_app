import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NewsUpdate {
  final String title;
  final String description;
  final DateTime date;
  final NewsCategory category;
  final IconData icon;

  const NewsUpdate({
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    required this.icon,
  });
}

enum NewsCategory {
  company,
  industry,
  protocol,
  training,
}

class NewsUpdatesSection extends StatelessWidget {
  const NewsUpdatesSection({super.key});

  // Sample updates - in a real app, these would come from a backend
  static final List<NewsUpdate> updates = [
    NewsUpdate(
      title: 'Annual Safety Training Due',
      description: 'Complete your annual safety certification by June 30th',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      category: NewsCategory.training,
      icon: Icons.school,
    ),
    NewsUpdate(
      title: 'New Inspection Protocol',
      description: 'Updated guidelines for corrosion assessment',
      date: DateTime.now().subtract(const Duration(hours: 5)),
      category: NewsCategory.protocol,
      icon: Icons.new_releases,
    ),
    NewsUpdate(
      title: 'Industry Conference 2024',
      description: 'Registration open for Pipeline Tech Conference',
      date: DateTime.now().subtract(const Duration(days: 1)),
      category: NewsCategory.industry,
      icon: Icons.business,
    ),
    NewsUpdate(
      title: 'Company Milestone',
      description: '1000 successful inspections completed this quarter',
      date: DateTime.now().subtract(const Duration(days: 2)),
      category: NewsCategory.company,
      icon: Icons.celebration,
    ),
  ];

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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: const BorderSide(color: AppTheme.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.newspaper, color: AppTheme.accent5, size: 24),
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
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/news_updates');
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingLarge),
            ...updates.map((update) => Column(
              children: [
                _buildUpdateItem(update),
                if (update != updates.last)
                  const Divider(height: 24),
              ],
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateItem(NewsUpdate update) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getCategoryColor(update.category).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Icon(
            update.icon,
            color: _getCategoryColor(update.category),
            size: 24,
          ),
        ),
        const SizedBox(width: AppTheme.paddingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      style: AppTheme.bodyMedium.copyWith(
                        color: _getCategoryColor(update.category),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.paddingSmall),
                  Text(
                    _getTimeAgo(update.date),
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                update.title,
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                update.description,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
