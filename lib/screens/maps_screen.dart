import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/offline_service.dart';
import '../services/job_locations_service.dart';
import '../services/personal_locations_service.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../models/division.dart';
import '../models/project.dart';
import '../models/dig.dart';
import '../models/personal_folder.dart';
import '../models/personal_location.dart';
import '../utils/location_colors.dart';
import '../widgets/color_picker_widget.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> with SingleTickerProviderStateMixin {
  final OfflineService _offlineService = OfflineService();
  final JobLocationsService _locationsService = JobLocationsService();
  final PersonalLocationsService _personalLocationsService = PersonalLocationsService();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  
  bool _isOnline = true;
  bool _isAdmin = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Navigation state
  Division? _selectedDivision;
  Project? _selectedProject;
  PersonalFolder? _selectedPersonalFolder;
  bool _showingPersonalLocations = false;
  
  // Pin state management
  Set<String> _pinnedDivisions = {};
  Set<String> _pinnedProjects = {};
  Set<String> _pinnedDigs = {};
  Set<String> _pinnedPersonalFolders = {};
  Set<String> _pinnedPersonalLocations = {};
  static const int maxPinnedItems = 3;


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

  void _navigateToPersonalFolder(PersonalFolder folder) {
    setState(() {
      _selectedPersonalFolder = folder;
    });
  }

  void _showPersonalLocations() {
    setState(() {
      _showingPersonalLocations = true;
      _selectedDivision = null;
      _selectedProject = null;
      _selectedPersonalFolder = null;
    });
  }

  void _showCompanyLocations() {
    setState(() {
      _showingPersonalLocations = false;
      _selectedPersonalFolder = null;
    });
  }

  String _getAddButtonText() {
    if (_showingPersonalLocations) {
      if (_selectedPersonalFolder != null) {
        return 'Add Location';
      } else {
        return 'Add Folder';
      }
    } else {
      if (_selectedProject != null) {
        return 'Add Location';
      } else if (_selectedDivision != null) {
        return 'Add Project';
      } else {
        return 'Add Division';
      }
    }
  }

  // Pin functionality methods
  void _togglePinDivision(String divisionId) {
    setState(() {
      if (_pinnedDivisions.contains(divisionId)) {
        _pinnedDivisions.remove(divisionId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Division unpinned')),
        );
      } else {
        if (_pinnedDivisions.length >= maxPinnedItems) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Maximum $maxPinnedItems items can be pinned')),
          );
          return;
        }
        _pinnedDivisions.add(divisionId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Division pinned to top')),
        );
      }
    });
  }

  void _togglePinProject(String projectId) {
    setState(() {
      if (_pinnedProjects.contains(projectId)) {
        _pinnedProjects.remove(projectId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project unpinned')),
        );
      } else {
        if (_pinnedProjects.length >= maxPinnedItems) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Maximum $maxPinnedItems items can be pinned')),
          );
          return;
        }
        _pinnedProjects.add(projectId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project pinned to top')),
        );
      }
    });
  }

  void _togglePinDig(String digId) {
    setState(() {
      if (_pinnedDigs.contains(digId)) {
        _pinnedDigs.remove(digId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location unpinned')),
        );
      } else {
        if (_pinnedDigs.length >= maxPinnedItems) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Maximum $maxPinnedItems items can be pinned')),
          );
          return;
        }
        _pinnedDigs.add(digId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location pinned to top')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOnline) {
      return _buildOfflineView();
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildBreadcrumbs(),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
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
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.yellowAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.wifi_off,
                  size: 48,
                  color: AppTheme.yellowAccent,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No Internet Connection',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
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
      margin: const EdgeInsets.only(bottom: AppTheme.paddingLarge),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.location_on_rounded,
              size: 28,
              color: AppTheme.primaryAccent,
            ),
          ),
          const SizedBox(width: AppTheme.paddingLarge),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Job Locations',
                  style: AppTheme.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage divisions, projects, and dig locations',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (_isAdmin) ...[
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                onPressed: _showAddDialog,
                icon: const Icon(Icons.add, size: 18),
                label: Text(_getAddButtonText()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    List<Widget> breadcrumbs = [];

    if (_showingPersonalLocations) {
      breadcrumbs.add(
        TextButton.icon(
          onPressed: () => setState(() {
            _showingPersonalLocations = false;
            _selectedPersonalFolder = null;
          }),
          icon: Icon(Icons.home, size: 16, color: AppTheme.textSecondary),
          label: Text('Locations', style: TextStyle(color: AppTheme.textSecondary)),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
      );
      breadcrumbs.addAll([
        Icon(Icons.chevron_right, size: 16, color: AppTheme.textMuted),
        TextButton.icon(
          onPressed: () => setState(() {
            _selectedPersonalFolder = null;
          }),
          icon: Icon(Icons.folder_special, size: 16, color: _selectedPersonalFolder == null ? AppTheme.primaryAccent : AppTheme.textSecondary),
          label: Text('My Saved Locations', style: TextStyle(color: _selectedPersonalFolder == null ? AppTheme.primaryAccent : AppTheme.textSecondary)),
          style: TextButton.styleFrom(
            foregroundColor: _selectedPersonalFolder == null ? AppTheme.primaryAccent : AppTheme.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
      ]);

      if (_selectedPersonalFolder != null) {
        breadcrumbs.addAll([
          Icon(Icons.chevron_right, size: 16, color: AppTheme.textMuted),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              _selectedPersonalFolder!.name,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ]);
      }
    } else {
      breadcrumbs.add(
        TextButton.icon(
          onPressed: () => setState(() {
            _selectedDivision = null;
            _selectedProject = null;
          }),
          icon: Icon(Icons.home, size: 16, color: _selectedDivision == null ? AppTheme.primaryAccent : AppTheme.textSecondary),
          label: Text('Divisions', style: TextStyle(color: _selectedDivision == null ? AppTheme.primaryAccent : AppTheme.textSecondary)),
          style: TextButton.styleFrom(
            foregroundColor: _selectedDivision == null ? AppTheme.primaryAccent : AppTheme.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
      );

      if (_selectedDivision != null) {
        breadcrumbs.addAll([
          Icon(Icons.chevron_right, size: 16, color: AppTheme.textMuted),
          TextButton(
            onPressed: () => setState(() {
              _selectedProject = null;
            }),
            child: Text(_selectedDivision!.name, style: TextStyle(color: _selectedProject == null ? AppTheme.primaryAccent : AppTheme.textSecondary)),
            style: TextButton.styleFrom(
              foregroundColor: _selectedProject == null ? AppTheme.primaryAccent : AppTheme.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
        ]);
      }

      if (_selectedProject != null) {
        breadcrumbs.addAll([
          Icon(Icons.chevron_right, size: 16, color: AppTheme.textMuted),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              _selectedProject!.name,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ]);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge, vertical: AppTheme.paddingSmall),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: breadcrumbs,
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_showingPersonalLocations) {
      if (_selectedPersonalFolder != null) {
        return _buildPersonalLocationsList(_selectedPersonalFolder!.id!);
      } else {
        return _buildPersonalFoldersList();
      }
    } else if (_selectedProject != null && _selectedDivision != null) {
      return _buildDigsList(_selectedDivision!.id!, _selectedProject!.id!);
    } else if (_selectedDivision != null) {
      return _buildProjectsList(_selectedDivision!.id!);
    } else {
      return _buildMainLocationsList();
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

        final allDivisions = snapshot.data ?? [];

        if (allDivisions.isEmpty) {
          return _buildEmptyState(
            'No Divisions Yet',
            'Create your first division to organize job locations',
            Icons.location_city,
          );
        }

        // Sort divisions: pinned items first, then unpinned
        final sortedDivisions = List<Division>.from(allDivisions);
        sortedDivisions.sort((a, b) {
          final aIsPinned = _pinnedDivisions.contains(a.id);
          final bIsPinned = _pinnedDivisions.contains(b.id);
          
          if (aIsPinned && !bIsPinned) return -1;
          if (!aIsPinned && bIsPinned) return 1;
          return 0; // Keep original order for items with same pin status
        });

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          itemCount: sortedDivisions.length,
          itemBuilder: (context, index) {
            final division = sortedDivisions[index];
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

        final allProjects = snapshot.data ?? [];

        if (allProjects.isEmpty) {
          return _buildEmptyState(
            'No Projects Yet',
            'Add projects to organize dig locations within this division',
            Icons.folder,
          );
        }

        // Sort projects: pinned items first, then unpinned
        final sortedProjects = List<Project>.from(allProjects);
        sortedProjects.sort((a, b) {
          final aIsPinned = _pinnedProjects.contains(a.id);
          final bIsPinned = _pinnedProjects.contains(b.id);
          
          if (aIsPinned && !bIsPinned) return -1;
          if (!aIsPinned && bIsPinned) return 1;
          return 0; // Keep original order for items with same pin status
        });

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          itemCount: sortedProjects.length,
          itemBuilder: (context, index) {
            final project = sortedProjects[index];
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

        final allDigs = snapshot.data ?? [];

        if (allDigs.isEmpty) {
          return _buildEmptyState(
            'No Digs Yet',
            'Add dig locations with coordinates to this project',
            Icons.room,
          );
        }

        // Sort digs: pinned items first, then unpinned
        final sortedDigs = List<Dig>.from(allDigs);
        sortedDigs.sort((a, b) {
          final aIsPinned = _pinnedDigs.contains(a.id);
          final bIsPinned = _pinnedDigs.contains(b.id);
          
          if (aIsPinned && !bIsPinned) return -1;
          if (!aIsPinned && bIsPinned) return 1;
          return 0; // Keep original order for items with same pin status
        });

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          itemCount: sortedDigs.length,
          itemBuilder: (context, index) {
            final dig = sortedDigs[index];
            return _buildDigCard(dig);
          },
        );
      },
    );
  }

  Widget _buildMainLocationsList() {
    return StreamBuilder<List<Division>>(
      stream: _locationsService.getAllDivisions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorState('Error loading divisions');
        }

        final allDivisions = snapshot.data ?? [];

        // Sort divisions: pinned items first, then unpinned
        final sortedDivisions = List<Division>.from(allDivisions);
        sortedDivisions.sort((a, b) {
          final aIsPinned = _pinnedDivisions.contains(a.id);
          final bIsPinned = _pinnedDivisions.contains(b.id);
          
          if (aIsPinned && !bIsPinned) return -1;
          if (!aIsPinned && bIsPinned) return 1;
          return 0; // Keep original order for items with same pin status
        });

        return CustomScrollView(
          slivers: [
            // Personal Locations Section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Material(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 0,
                  child: InkWell(
                    onTap: _showPersonalLocations,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.folder_special,
                              color: AppTheme.primaryAccent,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'My Saved Locations',
                                  style: AppTheme.titleMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Personal folders and locations visible only to you',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: AppTheme.textMuted,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Company Locations Header
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(AppTheme.paddingLarge, 0, AppTheme.paddingLarge, AppTheme.paddingSmall),
                child: Text(
                  'Company Locations',
                  style: AppTheme.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ),

            // Company Divisions List
            if (allDivisions.isEmpty)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(AppTheme.paddingLarge),
                  child: _buildEmptyState(
                    'No Company Divisions Yet',
                    _isAdmin 
                        ? 'Create your first division to organize job locations'
                        : 'No company locations have been created yet',
                    Icons.location_city,
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final division = sortedDivisions[index];
                    return Container(
                      margin: EdgeInsets.fromLTRB(
                        AppTheme.paddingLarge, 
                        0, 
                        AppTheme.paddingLarge, 
                        index == sortedDivisions.length - 1 ? AppTheme.paddingLarge : 16
                      ),
                      child: _buildDivisionCard(division),
                    );
                  },
                  childCount: sortedDivisions.length,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPersonalFoldersList() {
    final userId = _authService.userId ?? '';
    
    return StreamBuilder<List<PersonalFolder>>(
      stream: _personalLocationsService.getUserFolders(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorState('Error loading personal folders');
        }

        final allFolders = snapshot.data ?? [];

        if (allFolders.isEmpty) {
          return _buildEmptyState(
            'No Personal Folders Yet',
            'Create your first folder to organize your saved locations',
            Icons.folder_special,
          );
        }

        // Sort folders: pinned items first, then unpinned
        final sortedFolders = List<PersonalFolder>.from(allFolders);
        sortedFolders.sort((a, b) {
          final aIsPinned = _pinnedPersonalFolders.contains(a.id);
          final bIsPinned = _pinnedPersonalFolders.contains(b.id);
          
          if (aIsPinned && !bIsPinned) return -1;
          if (!aIsPinned && bIsPinned) return 1;
          return 0; // Keep original order for items with same pin status
        });

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          itemCount: sortedFolders.length,
          itemBuilder: (context, index) {
            final folder = sortedFolders[index];
            return _buildPersonalFolderCard(folder);
          },
        );
      },
    );
  }

  Widget _buildPersonalLocationsList(String folderId) {
    final userId = _authService.userId ?? '';
    
    return StreamBuilder<List<PersonalLocation>>(
      stream: _personalLocationsService.getLocationsByFolder(folderId, userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorState('Error loading personal locations');
        }

        final allLocations = snapshot.data ?? [];

        if (allLocations.isEmpty) {
          return _buildEmptyState(
            'No Locations Yet',
            'Add locations with coordinates to this folder',
            Icons.room,
          );
        }

        // Sort locations: pinned items first, then unpinned
        final sortedLocations = List<PersonalLocation>.from(allLocations);
        sortedLocations.sort((a, b) {
          final aIsPinned = _pinnedPersonalLocations.contains(a.id);
          final bIsPinned = _pinnedPersonalLocations.contains(b.id);
          
          if (aIsPinned && !bIsPinned) return -1;
          if (!aIsPinned && bIsPinned) return 1;
          return 0; // Keep original order for items with same pin status
        });

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          itemCount: sortedLocations.length,
          itemBuilder: (context, index) {
            final location = sortedLocations[index];
            return _buildPersonalLocationCard(location);
          },
        );
      },
    );
  }

  Widget _buildDivisionCard(Division division) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          onTap: () => _navigateToDivision(division),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.location_city,
                    color: AppTheme.primaryAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              division.name,
                              style: AppTheme.titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          // Show pin indicator if item is pinned
                          if (_pinnedDivisions.contains(division.id)) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.yellowAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.push_pin,
                                color: AppTheme.yellowAccent,
                                size: 14,
                              ),
                            ),
                          ],
                        ],
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
                    Icon(
                      Icons.chevron_right,
                      color: AppTheme.textMuted,
                      size: 20,
                    ),
                    if (_isAdmin) ...[
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        onSelected: (value) => _handleDivisionAction(value, division),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: _pinnedDivisions.contains(division.id) ? 'unpin' : 'pin',
                            child: Row(
                              children: [
                                Icon(
                                  _pinnedDivisions.contains(division.id)
                                      ? Icons.push_pin
                                      : Icons.push_pin_outlined,
                                  size: 16,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _pinnedDivisions.contains(division.id) ? 'Unpin' : 'Pin to top',
                                  style: TextStyle(color: AppTheme.textPrimary),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 16, color: AppTheme.textSecondary),
                                const SizedBox(width: 8),
                                Text('Edit', style: TextStyle(color: AppTheme.textPrimary)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 16, color: AppTheme.accessoryAccent),
                                const SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: AppTheme.accessoryAccent)),
                              ],
                            ),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.more_vert,
                            size: 16,
                            color: AppTheme.textMuted,
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
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          onTap: () => _navigateToProject(project),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.folder,
                    color: AppTheme.secondaryAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              project.name,
                              style: AppTheme.titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          // Show pin indicator if item is pinned
                          if (_pinnedProjects.contains(project.id)) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.yellowAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.push_pin,
                                color: AppTheme.yellowAccent,
                                size: 14,
                              ),
                            ),
                          ],
                        ],
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
                    Icon(
                      Icons.chevron_right,
                      color: AppTheme.textMuted,
                      size: 20,
                    ),
                    if (_isAdmin) ...[
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        onSelected: (value) => _handleProjectAction(value, project),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: _pinnedProjects.contains(project.id) ? 'unpin' : 'pin',
                            child: Row(
                              children: [
                                Icon(
                                  _pinnedProjects.contains(project.id)
                                      ? Icons.push_pin
                                      : Icons.push_pin_outlined,
                                  size: 16,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _pinnedProjects.contains(project.id) ? 'Unpin' : 'Pin to top',
                                  style: TextStyle(color: AppTheme.textPrimary),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 16, color: AppTheme.textSecondary),
                                const SizedBox(width: 8),
                                Text('Edit', style: TextStyle(color: AppTheme.textPrimary)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 16, color: AppTheme.accessoryAccent),
                                const SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: AppTheme.accessoryAccent)),
                              ],
                            ),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.more_vert,
                            size: 16,
                            color: AppTheme.textMuted,
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accessoryAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.room,
                    color: AppTheme.accessoryAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              dig.digNumber,
                              style: AppTheme.titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          // Show pin indicator if item is pinned
                          if (_pinnedDigs.contains(dig.id)) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.yellowAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.push_pin,
                                color: AppTheme.yellowAccent,
                                size: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (dig.rgwNumber.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'RGW #${dig.rgwNumber}',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_isAdmin) ...[
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleDigAction(value, dig),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: _pinnedDigs.contains(dig.id) ? 'unpin' : 'pin',
                        child: Row(
                          children: [
                            Icon(
                              _pinnedDigs.contains(dig.id)
                                  ? Icons.push_pin
                                  : Icons.push_pin_outlined,
                              size: 16,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _pinnedDigs.contains(dig.id) ? 'Unpin' : 'Pin to top',
                              style: TextStyle(color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16, color: AppTheme.textSecondary),
                            const SizedBox(width: 8),
                            Text('Edit', style: TextStyle(color: AppTheme.textPrimary)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: AppTheme.accessoryAccent),
                            const SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: AppTheme.accessoryAccent)),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.more_vert,
                        size: 16,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.my_location,
                        size: 16,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Coordinates: ${dig.coordinates}',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textPrimary,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (dig.notes != null && dig.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.note,
                          size: 16,
                          color: AppTheme.textMuted,
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
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                onPressed: dig.hasValidCoordinates ? () => _openInMaps(dig) : null,
                icon: const Icon(Icons.map, size: 18),
                label: const Text('Open in Maps'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalFolderCard(PersonalFolder folder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          onTap: () => _navigateToPersonalFolder(folder),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: LocationColors.getLightColor(folder.colorHex).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.folder,
                    color: LocationColors.getColor(folder.colorHex),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              folder.name,
                              style: AppTheme.titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          // Show pin indicator if item is pinned
                          if (_pinnedPersonalFolders.contains(folder.id)) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.yellowAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.push_pin,
                                color: AppTheme.yellowAccent,
                                size: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (folder.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          folder.description!,
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
                    Icon(
                      Icons.chevron_right,
                      color: AppTheme.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      onSelected: (value) => _handlePersonalFolderAction(value, folder),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: _pinnedPersonalFolders.contains(folder.id) ? 'unpin' : 'pin',
                          child: Row(
                            children: [
                              Icon(
                                _pinnedPersonalFolders.contains(folder.id)
                                    ? Icons.push_pin
                                    : Icons.push_pin_outlined,
                                size: 16,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _pinnedPersonalFolders.contains(folder.id) ? 'Unpin' : 'Pin to top',
                                style: TextStyle(color: AppTheme.textPrimary),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16, color: AppTheme.textSecondary),
                              const SizedBox(width: 8),
                              Text('Edit', style: TextStyle(color: AppTheme.textPrimary)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: AppTheme.accessoryAccent),
                              const SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: AppTheme.accessoryAccent)),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.more_vert,
                          size: 16,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalLocationCard(PersonalLocation location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: LocationColors.getLightColor(location.colorHex).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.room,
                    color: LocationColors.getColor(location.colorHex),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              location.title,
                              style: AppTheme.titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          // Show pin indicator if item is pinned
                          if (_pinnedPersonalLocations.contains(location.id)) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.yellowAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.push_pin,
                                color: AppTheme.yellowAccent,
                                size: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (location.subtitle != null && location.subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          location.subtitle!,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handlePersonalLocationAction(value, location),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _pinnedPersonalLocations.contains(location.id) ? 'unpin' : 'pin',
                      child: Row(
                        children: [
                          Icon(
                            _pinnedPersonalLocations.contains(location.id)
                                ? Icons.push_pin
                                : Icons.push_pin_outlined,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _pinnedPersonalLocations.contains(location.id) ? 'Unpin' : 'Pin to top',
                            style: TextStyle(color: AppTheme.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16, color: AppTheme.textSecondary),
                          const SizedBox(width: 8),
                          Text('Edit', style: TextStyle(color: AppTheme.textPrimary)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: AppTheme.accessoryAccent),
                          const SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: AppTheme.accessoryAccent)),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.more_vert,
                      size: 16,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.my_location,
                        size: 16,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Coordinates: ${location.coordinates}',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textPrimary,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (location.notes != null && location.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.note,
                          size: 16,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            location.notes!,
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
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                onPressed: location.hasValidCoordinates ? () => _openPersonalLocationInMaps(location) : null,
                icon: const Icon(Icons.map, size: 18),
                label: const Text('Open in Maps'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accessoryAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: AppTheme.accessoryAccent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
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
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.textMuted.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
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
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(_getAddButtonText()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddDialog() {
    if (_showingPersonalLocations) {
      if (_selectedPersonalFolder != null) {
        _showAddPersonalLocationDialog();
      } else {
        _showAddPersonalFolderDialog();
      }
    } else if (_selectedProject != null && _selectedDivision != null) {
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
        backgroundColor: AppTheme.surface,
        title: Text('Add Division', style: TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Division Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              style: TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
            child: const Text('Cancel'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Please enter a division name'),
                      backgroundColor: AppTheme.accessoryAccent,
                    ),
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
                      SnackBar(
                        content: const Text('Division created successfully'),
                        backgroundColor: AppTheme.secondaryAccent,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error creating division: $e'),
                        backgroundColor: AppTheme.accessoryAccent,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: const Text('Create'),
            ),
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
        backgroundColor: AppTheme.surface,
        title: Text('Add Project', style: TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Project Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              style: TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
            child: const Text('Cancel'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Please enter a project name'),
                      backgroundColor: AppTheme.accessoryAccent,
                    ),
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
                      SnackBar(
                        content: const Text('Project created successfully'),
                        backgroundColor: AppTheme.secondaryAccent,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error creating project: $e'),
                        backgroundColor: AppTheme.accessoryAccent,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: const Text('Create'),
            ),
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
        backgroundColor: AppTheme.surface,
        title: Text('Add Location', style: TextStyle(color: AppTheme.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: digNumberController,
                style: TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: rgwNumberController,
                style: TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'RGW Number',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: coordinatesController,
                style: TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Coordinates (lat, lng)',
                  hintText: 'e.g., 31.12345, -88.54321',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                style: TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
            child: const Text('Cancel'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () async {
                if (digNumberController.text.trim().isEmpty ||
                    coordinatesController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Please fill in title and coordinates'),
                      backgroundColor: AppTheme.accessoryAccent,
                    ),
                  );
                  return;
                }

                if (!_locationsService.isValidCoordinateFormat(coordinatesController.text.trim())) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Invalid coordinate format. Use: lat, lng'),
                      backgroundColor: AppTheme.accessoryAccent,
                    ),
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
                      SnackBar(
                        content: const Text('Dig location created successfully'),
                        backgroundColor: AppTheme.secondaryAccent,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error creating dig location: $e'),
                        backgroundColor: AppTheme.accessoryAccent,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: const Text('Create'),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPersonalFolderDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedColor = LocationColors.availableColors.keys.first; // Default to first color

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text('Add Personal Folder', style: TextStyle(color: AppTheme.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Folder Name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                style: TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ColorPickerWidget(
                selectedColorHex: selectedColor,
                onColorSelected: (color) {
                  setState(() {
                    selectedColor = color;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
              child: const Text('Cancel'),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Please enter a folder name'),
                        backgroundColor: AppTheme.accessoryAccent,
                      ),
                    );
                    return;
                  }

                  try {
                    final folder = PersonalFolder(
                      userId: _authService.userId ?? 'unknown',
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim().isNotEmpty
                          ? descriptionController.text.trim()
                          : null,
                      colorHex: selectedColor,
                    );

                    await _personalLocationsService.createFolder(folder);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Personal folder created successfully'),
                          backgroundColor: AppTheme.secondaryAccent,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error creating folder: $e'),
                          backgroundColor: AppTheme.accessoryAccent,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: const Text('Create'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPersonalLocationDialog() {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final coordinatesController = TextEditingController();
    final notesController = TextEditingController();
    String selectedColor = LocationColors.availableColors.keys.first; // Default to first color

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text('Add Personal Location', style: TextStyle(color: AppTheme.textPrimary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: subtitleController,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Subtitle (Optional)',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: coordinatesController,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Coordinates (lat, lng)',
                    hintText: 'e.g., 31.12345, -88.54321',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ColorPickerWidget(
                  selectedColorHex: selectedColor,
                  onColorSelected: (color) {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
              child: const Text('Cancel'),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  if (titleController.text.trim().isEmpty ||
                      coordinatesController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Please fill in title and coordinates'),
                        backgroundColor: AppTheme.accessoryAccent,
                      ),
                    );
                    return;
                  }

                  if (!_personalLocationsService.isValidCoordinateFormat(coordinatesController.text.trim())) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Invalid coordinate format. Use: lat, lng'),
                        backgroundColor: AppTheme.accessoryAccent,
                      ),
                    );
                    return;
                  }

                  try {
                    final location = PersonalLocation(
                      userId: _authService.userId ?? 'unknown',
                      folderId: _selectedPersonalFolder!.id!,
                      title: titleController.text.trim(),
                      subtitle: subtitleController.text.trim().isNotEmpty
                          ? subtitleController.text.trim()
                          : null,
                      coordinates: coordinatesController.text.trim(),
                      notes: notesController.text.trim().isNotEmpty
                          ? notesController.text.trim()
                          : null,
                      colorHex: selectedColor,
                    );

                    await _personalLocationsService.createLocation(location);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Personal location created successfully'),
                          backgroundColor: AppTheme.secondaryAccent,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error creating location: $e'),
                          backgroundColor: AppTheme.accessoryAccent,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: const Text('Create'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDivisionAction(String action, Division division) {
    switch (action) {
      case 'pin':
      case 'unpin':
        _togglePinDivision(division.id!);
        break;
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
      case 'pin':
      case 'unpin':
        _togglePinProject(project.id!);
        break;
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
      case 'pin':
      case 'unpin':
        _togglePinDig(dig.id!);
        break;
      case 'edit':
        _showEditDigDialog(dig);
        break;
      case 'delete':
        _showDeleteConfirmation(
          'Delete Location',
          'Are you sure you want to delete "${dig.digNumber}"?',
          () => _locationsService.deleteDig(dig.divisionId, dig.projectId, dig.id!),
        );
        break;
    }
  }

  void _handlePersonalFolderAction(String action, PersonalFolder folder) {
    switch (action) {
      case 'pin':
      case 'unpin':
        _togglePinPersonalFolder(folder.id!);
        break;
      case 'edit':
        _showEditPersonalFolderDialog(folder);
        break;
      case 'delete':
        _showDeleteConfirmation(
          'Delete Folder',
          'Are you sure you want to delete "${folder.name}" and all its locations?',
          () => _personalLocationsService.deleteFolder(folder.id!, folder.userId),
        );
        break;
    }
  }

  void _handlePersonalLocationAction(String action, PersonalLocation location) {
    switch (action) {
      case 'pin':
      case 'unpin':
        _togglePinPersonalLocation(location.id!);
        break;
      case 'edit':
        _showEditPersonalLocationDialog(location);
        break;
      case 'delete':
        _showDeleteConfirmation(
          'Delete Location',
          'Are you sure you want to delete "${location.title}"?',
          () => _personalLocationsService.deleteLocation(location.id!, location.userId),
        );
        break;
    }
  }

  void _togglePinPersonalFolder(String folderId) {
    setState(() {
      if (_pinnedPersonalFolders.contains(folderId)) {
        _pinnedPersonalFolders.remove(folderId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Folder unpinned')),
        );
      } else {
        if (_pinnedPersonalFolders.length >= maxPinnedItems) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Maximum $maxPinnedItems items can be pinned')),
          );
          return;
        }
        _pinnedPersonalFolders.add(folderId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Folder pinned to top')),
        );
      }
    });
  }

  void _togglePinPersonalLocation(String locationId) {
    setState(() {
      if (_pinnedPersonalLocations.contains(locationId)) {
        _pinnedPersonalLocations.remove(locationId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location unpinned')),
        );
      } else {
        if (_pinnedPersonalLocations.length >= maxPinnedItems) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Maximum $maxPinnedItems items can be pinned')),
          );
          return;
        }
        _pinnedPersonalLocations.add(locationId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location pinned to top')),
        );
      }
    });
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
                  labelText: 'Title',
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
                  coordinatesController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in title and coordinates')),
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

  void _showEditPersonalFolderDialog(PersonalFolder folder) {
    final nameController = TextEditingController(text: folder.name);
    final descriptionController = TextEditingController(text: folder.description);
    String selectedColor = folder.colorHex;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Personal Folder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Folder Name',
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
              const SizedBox(height: 16),
              ColorPickerWidget(
                selectedColorHex: selectedColor,
                onColorSelected: (color) {
                  setState(() {
                    selectedColor = color;
                  });
                },
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
                    const SnackBar(content: Text('Please enter a folder name')),
                  );
                  return;
                }

                try {
                  final updatedFolder = folder.copyWith(
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim().isNotEmpty 
                        ? descriptionController.text.trim() 
                        : null,
                    colorHex: selectedColor,
                  );

                  await _personalLocationsService.updateFolder(updatedFolder);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Folder updated successfully')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating folder: $e')),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPersonalLocationDialog(PersonalLocation location) {
    final titleController = TextEditingController(text: location.title);
    final subtitleController = TextEditingController(text: location.subtitle);
    final coordinatesController = TextEditingController(text: location.coordinates);
    final notesController = TextEditingController(text: location.notes);
    String selectedColor = location.colorHex;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Personal Location'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: subtitleController,
                  decoration: const InputDecoration(
                    labelText: 'Subtitle (Optional)',
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
                const SizedBox(height: 16),
                ColorPickerWidget(
                  selectedColorHex: selectedColor,
                  onColorSelected: (color) {
                    setState(() {
                      selectedColor = color;
                    });
                  },
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
                if (titleController.text.trim().isEmpty ||
                    coordinatesController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in title and coordinates')),
                  );
                  return;
                }

                if (!_personalLocationsService.isValidCoordinateFormat(
                    coordinatesController.text.trim())) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid coordinate format. Use: lat, lng')),
                  );
                  return;
                }

                try {
                  final updatedLocation = location.copyWith(
                    title: titleController.text.trim(),
                    subtitle: subtitleController.text.trim().isNotEmpty
                        ? subtitleController.text.trim()
                        : null,
                    coordinates: coordinatesController.text.trim(),
                    notes: notesController.text.trim().isNotEmpty
                        ? notesController.text.trim()
                        : null,
                    colorHex: selectedColor,
                  );

                  await _personalLocationsService.updateLocation(updatedLocation);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Location updated successfully')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating location: $e')),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String title, String message, Function() onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(title, style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(message, style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await onConfirm();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Deleted successfully'),
                      backgroundColor: AppTheme.secondaryAccent,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting: $e'),
                      backgroundColor: AppTheme.accessoryAccent,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.accessoryAccent),
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
        backgroundColor: AppTheme.surface,
        title: Text('Open in Maps', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text('Choose which maps app to use:', style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _launchUrl(dig.googleMapsUrl);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryAccent,
            ),
            child: const Text('Google Maps'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _launchUrl(dig.appleMapsUrl);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryAccent,
            ),
            child: const Text('Apple Maps'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
            ),
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

  void _openPersonalLocationInMaps(PersonalLocation location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Open in Maps', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text('Choose which maps app to use:', style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _launchUrl(location.googleMapsUrl);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryAccent,
            ),
            child: const Text('Google Maps'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _launchUrl(location.appleMapsUrl);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryAccent,
            ),
            child: const Text('Apple Maps'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
