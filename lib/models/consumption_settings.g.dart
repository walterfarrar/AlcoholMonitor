// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consumption_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConsumptionSettingsAdapter extends TypeAdapter<ConsumptionSettings> {
  @override
  final int typeId = 1;

  @override
  ConsumptionSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConsumptionSettings(
      dailyLimit: fields[0] as double,
      weeklyLimit: fields[1] as double,
      monthlyLimit: fields[2] as double,
      displayUnitIndex: fields[3] as int?,
      cutoffMinutes: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ConsumptionSettings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.dailyLimit)
      ..writeByte(1)
      ..write(obj.weeklyLimit)
      ..writeByte(2)
      ..write(obj.monthlyLimit)
      ..writeByte(3)
      ..write(obj.displayUnitIndex)
      ..writeByte(4)
      ..write(obj.cutoffMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsumptionSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
