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
    _descriptionController =
        TextEditingController(text: widget.update?.description ?? '');
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Modern Header
                _buildModernHeader(),

                // Form Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBasicInfoSection(),
                          const SizedBox(height: 32),
                          _buildContentSection(),
                          const SizedBox(height: 32),
                          _buildLinksSection(),
                          const SizedBox(height: 32),
                          _buildPublishingSection(),
                          const SizedBox(height: 32),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            AppTheme.primaryBlue.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isEditing ? Icons.edit_note : Icons.create,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEditing ? 'Edit Post' : 'Create New Post',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isEditing
                        ? 'Update your news content and settings'
                        : 'Share updates and news with your team',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryBlue,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? minLines,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      minLines: minLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppTheme.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: AppTheme.textSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: AppTheme.bodyMedium,
    );
  }

  Widget _buildDropdownField<T>({
    required T value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: AppTheme.textSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items,
      onChanged: onChanged,
      style: AppTheme.bodyMedium,
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Basic Information', Icons.info_outline),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _titleController,
            label: 'Post Title',
            icon: Icons.title,
            hintText: 'Enter an engaging title for your post',
            validator: (value) =>
                value?.trim().isEmpty ?? true ? 'Title is required' : null,
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField<NewsCategory>(
                  value: _selectedCategory,
                  label: 'Category',
                  icon: Icons.category,
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
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField<NewsType>(
                  value: _selectedType,
                  label: 'Type',
                  icon: Icons.type_specimen,
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
                      setState(() => _selectedType = value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField<NewsPriority>(
                  value: _selectedPriority,
                  label: 'Priority',
                  icon: Icons.priority_high,
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
                      setState(() => _selectedPriority = value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildIconSelector(),
              ),
            ],
          ),
        ],
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.divider),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(Icons.emoji_emotions, color: AppTheme.textSecondary),
            const SizedBox(width: 12),
            Icon(selectedIcon['icon'], size: 20),
            const SizedBox(width: 8),
            Expanded(
                child: Text(selectedIcon['label'], style: AppTheme.bodyMedium)),
            const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Content', Icons.article),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _descriptionController,
            label: 'Post Content',
            icon: Icons.description,
            hintText:
                'Write your news content here...\n\nProvide detailed information that will be helpful to your team.',
            validator: (value) =>
                value?.trim().isEmpty ?? true ? 'Content is required' : null,
            maxLines: 10,
            minLines: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildLinksSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Links & Resources', Icons.link),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _linksController,
            label: 'Related Links',
            icon: Icons.insert_link,
            hintText:
                'Add relevant links (one per line)\nhttps://example.com\nhttps://another-link.com',
            maxLines: 4,
            minLines: 3,
            onChanged: (value) {
              setState(() {
                _links = value
                    .split('\n')
                    .where((link) => link.trim().isNotEmpty)
                    .toList();
              });
            },
          ),
          if (_links.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.preview,
                          color: AppTheme.primaryBlue, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Link Preview:',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._links.map((link) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.link,
                                size: 16, color: AppTheme.primaryBlue),
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
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPublishingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Publishing Options', Icons.publish),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _publishImmediately
                  ? Colors.green.withOpacity(0.05)
                  : AppTheme.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _publishImmediately
                    ? Colors.green.withOpacity(0.3)
                    : AppTheme.divider,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _publishImmediately ? Icons.public : Icons.schedule,
                  color: _publishImmediately
                      ? Colors.green
                      : AppTheme.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Publish Immediately',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Make this post visible to users right away',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _publishImmediately,
                  onChanged: (value) {
                    setState(() {
                      _publishImmediately = value;
                      if (value) {
                        _publishDate = DateTime.now();
                      }
                    });
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),
          if (!_publishImmediately) ...[
            const SizedBox(height: 16),
            _buildDateTimeSelector(
              title: 'Publish Date',
              subtitle: _publishDate != null
                  ? 'Scheduled for ${_formatDateTime(_publishDate!)}'
                  : 'Click to schedule publication',
              icon: Icons.calendar_today,
              onTap: _selectPublishDate,
              hasValue: _publishDate != null,
            ),
          ],
          const SizedBox(height: 16),
          _buildDateTimeSelector(
            title: 'Expiration Date',
            subtitle: _expirationDate != null
                ? 'Expires on ${_formatDateTime(_expirationDate!)}'
                : 'Optional: Set when post expires',
            icon: Icons.event_busy,
            onTap: _selectExpirationDate,
            hasValue: _expirationDate != null,
            onClear: _expirationDate != null
                ? () {
                    setState(() => _expirationDate = null);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSelector({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool hasValue,
    VoidCallback? onClear,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: hasValue
            ? AppTheme.primaryBlue.withOpacity(0.05)
            : AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasValue
              ? AppTheme.primaryBlue.withOpacity(0.3)
              : AppTheme.divider,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: hasValue ? AppTheme.primaryBlue : AppTheme.textSecondary,
        ),
        title: Text(
          title,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onClear != null)
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.clear),
                iconSize: 20,
              ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _saveDraft,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Draft'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                side: BorderSide(color: AppTheme.divider),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _publishImmediately ? _publishNow : _savePost,
              icon: Icon(
                _publishImmediately
                    ? Icons.publish
                    : (_isEditing ? Icons.save : Icons.add),
              ),
              label: Text(
                _publishImmediately
                    ? 'Publish Now'
                    : (_isEditing ? 'Update Post' : 'Create Post'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _publishImmediately ? Colors.green : AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showIconPicker() {
    final availableIcons = NewsUpdate.getAvailableIcons();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.emoji_emotions,
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Select Icon',
                      style: AppTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Icon Grid
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
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
                            color: isSelected
                                ? AppTheme.primaryBlue
                                : AppTheme.divider,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected
                              ? AppTheme.primaryBlue.withOpacity(0.1)
                              : Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              iconData['icon'],
                              color: isSelected
                                  ? AppTheme.primaryBlue
                                  : AppTheme.textSecondary,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              iconData['label'],
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected
                                    ? AppTheme.primaryBlue
                                    : AppTheme.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
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
            ],
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
      initialDate:
          _expirationDate ?? DateTime.now().add(const Duration(days: 30)),
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
