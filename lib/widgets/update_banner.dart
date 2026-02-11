import 'package:flutter/material.dart';
import '../services/update_service.dart';
import '../services/analytics_service.dart';

/// Banner widget that displays when a PWA update is available
/// Shows a persistent Material banner with options to update or dismiss
class UpdateBanner extends StatefulWidget {
  const UpdateBanner({super.key});

  @override
  State<UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends State<UpdateBanner> {
  final _updateService = UpdateService();
  bool _updateAvailable = false;
  String? _newVersion;

  @override
  void initState() {
    super.initState();
    _listenForUpdates();
  }

  void _listenForUpdates() {
    _updateService.updateAvailableStream.listen((version) {
      if (mounted) {
        setState(() {
          _updateAvailable = true;
          _newVersion = version;
        });
        
        // Log analytics event
        AnalyticsService().logEvent(
          name: 'pwa_update_detected',
          parameters: {'version': version},
        );
        
        _showUpdateBanner();
      }
    });
  }

  void _showUpdateBanner() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        backgroundColor: const Color(0xFF1b325b),
        leading: const Icon(
          Icons.system_update,
          color: Color(0xFFfbcd0f),
          size: 32,
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Update Available',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'A new version of Integrity Tools is ready ($_newVersion)',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _dismissUpdate,
            child: const Text(
              'Later',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: _applyUpdate,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFfbcd0f),
              foregroundColor: const Color(0xFF1b325b),
              elevation: 0,
            ),
            child: const Text(
              'Update Now',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _dismissUpdate() {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    
    setState(() {
      _updateAvailable = false;
    });
    
    // Log analytics event
    AnalyticsService().logEvent(
      name: 'pwa_update_dismissed',
      parameters: {'version': _newVersion ?? 'unknown'},
    );
  }

  void _applyUpdate() async {
    if (!mounted) return;
    
    // Log analytics event
    AnalyticsService().logEvent(
      name: 'pwa_update_applied',
      parameters: {'version': _newVersion ?? 'unknown'},
    );
    
    // Show loading indicator
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 16),
            Text('Updating app...'),
          ],
        ),
        duration: Duration(seconds: 3),
        backgroundColor: Color(0xFF1b325b),
      ),
    );
    
    // Wait a moment for user to see the message
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Apply the update (reloads the page)
    await _updateService.applyUpdate();
  }

  @override
  Widget build(BuildContext context) {
    // This widget doesn't render anything directly
    // It manages the MaterialBanner through ScaffoldMessenger
    return const SizedBox.shrink();
  }
}
