import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../theme/app_theme.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html; // Only used on web

class CompanyPdfsScreen extends StatefulWidget {
  final String company;
  
  const CompanyPdfsScreen({
    super.key,
    required this.company,
  });

  @override
  State<CompanyPdfsScreen> createState() => _CompanyPdfsScreenState();
}

class _CompanyPdfsScreenState extends State<CompanyPdfsScreen> {
  List<String> _pdfFiles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPdfFiles();
  }

  Future<void> _loadPdfFiles() async {
    setState(() {
      _isLoading = true;
      _pdfFiles = [];
    });

    try {
      final storage = FirebaseStorage.instance;
      final folderRef = storage.ref('procedures/${widget.company}');
      final result = await folderRef.listAll();
      print('Loaded files for company: ${widget.company}, found: ${result.items.length}');
      setState(() {
        _pdfFiles = result.items.map((item) => item.name).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading PDFs for company ${widget.company}: $e');
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

  Future<String> _getPdfUrl(String filename) async {
    try {
      final ref = FirebaseStorage.instance.ref('procedures/${widget.company}/$filename');
      final url = await ref.getDownloadURL();
      print('Fetched download URL for ${widget.company}/$filename: $url');
      return url;
    } catch (e) {
      print('Error getting download URL for ${widget.company}/$filename: $e');
      rethrow;
    }
  }

  void _openPdfViewer(String filename) async {
    try {
      final url = await _getPdfUrl(filename);
      if (mounted) {
        if (kIsWeb) {
          // On web, open the PDF in a new tab immediately
          html.window.open(url, '_blank');
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: Text(filename),
                  backgroundColor: AppTheme.background,
                  foregroundColor: AppTheme.textPrimary,
                ),
                body: SfPdfViewer.network(
                  url,
                  onDocumentLoadFailed: (details) async {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to load PDF: \\${details.error}'),
                          backgroundColor: Colors.red,
                          action: SnackBarAction(
                            label: 'Open with fallback',
                            onPressed: () async {
                              try {
                                final tempDir = await getTemporaryDirectory();
                                final filePath = '${tempDir.path}/$filename';
                                final response = await http.get(Uri.parse(url));
                                final file = File(filePath);
                                await file.writeAsBytes(response.bodyBytes);
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
                                        body: PDFView(
                                          filePath: filePath,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Fallback failed: \\${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          );
        }
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
        title: Text('${widget.company.toUpperCase()} Procedures'),
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
                            '${widget.company.toUpperCase()} Procedures',
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
            ),
          ),
        ),
      ),
    );
  }
} 