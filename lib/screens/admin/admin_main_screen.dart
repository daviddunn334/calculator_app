import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_drawer.dart';
import 'user_management_screen.dart';
import 'news_editor_screen.dart';
import '../../models/news_update.dart';
import '../../services/news_service.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;
  final NewsService _newsService = NewsService();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop layout (width >= 1200px)
        if (constraints.maxWidth >= 1200) {
          return Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: 280,
                  child: AdminDrawer(
                    selectedIndex: _selectedIndex,
                    onItemSelected: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: _buildBody(),
                ),
              ],
            ),
          );
        }
        
        // Mobile layout
        return Scaffold(
          body: _buildBody(),
          drawer: AdminDrawer(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildNewsManagement();
      case 2:
        return _buildUserManagement();
      case 3:
        return _buildAnalytics();
      case 4:
        return _buildCreatePost();
      case 5:
        return _buildDrafts();
      case 6:
        return _buildPublished();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: MediaQuery.of(context).size.width < 1200,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Admin Dashboard',
              style: AppTheme.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            Text(
              'Manage your content, users, and analytics from here.',
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.paddingLarge),
            
            // Quick Stats Cards
            FutureBuilder<Map<String, int>>(
              future: _getQuickStats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final stats = snapshot.data ?? {};
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: AppTheme.paddingMedium,
                  mainAxisSpacing: AppTheme.paddingMedium,
                  children: [
                    _buildStatCard(
                      'Total Posts',
                      stats['totalPosts']?.toString() ?? '0',
                      Icons.article,
                      AppTheme.primaryBlue,
                    ),
                    _buildStatCard(
                      'Published',
                      stats['publishedPosts']?.toString() ?? '0',
                      Icons.public,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Drafts',
                      stats['draftPosts']?.toString() ?? '0',
                      Icons.drafts,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Total Views',
                      stats['totalViews']?.toString() ?? '0',
                      Icons.visibility,
                      AppTheme.accent2,
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: AppTheme.paddingLarge),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            
            Wrap(
              spacing: AppTheme.paddingMedium,
              runSpacing: AppTheme.paddingMedium,
              children: [
                _buildQuickActionCard(
                  'Create New Post',
                  Icons.add_circle,
                  AppTheme.primaryBlue,
                  () {
                    setState(() {
                      _selectedIndex = 4;
                    });
                  },
                ),
                _buildQuickActionCard(
                  'Manage Users',
                  Icons.people,
                  AppTheme.accent3,
                  () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                ),
                _buildQuickActionCard(
                  'View Analytics',
                  Icons.analytics,
                  AppTheme.accent4,
                  () {
                    setState(() {
                      _selectedIndex = 3;
                    });
                  },
                ),
                _buildQuickActionCard(
                  'News Management',
                  Icons.newspaper,
                  AppTheme.accent2,
                  () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppTheme.paddingSmall),
            Text(
              value,
              style: AppTheme.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: 200,
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: AppTheme.paddingMedium),
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewsManagement() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('News Management'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: MediaQuery.of(context).size.width < 1200,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedIndex = 4; // Navigate to Create Post
              });
            },
            icon: const Icon(Icons.add),
            tooltip: 'Create Post',
          ),
        ],
      ),
      body: StreamBuilder<List<NewsUpdate>>(
        stream: _newsService.getAllUpdates(),
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

          final updates = snapshot.data ?? [];

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
      ),
    );
  }

  Widget _buildUserManagement() {
    return const UserManagementScreen();
  }

  Widget _buildAnalytics() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: MediaQuery.of(context).size.width < 1200,
      ),
      body: SingleChildScrollView(
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
      ),
    );
  }

  Widget _buildCreatePost() {
    return const NewsEditorScreen();
  }

  Widget _buildDrafts() {
    return _buildFilteredPosts('Drafts', isDraft: true);
  }

  Widget _buildPublished() {
    return _buildFilteredPosts('Published', isPublished: true);
  }

  Widget _buildFilteredPosts(String title, {bool? isDraft, bool? isPublished}) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: MediaQuery.of(context).size.width < 1200,
      ),
      body: StreamBuilder<List<NewsUpdate>>(
        stream: _newsService.getAllUpdates(isDraft: isDraft, isPublished: isPublished),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final updates = snapshot.data ?? [];

          if (updates.isEmpty) {
            return _buildEmptyState(
              title: 'No $title found',
              subtitle: isDraft == true 
                  ? 'Create a new post to get started'
                  : 'Publish some drafts to see them here',
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
    String title = 'No posts found',
    String subtitle = 'Create your first post to get started',
  }) {
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
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedIndex = 4; // Navigate to Create Post
              });
            },
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

  Future<Map<String, int>> _getQuickStats() async {
    try {
      final allUpdates = await _newsService.getAllUpdates().first;
      final publishedCount = allUpdates.where((u) => u.isPublished).length;
      final draftCount = allUpdates.where((u) => u.isDraft).length;
      final totalViews = await _newsService.getTotalViewCount();
      
      return {
        'totalPosts': allUpdates.length,
        'publishedPosts': publishedCount,
        'draftPosts': draftCount,
        'totalViews': totalViews,
      };
    } catch (e) {
      return {
        'totalPosts': 0,
        'publishedPosts': 0,
        'draftPosts': 0,
        'totalViews': 0,
      };
    }
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

  void _handleUpdateAction(String action, NewsUpdate update) async {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsEditorScreen(update: update),
          ),
        );
        break;
      case 'publish':
        await _newsService.publishUpdate(update.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post published successfully')),
          );
        }
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
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post deleted successfully')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
