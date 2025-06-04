import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../services/todo_service.dart';
import '../models/todo_item.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TodoService _todoService = TodoService();
  FilterType _currentFilter = FilterType.all;

  @override
  void dispose() {
    _taskController.dispose();
    _notesController.dispose();
    super.dispose();
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
                child: Text(tag.label),
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
            onPressed: () async {
              if (_taskController.text.trim().isNotEmpty) {
                final task = TodoItem(
                  text: _taskController.text.trim(),
                  dateCreated: DateTime.now(),
                  tag: selectedTag,
                );
                await _todoService.addTask(task);
                _taskController.clear();
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
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
            onPressed: () async {
              if (task.id != null) {
                final updatedTask = TodoItem(
                  id: task.id,
                  text: task.text,
                  notes: _notesController.text,
                  dateCreated: task.dateCreated,
                  isCompleted: task.isCompleted,
                  tag: task.tag,
                );
                await _todoService.updateTask(task.id!, updatedTask);
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  List<TodoItem> _getFilteredTasks(List<TodoItem> tasks) {
    switch (_currentFilter) {
      case FilterType.all:
        return tasks;
      case FilterType.incomplete:
        return tasks.where((task) => !task.isCompleted).toList();
      case FilterType.completed:
        return tasks.where((task) => task.isCompleted).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: StreamBuilder<List<TodoItem>>(
                stream: _todoService.getTasks(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final tasks = snapshot.data!;
                  final filteredTasks = _getFilteredTasks(tasks);

                  return ListView.builder(
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
                                  onChanged: (value) async {
                                    if (task.id != null) {
                                      final updatedTask = TodoItem(
                                        id: task.id,
                                        text: task.text,
                                        notes: task.notes,
                                        dateCreated: task.dateCreated,
                                        isCompleted: value ?? false,
                                        tag: task.tag,
                                      );
                                      await _todoService.updateTask(task.id!, updatedTask);
                                    }
                                  },
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
                                      onPressed: () async {
                                        if (task.id != null) {
                                          await _todoService.deleteTask(task.id!);
                                        }
                                      },
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