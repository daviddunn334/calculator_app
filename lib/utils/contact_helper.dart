import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/analytics_service.dart';

/// Helper class for launching contact actions (phone, email, SMS)
class ContactHelper {
  /// Launch phone dialer with the given phone number
  /// Formats: tel:+1234567890
  static Future<void> launchPhone(BuildContext context, String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      _showErrorSnackBar(context, 'No phone number available');
      return;
    }

    // Clean phone number (remove spaces, dashes, parentheses)
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final Uri phoneUri = Uri.parse('tel:$cleanedNumber');

    try {
      final canLaunch = await canLaunchUrl(phoneUri);
      if (canLaunch) {
        await launchUrl(phoneUri);
        // Log analytics event
        AnalyticsService().logContactAction('call', 'phone');
      } else {
        _showErrorSnackBar(context, 'Cannot open phone dialer on this device');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Error launching phone: $e');
    }
  }

  /// Launch email client with the given email address
  /// Optionally include subject and body
  /// Formats: mailto:user@example.com?subject=Hello&body=Message
  static Future<void> launchEmail(
    BuildContext context,
    String email, {
    String? subject,
    String? body,
  }) async {
    if (email.isEmpty) {
      _showErrorSnackBar(context, 'No email address available');
      return;
    }

    // Build mailto URI with optional parameters
    String mailtoString = 'mailto:$email';
    final List<String> params = [];
    
    if (subject != null && subject.isNotEmpty) {
      params.add('subject=${Uri.encodeComponent(subject)}');
    }
    
    if (body != null && body.isNotEmpty) {
      params.add('body=${Uri.encodeComponent(body)}');
    }
    
    if (params.isNotEmpty) {
      mailtoString += '?${params.join('&')}';
    }

    final Uri emailUri = Uri.parse(mailtoString);

    try {
      final canLaunch = await canLaunchUrl(emailUri);
      if (canLaunch) {
        await launchUrl(emailUri);
        // Log analytics event
        AnalyticsService().logContactAction('email', 'mailto');
      } else {
        _showErrorSnackBar(context, 'Cannot open email client on this device');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Error launching email: $e');
    }
  }

  /// Launch SMS app with the given phone number
  /// Formats: sms:+1234567890
  static Future<void> launchSMS(BuildContext context, String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      _showErrorSnackBar(context, 'No phone number available');
      return;
    }

    // Clean phone number
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final Uri smsUri = Uri.parse('sms:$cleanedNumber');

    try {
      final canLaunch = await canLaunchUrl(smsUri);
      if (canLaunch) {
        await launchUrl(smsUri);
      } else {
        _showErrorSnackBar(context, 'Cannot open SMS app on this device');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Error launching SMS: $e');
    }
  }

  /// Format phone number for display
  /// Example: 1234567890 -> (123) 456-7890
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length == 10) {
      // Format as (XXX) XXX-XXXX
      return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
    } else if (digitsOnly.length == 11 && digitsOnly.startsWith('1')) {
      // Format as +1 (XXX) XXX-XXXX
      return '+1 (${digitsOnly.substring(1, 4)}) ${digitsOnly.substring(4, 7)}-${digitsOnly.substring(7)}';
    }
    
    // Return original if not a standard format
    return phoneNumber;
  }

  /// Show error snackbar
  static void _showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
      ),
    );
  }
}
