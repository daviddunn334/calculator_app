import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/news_update.dart';
import '../../services/news_service.dart';
import 'news_editor_screen.dart';
import 'user_management_screen.dart';

class NewsAdminScreen extends StatefulWidget {
  const NewsAdminScreen({super.key});

  @override
  State<NewsAdminScreen> createState() => _NewsAdminScreenState();
}

class _NewsAdminScreenState extends State<NewsAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NewsService _newsService = NewsService();
  
  // Filter states
  NewsCategory? _selectedCategory;
  String _searchQuery = '';
  bool _showDraftsOnly = false;
  bool _showPublishedOnly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('News Admin Panel'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All Posts', icon: Icon(Icons.list)),
            Tab(text: 'Drafts', icon: Icon(Icons.drafts)),
            Tab(text: 'Published', icon: Icon(Icons.public)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserManagementScreen(),
                ),
              );
            },
            icon: const Icon(Icons.people),
            tooltip: 'User Management',
          ),
          IconButton(
            onPressed: _showQuickCreateDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Quick Create',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'create_alert',
                child: Row(
                  children: [
                    Icon(Icons.warning, color: AppTheme.accent3),
                    SizedBox(width: 8),
                    Text('Create Alert'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'create_newsletter',
                child: Row(
                  children: [
                    Icon(Icons.article, color: AppTheme.accent2),
                    SizedBox(width: 8),
                    Text('Create Newsletter'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'bulk_actions',
                child: Row(
                  children: [
                    Icon(Icons.checklist, color: AppTheme.accent4),
                    SizedBox(width: 8),
                    Text('Bulk Actions'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllPostsTab(),
                _buildDraftsTab(),
                _buildPublishedTab(),
                _buildAnalyticsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToEditor(),
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add),
        label: const Text('New Post'),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search posts...',
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
          const SizedBox(height: AppTheme.paddingMedium),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All Categories', _selectedCategory == null, () {
                  setState(() {
                    _selectedCategory = null;
                  });
                }),
                const SizedBox(width: 8),
                ...NewsCategory.values.map((category) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(
                    category.displayName,
                    _selectedCategory == category,
                    () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey[100],
      selectedColor: AppTheme.primaryBlue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textPrimary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildAllPostsTab() {
    return StreamBuilder<List<NewsUpdate>>(
      stream: _newsService.getAllUpdates(category: _selectedCategory),
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
                Text('Error loading posts: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final updates = _filterUpdates(snapshot.data ?? []);

        if (updates.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          itemCount: updates.length,
          itemBuilder: (context, index) {
            return _buildUpdateCard(updates[index]);
          },
        );
      },
    );
  }

  Widget _buildDraftsTab() {
    return StreamBuilder<List<NewsUpdate>>(
      stream: _newsService.getAllUpdates(
        category: _selectedCategory,
        isDraft: true,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final updates = _filterUpdates(snapshot.data ?? []);

        if (updates.isEmpty) {
          return _buildEmptyState(
            icon: Icons.drafts,
            title: 'No drafts found',
            subtitle: 'Create a new post to get started',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          itemCount: updates.length,
          itemBuilder: (context, index) {
            return _buildUpdateCard(updates[index]);
          },
        );
      },
    );
  }

  Widget _buildPublishedTab() {
    return StreamBuilder<List<NewsUpdate>>(
      stream: _newsService.getAllUpdates(
        category: _selectedCategory,
        isPublished: true,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final updates = _filterUpdates(snapshot.data ?? []);

        if (updates.isEmpty) {
          return _buildEmptyState(
            icon: Icons.public,
            title: 'No published posts',
            subtitle: 'Publish some drafts to see them here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          itemCount: updates.length,
          itemBuilder: (context, index) {
            return _buildUpdateCard(updates[index]);
          },
        );
      },
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Content Analytics',
            style: AppTheme.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.paddingLarge),
          FutureBuilder<Map<String, int>>(
            future: _newsService.getCategoryStats(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final stats = snapshot.data ?? {};
              return _buildStatsCards(stats);
            },
          ),
          const SizedBox(height: AppTheme.paddingLarge),
          FutureBuilder<int>(
            future: _newsService.getTotalViewCount(),
            builder: (context, snapshot) {
              final totalViews = snapshot.data ?? 0;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingLarge),
                  child: Row(
                    children: [
                      Icon(Icons.visibility, color: AppTheme.primaryBlue, size: 32),
                      const SizedBox(width: AppTheme.paddingMedium),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Views',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            totalViews.toString(),
                            style: AppTheme.titleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(Map<String, int> stats) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: AppTheme.paddingMedium,
        mainAxisSpacing: AppTheme.paddingMedium,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final entry = stats.entries.elementAt(index);
        final category = NewsCategory.values.firstWhere(
          (c) => c.displayName == entry.key,
          orElse: () => NewsCategory.company,
        );
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder,
                  color: category.color,
                  size: 32,
                ),
                const SizedBox(height: AppTheme.paddingSmall),
                Text(
                  entry.key,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  entry.value.toString(),
                  style: AppTheme.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: category.color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    IconData icon = Icons.article,
    String title = 'No posts found',
    String subtitle = 'Create your first post to get started',
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
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
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToEditor(),
            icon: const Icon(Icons.add),
            label: const Text('Create Post'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateCard(NewsUpdate update) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
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
                      Text(
                        update.title,
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildStatusChip(update),
                          const SizedBox(width: 8),
                          _buildCategoryChip(update.category),
                          const SizedBox(width: 8),
                          _buildPriorityChip(update.priority),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleUpdateAction(value, update),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    if (update.isDraft)
                      const PopupMenuItem(
                        value: 'publish',
                        child: Row(
                          children: [
                            Icon(Icons.publish, size: 16),
                            SizedBox(width: 8),
                            Text('Publish'),
                          ],
                        ),
                      ),
                    if (update.isPublished)
                      const PopupMenuItem(
                        value: 'unpublish',
                        child: Row(
                          children: [
                            Icon(Icons.unpublished, size: 16),
                            SizedBox(width: 8),
                            Text('Unpublish'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Row(
                        children: [
                          Icon(Icons.copy, size: 16),
                          SizedBox(width: 8),
                          Text('Duplicate'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            Text(
              update.description,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  update.authorName ?? 'Unknown',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  _formatDate(update.lastModified),
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                if (update.viewCount > 0) ...[
                  Icon(Icons.visibility, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    update.viewCount.toString(),
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
    );
  }

  Widget _buildStatusChip(NewsUpdate update) {
    String label;
    Color color;
    
    if (update.isDraft) {
      label = 'Draft';
      color = Colors.orange;
    } else if (update.isScheduled) {
      label = 'Scheduled';
      color = Colors.blue;
    } else if (update.isExpired) {
      label = 'Expired';
      color = Colors.red;
    } else if (update.isPublished) {
      label = 'Published';
      color = Colors.green;
    } else {
      label = 'Unknown';
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTheme.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(NewsCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category.displayName,
        style: AppTheme.bodySmall.copyWith(
          color: category.color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(NewsPriority priority) {
    if (priority == NewsPriority.normal) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: priority.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority.displayName,
        style: AppTheme.bodySmall.copyWith(
          color: priority.color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<NewsUpdate> _filterUpdates(List<NewsUpdate> updates) {
    return updates.where((update) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!update.title.toLowerCase().contains(query) &&
            !update.description.toLowerCase().contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }

  void _navigateToEditor([NewsUpdate? update]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsEditorScreen(update: update),
      ),
    );
  }

  void _showQuickCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Create'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.warning, color: Colors.orange),
              title: const Text('Quick Alert'),
              subtitle: const Text('Create a simple alert message'),
              onTap: () {
                Navigator.pop(context);
                _handleMenuAction('create_alert');
              },
            ),
            ListTile(
              leading: const Icon(Icons.article, color: Colors.blue),
              title: const Text('Newsletter'),
              subtitle: const Text('Create a detailed newsletter'),
              onTap: () {
                Navigator.pop(context);
                _handleMenuAction('create_newsletter');
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.green),
              title: const Text('Custom Post'),
              subtitle: const Text('Create with full editor'),
              onTap: () {
                Navigator.pop(context);
                _navigateToEditor();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'create_alert':
        _navigateToEditor(_createAlertTemplate());
        break;
      case 'create_newsletter':
        _navigateToEditor(_createNewsletterTemplate());
        break;
      case 'bulk_actions':
        _showBulkActionsDialog();
        break;
    }
  }

  void _handleUpdateAction(String action, NewsUpdate update) async {
    switch (action) {
      case 'edit':
        _navigateToEditor(update);
        break;
      case 'publish':
        await _newsService.publishUpdate(update.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post published successfully')),
        );
        break;
      case 'unpublish':
        await _newsService.unpublishUpdate(update.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post unpublished successfully')),
        );
        break;
      case 'duplicate':
        final duplicated = update.copyWith(
          id: null,
          title: '${update.title} (Copy)',
          isDraft: true,
          isPublished: false,
          createdDate: DateTime.now(),
          lastModified: DateTime.now(),
        );
        await _newsService.createUpdate(duplicated);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post duplicated successfully')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(update);
        break;
    }
  }

  void _showDeleteConfirmation(NewsUpdate update) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: Text('Are you sure you want to delete "${update.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _newsService.deleteUpdate(update.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post deleted successfully')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showBulkActionsDialog() {
    // TODO: Implement bulk actions dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bulk actions coming soon!')),
    );
  }

  NewsUpdate _createAlertTemplate() {
    return NewsUpdate(
      title: 'New Alert',
      description: 'Enter your alert message here...',
      createdDate: DateTime.now(),
      category: NewsCategory.training,
      priority: NewsPriority.high,
      type: NewsType.alert,
      icon: Icons.warning,
      iconName: 'warning',
      authorId: 'current_user',
      lastModified: DateTime.now(),
    );
  }

  NewsUpdate _createNewsletterTemplate() {
    return NewsUpdate(
      title: 'Monthly Newsletter - ${DateTime.now().month}/${DateTime.now().year}',
      description: 'This month\'s updates and important information...',
      createdDate: DateTime.now(),
      category: NewsCategory.company,
      priority: NewsPriority.normal,
      type: NewsType.newsletter,
      icon: Icons.article,
      iconName: 'article',
      authorId: 'current_user',
      lastModified: DateTime.now(),
    );
  }
}
