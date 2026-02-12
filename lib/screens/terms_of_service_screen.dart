import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Terms of Service'),
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

            // Acceptance of Terms
            _buildSection(
              '1. Acceptance of Terms',
              'By accessing or using the NDT-ToolKit mobile and web application ("Service"), you agree to be bound by these Terms of Service ("Terms"). If you do not agree to these Terms, do not use the Service. You must be at least 18 years old or have authorization from your employer to use this Service.',
            ),

            // Description of Service
            _buildSection(
              '2. Description of Service',
              'NDT-ToolKit is a professional application for pipeline inspection and Non-Destructive Testing (NDT). The Service includes:',
            ),
            _buildBulletPoint('NDT calculation tools (B31G, pit depth, wall loss, etc.)'),
            _buildBulletPoint('Inspection report creation and management'),
            _buildBulletPoint('AI-powered defect analysis using Google Vertex AI (Gemini)'),
            _buildBulletPoint('Photo-based defect identification'),
            _buildBulletPoint('Method hours tracking and Excel export'),
            _buildBulletPoint('Knowledge base and reference materials'),
            _buildBulletPoint('Company directory and professional tools'),
            const SizedBox(height: 8),
            _buildNote(
              'The Service is provided "as is" with no guarantees of accuracy. We reserve the right to modify, suspend, or discontinue any features at any time without notice.',
            ),
            const SizedBox(height: 16),

            // User Accounts
            _buildSection(
              '3. User Accounts',
              'To use most features of the Service, you must create an account:',
            ),
            _buildBulletPoint('You must provide a valid email address and accurate information'),
            _buildBulletPoint('You are responsible for maintaining the confidentiality of your password'),
            _buildBulletPoint('You are responsible for all activities that occur under your account'),
            _buildBulletPoint('Account sharing is prohibited'),
            _buildBulletPoint('We reserve the right to terminate accounts that violate these Terms'),
            _buildBulletPoint('You must notify us immediately of any unauthorized use of your account'),
            const SizedBox(height: 16),

            // Acceptable Use Policy
            _buildSection(
              '4. Acceptable Use Policy',
              'You agree to use the Service only for lawful, professional purposes related to pipeline inspection. You agree NOT to:',
            ),
            _buildBulletPoint('Use the Service for any illegal purpose or in violation of regulations'),
            _buildBulletPoint('Attempt to hack, reverse engineer, or compromise the Service security'),
            _buildBulletPoint('Upload malicious code, viruses, or harmful content'),
            _buildBulletPoint('Misrepresent your credentials, qualifications, or employment'),
            _buildBulletPoint('Share confidential company information without authorization'),
            _buildBulletPoint('Harass, abuse, or harm other users'),
            _buildBulletPoint('Use the Service to compete with NDT-ToolKit'),
            _buildBulletPoint('Scrape, data mine, or extract data using automated means'),
            const SizedBox(height: 16),

            // User-Generated Content
            _buildSection(
              '5. User-Generated Content',
              'You retain ownership of your inspection reports, defect data, photos, and other content you create ("User Content"):',
            ),
            _buildBulletPoint('You grant us a license to store, display, and process your User Content to provide the Service'),
            _buildBulletPoint('You are responsible for the accuracy of all data you enter'),
            _buildBulletPoint('We are not liable for incorrect calculations based on inaccurate input data'),
            _buildBulletPoint('We are not liable for data loss, though we implement regular backups'),
            _buildBulletPoint('You must not upload copyrighted material without proper authorization'),
            _buildBulletPoint('Your employer may have access to User Content you create if you are their employee'),
            const SizedBox(height: 16),

            // Professional Responsibility
            _buildSection(
              '6. Professional Responsibility',
              'CRITICAL: The tools provided are calculation aids only and NOT a replacement for professional judgment:',
            ),
            _buildBulletPoint('YOU are responsible for verifying all calculations independently before use in critical applications'),
            _buildBulletPoint('AI-powered defect analysis provides recommendations only - final decisions are YOUR responsibility'),
            _buildBulletPoint('You must comply with all applicable industry standards (ASME, API, B31G, etc.)'),
            _buildBulletPoint('You must hold appropriate certifications and qualifications for your work'),
            _buildBulletPoint('We are NOT liable for decisions made based on tool outputs'),
            _buildBulletPoint('Field conditions may differ from calculation assumptions - use engineering judgment'),
            const SizedBox(height: 8),
            _buildWarning(
              'The Service does not replace qualified inspection personnel or engineering analysis. Always consult with qualified engineers for critical decisions.',
            ),
            const SizedBox(height: 16),

            // Intellectual Property
            _buildSection(
              '7. Intellectual Property',
              'The Service and all its content (excluding your User Content) are owned by NDT-ToolKit:',
            ),
            _buildBulletPoint('All trademarks, logos, and service marks are our property'),
            _buildBulletPoint('You may not reproduce, distribute, or create derivative works without written permission'),
            _buildBulletPoint('Calculator algorithms and formulas are protected intellectual property'),
            _buildBulletPoint('You may use the Service for your professional work but not resell or redistribute it'),
            const SizedBox(height: 16),

            // Limitation of Liability
            _buildSection(
              '8. Limitation of Liability',
              'TO THE MAXIMUM EXTENT PERMITTED BY LAW, NDT-TOOLKIT IS NOT LIABLE FOR:',
            ),
            _buildBulletPoint('Calculation errors or inaccuracies in any tool or feature'),
            _buildBulletPoint('Data loss, corruption, or unauthorized access'),
            _buildBulletPoint('Service interruptions, downtime, or unavailability'),
            _buildBulletPoint('Decisions made based on tool outputs or AI recommendations'),
            _buildBulletPoint('Third-party service failures (Firebase, Google Cloud, Vertex AI)'),
            _buildBulletPoint('Indirect, incidental, consequential, or punitive damages'),
            _buildBulletPoint('Loss of profits, revenue, data, or business opportunities'),
            const SizedBox(height: 8),
            _buildNote(
              'Our maximum liability to you for any claims is limited to the fees you paid (if any) in the 12 months preceding the claim. Some jurisdictions do not allow limitation of liability, so these limits may not apply to you.',
            ),
            const SizedBox(height: 16),

            // Disclaimer of Warranties
            _buildSection(
              '9. Disclaimer of Warranties',
              'THE SERVICE IS PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT WARRANTIES OF ANY KIND:',
            ),
            _buildBulletPoint('We make NO warranty regarding accuracy, reliability, or fitness for any particular purpose'),
            _buildBulletPoint('We do NOT guarantee uninterrupted or error-free operation'),
            _buildBulletPoint('We do NOT guarantee that defects will be corrected'),
            _buildBulletPoint('AI analysis results may contain errors or be incomplete'),
            _buildBulletPoint('Calculations may not account for all real-world variables'),
            const SizedBox(height: 8),
            _buildWarning(
              'YOU ASSUME ALL RISK ASSOCIATED WITH USING THE SERVICE AND RELYING ON ITS OUTPUTS.',
            ),
            const SizedBox(height: 16),

            // Indemnification
            _buildSection(
              '10. Indemnification',
              'You agree to indemnify, defend, and hold harmless NDT-ToolKit, its officers, employees, and agents from any claims, damages, or expenses arising from:',
            ),
            _buildBulletPoint('Your violation of these Terms of Service'),
            _buildBulletPoint('Your violation of any laws or regulations'),
            _buildBulletPoint('Your negligence or professional misconduct'),
            _buildBulletPoint('Your misuse of calculation outputs or AI recommendations'),
            _buildBulletPoint('Your infringement of any third-party rights'),
            _buildBulletPoint('Your User Content or activities using the Service'),
            const SizedBox(height: 16),

            // Data and Privacy
            _buildSection(
              '11. Data and Privacy',
              'Your use of the Service is also governed by our Privacy Policy:',
            ),
            _buildBulletPoint('We store your data on Firebase (Google Cloud Platform) servers in the United States'),
            _buildBulletPoint('AI analysis uses Google Vertex AI and processes your submitted defect data and photos'),
            _buildBulletPoint('We may access your data for technical support and service improvement'),
            _buildBulletPoint('Data backups are performed regularly but are not guaranteed'),
            _buildBulletPoint('You are responsible for maintaining your own backups of critical data'),
            const SizedBox(height: 8),
            _buildNote(
              'Please review our Privacy Policy for complete details on data collection, use, and protection.',
            ),
            const SizedBox(height: 16),

            // Termination
            _buildSection(
              '12. Termination',
              'We reserve the right to suspend or terminate your account at any time for:',
            ),
            _buildBulletPoint('Violation of these Terms of Service'),
            _buildBulletPoint('Fraudulent, abusive, or illegal activity'),
            _buildBulletPoint('Extended periods of inactivity'),
            _buildBulletPoint('At our discretion for any reason with notice'),
            const SizedBox(height: 8),
            Text(
              'You may delete your account at any time from the Profile screen. Upon termination:',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            _buildBulletPoint('Your access to the Service will be immediately revoked'),
            _buildBulletPoint('Your User Content will be deleted within 30 days'),
            _buildBulletPoint('Backup copies may persist for up to 90 days'),
            _buildBulletPoint('Some anonymized usage data may be retained for analytics'),
            const SizedBox(height: 16),

            // Governing Law and Dispute Resolution
            _buildSection(
              '13. Governing Law and Dispute Resolution',
              'These Terms are governed by the laws of the State of Texas, United States, without regard to conflict of law principles:',
            ),
            _buildBulletPoint('Any disputes shall be resolved in the state or federal courts located in Texas'),
            _buildBulletPoint('You consent to the personal jurisdiction of these courts'),
            _buildBulletPoint('You waive any objection to venue in these courts'),
            _buildBulletPoint('If any provision of these Terms is found unenforceable, the remaining provisions remain valid'),
            const SizedBox(height: 16),

            // Contact Information
            _buildSection(
              '14. Contact Information',
              'For questions about these Terms of Service, technical support, or to report violations, contact us:',
            ),
            _buildContactInfo('Email', 'ndt-toolkit-support@gmail.com'),
            _buildContactInfo('Company', 'NDT-ToolKit'),
            const SizedBox(height: 16),

            // Severability
            _buildSection(
              '15. Severability',
              'If any provision of these Terms is held to be invalid, illegal, or unenforceable, the remaining provisions shall continue in full force and effect. The invalid provision shall be modified to the minimum extent necessary to make it valid and enforceable.',
            ),

            // Entire Agreement
            _buildSection(
              '16. Entire Agreement',
              'These Terms of Service, together with our Privacy Policy, constitute the entire agreement between you and NDT-ToolKit regarding the Service. These Terms supersede any prior agreements or understandings. We may update these Terms from time to time - continued use after changes constitutes acceptance.',
            ),

            const SizedBox(height: 32),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.verified_user,
                    color: AppTheme.primaryBlue,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'By creating an account, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service.',
                    style: AppTheme.bodyMedium.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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

  Widget _buildNote(String text) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodySmall.copyWith(color: Colors.blue.shade900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarning(String text) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodySmall.copyWith(
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w600,
              ),
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
