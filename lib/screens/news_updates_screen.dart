import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/news_update.dart';
import '../services/news_service.dart';
import '../services/user_service.dart';

class NewsUpdatesScreen extends StatefulWidget {
  const NewsUpdatesScreen({super.key});

  @override
  State<NewsUpdatesScreen> createState() => _NewsUpdatesScreenState();
}

class _NewsUpdatesScreenState extends State<NewsUpdatesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NewsService _newsService = NewsService();
  final UserService _userService = UserService();
  
  NewsCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // 4 categories + All
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('News & Updates'),
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            isScrollable: true,
            tabs: [
              const Tab(text: 'All'),
              Tab(text: NewsCategory.company.displayName),
              Tab(text: NewsCategory.industry.displayName),
              Tab(text: NewsCategory.protocol.displayName),
              Tab(text: NewsCategory.training.displayName),
            ],
            onTap: (index) {
              setState(() {
                _selectedCategory = index == 0 ? null : NewsCategory.values[index - 1];
              });
            },
          ),
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildNewsTab(null), // All categories
                  _buildNewsTab(NewsCategory.company),
                  _buildNewsTab(NewsCategory.industry),
                  _buildNewsTab(NewsCategory.protocol),
                  _buildNewsTab(NewsCategory.training),
                ],
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      color: Colors.white,
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search news and updates...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          filled: true,
          fillColor: AppTheme.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildNewsTab(NewsCategory? category) {
    return StreamBuilder<List<NewsUpdate>>(
      stream: _newsService.getPublishedUpdates(category: category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text('Error loading updates: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final allUpdates = snapshot.data ?? [];
        final filteredUpdates = _filterUpdates(allUpdates);

        if (filteredUpdates.isEmpty) {
          return _buildEmptyState(category);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          itemCount: filteredUpdates.length,
          itemBuilder: (context, index) {
            return _buildUpdateCard(filteredUpdates[index]);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(NewsCategory? category) {
    String title = 'No updates found';
    String subtitle = 'Check back later for new updates';
    
    if (_searchQuery.isNotEmpty) {
      title = 'No results found';
      subtitle = 'Try adjusting your search terms';
    } else if (category != null) {
      title = 'No ${category.displayName.toLowerCase()} updates';
      subtitle = 'No updates available in this category yet';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateCard(NewsUpdate update) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
      child: InkWell(
        onTap: () => _showUpdateDetails(update),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: update.category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Icon(
                      update.icon,
                      color: update.category.color,
                      size: 20,
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
                                style: AppTheme.bodySmall.copyWith(
                                  color: update.category.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (update.priority != NewsPriority.normal)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: update.priority.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  update.priority.displayName,
                                  style: AppTheme.bodySmall.copyWith(
                                    color: update.priority.color,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(update.publishDate ?? update.createdDate),
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (update.type != NewsType.update)
                    Icon(
                      update.type.icon,
                      color: AppTheme.textSecondary,
                      size: 16,
                    ),
                ],
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              Text(
                update.title,
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.paddingSmall),
              Text(
                update.description,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (update.links.isNotEmpty) ...[
                const SizedBox(height: AppTheme.paddingMedium),
                Row(
                  children: [
                    Icon(
                      Icons.link,
                      size: 16,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${update.links.length} link${update.links.length > 1 ? 's' : ''}',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppTheme.paddingSmall),
              Row(
                children: [
                  if (update.authorName != null) ...[
                    Icon(Icons.person, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      update.authorName!,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (update.viewCount > 0) ...[
                    Icon(Icons.visibility, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${update.viewCount} views',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<NewsUpdate> _filterUpdates(List<NewsUpdate> updates) {
    if (_searchQuery.isEmpty) return updates;
    
    final query = _searchQuery.toLowerCase();
    return updates.where((update) {
      return update.title.toLowerCase().contains(query) ||
             update.description.toLowerCase().contains(query);
    }).toList();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  void _showUpdateDetails(NewsUpdate update) {
    // Increment view count
    if (update.id != null) {
      _newsService.incrementViewCount(update.id!);
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                decoration: BoxDecoration(
                  color: update.category.color.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusMedium),
                    topRight: Radius.circular(AppTheme.radiusMedium),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      update.icon,
                      color: update.category.color,
                      size: 32,
                    ),
                    const SizedBox(width: AppTheme.paddingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            update.category.displayName,
                            style: AppTheme.bodyMedium.copyWith(
                              color: update.category.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            update.title,
                            style: AppTheme.titleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Metadata
                      Row(
                        children: [
                          if (update.priority != NewsPriority.normal) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: update.priority.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                update.priority.displayName,
                                style: AppTheme.bodySmall.copyWith(
                                  color: update.priority.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Icon(
                            update.type.icon,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            update.type.displayName,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatDate(update.publishDate ?? update.createdDate),
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),
                      // Description
                      Text(
                        update.description,
                        style: AppTheme.bodyMedium,
                      ),
                      // Links
                      if (update.links.isNotEmpty) ...[
                        const SizedBox(height: AppTheme.paddingLarge),
                        Text(
                          'Related Links',
                          style: AppTheme.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppTheme.paddingMedium),
                        ...update.links.map((link) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () {
                              // TODO: Launch URL
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Opening: $link')),
                              );
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.link,
                                  size: 16,
                                  color: AppTheme.primaryBlue,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    link,
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.primaryBlue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.open_in_new,
                                  size: 16,
                                  color: AppTheme.primaryBlue,
                                ),
                              ],
                            ),
                          ),
                        )),
                      ],
                      // Author and stats
                      const SizedBox(height: AppTheme.paddingLarge),
                      const Divider(),
                      const SizedBox(height: AppTheme.paddingMedium),
                      Row(
                        children: [
                          if (update.authorName != null) ...[
                            Icon(Icons.person, size: 16, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              'By ${update.authorName}',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          Icon(Icons.visibility, size: 16, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${update.viewCount + 1} views',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
