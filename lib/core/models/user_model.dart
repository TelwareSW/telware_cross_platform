// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:telware_cross_platform/features/stories/utils/utils_functions.dart';

import '../constants/server_constants.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String username;
  @HiveField(1)
  final String screenName;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String? photo;
  @HiveField(4)
  final String status;
  @HiveField(5)
  final String bio;
  @HiveField(6)
  final int maxFileSize;
  @HiveField(7)
  final bool automaticDownloadEnable;
  @HiveField(8)
  final String lastSeenPrivacy;
  @HiveField(9)
  final bool readReceiptsEnablePrivacy;
  @HiveField(10)
  final String storiesPrivacy;
  @HiveField(11)
  final String picturePrivacy;
  @HiveField(12)
  final String invitePermissionsPrivacy;
  @HiveField(13)
  final String phone;
  @HiveField(14)
  Uint8List? photoBytes;
  @HiveField(15)
  String? id;

  UserModel({
    required this.username,
    required this.screenName,
    required this.email,
    this.photo,
    required this.status,
    required this.bio,
    required this.maxFileSize,
    required this.automaticDownloadEnable,
    required this.lastSeenPrivacy,
    required this.readReceiptsEnablePrivacy,
    required this.storiesPrivacy,
    required this.picturePrivacy,
    required this.invitePermissionsPrivacy,
    required this.phone,
    required this.id,
    this.photoBytes,
  });

  _setPhotoBytes() async {
    print('** Entered SetPhotoBytes');
    late String url;
    if (photo?.startsWith('http') ?? false) {
      url = photo!;
    } else if (photo?.isNotEmpty ?? false) {
      url = '$API_URL_PICTURES/$photo';
    } else {
      url = '';
    }
    if (url.isEmpty) return;

    Uint8List? tempImage;
    try {
      print('** url before calling downloadImg: $url');
      tempImage = await downloadImage(url);
      if (tempImage != null) {
        photoBytes = tempImage;
        print('** donwload success');
      }
      print('** donwload ended');
    } catch (e) {
      print('** donwload failed');
      photoBytes = null;
    }
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.username == username &&
        other.screenName == screenName &&
        other.email == email &&
        other.photo == photo &&
        other.status == status &&
        other.bio == bio &&
        other.maxFileSize == maxFileSize &&
        other.automaticDownloadEnable == automaticDownloadEnable &&
        other.lastSeenPrivacy == lastSeenPrivacy &&
        other.readReceiptsEnablePrivacy == readReceiptsEnablePrivacy &&
        other.storiesPrivacy == storiesPrivacy &&
        other.picturePrivacy == picturePrivacy &&
        other.invitePermissionsPrivacy == invitePermissionsPrivacy &&
        other.phone == phone &&
        other.id == id;
  }

  @override
  int get hashCode {
    return username.hashCode ^
        screenName.hashCode ^
        email.hashCode ^
        photo.hashCode ^
        status.hashCode ^
        bio.hashCode ^
        maxFileSize.hashCode ^
        automaticDownloadEnable.hashCode ^
        lastSeenPrivacy.hashCode ^
        readReceiptsEnablePrivacy.hashCode ^
        storiesPrivacy.hashCode ^
        picturePrivacy.hashCode ^
        invitePermissionsPrivacy.hashCode ^
        phone.hashCode ^
        id.hashCode;
  }

  @override
  String toString() {
    return 'UserModel(\n username: $username,\n screenName: $screenName,\n email: $email,\n photo: $photo,\n status: $status,\n bio: $bio,\n maxFileSize: $maxFileSize,\n automaticDownloadEnable: $automaticDownloadEnable,\n lastSeenPrivacy: $lastSeenPrivacy,\n readReceiptsEnablePrivacy: $readReceiptsEnablePrivacy,\n storiesPrivacy: $storiesPrivacy,\n picturePrivacy: $picturePrivacy,\n invitePermissionsPrivacy: $invitePermissionsPrivacy,\n phone: $phone,\n id: $id,\n isPhotoBytesSet: ${photoBytes != null}\n)';
  }

  UserModel copyWith({
    String? username,
    String? screenName,
    String? email,
    String? photo,
    String? status,
    String? bio,
    int? maxFileSize,
    bool? automaticDownloadEnable,
    String? lastSeenPrivacy,
    bool? readReceiptsEnablePrivacy,
    String? storiesPrivacy,
    String? picturePrivacy,
    String? invitePermissionsPrivacy,
    String? phone,
    String? id,
    Uint8List? photoBytes,
  }) {
    return UserModel(
      username: username ?? this.username,
      screenName: screenName ?? this.screenName,
      email: email ?? this.email,
      photo: photo ?? this.photo,
      status: status ?? this.status,
      bio: bio ?? this.bio,
      maxFileSize: maxFileSize ?? this.maxFileSize,
      automaticDownloadEnable:
          automaticDownloadEnable ?? this.automaticDownloadEnable,
      lastSeenPrivacy: lastSeenPrivacy ?? this.lastSeenPrivacy,
      readReceiptsEnablePrivacy:
          readReceiptsEnablePrivacy ?? this.readReceiptsEnablePrivacy,
      storiesPrivacy: storiesPrivacy ?? this.storiesPrivacy,
      picturePrivacy: picturePrivacy ?? this.picturePrivacy,
      invitePermissionsPrivacy:
          invitePermissionsPrivacy ?? this.invitePermissionsPrivacy,
      phone: phone ?? this.phone,
      id: id ?? this.id,
      photoBytes: photoBytes ?? this.photoBytes,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
      'screenName': screenName,
      'email': email,
      'photo': photo,
      'status': status,
      'bio': bio,
      'maxFileSize': maxFileSize,
      'automaticDownloadEnable': automaticDownloadEnable,
      'lastSeenPrivacy': lastSeenPrivacy,
      'readReceiptsEnablePrivacy': readReceiptsEnablePrivacy,
      'storiesPrivacy': storiesPrivacy,
      'picturePrivacy': picturePrivacy,
      'invitePermissionsPrivacy': invitePermissionsPrivacy,
      'phone': phone,
      'id': id,
    };
  }

  static Future<UserModel> fromMap(Map<String, dynamic> map) async {
    String screenName = (map['screenName'] as String?) ?? '';
    if (screenName.isEmpty) {
      screenName = 'No Name';
    }
    final user = UserModel(
      username: map['username'] as String,
      screenName: screenName,
      email: (map['email'] as String?) ?? '',
      photo: map['photo'] != null ? map['photo'] as String : null,
      status: map['status'] as String,
      bio: map['bio'] as String,
      maxFileSize: map['maxFileSize'] as int,
      automaticDownloadEnable: map['automaticDownloadEnable'] as bool,
      lastSeenPrivacy: map['lastSeenPrivacy'] as String,
      readReceiptsEnablePrivacy: map['readReceiptsEnablePrivacy'] as bool,
      storiesPrivacy: map['storiesPrivacy'] as String,
      picturePrivacy: map['picturePrivacy'] as String,
      invitePermissionsPrivacy: map['invitePermessionsPrivacy'] as String,
      phone: (map['phoneNumber'] as String?) ?? '',
      id: map['id'] as String,
    );
    await user._setPhotoBytes();
    return user;
  }

  String toJson() => json.encode(toMap());
}
