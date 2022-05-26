// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemCacheAdapter extends TypeAdapter<ItemCache> {
  @override
  final int typeId = 0;

  @override
  ItemCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemCache(
      lastValidated: fields[1] as DateTime,
      key: fields[2] as String,
      expireOn: fields[0] as DateTime,
      data: fields[3] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, ItemCache obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.expireOn)
      ..writeByte(1)
      ..write(obj.lastValidated)
      ..writeByte(2)
      ..write(obj.key)
      ..writeByte(3)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
