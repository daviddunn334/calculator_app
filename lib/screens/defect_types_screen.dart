import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DefectTypesScreen extends StatelessWidget {
  const DefectTypesScreen({super.key});

  // New color system
  static const Color _background = Color(0xFF1E232A);
  static const Color _elevatedSurface = Color(0xFF242A33);
  static const Color _cardSurface = Color(0xFF2A313B);
  static const Color _primaryText = Color(0xFFEDF9FF);
  static const Color _secondaryText = Color(0xFFAEBBC8);
  static const Color _mutedText = Color(0xFF7F8A96);
  static const Color _primaryAccent = Color(0xFF6C5BFF);
  static const Color _secondaryAccent = Color(0xFF00E5A8);
  static const Color _accessoryAccent = Color(0xFFFE637E);
  static const Color _yellowAccent = Color(0xFFF8B800);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Defect Types & Identification'),
        backgroundColor: _cardSurface,
        foregroundColor: _primaryText,
        elevation: 0,
        iconTheme: IconThemeData(color: _primaryText),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.05),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _accessoryAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          size: 40,
                          color: _accessoryAccent,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Defect Types & Identification',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _primaryText,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Field guide for defect identification and assessment',
                              style: TextStyle(
                                fontSize: 14,
                                color: _secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // PDF Download Button
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryAccent.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: Text(
                        kIsWeb
                            ? 'Download/Open the Encyclopedia of Pipeline Defects'
                            : 'Open the Encyclopedia of Pipeline Defects',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final filename = 'EPD 3rd Edn - 2017 - all (v3).pdf';
                        try {
                          final ref = FirebaseStorage.instance
                              .ref('procedures/defectidentification/$filename');
                          final url = await ref.getDownloadURL();
                          if (kIsWeb) {
                            html.window.open(url, '_blank');
                          } else {
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    appBar: AppBar(
                                      title: Text(filename),
                                      backgroundColor: _cardSurface,
                                      foregroundColor: _primaryText,
                                    ),
                                    backgroundColor: _background,
                                    body: SfPdfViewer.network(
                                      url,
                                      onDocumentLoadFailed: (details) async {
                                        if (context.mounted) {
                                          try {
                                            final tempDir =
                                                await getTemporaryDirectory();
                                            final filePath =
                                                '${tempDir.path}/$filename';
                                            final response =
                                                await http.get(Uri.parse(url));
                                            final file = File(filePath);
                                            await file
                                                .writeAsBytes(response.bodyBytes);
                                            if (context.mounted) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => Scaffold(
                                                    appBar: AppBar(
                                                      title: Text(filename),
                                                      backgroundColor: _cardSurface,
                                                      foregroundColor: _primaryText,
                                                    ),
                                                    backgroundColor: _background,
                                                    body: PDFView(
                                                      filePath: filePath,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Fallback failed: ${e.toString()}'),
                                                  backgroundColor: _accessoryAccent,
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
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Error loading PDF: ${e.toString()}'),
                                backgroundColor: _accessoryAccent,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Common Defect Types Section
                _buildSection(
                  'Common Defect Types',
                  Icons.list,
                  _primaryAccent,
                  [
                    _buildExpandableCard(
                      'Corrosion',
                      _yellowAccent,
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
                      _secondaryAccent,
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
                      _accessoryAccent,
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
                      _primaryAccent,
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
                      _yellowAccent,
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
                  _secondaryAccent,
                  [
                    _buildImageCard(
                      'Corrosion Examples',
                      'Various types of corrosion patterns and their characteristics',
                      Icons.image,
                      _yellowAccent,
                    ),
                    const SizedBox(height: 12),
                    _buildImageCard(
                      'Dent Types',
                      'Different dent profiles and their implications',
                      Icons.image,
                      _secondaryAccent,
                    ),
                    const SizedBox(height: 12),
                    _buildImageCard(
                      'Crack Patterns',
                      'Common crack patterns and their causes',
                      Icons.image,
                      _accessoryAccent,
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Measurement & Severity Section
                _buildSection(
                  'Measurement & Severity Assessment',
                  Icons.straighten,
                  _yellowAccent,
                  [
                    _buildExpandableCard(
                      'Depth Measurement',
                      _primaryAccent,
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
                      _secondaryAccent,
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
                      _accessoryAccent,
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
                  _accessoryAccent,
                  [
                    _buildExpandableCard(
                      'Cluster Definition',
                      _primaryAccent,
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
                      _secondaryAccent,
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
                      _yellowAccent,
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    IconData icon,
    Color accentColor,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _primaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildExpandableCard(String title, Color accentColor, List<String> items) {
    return Container(
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          expansionTileTheme: ExpansionTileThemeData(
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            textColor: _primaryText,
            collapsedTextColor: _primaryText,
            iconColor: accentColor,
            collapsedIconColor: accentColor,
          ),
        ),
        child: ExpansionTile(
          title: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _primaryText,
                ),
              ),
            ],
          ),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items
                    .map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 14,
                              color: _secondaryText,
                              height: 1.5,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(
    String title,
    String description,
    IconData icon,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: _secondaryText,
                      ),
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
              color: _elevatedSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: _mutedText,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Image Placeholder',
                    style: TextStyle(
                      fontSize: 14,
                      color: _mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
