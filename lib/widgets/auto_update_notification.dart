import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/update_service.dart';

/// Aggressive auto-update notification that shows countdown and auto-reloads
/// Non-dismissible to ensure all users stay on latest version
class AutoUpdateNotification extends StatefulWidget {
  final String version;

  const AutoUpdateNotification({
    Key? key,
    required this.version,
  }) : super(key: key);

  @override
  State<AutoUpdateNotification> createState() => _AutoUpdateNotificationState();
}

class _AutoUpdateNotificationState extends State<AutoUpdateNotification> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  int _countdown = 3;
  Timer? _countdownTimer;
  final UpdateService _updateService = UpdateService();

  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    
    // Start animation
    _controller.forward();
    
    // Start countdown
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });
      
      if (_countdown <= 0) {
        timer.cancel();
        _applyUpdate();
      }
    });
  }

  Future<void> _applyUpdate() async {
    // Apply update immediately (no delay, we already counted down)
    await _updateService.applyUpdate(immediate: true);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          elevation: 8,
          color: AppTheme.primaryBlue,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Pulsing update icon
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(seconds: 1),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 1.0 + (value * 0.2),
                      child: Icon(
                        Icons.system_update,
                        color: Colors.white,
                        size: 28,
                      ),
                    );
                  },
                  onEnd: () {
                    // Restart animation
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
                const SizedBox(width: 16),
                
                // Update message
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Updating App',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'New version available (${widget.version})',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Countdown circle
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$_countdown',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'sec',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Update now button (optional - allows skipping countdown)
                ElevatedButton(
                  onPressed: () {
                    _countdownTimer?.cancel();
                    _applyUpdate();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Update Now',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Overlay that shows the auto-update notification at the top of the screen
class AutoUpdateOverlay extends StatelessWidget {
  final String version;

  const AutoUpdateOverlay({
    Key? key,
    required this.version,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: AutoUpdateNotification(version: version),
      ),
    );
  }
}
