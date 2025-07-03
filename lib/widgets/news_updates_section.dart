import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/news_update.dart';
import '../services/news_service.dart';

class NewsUpdatesSection extends StatelessWidget {
  const NewsUpdatesSection({super.key});

  NewsService get _newsService => NewsService();

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
            FutureBuilder<List<NewsUpdate>>(
              future: _newsService.getRecentUpdates(limit: 4),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppTheme.paddingLarge),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.paddingLarge),
                      child: Column(
                        children: [
                          Icon(Icons.error, color: Colors.red[300], size: 48),
                          const SizedBox(height: 8),
                          Text(
                            'Error loading updates',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final updates = snapshot.data ?? [];

                if (updates.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.paddingLarge),
                      child: Column(
                        children: [
                          Icon(Icons.article, color: AppTheme.textSecondary.withOpacity(0.5), size: 48),
                          const SizedBox(height: 8),
                          Text(
                            'No updates available',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: updates.asMap().entries.map((entry) {
                    final index = entry.key;
                    final update = entry.value;
                    return Column(
                      children: [
                        _buildUpdateItem(update),
                        if (index < updates.length - 1)
                          const Divider(height: 24),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
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
            color: update.category.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Icon(
            update.icon,
            color: update.category.color,
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
                      color: update.category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      update.category.displayName,
                      style: AppTheme.bodyMedium.copyWith(
                        color: update.category.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.paddingSmall),
                  Text(
                    _getTimeAgo(update.publishDate ?? update.createdDate),
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
