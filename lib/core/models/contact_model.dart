// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'contact_model.g.dart';

@HiveType(typeId: 2)
class ContactModel {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String? email;
  @HiveField(2)
  final Uint8List? photo;
  @HiveField(3)
  final String phone;
  @HiveField(4)
  final String lastSeen;

//<editor-fold desc="Data Methods">

  const ContactModel({
    required this.name,
    this.email,
    this.photo,
    required this.phone,
    required this.lastSeen,
  });

//<ed@override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactModel &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          email == other.email &&
          photo == other.photo &&
          phone == other.phone &&
          lastSeen == other.lastSeen);

  @override
  int get hashCode =>
      name.hashCode ^
      email.hashCode ^
      photo.hashCode ^
      phone.hashCode ^
      lastSeen.hashCode;

  @override
  String toString() {
    return 'ContactModel{ name: $name, email: $email, photo: $photo, phone: $phone, lastSeen: $lastSeen,}';
  }

  ContactModel copyWith({
    String? name,
    String? email,
    Uint8List? photo,
    String? phone,
    String? lastSeen,
  }) {
    return ContactModel(
      name: name ?? this.name,
      email: email ?? this.email,
      photo: photo ?? this.photo,
      phone: phone ?? this.phone,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photo': photo,
      'phone': phone,
      'lastSeen': lastSeen,
    };
  }

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      name: map['name'] as String,
      email: map['email'] as String,
      photo: map['photo'] as Uint8List,
      phone: map['phone'] as String,
      lastSeen: map['lastSeen'] as String,
    );
  }

//</editor-fold>
}