import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Last Updated
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: AppTheme.primaryBlue, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Last Updated: February 12, 2026',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),

            // Introduction
            _buildSection(
              'Introduction',
              'Integrity Specialists ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use the Integrity Tools mobile and web application.',
            ),

            // Information We Collect
            _buildSection(
              '1. Information We Collect',
              'We collect information that you provide directly to us:',
            ),
            _buildBulletPoint('Account Information: Email address, name, and password'),
            _buildBulletPoint('Profile Information: Display name, bio, phone number, company, position, location, and profile photo'),
            _buildBulletPoint('Inspection Data: Reports, field logs, method hours entries, defect analysis data, and photos'),
            _buildBulletPoint('User-Generated Content: Notes, calculations, locations, and certifications'),
            _buildBulletPoint('Device Information: Device type, operating system, browser information, and app version'),
            _buildBulletPoint('Usage Data: Features used, screen views, navigation patterns, and performance metrics'),
            const SizedBox(height: 16),

            // How We Use Your Information
            _buildSection(
              '2. How We Use Your Information',
              'We use the information we collect to:',
            ),
            _buildBulletPoint('Provide, maintain, and improve the Integrity Tools application'),
            _buildBulletPoint('Process and store your inspection reports and calculations'),
            _buildBulletPoint('Enable AI-powered defect analysis and photo identification features'),
            _buildBulletPoint('Authenticate your account and ensure security'),
            _buildBulletPoint('Send you technical notices and support messages'),
            _buildBulletPoint('Respond to your feedback and support requests'),
            _buildBulletPoint('Monitor and analyze usage patterns to improve performance'),
            _buildBulletPoint('Comply with legal obligations and enforce our terms'),
            const SizedBox(height: 16),

            // Data Storage and Security
            _buildSection(
              '3. Data Storage and Security',
              'Your data is stored securely using Firebase services (Google Cloud Platform):',
            ),
            _buildBulletPoint('Data is stored on servers located in the United States'),
            _buildBulletPoint('We use industry-standard encryption for data transmission (HTTPS/TLS)'),
            _buildBulletPoint('Firebase Authentication provides secure user authentication'),
            _buildBulletPoint('Access to your data is restricted to authorized personnel only'),
            _buildBulletPoint('We implement regular security audits and updates'),
            _buildBulletPoint('However, no method of transmission or storage is 100% secure'),
            const SizedBox(height: 16),

            // Data Sharing and Disclosure
            _buildSection(
              '4. Data Sharing and Disclosure',
              'We do not sell your personal information. We may share your information only in these circumstances:',
            ),
            _buildBulletPoint('With your employer: If you are using the app as an employee of a company, your company may have access to inspection reports and data you create'),
            _buildBulletPoint('Service Providers: We use Google Firebase/Cloud services to host and process data'),
            _buildBulletPoint('AI Processing: Defect analysis uses Google Vertex AI (Gemini) with your submitted defect data and photos'),
            _buildBulletPoint('Legal Requirements: When required by law or to protect our rights'),
            _buildBulletPoint('Business Transfers: In connection with a merger, sale, or acquisition'),
            const SizedBox(height: 16),

            // Your Data Rights
            _buildSection(
              '5. Your Data Rights',
              'You have the following rights regarding your personal information:',
            ),
            _buildBulletPoint('Access: View and export your data from within the app'),
            _buildBulletPoint('Correction: Update your profile and information at any time'),
            _buildBulletPoint('Deletion: Delete your account and associated data (some data may be retained for legal compliance)'),
            _buildBulletPoint('Portability: Export your inspection reports and data'),
            _buildBulletPoint('Opt-Out: Disable certain features like analytics tracking'),
            const SizedBox(height: 16),

            // Data Retention
            _buildSection(
              '6. Data Retention',
              'We retain your information for as long as your account is active or as needed to provide services. When you delete your account:',
            ),
            _buildBulletPoint('Personal profile data is deleted immediately'),
            _buildBulletPoint('Inspection reports and user-generated content are deleted within 30 days'),
            _buildBulletPoint('Some aggregated, anonymized data may be retained for analytics'),
            _buildBulletPoint('Backups may retain data for up to 90 days'),
            const SizedBox(height: 16),

            // Cookies and Tracking
            _buildSection(
              '7. Cookies and Tracking Technologies',
              'We use the following technologies:',
            ),
            _buildBulletPoint('Local Storage: To enable offline functionality and cache calculator tools'),
            _buildBulletPoint('Firebase Analytics: To track app usage and performance (can be disabled)'),
            _buildBulletPoint('Service Worker: To enable progressive web app (PWA) features'),
            _buildBulletPoint('Authentication Tokens: To maintain your logged-in session'),
            const SizedBox(height: 16),

            // Children's Privacy
            _buildSection(
              '8. Children\'s Privacy',
              'The Integrity Tools app is intended for professional use by adults. We do not knowingly collect information from children under 18. If you are under 18, you must have authorization from your employer to use this app.',
            ),

            // International Users
            _buildSection(
              '9. International Users',
              'Your information may be transferred to and processed in the United States. By using Integrity Tools, you consent to the transfer of your information to the United States and acknowledge that data protection laws may differ from those in your country.',
            ),

            // Changes to This Privacy Policy
            _buildSection(
              '10. Changes to This Privacy Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any changes by:',
            ),
            _buildBulletPoint('Posting the new Privacy Policy in the app'),
            _buildBulletPoint('Updating the "Last Updated" date at the top'),
            _buildBulletPoint('Sending an email notification for material changes (if applicable)'),
            _buildBulletPoint('Requiring re-acceptance for significant changes'),
            const SizedBox(height: 16),

            // Contact Us
            _buildSection(
              '11. Contact Us',
              'If you have any questions or concerns about this Privacy Policy, please contact us:',
            ),
            _buildContactInfo('Email', 'integrity-tools-support@gmail.com'),
            _buildContactInfo('Company', 'Integrity Specialists'),
            _buildContactInfo('Website', 'www.integrityspecialists.com'),
            const SizedBox(height: 32),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Text(
                'By using Integrity Tools, you acknowledge that you have read and understood this Privacy Policy.',
                style: AppTheme.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: AppTheme.bodyMedium),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
