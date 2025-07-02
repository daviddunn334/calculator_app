import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/news_update.dart';
import '../../services/news_service.dart';

class NewsEditorScreen extends StatefulWidget {
  final NewsUpdate? update;

  const NewsEditorScreen({super.key, this.update});

  @override
  State<NewsEditorScreen> createState() => _NewsEditorScreenState();
}

class _NewsEditorScreenState extends State<NewsEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final NewsService _newsService = NewsService();
  
  // Form controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _linksController;
  
  // Form state
  NewsCategory _selectedCategory = NewsCategory.company;
  NewsPriority _selectedPriority = NewsPriority.normal;
  NewsType _selectedType = NewsType.update;
  String _selectedIconName = 'info';
  DateTime? _publishDate;
  DateTime? _expirationDate;
  bool _publishImmediately = false;
  List<String> _links = [];
  
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.update != null;
    
    // Initialize controllers
    _titleController = TextEditingController(text: widget.update?.title ?? '');
    _descriptionController = TextEditingController(text: widget.update?.description ?? '');
    _linksController = TextEditingController();
    
    // Initialize form state from existing update
    if (widget.update != null) {
      _selectedCategory = widget.update!.category;
      _selectedPriority = widget.update!.priority;
      _selectedType = widget.update!.type;
      _selectedIconName = widget.update!.iconName;
      _publishDate = widget.update!.publishDate;
      _expirationDate = widget.update!.expirationDate;
      _publishImmediately = widget.update!.isPublished;
      _links = List.from(widget.update!.links);
      _linksController.text = _links.join('\n');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Post' : 'Create Post'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveDraft,
            child: const Text(
              'Save Draft',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfoSection(),
                    const SizedBox(height: AppTheme.paddingLarge),
                    _buildContentSection(),
                    const SizedBox(height: AppTheme.paddingLarge),
                    _buildLinksSection(),
                    const SizedBox(height: AppTheme.paddingLarge),
                    _buildPublishingSection(),
                    const SizedBox(height: 100), // Space for FAB
                  ],
                ),
              ),
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_publishImmediately && !_isEditing)
            FloatingActionButton.extended(
              onPressed: _publishNow,
              backgroundColor: Colors.green,
              heroTag: 'publish',
              icon: const Icon(Icons.publish),
              label: const Text('Publish Now'),
            ),
          if (!_publishImmediately && !_isEditing)
            const SizedBox(height: 8),
          FloatingActionButton.extended(
            onPressed: _savePost,
            backgroundColor: AppTheme.primaryBlue,
            heroTag: 'save',
            icon: Icon(_isEditing ? Icons.save : Icons.add),
            label: Text(_isEditing ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter post title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
              maxLines: 2,
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<NewsCategory>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category *',
                      border: OutlineInputBorder(),
                    ),
                    items: NewsCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: category.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(category.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppTheme.paddingMedium),
                Expanded(
                  child: DropdownButtonFormField<NewsType>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items: NewsType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(type.icon, size: 16),
                            const SizedBox(width: 8),
                            Text(type.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<NewsPriority>(
                    value: _selectedPriority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: NewsPriority.values.map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: priority.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(priority.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedPriority = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppTheme.paddingMedium),
                Expanded(
                  child: _buildIconSelector(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconSelector() {
    final availableIcons = NewsUpdate.getAvailableIcons();
    final selectedIcon = availableIcons.firstWhere(
      (icon) => icon['name'] == _selectedIconName,
      orElse: () => availableIcons.first,
    );

    return InkWell(
      onTap: _showIconPicker,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Icon',
          border: OutlineInputBorder(),
        ),
        child: Row(
          children: [
            Icon(selectedIcon['icon'], size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(selectedIcon['label'])),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Content',
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Enter post content...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
              maxLines: 8,
              minLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinksSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Links & Resources',
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            TextFormField(
              controller: _linksController,
              decoration: const InputDecoration(
                labelText: 'Links (one per line)',
                hintText: 'https://example.com\nhttps://another-link.com',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              onChanged: (value) {
                _links = value
                    .split('\n')
                    .where((link) => link.trim().isNotEmpty)
                    .toList();
              },
            ),
            if (_links.isNotEmpty) ...[
              const SizedBox(height: AppTheme.paddingMedium),
              Text(
                'Preview Links:',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppTheme.paddingSmall),
              ..._links.map((link) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.link, size: 16, color: AppTheme.primaryBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        link,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.primaryBlue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPublishingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Publishing Options',
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            SwitchListTile(
              title: const Text('Publish Immediately'),
              subtitle: const Text('Make this post visible to users right away'),
              value: _publishImmediately,
              onChanged: (value) {
                setState(() {
                  _publishImmediately = value;
                  if (value) {
                    _publishDate = DateTime.now();
                  }
                });
              },
            ),
            if (!_publishImmediately) ...[
              const Divider(),
              ListTile(
                title: const Text('Publish Date'),
                subtitle: Text(_publishDate != null
                    ? 'Scheduled for ${_formatDateTime(_publishDate!)}'
                    : 'Not scheduled'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectPublishDate,
              ),
            ],
            const Divider(),
            ListTile(
              title: const Text('Expiration Date'),
              subtitle: Text(_expirationDate != null
                  ? 'Expires on ${_formatDateTime(_expirationDate!)}'
                  : 'Never expires'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_expirationDate != null)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _expirationDate = null;
                        });
                      },
                      icon: const Icon(Icons.clear),
                    ),
                  const Icon(Icons.calendar_today),
                ],
              ),
              onTap: _selectExpirationDate,
            ),
          ],
        ),
      ),
    );
  }

  void _showIconPicker() {
    final availableIcons = NewsUpdate.getAvailableIcons();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Icon'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: availableIcons.length,
            itemBuilder: (context, index) {
              final iconData = availableIcons[index];
              final isSelected = iconData['name'] == _selectedIconName;
              
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedIconName = iconData['name'];
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryBlue : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        iconData['icon'],
                        color: isSelected ? AppTheme.primaryBlue : Colors.grey[600],
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        iconData['label'],
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? AppTheme.primaryBlue : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _selectPublishDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _publishDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_publishDate ?? DateTime.now()),
      );
      
      if (time != null) {
        setState(() {
          _publishDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectExpirationDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expirationDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_expirationDate ?? DateTime.now()),
      );
      
      if (time != null) {
        setState(() {
          _expirationDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} at ${TimeOfDay.fromDateTime(dateTime).format(context)}';
  }

  Future<void> _saveDraft() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final update = _createNewsUpdate(isDraft: true, isPublished: false);
      
      if (_isEditing) {
        await _newsService.updateUpdate(widget.update!.id!, update);
        _showSnackBar('Draft updated successfully');
      } else {
        await _newsService.createUpdate(update);
        _showSnackBar('Draft saved successfully');
      }
      
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error saving draft: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _publishNow() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final update = _createNewsUpdate(
        isDraft: false,
        isPublished: true,
        publishDate: DateTime.now(),
      );
      
      if (_isEditing) {
        await _newsService.updateUpdate(widget.update!.id!, update);
        _showSnackBar('Post updated and published successfully');
      } else {
        await _newsService.createUpdate(update);
        _showSnackBar('Post published successfully');
      }
      
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error publishing post: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _savePost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final update = _createNewsUpdate(
        isDraft: !_publishImmediately,
        isPublished: _publishImmediately,
        publishDate: _publishImmediately ? DateTime.now() : _publishDate,
      );
      
      if (_isEditing) {
        await _newsService.updateUpdate(widget.update!.id!, update);
        _showSnackBar('Post updated successfully');
      } else {
        await _newsService.createUpdate(update);
        _showSnackBar('Post created successfully');
      }
      
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error saving post: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  NewsUpdate _createNewsUpdate({
    required bool isDraft,
    required bool isPublished,
    DateTime? publishDate,
  }) {
    return NewsUpdate(
      id: widget.update?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      createdDate: widget.update?.createdDate ?? DateTime.now(),
      publishDate: publishDate,
      expirationDate: _expirationDate,
      category: _selectedCategory,
      priority: _selectedPriority,
      type: _selectedType,
      icon: NewsUpdate.getAvailableIcons()
          .firstWhere((icon) => icon['name'] == _selectedIconName)['icon'],
      iconName: _selectedIconName,
      isPublished: isPublished,
      isDraft: isDraft,
      authorId: 'current_user', // TODO: Get from auth service
      authorName: 'Admin User', // TODO: Get from auth service
      links: _links,
      imageUrls: widget.update?.imageUrls ?? [],
      metadata: widget.update?.metadata,
      viewCount: widget.update?.viewCount ?? 0,
      lastModified: DateTime.now(),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
