// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bottle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BottleAdapter extends TypeAdapter<Bottle> {
  @override
  final int typeId = 2;

  @override
  Bottle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bottle(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as String,
      abvPercent: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Bottle obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.abvPercent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BottleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
