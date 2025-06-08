import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/image_service.dart';
import '../models/user_profile.dart';
import '../widgets/app_header.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  final ImageService _imageService = ImageService();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _locationController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _positionController.dispose();
    _locationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showEditProfileDialog(BuildContext context, UserProfile profile) {
    _displayNameController.text = profile.displayName ?? '';
    _bioController.text = profile.bio ?? '';
    _phoneController.text = profile.preferences['phone'] ?? '';
    _companyController.text = profile.preferences['company'] ?? '';
    _positionController.text = profile.preferences['position'] ?? '';
    _locationController.text = profile.preferences['location'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: const Icon(Icons.edit, color: AppTheme.primaryBlue),
            ),
            const SizedBox(width: 12),
            const Text('Edit Profile'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  hintText: 'Enter your display name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Tell us about yourself',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Company',
                  hintText: 'Enter your company name',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _positionController,
                decoration: const InputDecoration(
                  labelText: 'Position',
                  hintText: 'Enter your job position',
                  prefixIcon: Icon(Icons.work_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Enter your location',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.save, size: 18),
            label: const Text('Save Changes'),
            onPressed: () async {
              try {
                await _profileService.updateProfileFields({
                  'displayName': _displayNameController.text,
                  'bio': _bioController.text,
                  'preferences': {
                    'phone': _phoneController.text,
                    'company': _companyController.text,
                    'position': _positionController.text,
                    'location': _locationController.text,
                  },
                });
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully'),
                      backgroundColor: AppTheme.accent2,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating profile: $e'),
                      backgroundColor: AppTheme.accent3,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Background design elements
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryBlue.withOpacity(0.03),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accent2.withOpacity(0.05),
              ),
            ),
          ),
          
          SafeArea(
            child: StreamBuilder<UserProfile?>(
              stream: _profileService.getCurrentProfile(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: AppTheme.accent3),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: AppTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final profile = snapshot.data;
                if (profile == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off, size: 48, color: AppTheme.textSecondary),
                        const SizedBox(height: 16),
                        Text(
                          'No profile data available',
                          style: AppTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppHeader(
                          title: 'Profile',
                          icon: Icons.person,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(AppTheme.paddingLarge),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Profile Header with Cover Image
                                Container(
                                  height: 180,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [AppTheme.primaryBlue, Color(0xFF5C85FF)],
                                    ),
                                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryBlue.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      // Decorative elements
                                      Positioned(
                                        top: -20,
                                        right: -20,
                                        child: Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white.withOpacity(0.1),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: -30,
                                        left: 30,
                                        child: Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white.withOpacity(0.1),
                                          ),
                                        ),
                                      ),
                                      
                                      // Profile content
                                      Padding(
                                        padding: const EdgeInsets.all(AppTheme.paddingLarge),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            // Profile image
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 3,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.2),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Stack(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 50,
                                                    backgroundColor: Colors.white,
                                                    backgroundImage: profile.photoUrl != null
                                                        ? NetworkImage(profile.photoUrl!)
                                                        : null,
                                                    child: profile.photoUrl == null
                                                        ? const Icon(
                                                            Icons.person,
                                                            size: 50,
                                                            color: AppTheme.primaryBlue,
                                                          )
                                                        : null,
                                                  ),
                                                  Positioned(
                                                    right: 0,
                                                    bottom: 0,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: AppTheme.primaryBlue,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.white,
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: IconButton(
                                                        icon: const Icon(
                                                          Icons.camera_alt,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                        onPressed: () => _showImagePickerOptions(context, profile),
                                                        constraints: const BoxConstraints(
                                                          minWidth: 36,
                                                          minHeight: 36,
                                                        ),
                                                        padding: const EdgeInsets.all(8),
                                                        tooltip: 'Change profile picture',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            
                                            // Name and email
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    profile.displayName ?? 'No Name Set',
                                                    style: AppTheme.headlineMedium.copyWith(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.email,
                                                        size: 16,
                                                        color: Colors.white70,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          profile.email,
                                                          style: AppTheme.bodyMedium.copyWith(
                                                            color: Colors.white70,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (profile.preferences['position'] != null) ...[
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.work,
                                                          size: 16,
                                                          color: Colors.white70,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            profile.preferences['position'],
                                                            style: AppTheme.bodyMedium.copyWith(
                                                              color: Colors.white70,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Edit button
                                      Positioned(
                                        top: 16,
                                        right: 16,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.1),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.edit, color: AppTheme.primaryBlue),
                                            onPressed: () => _showEditProfileDialog(context, profile),
                                            tooltip: 'Edit Profile',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                // Bio Section
                                if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(AppTheme.paddingLarge),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                                      boxShadow: AppTheme.cardShadow,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: AppTheme.accent1.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                              ),
                                              child: const Icon(
                                                Icons.info_outline,
                                                color: AppTheme.accent1,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'About Me',
                                              style: AppTheme.titleMedium.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          profile.bio!,
                                          style: AppTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],

                                // Professional Info Card
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(AppTheme.paddingLarge),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                                    boxShadow: AppTheme.cardShadow,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppTheme.accent2.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                            ),
                                            child: const Icon(
                                              Icons.business_center,
                                              color: AppTheme.accent2,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Professional Information',
                                            style: AppTheme.titleMedium.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      
                                      // Professional info grid
                                      GridView.count(
                                        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        childAspectRatio: 3,
                                        children: [
                                          if (profile.preferences['company'] != null)
                                            _buildInfoCard(
                                              Icons.business,
                                              'Company',
                                              profile.preferences['company'],
                                              AppTheme.primaryBlue,
                                            ),
                                          if (profile.preferences['position'] != null)
                                            _buildInfoCard(
                                              Icons.work,
                                              'Position',
                                              profile.preferences['position'],
                                              AppTheme.accent1,
                                            ),
                                          if (profile.preferences['location'] != null)
                                            _buildInfoCard(
                                              Icons.location_on,
                                              'Location',
                                              profile.preferences['location'],
                                              AppTheme.accent2,
                                            ),
                                          if (profile.preferences['phone'] != null)
                                            _buildInfoCard(
                                              Icons.phone,
                                              'Phone',
                                              profile.preferences['phone'],
                                              AppTheme.accent3,
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Activity Stats Section
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(AppTheme.paddingLarge),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                                    boxShadow: AppTheme.cardShadow,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppTheme.accent4.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                            ),
                                            child: const Icon(
                                              Icons.insights,
                                              color: AppTheme.accent4,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Activity Stats',
                                            style: AppTheme.titleMedium.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      
                                      // Stats row
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildStatItem('Reports', '12', Icons.bar_chart),
                                          _buildStatItem('Field Logs', '28', Icons.note_alt),
                                          _buildStatItem('Certifications', '3', Icons.verified),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Settings Section
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                                    boxShadow: AppTheme.cardShadow,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(AppTheme.paddingLarge),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: AppTheme.accent5.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                              ),
                                              child: const Icon(
                                                Icons.settings,
                                                color: AppTheme.accent5,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Settings',
                                              style: AppTheme.titleMedium.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Divider(height: 1),
                                      
                                      // Settings options
                                      ListTile(
                                        leading: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryBlue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                          ),
                                          child: const Icon(Icons.edit, color: AppTheme.primaryBlue),
                                        ),
                                        title: const Text('Edit Profile'),
                                        subtitle: const Text('Update your personal information'),
                                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                        onTap: () => _showEditProfileDialog(context, profile),
                                      ),
                                      const Divider(height: 1),
                                      ListTile(
                                        leading: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.accent3.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                          ),
                                          child: const Icon(Icons.logout, color: AppTheme.accent3),
                                        ),
                                        title: const Text('Sign Out'),
                                        subtitle: const Text('Log out of your account'),
                                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                        onTap: () async {
                                          try {
                                            await _authService.signOut();
                                            if (mounted) {
                                              Navigator.of(context).pushReplacementNamed('/login');
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Error signing out: $e'),
                                                  backgroundColor: AppTheme.accent3,
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryBlue,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        Text(
          label,
          style: AppTheme.bodySmall,
        ),
      ],
    );
  }
  
  void _showImagePickerOptions(BuildContext context, UserProfile profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLarge)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: const Icon(Icons.photo_library, color: AppTheme.primaryBlue),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Change Profile Picture',
                    style: AppTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImagePickerOption(
                    context,
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () async {
                      Navigator.pop(context);
                      final XFile? image = await _imageService.pickImageFromGallery();
                      if (image != null && mounted) {
                        _uploadProfileImage(image, profile);
                      }
                    },
                  ),
                  _buildImagePickerOption(
                    context,
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () async {
                      Navigator.pop(context);
                      final XFile? photo = await _imageService.takePhoto();
                      if (photo != null && mounted) {
                        _uploadProfileImage(photo, profile);
                      }
                    },
                  ),
                  if (profile.photoUrl != null)
                    _buildImagePickerOption(
                      context,
                      icon: Icons.delete,
                      label: 'Remove',
                      color: AppTheme.accent3,
                      onTap: () async {
                        Navigator.pop(context);
                        _removeProfileImage(profile);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildImagePickerOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppTheme.primaryBlue,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _uploadProfileImage(XFile image, UserProfile profile) async {
    try {
      // Show loading indicator
      _showLoadingDialog('Uploading profile picture...');
      
      // Upload image to Firebase Storage
      final String? downloadUrl = await _imageService.uploadProfileImage(image, profile.userId);
      
      if (downloadUrl != null && mounted) {
        // Update profile with new photo URL
        await _profileService.updateProfileFields({
          'photoUrl': downloadUrl,
        });
        
        // Close loading dialog
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully'),
              backgroundColor: AppTheme.accent2,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // Close loading dialog
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
        
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload profile picture'),
              backgroundColor: AppTheme.accent3,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.accent3,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  
  Future<void> _removeProfileImage(UserProfile profile) async {
    try {
      if (profile.photoUrl == null) return;
      
      // Show loading indicator
      _showLoadingDialog('Removing profile picture...');
      
      // Delete image from Firebase Storage
      if (profile.photoUrl != null) {
        await _imageService.deleteImage(profile.photoUrl!);
      }
      
      // Update profile to remove photo URL
      await _profileService.updateProfileFields({
        'photoUrl': null,
      });
      
      // Close loading dialog
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture removed successfully'),
            backgroundColor: AppTheme.accent2,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.accent3,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  
  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(message),
            ],
          ),
        );
      },
    );
  }
}
