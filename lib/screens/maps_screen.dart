import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/offline_service.dart';
import '../services/job_locations_service.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../models/division.dart';
import '../models/project.dart';
import '../models/dig.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> with SingleTickerProviderStateMixin {
  final OfflineService _offlineService = OfflineService();
  final JobLocationsService _locationsService = JobLocationsService();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  
  bool _isOnline = true;
  bool _isAdmin = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Navigation state
  Division? _selectedDivision;
  Project? _selectedProject;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _animationController.forward();
    
    // Listen to connectivity changes
    _isOnline = _offlineService.isOnline;
    _offlineService.onConnectivityChanged.listen((online) {
      if (mounted) {
        setState(() {
          _isOnline = online;
        });
      }
    });

    // Check admin status
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = await _userService.isCurrentUserAdmin();
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToDivision(Division division) {
    setState(() {
      _selectedDivision = division;
      _selectedProject = null;
    });
  }

  void _navigateToProject(Project project) {
    setState(() {
      _selectedProject = project;
    });
  }

  String _getAddButtonText() {
    if (_selectedProject != null) {
      return 'Add Dig';
    } else if (_selectedDivision != null) {
      return 'Add Project';
    } else {
      return 'Add Division';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOnline) {
      return _buildOfflineView();
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildHeader(),
            _buildBreadcrumbs(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineView() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(AppTheme.paddingLarge),
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                'No Internet Connection',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Job locations require internet connection to view and manage.',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accent2,
            AppTheme.accent2.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent2.withOpacity(0.3),
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
                Icons.location_on,
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
                    'Job Locations',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage divisions, projects, and dig locations',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            if (_isAdmin) ...[
              ElevatedButton.icon(
                onPressed: _showAddDialog,
                icon: const Icon(Icons.add, size: 18),
                label: Text(_getAddButtonText()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.accent2,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    List<Widget> breadcrumbs = [
      TextButton.icon(
        onPressed: () => setState(() {
          _selectedDivision = null;
          _selectedProject = null;
        }),
        icon: const Icon(Icons.home, size: 16),
        label: const Text('Divisions'),
        style: TextButton.styleFrom(
          foregroundColor: _selectedDivision == null ? AppTheme.primaryBlue : AppTheme.textSecondary,
        ),
      ),
    ];

    if (_selectedDivision != null) {
      breadcrumbs.addAll([
        const Icon(Icons.chevron_right, size: 16, color: AppTheme.textSecondary),
        TextButton(
          onPressed: () => setState(() {
            _selectedProject = null;
          }),
          child: Text(_selectedDivision!.name),
          style: TextButton.styleFrom(
            foregroundColor: _selectedProject == null ? AppTheme.primaryBlue : AppTheme.textSecondary,
          ),
        ),
      ]);
    }

    if (_selectedProject != null) {
      breadcrumbs.addAll([
        const Icon(Icons.chevron_right, size: 16, color: AppTheme.textSecondary),
        Text(
          _selectedProject!.name,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ]);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge, vertical: AppTheme.paddingSmall),
      child: Row(
        children: breadcrumbs,
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedProject != null && _selectedDivision != null) {
      return _buildDigsList(_selectedDivision!.id!, _selectedProject!.id!);
    } else if (_selectedDivision != null) {
      return _buildProjectsList(_selectedDivision!.id!);
    } else {
      return _buildDivisionsList();
    }
  }

  Widget _buildDivisionsList() {
    return StreamBuilder<List<Division>>(
      stream: _locationsService.getAllDivisions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorState('Error loading divisions');
        }

        final divisions = snapshot.data ?? [];

        if (divisions.isEmpty) {
          return _buildEmptyState(
            'No Divisions Yet',
            'Create your first division to organize job locations',
            Icons.location_city,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          itemCount: divisions.length,
          itemBuilder: (context, index) {
            final division = divisions[index];
            return _buildDivisionCard(division);
          },
        );
      },
    );
  }

  Widget _buildProjectsList(String divisionId) {
    return StreamBuilder<List<Project>>(
      stream: _locationsService.getProjectsByDivision(divisionId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorState('Error loading projects');
        }

        final projects = snapshot.data ?? [];

        if (projects.isEmpty) {
          return _buildEmptyState(
            'No Projects Yet',
            'Add projects to organize dig locations within this division',
            Icons.folder,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return _buildProjectCard(project);
          },
        );
      },
    );
  }

  Widget _buildDigsList(String divisionId, String projectId) {
    return StreamBuilder<List<Dig>>(
      stream: _locationsService.getDigsByProject(divisionId, projectId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorState('Error loading digs');
        }

        final digs = snapshot.data ?? [];

        if (digs.isEmpty) {
          return _buildEmptyState(
            'No Digs Yet',
            'Add dig locations with coordinates to this project',
            Icons.room,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          itemCount: digs.length,
          itemBuilder: (context, index) {
            final dig = digs[index];
            return _buildDigCard(dig);
          },
        );
      },
    );
  }

  Widget _buildDivisionCard(Division division) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        elevation: 0,
        child: InkWell(
          onTap: () => _navigateToDivision(division),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.divider, width: 1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.location_city,
                    color: AppTheme.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        division.name,
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (division.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          division.description!,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.chevron_right,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    if (_isAdmin) ...[
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        onSelected: (value) => _handleDivisionAction(value, division),
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
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.more_vert,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(Project project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        elevation: 0,
        child: InkWell(
          onTap: () => _navigateToProject(project),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.divider, width: 1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accent1.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.folder,
                    color: AppTheme.accent1,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (project.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          project.description!,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.chevron_right,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    if (_isAdmin) ...[
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        onSelected: (value) => _handleProjectAction(value, project),
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
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.more_vert,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDigCard(Dig dig) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.divider, width: 1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accent3.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.room,
                    color: AppTheme.accent3,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dig #${dig.digNumber}',
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'RGW #${dig.rgwNumber}',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isAdmin) ...[
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleDigAction(value, dig),
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
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.more_vert,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.my_location,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Coordinates: ${dig.coordinates}',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textPrimary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  if (dig.notes != null && dig.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.note,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dig.notes!,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: dig.hasValidCoordinates ? () => _openInMaps(dig) : null,
                icon: const Icon(Icons.map, size: 18),
                label: const Text('Open in Maps'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppTheme.paddingLarge),
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
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

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppTheme.paddingLarge),
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (_isAdmin) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _showAddDialog,
                icon: const Icon(Icons.add, size: 18),
                label: Text(_getAddButtonText()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddDialog() {
    if (_selectedProject != null && _selectedDivision != null) {
      _showAddDigDialog();
    } else if (_selectedDivision != null) {
      _showAddProjectDialog();
    } else {
      _showAddDivisionDialog();
    }
  }

  void _showAddDivisionDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Division'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Division Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a division name')),
                );
                return;
              }

              try {
                final division = Division(
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim().isNotEmpty 
                      ? descriptionController.text.trim() 
                      : null,
                  createdBy: _authService.userId ?? 'unknown',
                );

                await _locationsService.createDivision(division);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Division created successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error creating division: $e')),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddProjectDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a project name')),
                );
                return;
              }

              try {
                final project = Project(
                  divisionId: _selectedDivision!.id!,
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim().isNotEmpty 
                      ? descriptionController.text.trim() 
                      : null,
                  createdBy: _authService.userId ?? 'unknown',
                );

                await _locationsService.createProject(project);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Project created successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error creating project: $e')),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddDigDialog() {
    final digNumberController = TextEditingController();
    final rgwNumberController = TextEditingController();
    final coordinatesController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Dig Location'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: digNumberController,
                decoration: const InputDecoration(
                  labelText: 'Dig Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: rgwNumberController,
                decoration: const InputDecoration(
                  labelText: 'RGW Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: coordinatesController,
                decoration: const InputDecoration(
                  labelText: 'Coordinates (lat, lng)',
                  hintText: 'e.g., 31.12345, -88.54321',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (digNumberController.text.trim().isEmpty ||
                  rgwNumberController.text.trim().isEmpty ||
                  coordinatesController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all required fields')),
                );
                return;
              }

              if (!_locationsService.isValidCoordinateFormat(coordinatesController.text.trim())) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid coordinate format. Use: lat, lng')),
                );
                return;
              }

              try {
                final dig = Dig(
                  divisionId: _selectedDivision!.id!,
                  projectId: _selectedProject!.id!,
                  digNumber: digNumberController.text.trim(),
                  rgwNumber: rgwNumberController.text.trim(),
                  coordinates: coordinatesController.text.trim(),
                  notes: notesController.text.trim().isNotEmpty 
                      ? notesController.text.trim() 
                      : null,
                  createdBy: _authService.userId ?? 'unknown',
                );

                await _locationsService.createDig(dig);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dig location created successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error creating dig location: $e')),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _handleDivisionAction(String action, Division division) {
    switch (action) {
      case 'edit':
        _showEditDivisionDialog(division);
        break;
      case 'delete':
        _showDeleteConfirmation(
          'Delete Division',
          'Are you sure you want to delete "${division.name}" and all its projects and digs?',
          () => _locationsService.deleteDivision(division.id!),
        );
        break;
    }
  }

  void _handleProjectAction(String action, Project project) {
    switch (action) {
      case 'edit':
        _showEditProjectDialog(project);
        break;
      case 'delete':
        _showDeleteConfirmation(
          'Delete Project',
          'Are you sure you want to delete "${project.name}" and all its digs?',
          () => _locationsService.deleteProject(project.id!),
        );
        break;
    }
  }

  void _handleDigAction(String action, Dig dig) {
    switch (action) {
      case 'edit':
        _showEditDigDialog(dig);
        break;
      case 'delete':
        _showDeleteConfirmation(
          'Delete Dig',
          'Are you sure you want to delete "Dig #${dig.digNumber}"?',
          () => _locationsService.deleteDig(dig.divisionId, dig.projectId, dig.id!),
        );
        break;
    }
  }

  void _showEditDivisionDialog(Division division) {
    final nameController = TextEditingController(text: division.name);
    final descriptionController = TextEditingController(text: division.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Division'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Division Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a division name')),
                );
                return;
              }

              try {
                final updatedDivision = division.copyWith(
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim().isNotEmpty 
                      ? descriptionController.text.trim() 
                      : null,
                );

                await _locationsService.updateDivision(updatedDivision);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Division updated successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating division: $e')),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showEditProjectDialog(Project project) {
    final nameController = TextEditingController(text: project.name);
    final descriptionController = TextEditingController(text: project.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a project name')),
                );
                return;
              }

              try {
                final updatedProject = project.copyWith(
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim().isNotEmpty 
                      ? descriptionController.text.trim() 
                      : null,
                );

                await _locationsService.updateProject(updatedProject);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Project updated successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating project: $e')),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showEditDigDialog(Dig dig) {
    final digNumberController = TextEditingController(text: dig.digNumber);
    final rgwNumberController = TextEditingController(text: dig.rgwNumber);
    final coordinatesController = TextEditingController(text: dig.coordinates);
    final notesController = TextEditingController(text: dig.notes);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Dig Location'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: digNumberController,
                decoration: const InputDecoration(
                  labelText: 'Dig Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: rgwNumberController,
                decoration: const InputDecoration(
                  labelText: 'RGW Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: coordinatesController,
                decoration: const InputDecoration(
                  labelText: 'Coordinates (lat, lng)',
                  hintText: 'e.g., 31.12345, -88.54321',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (digNumberController.text.trim().isEmpty ||
                  rgwNumberController.text.trim().isEmpty ||
                  coordinatesController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all required fields')),
                );
                return;
              }

              if (!_locationsService.isValidCoordinateFormat(coordinatesController.text.trim())) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid coordinate format. Use: lat, lng')),
                );
                return;
              }

              try {
                final updatedDig = dig.copyWith(
                  digNumber: digNumberController.text.trim(),
                  rgwNumber: rgwNumberController.text.trim(),
                  coordinates: coordinatesController.text.trim(),
                  notes: notesController.text.trim().isNotEmpty 
                      ? notesController.text.trim() 
                      : null,
                );

                await _locationsService.updateDig(updatedDig);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dig location updated successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating dig location: $e')),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String title, String message, Function() onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await onConfirm();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting: $e')),
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

  void _openInMaps(Dig dig) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open in Maps'),
        content: const Text('Choose which maps app to use:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _launchUrl(dig.googleMapsUrl);
            },
            child: const Text('Google Maps'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _launchUrl(dig.appleMapsUrl);
            },
            child: const Text('Apple Maps'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid coordinates')),
      );
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open maps app')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening maps: $e')),
        );
      }
    }
  }
}
