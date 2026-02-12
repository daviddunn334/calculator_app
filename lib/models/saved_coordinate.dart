import 'package:hive/hive.dart';

part 'saved_coordinate.g.dart';

@HiveType(typeId: 0)
class SavedCoordinate extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? notes;

  @HiveField(3)
  final double lat;

  @HiveField(4)
  final double lon;

  @HiveField(5)
  final double accuracyMeters;

  @HiveField(6)
  final DateTime createdAt;

  SavedCoordinate({
    required this.id,
    required this.name,
    this.notes,
    required this.lat,
    required this.lon,
    required this.accuracyMeters,
    required this.createdAt,
  });

  String get formattedCoordinates => '$lat, $lon';
  
  String get shortCoordinates {
    final latStr = lat.toStringAsFixed(4);
    final lonStr = lon.toStringAsFixed(4);
    return '$latStr, $lonStr';
  }
}
