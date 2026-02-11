import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import '../theme/app_theme.dart';

/// Dialog showing platform-specific PWA install instructions for mobile devices
class MobileInstallDialog extends StatefulWidget {
  const MobileInstallDialog({Key? key}) : super(key: key);

  @override
  State<MobileInstallDialog> createState() => _MobileInstallDialogState();

  /// Show the dialog if on mobile and not already installed/dismissed
  static void showIfNeeded(BuildContext context) {
    if (!kIsWeb) return;

    // Check if already dismissed
    final dismissed = html.window.localStorage['mobile_install_dismissed'];
    if (dismissed == 'true') return;

    // Check if already installed (running in standalone mode)
    final isStandalone = html.window.matchMedia('(display-mode: standalone)').matches;
    if (isStandalone) return;

    // Check if on mobile
    if (_isMobile()) {
      // Show after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => const MobileInstallDialog(),
          );
        }
      });
    }
  }

  static bool _isMobile() {
    if (!kIsWeb) return false;
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    return userAgent.contains('mobile') || 
           userAgent.contains('android') || 
           userAgent.contains('iphone') || 
           userAgent.contains('ipad');
  }
}

class _MobileInstallDialogState extends State<MobileInstallDialog> {
  String _platform = 'unknown';
  String _browser = 'unknown';

  @override
  void initState() {
    super.initState();
    _detectPlatform();
  }

  void _detectPlatform() {
    if (!kIsWeb) return;

    final userAgent = html.window.navigator.userAgent.toLowerCase();
    
    // Detect platform
    if (userAgent.contains('iphone') || userAgent.contains('ipad')) {
      _platform = 'ios';
    } else if (userAgent.contains('android')) {
      _platform = 'android';
    }

    // Detect browser
    if (userAgent.contains('crios')) {
      _browser = 'chrome-ios'; // Chrome on iOS
    } else if (userAgent.contains('safari') && !userAgent.contains('chrome')) {
      _browser = 'safari';
    } else if (userAgent.contains('chrome')) {
      _browser = 'chrome';
    }

    setState(() {});
  }

  void _dismiss() {
    if (kIsWeb) {
      html.window.localStorage['mobile_install_dismissed'] = 'true';
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.install_mobile,
                    color: AppTheme.primaryBlue,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Install App',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Get faster access & offline mode',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Platform-specific instructions
            _buildInstructions(),
            
            const SizedBox(height: 24),
            
            // Benefits
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Benefits:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildBenefit(Icons.flash_on, '30-50% faster load times'),
                  _buildBenefit(Icons.offline_bolt, 'Works offline'),
                  _buildBenefit(Icons.home_outlined, 'One-tap access from home screen'),
                  _buildBenefit(Icons.update, 'Automatic updates'),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _dismiss,
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Maybe Later'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _dismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Got it!'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    if (_platform == 'ios' && (_browser == 'safari' || _browser == 'chrome-ios')) {
      // iOS (Safari or Chrome - both use same method)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How to install on iOS:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 12),
          _buildStep(
            1,
            'Tap the Share button',
            Icons.ios_share,
            'Located at the bottom center of Safari',
          ),
          _buildStep(
            2,
            'Scroll down and tap',
            Icons.add_box_outlined,
            '"Add to Home Screen"',
          ),
          _buildStep(
            3,
            'Tap "Add" in the top right',
            Icons.check_circle_outline,
            'The app icon will appear on your home screen',
          ),
        ],
      );
    } else if (_platform == 'android' && _browser == 'chrome') {
      // Android Chrome
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How to install on Android:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 12),
          _buildStep(
            1,
            'Tap the menu icon',
            Icons.more_vert,
            'Three dots in the top right corner',
          ),
          _buildStep(
            2,
            'Select "Install app" or',
            Icons.add_to_home_screen,
            '"Add to Home screen"',
          ),
          _buildStep(
            3,
            'Tap "Install" to confirm',
            Icons.check_circle_outline,
            'The app will appear on your home screen',
          ),
        ],
      );
    } else {
      // Generic instructions
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How to install:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 12),
          _buildStep(
            1,
            'Look for the install option',
            Icons.install_mobile,
            'In your browser menu or address bar',
          ),
          _buildStep(
            2,
            'Tap "Install" or "Add to Home Screen"',
            Icons.add_to_home_screen,
            'Follow the prompts',
          ),
          _buildStep(
            3,
            'Open from your home screen',
            Icons.check_circle_outline,
            'App will open in full-screen mode',
          ),
        ],
      );
    }
  }

  Widget _buildStep(int number, String title, IconData icon, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number circle
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: AppTheme.primaryBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
