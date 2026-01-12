// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_category_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityCategoryAdapter extends TypeAdapter<ActivityCategory> {
  @override
  final int typeId = 1;

  @override
  ActivityCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityCategory(
      id: fields[0] as String,
      name: fields[1] as String,
      iconCode: fields[2] as int,
      colorValue: fields[3] as int,
      emoji: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityCategory obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconCode)
      ..writeByte(3)
      ..write(obj.colorValue)
      ..writeByte(4)
      ..write(obj.emoji);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
