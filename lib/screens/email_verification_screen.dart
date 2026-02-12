import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../services/analytics_service.dart';
import '../theme/app_theme.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final AuthService _authService = AuthService();
  final AnalyticsService _analyticsService = AnalyticsService();
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  Timer? _verificationTimer;
  Timer? _resendCooldownTimer;
  int _resendCooldownSeconds = 0;
  bool _canResend = true;

  @override
  void initState() {
    super.initState();
    _startAutoVerificationCheck();
    _checkResendCooldown();
    _analyticsService.logEvent(name: 'email_verification_shown', parameters: {});
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    _resendCooldownTimer?.cancel();
    super.dispose();
  }

  /// Auto-check verification status every 5 seconds
  void _startAutoVerificationCheck() {
    _verificationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkVerificationStatus(silent: true);
    });
  }

  /// Check if user has verified email
  Future<void> _checkVerificationStatus({bool silent = false}) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      // Reload user data from Firebase
      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser != null && refreshedUser.emailVerified) {
        _verificationTimer?.cancel();
        _analyticsService.logEvent(name: 'email_verified_success', parameters: {});
        
        if (!silent) {
          setState(() {
            _successMessage = 'Email verified successfully!';
          });
        }

        // Navigate to main screen after short delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/');
        }
      } else if (!silent) {
        setState(() {
          _errorMessage = 'Email not verified yet. Please check your inbox and click the verification link.';
        });
      }
    } catch (e) {
      print('Error checking verification status: $e');
      if (!silent) {
        setState(() {
          _errorMessage = 'Error checking verification status. Please try again.';
        });
      }
    }
  }

  /// Send or resend verification email
  Future<void> _sendVerificationEmail() async {
    if (_resendCooldownSeconds > 0) {
      setState(() {
        _errorMessage = 'Please wait $_resendCooldownSeconds seconds before resending.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _authService.sendEmailVerification();
      
      setState(() {
        _successMessage = 'Verification email sent! Please check your inbox.';
        _canResend = false;
        _resendCooldownSeconds = 60;
      });

      // Save timestamp to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_verification_email_sent', DateTime.now().millisecondsSinceEpoch);

      // Start 60-second cooldown timer
      _startResendCooldown();

      _analyticsService.logEvent(name: 'email_verification_resent', parameters: {});
    } catch (e) {
      print('Error sending verification email: $e');
      String errorMessage = 'Failed to send verification email';
      
      if (e.toString().contains('too-many-requests')) {
        errorMessage = 'Too many requests. Please try again later.';
      } else if (e.toString().contains('network-request-failed')) {
        errorMessage = 'Network error. Please check your connection.';
      }
      
      setState(() {
        _errorMessage = errorMessage;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Check if user is in cooldown period from previous email send
  Future<void> _checkResendCooldown() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSent = prefs.getInt('last_verification_email_sent');
    
    if (lastSent != null) {
      final lastSentTime = DateTime.fromMillisecondsSinceEpoch(lastSent);
      final difference = DateTime.now().difference(lastSentTime);
      
      if (difference.inSeconds < 60) {
        final remaining = 60 - difference.inSeconds;
        setState(() {
          _resendCooldownSeconds = remaining;
          _canResend = false;
        });
        _startResendCooldown();
      }
    }
  }

  /// Start countdown timer for resend button
  void _startResendCooldown() {
    _resendCooldownTimer?.cancel();
    _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendCooldownSeconds--;
        if (_resendCooldownSeconds <= 0) {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  /// Sign out and return to login
  Future<void> _signOutAndReturn() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final userEmail = user?.email ?? 'your email';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _signOutAndReturn,
            child: Text(
              'Sign Out',
              style: TextStyle(color: AppTheme.primaryBlue),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 500,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 40,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Email icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.email_outlined,
                    size: 50,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Check Your Email',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  'We sent a verification link to:',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // User email
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Instructions
                Text(
                  'Click the link in the email to verify your account. The link will expire in 1 hour.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Success message
                if (_successMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.green.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _successMessage!,
                            style: TextStyle(color: Colors.green.shade700, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Error message
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Resend email button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _canResend ? AppTheme.primaryBlue : Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      foregroundColor: _canResend ? AppTheme.primaryBlue : Colors.grey,
                    ),
                    onPressed: (_isLoading || !_canResend) ? null : _sendVerificationEmail,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                      _resendCooldownSeconds > 0
                          ? 'Resend in $_resendCooldownSeconds seconds'
                          : 'Resend Verification Email',
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Check verification button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : () => _checkVerificationStatus(silent: false),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('I\'ve Verified My Email'),
                  ),
                ),
                const SizedBox(height: 24),

                // Info banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Didn\'t receive the email?',
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• Check your spam/junk folder\n'
                              '• Make sure the email address is correct\n'
                              '• Wait a few minutes for the email to arrive\n'
                              '• Click "Resend" to get a new link',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
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
}
