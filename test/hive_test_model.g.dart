// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_test_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveTestModelAdapter extends TypeAdapter<HiveTestModel> {
  @override
  final int typeId = 1;

  @override
  HiveTestModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveTestModel(
      key: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveTestModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.key);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveTestModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
