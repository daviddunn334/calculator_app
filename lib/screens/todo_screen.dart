import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  List<TodoItem> _tasks = [];
  FilterType _currentFilter = FilterType.all;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _taskController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList('tasks') ?? [];
    setState(() {
      _tasks = tasksJson.map((json) => TodoItem.fromJson(jsonDecode(json))).toList();
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = _tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList('tasks', tasksJson);
  }

  void _addTask() {
    if (_taskController.text.trim().isEmpty) return;

    setState(() {
      _tasks.add(TodoItem(
        text: _taskController.text.trim(),
        dateCreated: DateTime.now(),
      ));
      _taskController.clear();
    });
    _saveTasks();
  }

  void _showAddTaskDialog() {
    TaskTag selectedTag = TaskTag.normal;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                hintText: 'Enter task...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskTag>(
              value: selectedTag,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: TaskTag.values.map((tag) => DropdownMenuItem(
                value: tag,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: tag.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(tag.label),
                  ],
                ),
              )).toList(),
              onChanged: (value) {
                selectedTag = value!;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _taskController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_taskController.text.trim().isNotEmpty) {
                setState(() {
                  _tasks.add(TodoItem(
                    text: _taskController.text.trim(),
                    dateCreated: DateTime.now(),
                    tag: selectedTag,
                  ));
                  _taskController.clear();
                });
                _saveTasks();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  void _editNotes(TodoItem task) {
    _notesController.text = task.notes;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notes for "${task.text}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _notesController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Add notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                task.notes = _notesController.text;
              });
              _saveTasks();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  List<TodoItem> _getFilteredTasks() {
    switch (_currentFilter) {
      case FilterType.all:
        return _tasks;
      case FilterType.incomplete:
        return _tasks.where((task) => !task.isCompleted).toList();
      case FilterType.completed:
        return _tasks.where((task) => task.isCompleted).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _getFilteredTasks();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'To-Do List',
              subtitle: 'Track your daily tasks and reminders',
              icon: Icons.checklist,
            ),

            // Filter Buttons
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFilterButton(FilterType.all, 'All'),
                  _buildFilterButton(FilterType.incomplete, 'Incomplete'),
                  _buildFilterButton(FilterType.completed, 'Completed'),
                ],
              ),
            ),

            // Task Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showAddTaskDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add New Task'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent1,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.paddingMedium,
                          horizontal: AppTheme.paddingLarge,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Task List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      side: const BorderSide(color: AppTheme.divider),
                    ),
                    child: InkWell(
                      onTap: () => _editNotes(task),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: Checkbox(
                              value: task.isCompleted,
                              onChanged: (_) => _toggleTask(_tasks.indexOf(task)),
                              activeColor: AppTheme.primaryBlue,
                            ),
                            title: Text(
                              task.text,
                              style: task.isCompleted
                                  ? AppTheme.bodyMedium.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      color: AppTheme.textSecondary,
                                    )
                                  : AppTheme.bodyMedium,
                            ),
                            subtitle: Text(
                              _formatDate(task.dateCreated),
                              style: AppTheme.bodySmall,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: task.tag.color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: task.tag.color,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    task.tag.label,
                                    style: TextStyle(
                                      color: task.tag.color,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _deleteTask(_tasks.indexOf(task)),
                                  color: AppTheme.textSecondary,
                                ),
                              ],
                            ),
                          ),
                          if (task.notes.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppTheme.paddingLarge,
                                0,
                                AppTheme.paddingLarge,
                                AppTheme.paddingMedium,
                              ),
                              child: Text(
                                task.notes,
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
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
    );
  }

  Widget _buildFilterButton(FilterType type, String label) {
    final isSelected = _currentFilter == type;
    final buttonColor = isSelected 
        ? type == FilterType.incomplete 
            ? AppTheme.accent1 
            : type == FilterType.completed
                ? AppTheme.accent2
                : AppTheme.primaryBlue 
        : Colors.white;
    return ElevatedButton(
      onPressed: () => setState(() => _currentFilter = type),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: isSelected ? Colors.white : AppTheme.textSecondary,
        elevation: 0,
        side: BorderSide(
          color: isSelected 
              ? (type == FilterType.incomplete 
                  ? AppTheme.accent1 
                  : type == FilterType.completed
                      ? AppTheme.accent2
                      : AppTheme.primaryBlue) 
              : AppTheme.divider,
        ),
      ),
      child: Text(label),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

enum FilterType {
  all,
  incomplete,
  completed,
}

enum TaskTag {
  urgent,
  normal,
  lax,
}

extension TaskTagColor on TaskTag {
  Color get color {
    switch (this) {
      case TaskTag.urgent:
        return Colors.red;
      case TaskTag.normal:
        return AppTheme.primaryBlue;
      case TaskTag.lax:
        return Colors.green[300]!;
    }
  }

  String get label {
    switch (this) {
      case TaskTag.urgent:
        return 'Urgent';
      case TaskTag.normal:
        return 'Normal';
      case TaskTag.lax:
        return 'Lax';
    }
  }
}

class TodoItem {
  String text;
  String notes;
  DateTime dateCreated;
  bool isCompleted;
  TaskTag tag;

  TodoItem({
    required this.text,
    required this.dateCreated,
    this.notes = '',
    this.isCompleted = false,
    this.tag = TaskTag.normal,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'notes': notes,
      'dateCreated': dateCreated.toIso8601String(),
      'isCompleted': isCompleted,
      'tag': tag.index,
    };
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      text: json['text'] as String,
      notes: json['notes'] as String? ?? '',
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      isCompleted: json['isCompleted'] as bool,
      tag: TaskTag.values[json['tag'] as int? ?? TaskTag.normal.index],
    );
  }
} 