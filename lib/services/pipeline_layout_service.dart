import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/pipeline_layout.dart';

class PipelineLayoutService {
  static const String _storageKey = 'pipeline_layouts';
  final _uuid = const Uuid();

  Future<List<PipelineLayout>> getAllLayouts() async {
    final prefs = await SharedPreferences.getInstance();
    final layoutsJson = prefs.getStringList(_storageKey) ?? [];
    return layoutsJson
        .map((json) => PipelineLayout.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<PipelineLayout> saveLayout(PipelineLayout layout) async {
    final prefs = await SharedPreferences.getInstance();
    final layouts = await getAllLayouts();
    
    final updatedLayout = layout.copyWith(
      id: layout.id.isEmpty ? _uuid.v4() : layout.id,
      lastModified: DateTime.now(),
    );

    final index = layouts.indexWhere((l) => l.id == updatedLayout.id);
    if (index >= 0) {
      layouts[index] = updatedLayout;
    } else {
      layouts.add(updatedLayout);
    }

    await prefs.setStringList(
      _storageKey,
      layouts.map((l) => jsonEncode(l.toJson())).toList(),
    );

    return updatedLayout;
  }

  Future<void> deleteLayout(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final layouts = await getAllLayouts();
    layouts.removeWhere((layout) => layout.id == id);
    
    await prefs.setStringList(
      _storageKey,
      layouts.map((l) => jsonEncode(l.toJson())).toList(),
    );
  }

  Future<PipelineLayout?> getLayout(String id) async {
    final layouts = await getAllLayouts();
    return layouts.firstWhere(
      (layout) => layout.id == id,
      orElse: () => throw Exception('Layout not found'),
    );
  }
} 