import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../theme/app_theme.dart';

class NDTProceduresScreen extends StatefulWidget {
  const NDTProceduresScreen({super.key});

  @override
  State<NDTProceduresScreen> createState() => _NDTProceduresScreenState();
}

class _NDTProceduresScreenState extends State<NDTProceduresScreen> {
  final List<String> _companies = ['boardwalk', 'integrity', 'williams', 'southernstar'];
  String? _selectedCompany;
  List<String> _pdfFiles = [];
  bool _isLoading = false;

  Future<void> _loadPdfFiles(String company) async {
    setState(() {
      _isLoading = true;
      _pdfFiles = [];
    });

    try {
      final storage = FirebaseStorage.instance;
      final folderRef = storage.ref('procedures/$company');
      final result = await folderRef.listAll();
      
      setState(() {
        _pdfFiles = result.items.map((item) => item.name).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading PDFs. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String> _getPdfUrl(String company, String filename) async {
    final ref = FirebaseStorage.instance.ref('procedures/$company/$filename');
    return await ref.getDownloadURL();
  }

  void _openPdfViewer(String filename) async {
    try {
      final url = await _getPdfUrl(_selectedCompany!, filename);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: Text(filename),
                backgroundColor: AppTheme.background,
                foregroundColor: AppTheme.textPrimary,
              ),
              body: SfPdfViewer.network(url),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading PDF. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCompanyCard(String company) {
    final isSelected = _selectedCompany == company;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryBlue : AppTheme.divider,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCompany = company;
          });
          _loadPdfFiles(company);
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          child: Row(
            children: [
              Icon(
                Icons.folder,
                color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  company.toUpperCase(),
                  style: AppTheme.titleLarge.copyWith(
                    color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryBlue,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPdfCard(String filename) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: const BorderSide(color: AppTheme.divider),
      ),
      child: InkWell(
        onTap: () => _openPdfViewer(filename),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, color: AppTheme.primaryBlue, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  filename,
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('NDT Procedures & Standards'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.paddingMedium),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      ),
                      child: Icon(Icons.science, size: 40, color: AppTheme.primaryBlue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Company Procedures',
                            style: AppTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Official NDT procedures and standards',
                            style: AppTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Company Selection
                Text(
                  'Select Company',
                  style: AppTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ..._companies.map((company) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCompanyCard(company),
                )),
                
                if (_selectedCompany != null) ...[
                  const SizedBox(height: 32),
                  Text(
                    'Available Procedures',
                    style: AppTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_pdfFiles.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'No procedures found',
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._pdfFiles.map((filename) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildPdfCard(filename),
                    )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
} 