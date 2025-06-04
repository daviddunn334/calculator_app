import 'package:flutter/material.dart';

class TodoItem {
  final String? id;
  final String text;
  String notes;
  final DateTime dateCreated;
  bool isCompleted;
  TaskTag tag;

  TodoItem({
    this.id,
    required this.text,
    this.notes = '',
    required this.dateCreated,
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
      id: json['id'] as String?,
      text: json['text'] as String,
      notes: json['notes'] as String? ?? '',
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      isCompleted: json['isCompleted'] as bool,
      tag: TaskTag.values[json['tag'] as int? ?? TaskTag.normal.index],
    );
  }
}

enum TaskTag {
  urgent,
  normal,
  lax,
}

extension TaskTagExtension on TaskTag {
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

  Color get color {
    switch (this) {
      case TaskTag.urgent:
        return Colors.red;
      case TaskTag.normal:
        return Colors.blue;
      case TaskTag.lax:
        return Colors.green[300]!;
    }
  }
} 