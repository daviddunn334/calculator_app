import 'package:flutter/material.dart';
import 'pipeline_element.dart';

class PipelineLayout {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime lastModified;
  final List<PipelineElement> elements;

  PipelineLayout({
    required this.id,
    required this.name,
    DateTime? createdAt,
    DateTime? lastModified,
    List<PipelineElement>? elements,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastModified = lastModified ?? DateTime.now(),
        elements = elements ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'elements': elements.map((e) => e.toJson()).toList(),
    };
  }

  factory PipelineLayout.fromJson(Map<String, dynamic> json) {
    return PipelineLayout(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      lastModified: DateTime.parse(json['lastModified']),
      elements: (json['elements'] as List)
          .map((e) => PipelineElement.fromJson(e))
          .toList(),
    );
  }

  PipelineLayout copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? lastModified,
    List<PipelineElement>? elements,
  }) {
    return PipelineLayout(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      elements: elements ?? this.elements,
    );
  }
} 