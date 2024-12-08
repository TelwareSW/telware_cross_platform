// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      username: fields[0] as String,
      screenFirstName: fields[1] as String,
      screenLastName: fields[16] as String,
      email: fields[2] as String,
      photo: fields[3] as String?,
      status: fields[4] as String,
      bio: fields[5] as String,
      maxFileSize: fields[6] as int,
      automaticDownloadEnable: fields[7] as bool,
      lastSeenPrivacy: fields[8] as String,
      readReceiptsEnablePrivacy: fields[9] as bool,
      storiesPrivacy: fields[10] as String,
      picturePrivacy: fields[11] as String,
      invitePermissionsPrivacy: fields[12] as String,
      phone: fields[13] as String,
      id: fields[15] as String?,
      photoBytes: fields[14] as Uint8List?,
      blockedUsers: (fields[17] as List?)?.cast<UserModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.screenFirstName)
      ..writeByte(16)
      ..write(obj.screenLastName)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.photo)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.bio)
      ..writeByte(6)
      ..write(obj.maxFileSize)
      ..writeByte(7)
      ..write(obj.automaticDownloadEnable)
      ..writeByte(8)
      ..write(obj.lastSeenPrivacy)
      ..writeByte(9)
      ..write(obj.readReceiptsEnablePrivacy)
      ..writeByte(10)
      ..write(obj.storiesPrivacy)
      ..writeByte(11)
      ..write(obj.picturePrivacy)
      ..writeByte(12)
      ..write(obj.invitePermissionsPrivacy)
      ..writeByte(13)
      ..write(obj.phone)
      ..writeByte(14)
      ..write(obj.photoBytes)
      ..writeByte(15)
      ..write(obj.id)
      ..writeByte(17)
      ..write(obj.blockedUsers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
