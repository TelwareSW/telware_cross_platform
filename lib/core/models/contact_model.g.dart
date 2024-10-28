// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContactModelBlockAdapter extends TypeAdapter<ContactModelBlock> {
  @override
  final int typeId = 3;

  @override
  ContactModelBlock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContactModelBlock(
      name: fields[0] as String,
      email: fields[1] as String?,
      photo: fields[2] as Uint8List?,
      phone: fields[3] as String,
      lastSeen: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ContactModelBlock obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.photo)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.lastSeen);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactModelBlockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
