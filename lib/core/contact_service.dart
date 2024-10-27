import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:hive/hive.dart';
import 'package:telware_cross_platform/core/models/contact_model.dart';
import 'package:telware_cross_platform/core/utils.dart';

class ContactService {
  Future<void> fetchAndStoreContacts() async {
    bool isPermissionGranted = await Permission.contacts.isGranted;
    if (!isPermissionGranted) {
      await Permission.contacts.request();
    }
    if (await Permission.contacts.isGranted) {
      final contacts = await FastContacts.getAllContacts();

      // for (var contact in contacts) {
      //   contact.toMap().forEach((key, value) {
      //     debugPrint('$key: $value');
      //   });
      // }

      var box = await Hive.openBox<ContactModel>("contacts");
      await box.clear();
      // Store contacts in Hive
      for (var contact in contacts) {
        if (contact.phones.isEmpty || contact.displayName.isEmpty) continue;
        final thumbnail = await FastContacts.getContactImage(contact.id);
        final email =
            contact.emails.isNotEmpty ? contact.emails[0].toString() : "";
        final phone = formatPhoneNumber(contact.phones[0].number);
        box.put(
          contact.id,
          ContactModel(
              name: contact.displayName,
              email: email,
              phone: phone,
              photo: thumbnail,
              lastSeen: ""),
        );
      }
    }
  }
}
