import 'dart:convert';
import 'package:contacts_service/contacts_service.dart' as DeviceContact;

// Base entity class
abstract class BaseEntity {
  int? get id; // Getter for id
}

class Contact extends BaseEntity {
  int? id;
  final String name;
  final String phone1;
  final String phone2;
  final String nickname;
  final String organization;
  final String? identifier; // Non-nullable identifier
  Map<String, String> additionalInfo;

  Contact({
    this.id,
    required this.name,
    required this.phone1,
    required this.phone2,
    required this.nickname,
    required this.organization,
    required this.identifier, // Ensure identifier is initialized
    Map<String, String>? additionalInfo,
  }) : additionalInfo = additionalInfo ?? {};

  // Default Contact instance
  static Contact get defaultContact => Contact(
        id: null,
        name: '',
        phone1: '',
        phone2: '',
        nickname: '',
        organization: '',
        identifier: 'default', // Set a default identifier
        additionalInfo: {}, // Default empty additional info
      );

  // Create a Contact object from a Map (DB Map)
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'] as String,
      phone1: map['phone1'] as String,
      phone2: map['phone2'] as String,
      nickname: map['nickname'] as String,
      organization: map['organization'] as String,
      additionalInfo: _decodeAdditionalInfo(map['additionalInfo']),
      identifier:
          map['identifier'] ?? 'default', // Ensure identifier is handled
    );
  }

  // Convert a Contact object to a Map (DB Map)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone1': phone1,
      'phone2': phone2,
      'nickname': nickname,
      'organization': organization,
      'additionalInfo': jsonEncode(additionalInfo),
      'identifier': identifier, // Include identifier in the Map
    };
  }

  // Helper method to decode additionalInfo safely
  static Map<String, String> _decodeAdditionalInfo(dynamic additionalInfo) {
    if (additionalInfo is String) {
      final decodedMap = jsonDecode(additionalInfo) as Map<String, dynamic>;
      return decodedMap.map((key, value) => MapEntry(key, value.toString()));
    } else if (additionalInfo is Map<String, dynamic>) {
      return additionalInfo
          .map((key, value) => MapEntry(key, value.toString()));
    }
    return {};
  }

  // Converts a DeviceContact to your custom Contact model
  static Contact fromDeviceContact(DeviceContact.Contact deviceContact) {
    return Contact(
      name: deviceContact.displayName ?? '',
      phone1: deviceContact.phones?.isNotEmpty == true
          ? deviceContact.phones!.first.value ?? ''
          : '',
      phone2: deviceContact.phones?.length == 2
          ? deviceContact.phones![1].value ?? ''
          : '',
      //nickname: deviceContact.nickname ?? '',
      organization: deviceContact.company ?? '',
      additionalInfo: {}, // You can add logic for extra fields if needed
      identifier: deviceContact.identifier ?? 'default',
      nickname: '', // Handle identifier from device contact
    );
  }

  // Converts your custom Contact model back to DeviceContact
  DeviceContact.Contact toDeviceContact() {
    return DeviceContact.Contact(
      displayName: name,
      phones: [
        DeviceContact.Item(label: "phone1", value: phone1),
        if (phone2.isNotEmpty)
          DeviceContact.Item(label: "phone2", value: phone2),
      ],
      //nickname: nickname,
      company: organization,
    );
  }
}
