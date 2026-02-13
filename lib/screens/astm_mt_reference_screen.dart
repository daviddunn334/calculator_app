import 'package:flutter/material.dart';
import '../models/reference_section.dart';
import '../data/astm_mt_reference_data.dart';
import '../theme/app_theme.dart';

class AstmMtReferenceScreen extends StatefulWidget {
  const AstmMtReferenceScreen({super.key});

  @override
  State<AstmMtReferenceScreen> createState() => _AstmMtReferenceScreenState();
}

class _AstmMtReferenceScreenState extends State<AstmMtReferenceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<int> _expandedSections = {};

  @override
  void initState() {
    super.initState();
    // Expand first section by default
    _expandedSections.add(0);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MapEntry<int, ReferenceSection>> get _filteredSections {
    if (_searchQuery.isEmpty) {
      return astmMtReferenceData.asMap().entries.toList();
    }

    final query = _searchQuery.toLowerCase();
    final filtered = <MapEntry<int, ReferenceSection>>[];

    for (var entry in astmMtReferenceData.asMap().entries) {
      final section = entry.value;
      final titleMatch = section.title.toLowerCase().contains(query);
      final bulletMatch = section.bulletPoints.any(
        (bullet) => bullet.toLowerCase().contains(query),
      );

      if (titleMatch || bulletMatch) {
        filtered.add(entry);
      }
    }

    return filtered;
  }

  void _toggleSection(int index) {
    setState(() {
      if (_expandedSections.contains(index)) {
        _expandedSections.remove(index);
      } else {
        _expandedSections.add(index);
      }
    });
  }

  void _expandAll() {
    setState(() {
      _expandedSections.addAll(
        List.generate(astmMtReferenceData.length, (index) => index),
      );
    });
  }

  void _collapseAll() {
    setState(() {
      _expandedSections.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredSections = _filteredSections;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Quick ASTM Reference – MT'),
        backgroundColor: AppTheme.surface,
        elevation: 0,
        actions: [
          if (_searchQuery.isEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              color: AppTheme.surfaceElevated,
              onSelected: (value) {
                if (value == 'expand_all') {
                  _expandAll();
                } else if (value == 'collapse_all') {
                  _collapseAll();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'expand_all',
                  child: Row(
                    children: [
                      Icon(Icons.unfold_more, size: 20, color: AppTheme.textSecondary),
                      SizedBox(width: 12),
                      Text('Expand All', style: TextStyle(color: AppTheme.textPrimary)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'collapse_all',
                  child: Row(
                    children: [
                      Icon(Icons.unfold_less, size: 20, color: AppTheme.textSecondary),
                      SizedBox(width: 12),
                      Text('Collapse All', style: TextStyle(color: AppTheme.textPrimary)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  // Auto-expand all sections when searching
                  if (_searchQuery.isNotEmpty) {
                    _expandAll();
                  }
                });
              },
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search sections and content...',
                hintStyle: const TextStyle(color: AppTheme.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.textMuted),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
            ),
          ),

          // Results info
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_list,
                    size: 16,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${filteredSections.length} section${filteredSections.length != 1 ? 's' : ''} found',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),

          // Content
          Expanded(
            child: filteredSections.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppTheme.textMuted.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No results found',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Try a different search term',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredSections.length + 1, // +1 for footer disclaimer
                    itemBuilder: (context, index) {
                      if (index == filteredSections.length) {
                        // Footer disclaimer
                        return Container(
                          margin: const EdgeInsets.only(top: 8, bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.yellowAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.yellowAccent.withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: AppTheme.yellowAccent,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'This is a field quick-reference summary only. Always refer to the latest applicable ASTM standard and project procedure for governing requirements.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final entry = filteredSections[index];
                      final sectionIndex = entry.key;
                      final section = entry.value;
                      final isExpanded = _expandedSections.contains(sectionIndex);

                      return _buildSectionCard(
                        section,
                        sectionIndex,
                        isExpanded,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(ReferenceSection section, int index, bool isExpanded) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded
              ? AppTheme.primaryAccent.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: AppTheme.primaryAccent.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleSection(index),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getSectionColor(index).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getSectionIcon(index),
                        size: 20,
                        color: _getSectionColor(index),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title
                    Expanded(
                      child: Text(
                        section.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                    // Expand/collapse icon
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppTheme.textSecondary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // Content (expandable)
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      color: Colors.white.withOpacity(0.05),
                      height: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bullet points
                          ...section.bulletPoints.map((bullet) {
                            final isMatch = _searchQuery.isNotEmpty &&
                                bullet.toLowerCase().contains(_searchQuery.toLowerCase());
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: _getSectionColor(index),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      bullet,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isMatch 
                                            ? AppTheme.textPrimary 
                                            : AppTheme.textSecondary,
                                        height: 1.5,
                                        fontWeight: isMatch 
                                            ? FontWeight.w500 
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),

                          // Section-specific disclaimer
                          if (section.disclaimer != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.yellowAccent.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.yellowAccent.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: AppTheme.yellowAccent,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      section.disclaimer!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                        height: 1.4,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSectionColor(int index) {
    final colors = [
      AppTheme.primaryAccent,
      AppTheme.secondaryAccent,
      AppTheme.accessoryAccent,
      AppTheme.yellowAccent,
      AppTheme.primaryAccent,
      AppTheme.secondaryAccent,
      AppTheme.accessoryAccent,
      AppTheme.yellowAccent,
    ];
    return colors[index % colors.length];
  }

  IconData _getSectionIcon(int index) {
    final icons = [
      Icons.library_books_outlined,
      Icons.factory_outlined,
      Icons.electric_bolt_outlined,
      Icons.thermostat_outlined,
      Icons.settings_input_antenna_outlined,
      Icons.grain_outlined,
      Icons.checklist_outlined,
      Icons.error_outline,
    ];
    return icons[index % icons.length];
  }
}
