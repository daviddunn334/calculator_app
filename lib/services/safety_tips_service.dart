import 'dart:async';
import 'package:flutter/material.dart';

enum SafetyTipPriority {
  high,
  medium,
  low,
}

class SafetyTip {
  final String message;
  final SafetyTipPriority priority;
  final IconData icon;

  const SafetyTip({
    required this.message,
    required this.priority,
    required this.icon,
  });
}

class SafetyTipsService {
  static const List<SafetyTip> tips = [
    SafetyTip(
      message: 'Always wear appropriate PPE when conducting inspections',
      priority: SafetyTipPriority.high,
      icon: Icons.security,
    ),
    SafetyTip(
      message: 'Check weather conditions before field work',
      priority: SafetyTipPriority.medium,
      icon: Icons.wb_sunny,
    ),
    SafetyTip(
      message: 'Maintain clear communication with your team',
      priority: SafetyTipPriority.high,
      icon: Icons.group,
    ),
    SafetyTip(
      message: 'Keep emergency contact numbers readily available',
      priority: SafetyTipPriority.high,
      icon: Icons.emergency,
    ),
    SafetyTip(
      message: 'Document all safety observations',
      priority: SafetyTipPriority.medium,
      icon: Icons.note_add,
    ),
    SafetyTip(
      message: 'Stay hydrated during field work',
      priority: SafetyTipPriority.medium,
      icon: Icons.water_drop,
    ),
    SafetyTip(
      message: 'Review safety protocols before starting work',
      priority: SafetyTipPriority.high,
      icon: Icons.checklist,
    ),
    SafetyTip(
      message: 'Keep your work area clean and organized',
      priority: SafetyTipPriority.low,
      icon: Icons.cleaning_services,
    ),
  ];

  static Color getPriorityColor(SafetyTipPriority priority) {
    switch (priority) {
      case SafetyTipPriority.high:
        return Colors.red.shade100;
      case SafetyTipPriority.medium:
        return Colors.orange.shade100;
      case SafetyTipPriority.low:
        return Colors.blue.shade100;
    }
  }

  static Color getPriorityIconColor(SafetyTipPriority priority) {
    switch (priority) {
      case SafetyTipPriority.high:
        return Colors.red;
      case SafetyTipPriority.medium:
        return Colors.orange;
      case SafetyTipPriority.low:
        return Colors.blue;
    }
  }
} 