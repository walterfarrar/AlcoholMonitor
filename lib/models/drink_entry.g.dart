// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drink_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DrinkEntryAdapter extends TypeAdapter<DrinkEntry> {
  @override
  final int typeId = 0;

  @override
  DrinkEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DrinkEntry(
      id: fields[0] as String,
      volumeOz: fields[1] as double,
      abvPercent: fields[2] as double,
      standardDrinks: fields[3] as double,
      timestamp: fields[4] as DateTime,
      name: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DrinkEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.volumeOz)
      ..writeByte(2)
      ..write(obj.abvPercent)
      ..writeByte(3)
      ..write(obj.standardDrinks)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrinkEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
