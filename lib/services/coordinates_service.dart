import 'package:hive_flutter/hive_flutter.dart';
import '../models/saved_coordinate.dart';
import 'package:uuid/uuid.dart';

class CoordinatesService {
  static const String _boxName = 'saved_coordinates';
  static Box<SavedCoordinate>? _box;

  // Initialize Hive and open the box
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(SavedCoordinateAdapter());
    _box = await Hive.openBox<SavedCoordinate>(_boxName);
  }

  // Get the box instance
  Box<SavedCoordinate> get _getBox {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Coordinates box is not initialized. Call init() first.');
    }
    return _box!;
  }

  // Add a new coordinate
  Future<SavedCoordinate> addCoordinate({
    required String name,
    String? notes,
    required double lat,
    required double lon,
    required double accuracyMeters,
  }) async {
    final coordinate = SavedCoordinate(
      id: const Uuid().v4(),
      name: name,
      notes: notes,
      lat: lat,
      lon: lon,
      accuracyMeters: accuracyMeters,
      createdAt: DateTime.now(),
    );

    await _getBox.put(coordinate.id, coordinate);
    return coordinate;
  }

  // Get all coordinates sorted by newest first
  List<SavedCoordinate> getAllCoordinates() {
    final coordinates = _getBox.values.toList();
    coordinates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return coordinates;
  }

  // Get a specific coordinate by ID
  SavedCoordinate? getCoordinate(String id) {
    return _getBox.get(id);
  }

  // Delete a coordinate
  Future<void> deleteCoordinate(String id) async {
    await _getBox.delete(id);
  }

  // Delete all coordinates
  Future<void> deleteAllCoordinates() async {
    await _getBox.clear();
  }

  // Search coordinates by name or notes
  List<SavedCoordinate> searchCoordinates(String query) {
    if (query.isEmpty) {
      return getAllCoordinates();
    }

    final lowerQuery = query.toLowerCase();
    final allCoordinates = getAllCoordinates();
    
    return allCoordinates.where((coord) {
      final nameMatch = coord.name.toLowerCase().contains(lowerQuery);
      final notesMatch = coord.notes?.toLowerCase().contains(lowerQuery) ?? false;
      return nameMatch || notesMatch;
    }).toList();
  }

  // Get count of saved coordinates
  int getCount() {
    return _getBox.length;
  }

  // Listen to changes in the box
  Stream<BoxEvent> watchCoordinates() {
    return _getBox.watch();
  }
}
