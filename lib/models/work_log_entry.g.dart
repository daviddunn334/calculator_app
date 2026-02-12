// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_log_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkLogEntryAdapter extends TypeAdapter<WorkLogEntry> {
  @override
  final int typeId = 1;

  @override
  WorkLogEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkLogEntry(
      digNumber: fields[0] as String,
      location: fields[1] as String,
      crew: fields[2] as String,
      hoursWorked: fields[3] as double,
      notes: fields[4] as String,
      timestamp: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkLogEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.digNumber)
      ..writeByte(1)
      ..write(obj.location)
      ..writeByte(2)
      ..write(obj.crew)
      ..writeByte(3)
      ..write(obj.hoursWorked)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkLogEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
