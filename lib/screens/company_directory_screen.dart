import 'package:flutter/material.dart';
import '../models/company_employee.dart';
import '../services/employee_service.dart';
import '../services/user_service.dart';
import '../widgets/add_employee_dialog.dart';
import '../utils/contact_helper.dart';

class CompanyDirectoryScreen extends StatefulWidget {
  const CompanyDirectoryScreen({super.key});

  @override
  State<CompanyDirectoryScreen> createState() => _CompanyDirectoryScreenState();
}

class _CompanyDirectoryScreenState extends State<CompanyDirectoryScreen>
    with SingleTickerProviderStateMixin {
  final EmployeeService _employeeService = EmployeeService();
  final UserService _userService = UserService();
  String _searchQuery = '';
  String? _selectedDepartment;
  bool _isGridView = false;
  bool _isAdmin = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // New Dark Color System
  static const Color _backgroundColor = Color(0xFF1E232A);
  static const Color _surfaceColor = Color(0xFF242A33);
  static const Color _cardColor = Color(0xFF2A313B);
  static const Color _primaryText = Color(0xFFEDF9FF);
  static const Color _secondaryText = Color(0xFFAEBBC8);
  static const Color _mutedText = Color(0xFF7F8A96);
  static const Color _primaryAccent = Color(0xFF6C5BFF);
  static const Color _secondaryAccent = Color(0xFF00E5A8);
  static const Color _accentAlert = Color(0xFFFE637E);
  static const Color _yellowAccent = Color(0xFFF8B800);

  final List<String> _employeeGroups = [
    'All',
    'Directors',
    'Project Managers',
    'Advanced NDE Technicians',
    'Senior Technicians',
    'Junior Technicians',
    'Assistants',
    'Account Managers',
    'Business Development',
    'Admin / HR',
  ];

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
    _checkAdminStatus();
  }

  void _checkAdminStatus() async {
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

  void _showAddEmployeeDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddEmployeeDialog(),
    ).then((result) async {
      if (result != null) {
        try {
          await _employeeService.addEmployee(result);
          if (mounted) {
            _showSnackBar(
              '${result.firstName} ${result.lastName} added successfully',
              _secondaryAccent,
              Icons.check_circle,
            );
          }
        } catch (e) {
          if (mounted) {
            _showSnackBar(
              'Error adding team member: $e',
              _accentAlert,
              Icons.error_outline,
            );
          }
        }
      }
    });
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: _primaryText),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(color: _primaryText))),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: _showAddEmployeeDialog,
              backgroundColor: _primaryAccent,
              elevation: 2,
              child: const Icon(Icons.person_add, color: Colors.white),
            )
          : null,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                
                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search and filter bar
                      _buildSearchAndFilters(),
                      const SizedBox(height: 24),

                      // Directory content
                      _buildEmployeeDirectory(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _primaryAccent.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.people_alt,
              size: 32,
              color: _primaryAccent,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Company Directory',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Contact information and employee details',
                  style: TextStyle(
                    fontSize: 14,
                    color: _secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: _surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: _mutedText, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search by name, email, or position...',
                            hintStyle: TextStyle(color: _mutedText),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          style: TextStyle(color: _primaryText),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.clear, size: 18, color: _mutedText),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    _isGridView ? Icons.view_list : Icons.grid_view,
                    color: _secondaryText,
                  ),
                  onPressed: () {
                    setState(() {
                      _isGridView = !_isGridView;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _employeeGroups.map((department) {
                final isSelected = _selectedDepartment == department ||
                    (department == 'All' && _selectedDepartment == null);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDepartment = department == 'All' ? null : department;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _primaryAccent.withOpacity(0.15)
                            : _surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? _primaryAccent
                              : Colors.white.withOpacity(0.08),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        department,
                        style: TextStyle(
                          color: isSelected ? _primaryAccent : _secondaryText,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeDirectory() {
    return StreamBuilder<List<CompanyEmployee>>(
      stream: _employeeService.getEmployees(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState();
        }

        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(color: _primaryAccent),
          );
        }

        final employees = snapshot.data!;

        if (employees.isEmpty) {
          return _buildEmptyState();
        }

        final filteredEmployees = employees.where((employee) {
          final matchesSearch = _searchQuery.isEmpty ||
              ('${employee.firstName} ${employee.lastName}'
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase())) ||
              (employee.email.toLowerCase().contains(_searchQuery.toLowerCase())) ||
              (employee.title.toLowerCase().contains(_searchQuery.toLowerCase()));
          final matchesDepartment =
              _selectedDepartment == null || employee.group == _selectedDepartment;
          return matchesSearch && matchesDepartment;
        }).toList();

        if (filteredEmployees.isEmpty) {
          return _buildNoResultsState();
        }

        // Group employees by job group
        final Map<String, List<CompanyEmployee>> groupedEmployees = {};
        for (var employee in filteredEmployees) {
          final group = employee.group;
          groupedEmployees.putIfAbsent(group, () => []);
          groupedEmployees[group]!.add(employee);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: groupedEmployees.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                  child: Row(
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 18,
                          color: _primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _yellowAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _yellowAccent.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${entry.value.length}',
                          style: TextStyle(
                            color: _yellowAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _isGridView
                    ? GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: entry.value.length,
                        itemBuilder: (context, index) {
                          return _buildEmployeeGridCard(entry.value[index]);
                        },
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: entry.value.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildEmployeeCard(entry.value[index]),
                          );
                        },
                      ),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEmployeeCard(CompanyEmployee employee) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAvatar(employee),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${employee.firstName} ${employee.lastName}',
                        style: TextStyle(
                          fontSize: 16,
                          color: _primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        employee.title,
                        style: TextStyle(
                          fontSize: 14,
                          color: _secondaryText,
                        ),
                      ),
                      if (employee.division != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          employee.division!,
                          style: TextStyle(
                            color: _mutedText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _primaryAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _primaryAccent.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    employee.group,
                    style: TextStyle(
                      color: _primaryAccent,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: Colors.white.withOpacity(0.05),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (employee.email.isNotEmpty) ...[
                        _buildContactRow(Icons.email, employee.email),
                        const SizedBox(height: 8),
                      ],
                      if (employee.phone.isNotEmpty) ...[
                        _buildContactRow(Icons.phone, employee.phone),
                      ],
                    ],
                  ),
                ),
                if (_isAdmin)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: _secondaryText),
                    color: _cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18, color: _secondaryText),
                            const SizedBox(width: 8),
                            Text('Edit', style: TextStyle(color: _primaryText)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: _accentAlert),
                            const SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: _accentAlert)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editEmployee(employee);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(employee);
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeGridCard(CompanyEmployee employee) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAvatar(employee, radius: 32),
            const SizedBox(height: 12),
            Text(
              '${employee.firstName} ${employee.lastName}',
              style: TextStyle(
                fontSize: 14,
                color: _primaryText,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              employee.title,
              style: TextStyle(
                fontSize: 12,
                color: _secondaryText,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (employee.division != null) ...[
              const SizedBox(height: 2),
              Text(
                employee.division!,
                style: TextStyle(
                  color: _mutedText,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _primaryAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _primaryAccent.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                employee.group,
                style: TextStyle(
                  color: _primaryAccent,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.email, color: _primaryAccent, size: 20),
                  onPressed: employee.email.isNotEmpty
                      ? () => ContactHelper.launchEmail(context, employee.email)
                      : null,
                  tooltip: 'Email',
                ),
                IconButton(
                  icon: Icon(Icons.phone, color: _secondaryAccent, size: 20),
                  onPressed: employee.phone.isNotEmpty
                      ? () => ContactHelper.launchPhone(context, employee.phone)
                      : null,
                  tooltip: 'Call',
                ),
                if (_isAdmin)
                  IconButton(
                    icon: Icon(Icons.edit, color: _secondaryText, size: 20),
                    onPressed: () => _editEmployee(employee),
                    tooltip: 'Edit',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(CompanyEmployee employee, {double radius = 24}) {
    final String initials = '${employee.firstName[0]}${employee.lastName[0]}';
    final int hash = employee.firstName.hashCode + employee.lastName.hashCode;

    final List<Color> avatarColors = [
      _primaryAccent,
      _secondaryAccent,
      _accentAlert,
      _yellowAccent,
      const Color(0xFF00D4FF),
      const Color(0xFFFF6B9D),
    ];

    final int colorIndex = hash.abs() % avatarColors.length;

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: avatarColors[colorIndex].withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: avatarColors[colorIndex].withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: avatarColors[colorIndex],
            fontWeight: FontWeight.bold,
            fontSize: radius * 0.7,
          ),
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    final bool isEmail = icon == Icons.email;
    final bool isPhone = icon == Icons.phone;

    return InkWell(
      onTap: () {
        if (isEmail) {
          ContactHelper.launchEmail(context, text);
        } else if (isPhone) {
          ContactHelper.launchPhone(context, text);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isEmail ? _primaryAccent : _secondaryAccent,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: _secondaryText,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: _mutedText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _surfaceColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline,
                size: 64,
                color: _mutedText,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No employees found',
              style: TextStyle(
                fontSize: 18,
                color: _primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first team member to get started',
              style: TextStyle(
                fontSize: 14,
                color: _secondaryText,
              ),
            ),
            if (_isAdmin) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _showAddEmployeeDialog,
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Add Team Member'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _surfaceColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 64,
                color: _mutedText,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No matching employees found',
              style: TextStyle(
                fontSize: 18,
                color: _primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: _secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _surfaceColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: _accentAlert,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error loading directory',
              style: TextStyle(
                fontSize: 18,
                color: _primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again later',
              style: TextStyle(
                fontSize: 14,
                color: _secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editEmployee(CompanyEmployee employee) {
    showDialog(
      context: context,
      builder: (context) => AddEmployeeDialog(employee: employee),
    ).then((result) async {
      if (result != null) {
        try {
          await _employeeService.updateEmployee(employee.id!, result);
          if (mounted) {
            _showSnackBar(
              'Employee updated successfully',
              _secondaryAccent,
              Icons.check_circle,
            );
          }
        } catch (e) {
          if (mounted) {
            _showSnackBar(
              'Error updating employee: $e',
              _accentAlert,
              Icons.error_outline,
            );
          }
        }
      }
    });
  }

  void _showDeleteConfirmation(CompanyEmployee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Employee',
          style: TextStyle(color: _primaryText),
        ),
        content: Text(
          'Are you sure you want to delete ${employee.firstName} ${employee.lastName}?',
          style: TextStyle(color: _secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: _secondaryText)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _employeeService.deleteEmployee(employee.id!);
                if (mounted) {
                  _showSnackBar(
                    '${employee.firstName} ${employee.lastName} deleted successfully',
                    _secondaryAccent,
                    Icons.check_circle,
                  );
                }
              } catch (e) {
                if (mounted) {
                  _showSnackBar(
                    'Error deleting employee: $e',
                    _accentAlert,
                    Icons.error_outline,
                  );
                }
              }
            },
            child: Text('Delete', style: TextStyle(color: _accentAlert)),
          ),
        ],
      ),
    );
  }
}
