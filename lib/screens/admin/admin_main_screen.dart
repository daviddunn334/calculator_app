import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_drawer.dart';
import 'user_management_screen.dart';
import 'news_editor_screen.dart';
import 'feedback_management_screen.dart';
import 'pdf_management_screen.dart';
import 'employee_management_screen.dart';
import 'analytics_screen.dart';
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
      case 7:
        return _buildFeedbackManagement();
      case 8:
        return _buildPdfManagement();
      case 9:
        return _buildEmployeeManagement();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Modern Header
          _buildModernDashboardHeader(),

          // Dashboard Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  _buildWelcomeSection(),
                  const SizedBox(height: 32),

                  // Stats Overview
                  _buildStatsOverview(),
                  const SizedBox(height: 32),

                  // Quick Actions
                  _buildQuickActionsSection(),
                  const SizedBox(height: 32),

                  // Recent Activity
                  _buildRecentActivitySection(),
                  const SizedBox(height: 32),

                  // System Overview
                  _buildSystemOverview(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDashboardHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            AppTheme.primaryBlue.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.dashboard,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Admin Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your system and monitor performance',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            if (MediaQuery.of(context).size.width < 1200)
              Builder(
                builder: (context) => IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          _buildSectionHeader('Welcome Back!', Icons.waving_hand),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good ${_getGreeting()}!',
                      style: AppTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Here\'s what\'s happening with your system today. You have new reports to review and content to manage.',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.notifications_active,
                  color: AppTheme.primaryBlue,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryBlue,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          _buildSectionHeader('System Overview', Icons.analytics),
          const SizedBox(height: 20),
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
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard(
                    'Total Reports',
                    stats['totalReports']?.toString() ?? '147',
                    Icons.assessment,
                    AppTheme.primaryBlue,
                  ),
                  _buildStatCard(
                    'Published Posts',
                    stats['publishedPosts']?.toString() ?? '23',
                    Icons.public,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'Active Users',
                    stats['activeUsers']?.toString() ?? '89',
                    Icons.people,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    'Total Views',
                    stats['totalViews']?.toString() ?? '2.4K',
                    Icons.visibility,
                    Colors.purple,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          _buildSectionHeader('Quick Actions', Icons.flash_on),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 800 ? 2 : 1,
            childAspectRatio: 3.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildQuickActionCard(
                'Create New Post',
                Icons.add_circle,
                AppTheme.primaryBlue,
                () => setState(() => _selectedIndex = 4),
              ),
              _buildQuickActionCard(
                'Manage Users',
                Icons.people,
                Colors.green,
                () => setState(() => _selectedIndex = 2),
              ),
              _buildQuickActionCard(
                'View Reports',
                Icons.assessment,
                Colors.orange,
                () => setState(() => _selectedIndex = 7),
              ),
              _buildQuickActionCard(
                'System Analytics',
                Icons.analytics,
                Colors.purple,
                () => setState(() => _selectedIndex = 3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildRecentActivitySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          _buildSectionHeader('Recent Activity', Icons.schedule),
          const SizedBox(height: 20),

          // Sample activity items
          _buildActivityItem(
            'New report submitted',
            'Pipeline inspection report #147',
            Icons.assessment,
            AppTheme.primaryBlue,
            '2 hours ago',
          ),
          _buildActivityItem(
            'User registered',
            'John Doe joined the system',
            Icons.person_add,
            Colors.green,
            '4 hours ago',
          ),
          _buildActivityItem(
            'Post published',
            'Safety update for equipment procedures',
            Icons.public,
            Colors.orange,
            '1 day ago',
          ),
          _buildActivityItem(
            'System backup completed',
            'Daily backup successful',
            Icons.backup,
            Colors.purple,
            '1 day ago',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
      String title, String subtitle, IconData icon, Color color, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          _buildSectionHeader('System Health', Icons.health_and_safety),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildHealthItem(
                  'Server Status',
                  'Online',
                  Icons.dns,
                  Colors.green,
                  0.95,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildHealthItem(
                  'Database',
                  'Healthy',
                  Icons.storage,
                  Colors.blue,
                  0.88,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildHealthItem(
                  'Storage Usage',
                  '65% Used',
                  Icons.pie_chart,
                  Colors.orange,
                  0.65,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildHealthItem(
                  'Response Time',
                  '< 200ms',
                  Icons.speed,
                  Colors.purple,
                  0.92,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthItem(
      String title, String value, IconData icon, Color color, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _buildNewsManagement() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Modern Header
          _buildNewsManagementHeader(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics Overview
                  _buildNewsStatisticsSection(),
                  const SizedBox(height: 32),

                  // Search and Filters
                  _buildNewsSearchAndFilters(),
                  const SizedBox(height: 32),

                  // News List
                  _buildNewsListSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserManagement() {
    return const UserManagementScreen();
  }

  Widget _buildFeedbackManagement() {
    return const FeedbackManagementScreen();
  }

  Widget _buildPdfManagement() {
    return const PdfManagementScreen();
  }

  Widget _buildEmployeeManagement() {
    return const EmployeeManagementScreen();
  }

  Widget _buildAnalytics() {
    return const AnalyticsScreen();
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
      body: const Center(
        child: Text('Filtered Posts - Coming Soon'),
      ),
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
      child: ListTile(
        title: Text(update.title),
        subtitle: Text(update.description),
        trailing: const Icon(Icons.more_vert),
      ),
    );
  }

  Widget _buildNewsManagementHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue,
            Colors.blue.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.article,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'News Management',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create, edit, and manage news posts and updates',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => setState(() => _selectedIndex = 4),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create Post'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
            if (MediaQuery.of(context).size.width < 1200)
              Builder(
                builder: (context) => IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsStatisticsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          _buildSectionHeader('Content Overview', Icons.analytics),
          const SizedBox(height: 20),
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
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard(
                    'Total Posts',
                    '${stats['totalPosts'] ?? 0}',
                    Icons.article,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'Published',
                    '${stats['publishedPosts'] ?? 0}',
                    Icons.public,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'Drafts',
                    '${stats['draftPosts'] ?? 0}',
                    Icons.drafts,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    'Total Views',
                    '${stats['totalViews'] ?? 0}',
                    Icons.visibility,
                    Colors.purple,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNewsSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          _buildSectionHeader('Search & Filters', Icons.search),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search posts...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppTheme.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsListSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          _buildSectionHeader('Recent Posts', Icons.list),
          const SizedBox(height: 20),
          StreamBuilder<List<NewsUpdate>>(
            stream: _newsService.getAllUpdates(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading posts',
                          style: AppTheme.titleMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please try again later',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final updates = snapshot.data ?? [];

              if (updates.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: updates.length,
                itemBuilder: (context, index) {
                  return _buildNewsCard(updates[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(NewsUpdate update) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: update.category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  update.icon,
                  color: update.category.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
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
                        Text(
                          update.category.displayName,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleNewsAction(value, update),
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
          const SizedBox(height: 12),
          Text(
            update.description,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.visibility,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${update.viewCount} views',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.schedule,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(update.createdDate),
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(NewsUpdate update) {
    Color color;
    String label;

    if (update.isDraft) {
      color = Colors.orange;
      label = 'Draft';
    } else if (update.isPublished) {
      color = Colors.green;
      label = 'Published';
    } else {
      color = Colors.grey;
      label = 'Scheduled';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTheme.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _handleNewsAction(String action, NewsUpdate update) {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsEditorScreen(update: update),
          ),
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
              try {
                await _newsService.deleteUpdate(update.id!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting post: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
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
        'totalReports': 147,
        'activeUsers': 89,
      };
    } catch (e) {
      return {
        'totalPosts': 0,
        'publishedPosts': 0,
        'draftPosts': 0,
        'totalViews': 0,
        'totalReports': 147,
        'activeUsers': 89,
      };
    }
  }
}
