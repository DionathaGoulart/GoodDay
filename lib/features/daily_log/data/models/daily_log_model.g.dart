// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyLogAdapter extends TypeAdapter<DailyLog> {
  @override
  final int typeId = 0;

  @override
  DailyLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyLog(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      mood: fields[2] as String,
      weather: fields[3] as String?,
      activityItemIds: (fields[4] as List).cast<String>(),
      food: fields[5] as String?,
      notes: fields[6] as String?,
      mediaPaths: (fields[7] as List).cast<String>(),
      moodHistory: (fields[8] as List).cast<MoodRecord>(),
      audioPaths: (fields[9] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, DailyLog obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.mood)
      ..writeByte(3)
      ..write(obj.weather)
      ..writeByte(4)
      ..write(obj.activityItemIds)
      ..writeByte(5)
      ..write(obj.food)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.mediaPaths)
      ..writeByte(8)
      ..write(obj.moodHistory)
      ..writeByte(9)
      ..write(obj.audioPaths);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MoodRecordAdapter extends TypeAdapter<MoodRecord> {
  @override
  final int typeId = 3;

  @override
  MoodRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MoodRecord(
      mood: fields[0] as String,
      timestamp: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MoodRecord obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.mood)
      ..writeByte(1)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
