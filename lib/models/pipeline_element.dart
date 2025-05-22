import 'package:flutter/material.dart';

enum PipelineElementType {
  pipe,
  bend,
  valve,
  tee,
  weld,
}

class PipelineElement {
  final String id;
  final PipelineElementType type;
  final Offset position;
  String label;
  Color color;

  PipelineElement({
    required this.id,
    required this.type,
    required this.position,
    this.label = '',
    this.color = Colors.blue,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'position': {'dx': position.dx, 'dy': position.dy},
      'label': label,
      'color': color.value,
    };
  }

  factory PipelineElement.fromJson(Map<String, dynamic> json) {
    return PipelineElement(
      id: json['id'],
      type: PipelineElementType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      position: Offset(
        json['position']['dx'],
        json['position']['dy'],
      ),
      label: json['label'],
      color: Color(json['color']),
    );
  }

  PipelineElement copyWith({
    String? id,
    PipelineElementType? type,
    Offset? position,
    String? label,
    Color? color,
  }) {
    return PipelineElement(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      label: label ?? this.label,
      color: color ?? this.color,
    );
  }
} 