// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_coordinate.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedCoordinateAdapter extends TypeAdapter<SavedCoordinate> {
  @override
  final int typeId = 0;

  @override
  SavedCoordinate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedCoordinate(
      id: fields[0] as String,
      name: fields[1] as String,
      notes: fields[2] as String?,
      lat: fields[3] as double,
      lon: fields[4] as double,
      accuracyMeters: fields[5] as double,
      createdAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SavedCoordinate obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.lat)
      ..writeByte(4)
      ..write(obj.lon)
      ..writeByte(5)
      ..write(obj.accuracyMeters)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedCoordinateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
