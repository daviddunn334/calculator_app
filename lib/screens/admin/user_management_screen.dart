import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/user_profile.dart';
import '../../services/user_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: StreamBuilder<List<UserProfile>>(
              stream: _userService.getAllUsersStream(),
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
                        Text('Error loading users: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final allUsers = snapshot.data ?? [];
                final filteredUsers = _filterUsers(allUsers);

                if (filteredUsers.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    return _buildUserCard(filteredUsers[index]);
                  },
                );
              },
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
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search users by email or name...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? 'No users found' : 'No users registered',
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search terms'
                : 'Users will appear here once they sign up',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserProfile user) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: user.isAdmin 
                      ? AppTheme.primaryBlue.withOpacity(0.1)
                      : AppTheme.textSecondary.withOpacity(0.1),
                  child: Icon(
                    user.isAdmin ? Icons.admin_panel_settings : Icons.person,
                    color: user.isAdmin ? AppTheme.primaryBlue : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: AppTheme.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.displayName ?? user.email,
                              style: AppTheme.titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (user.isAdmin)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'ADMIN',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (user.displayName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Joined ${_formatDate(user.createdAt)}',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                if (user.updatedAt != null) ...[
                  Icon(
                    Icons.update,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Updated ${_formatDate(user.updatedAt!)}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            const Divider(),
            const SizedBox(height: AppTheme.paddingSmall),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showUserDetails(user),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryBlue,
                      side: BorderSide(color: AppTheme.primaryBlue),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.paddingSmall),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleAdminStatus(user),
                    icon: Icon(
                      user.isAdmin ? Icons.remove_moderator : Icons.security,
                      size: 16,
                    ),
                    label: Text(user.isAdmin ? 'Remove Admin' : 'Make Admin'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: user.isAdmin ? Colors.orange : AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<UserProfile> _filterUsers(List<UserProfile> users) {
    if (_searchQuery.isEmpty) return users;
    
    final query = _searchQuery.toLowerCase();
    return users.where((user) {
      return user.email.toLowerCase().contains(query) ||
             (user.displayName?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  void _showUserDetails(UserProfile user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                decoration: BoxDecoration(
                  color: user.isAdmin 
                      ? AppTheme.primaryBlue.withOpacity(0.1)
                      : AppTheme.textSecondary.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusMedium),
                    topRight: Radius.circular(AppTheme.radiusMedium),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: user.isAdmin 
                          ? AppTheme.primaryBlue.withOpacity(0.2)
                          : AppTheme.textSecondary.withOpacity(0.2),
                      child: Icon(
                        user.isAdmin ? Icons.admin_panel_settings : Icons.person,
                        color: user.isAdmin ? AppTheme.primaryBlue : AppTheme.textSecondary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: AppTheme.paddingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName ?? 'No display name',
                            style: AppTheme.titleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user.email,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
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
                      _buildDetailRow('User ID', user.userId),
                      _buildDetailRow('Email', user.email),
                      _buildDetailRow('Display Name', user.displayName ?? 'Not set'),
                      _buildDetailRow('Role', user.isAdmin ? 'Administrator' : 'Regular User'),
                      _buildDetailRow('Account Created', _formatFullDate(user.createdAt)),
                      if (user.updatedAt != null)
                        _buildDetailRow('Last Updated', _formatFullDate(user.updatedAt!)),
                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        const SizedBox(height: AppTheme.paddingMedium),
                        Text(
                          'Bio',
                          style: AppTheme.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppTheme.paddingSmall),
                        Text(
                          user.bio!,
                          style: AppTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Actions
              Container(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: AppTheme.paddingMedium),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _toggleAdminStatus(user);
                        },
                        icon: Icon(
                          user.isAdmin ? Icons.remove_moderator : Icons.security,
                          size: 16,
                        ),
                        label: Text(user.isAdmin ? 'Remove Admin' : 'Make Admin'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: user.isAdmin ? Colors.orange : AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _toggleAdminStatus(UserProfile user) {
    final newStatus = !user.isAdmin;
    final action = newStatus ? 'grant admin access to' : 'remove admin access from';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${newStatus ? 'Grant' : 'Remove'} Admin Access'),
        content: Text(
          'Are you sure you want to $action ${user.displayName ?? user.email}?\n\n'
          '${newStatus 
              ? 'This user will be able to manage news updates and other users.' 
              : 'This user will lose admin privileges and only have regular user access.'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performAdminToggle(user, newStatus);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus ? AppTheme.primaryBlue : Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(newStatus ? 'Grant Access' : 'Remove Access'),
          ),
        ],
      ),
    );
  }

  Future<void> _performAdminToggle(UserProfile user, bool newStatus) async {
    try {
      await _userService.toggleUserAdminStatus(user.userId, newStatus);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${user.displayName ?? user.email} ${newStatus ? 'granted' : 'removed'} admin access',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
