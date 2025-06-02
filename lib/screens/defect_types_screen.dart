import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html; // Only used on web
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DefectTypesScreen extends StatelessWidget {
  const DefectTypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Defect Types & Identification'),
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
                      child: Icon(Icons.warning, size: 40, color: AppTheme.primaryBlue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Defect Types & Identification',
                            style: AppTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Field guide for defect identification and assessment',
                            style: AppTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.picture_as_pdf),
                    label: Text(kIsWeb ? 'Download/Open the Encyclopedia of Pipeline Defects' : 'Open the Encyclopedia of Pipeline Defects'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      textStyle: AppTheme.titleMedium,
                    ),
                    onPressed: () async {
                      final filename = 'EPD 3rd Edn - 2017 - all (v3).pdf';
                      try {
                        final ref = FirebaseStorage.instance.ref('procedures/defectidentification/$filename');
                        final url = await ref.getDownloadURL();
                        if (kIsWeb) {
                          html.window.open(url, '_blank');
                        } else {
                          // Try to open with Syncfusion first, fallback to PDFView
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
                                    if (context.mounted) {
                                      try {
                                        final tempDir = await getTemporaryDirectory();
                                        final filePath = '${tempDir.path}/$filename';
                                        final response = await http.get(Uri.parse(url));
                                        final file = File(filePath);
                                        await file.writeAsBytes(response.bodyBytes);
                                        if (context.mounted) {
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
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Fallback failed: \\${e.toString()}'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error loading PDF: \\${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(height: 32),
                
                // Common Defect Types Section
                _buildSection(
                  'Common Defect Types',
                  Icons.list,
                  [
                    _buildExpandableCard(
                      'Corrosion',
                      [
                        '• General corrosion: Uniform metal loss',
                        '• Pitting corrosion: Localized deep pits',
                        '• Galvanic corrosion: Dissimilar metal contact',
                        '• Stress corrosion: Cracking under stress',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'Dents',
                      [
                        '• Plain dents: Smooth deformation',
                        '• Gouge dents: Metal loss with deformation',
                        '• Rock dents: Sharp, localized deformation',
                        '• Construction dents: Equipment damage',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'Gouges',
                      [
                        '• Mechanical gouges: Tool or equipment damage',
                        '• Abrasion: Surface wear',
                        '• Scratches: Linear surface damage',
                        '• Impact damage: Sharp force damage',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'Cracks',
                      [
                        '• Stress corrosion cracks',
                        '• Fatigue cracks',
                        '• Weld cracks',
                        '• Environmental cracking',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'Laminations',
                      [
                        '• Rolling laminations',
                        '• Seam laminations',
                        '• Inclusions',
                        '• Delaminations',
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Visual Identification Section
                _buildSection(
                  'Visual Identification',
                  Icons.visibility,
                  [
                    _buildImageCard(
                      'Corrosion Examples',
                      'Various types of corrosion patterns and their characteristics',
                      Icons.image,
                    ),
                    const SizedBox(height: 12),
                    _buildImageCard(
                      'Dent Types',
                      'Different dent profiles and their implications',
                      Icons.image,
                    ),
                    const SizedBox(height: 12),
                    _buildImageCard(
                      'Crack Patterns',
                      'Common crack patterns and their causes',
                      Icons.image,
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Measurement & Severity Section
                _buildSection(
                  'Measurement & Severity Assessment',
                  Icons.straighten,
                  [
                    _buildExpandableCard(
                      'Depth Measurement',
                      [
                        '• Pit gauge usage and calibration',
                        '• Ultrasonic thickness measurement',
                        '• Depth micrometer techniques',
                        '• Recording and documentation',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'Length/Width Measurement',
                      [
                        '• Steel ruler techniques',
                        '• Measuring tape methods',
                        '• Laser measurement tools',
                        '• Digital caliper usage',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'Severity Classification',
                      [
                        '• Deep vs. shallow pit criteria',
                        '• Sharp vs. blunt gouge assessment',
                        '• Crack length and depth thresholds',
                        '• Dent depth and sharpness evaluation',
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Pit Density Section
                _buildSection(
                  'Pit Density & Clustering',
                  Icons.grid_on,
                  [
                    _buildExpandableCard(
                      'Cluster Definition',
                      [
                        '• Minimum distance between pits',
                        '• Maximum cluster size',
                        '• Interaction effects',
                        '• Combined defect assessment',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      'Assessment Methods',
                      [
                        '• Grid measurement techniques',
                        '• Cluster mapping',
                        '• Severity evaluation',
                        '• Repair criteria',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildImageCard(
                      'Cluster Examples',
                      'Visual examples of pit clusters and their classification',
                      Icons.image,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryBlue, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildExpandableCard(String title, List<String> items) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: const BorderSide(color: AppTheme.divider),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: AppTheme.titleMedium,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  item,
                  style: AppTheme.bodyMedium,
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(String title, String description, IconData icon) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: const BorderSide(color: AppTheme.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Icon(icon, color: AppTheme.primaryBlue, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: AppTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Center(
                child: Text(
                  'Image Placeholder',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 