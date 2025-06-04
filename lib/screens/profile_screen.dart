import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../models/user_profile.dart';
import '../widgets/app_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _positionController.dispose();
    _locationController.dispose();
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
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  hintText: 'Enter your display name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Tell us about yourself',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Company',
                  hintText: 'Enter your company name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _positionController,
                decoration: const InputDecoration(
                  labelText: 'Position',
                  hintText: 'Enter your job position',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Enter your location',
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
          ElevatedButton(
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
                    const SnackBar(content: Text('Profile updated successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating profile: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: StreamBuilder<UserProfile?>(
          stream: _profileService.getCurrentProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final profile = snapshot.data;
            if (profile == null) {
              return const Center(
                child: Text('No profile data available'),
              );
            }

            return Column(
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
                        // Profile Header
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
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
                              const SizedBox(height: 16),
                              Text(
                                profile.displayName ?? 'No Name Set',
                                style: AppTheme.headlineMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile.email,
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  profile.bio!,
                                  style: AppTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Professional Info Card
                        Card(
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
                                Text('Professional Information', style: AppTheme.titleLarge),
                                const SizedBox(height: 16),
                                if (profile.preferences['company'] != null) ...[
                                  _buildInfoRow(Icons.business, profile.preferences['company'], 'Company'),
                                  const SizedBox(height: 12),
                                ],
                                if (profile.preferences['position'] != null) ...[
                                  _buildInfoRow(Icons.work, profile.preferences['position'], 'Position'),
                                  const SizedBox(height: 12),
                                ],
                                if (profile.preferences['location'] != null) ...[
                                  _buildInfoRow(Icons.location_on, profile.preferences['location'], 'Location'),
                                  const SizedBox(height: 12),
                                ],
                                if (profile.preferences['phone'] != null) ...[
                                  _buildInfoRow(Icons.phone, profile.preferences['phone'], 'Phone'),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Settings Section
                        Text('Settings', style: AppTheme.titleLarge),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                            side: const BorderSide(color: AppTheme.divider),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.edit),
                                title: const Text('Edit Profile'),
                                onTap: () => _showEditProfileDialog(context, profile),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.logout),
                                title: const Text('Sign Out'),
                                onTap: () async {
                                  try {
                                    await _authService.signOut();
                                    if (mounted) {
                                      Navigator.of(context).pushReplacementNamed('/login');
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error signing out: $e')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String value, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTheme.titleMedium),
              Text(
                label,
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 