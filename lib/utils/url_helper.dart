import 'package:url_launcher/url_launcher.dart';

class UrlHelper {
  // Open Terms of Service in external browser
  static Future<void> openTermsOfService() async {
    const url = 'https://integrity-tools.web.app/terms-of-service.html';
    final uri = Uri.parse(url);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching Terms of Service URL: $e');
    }
  }

  // Open Privacy Policy in external browser
  static Future<void> openPrivacyPolicy() async {
    const url = 'https://integrity-tools.web.app/privacy-policy.html';
    final uri = Uri.parse(url);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching Privacy Policy URL: $e');
    }
  }

  // Open company website
  static Future<void> openCompanyWebsite() async {
    const url = 'https://www.integrityspecialists.com';
    final uri = Uri.parse(url);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching company website: $e');
    }
  }

  // Open email client
  static Future<void> openSupportEmail() async {
    const email = 'integrity-tools-support@gmail.com';
    final uri = Uri.parse('mailto:$email?subject=Integrity Tools Support');
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch email client';
      }
    } catch (e) {
      print('Error launching email client: $e');
    }
  }
}
