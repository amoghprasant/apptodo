import 'dart:convert';

import 'package:sqliteproj/database/repository.dart';

class Contact extends BaseEntity {
  late int? id;
  final String name;
  final String phone1;
  final String phone2;
  final String nickname;
  final String organization;
  Map<String, String> additionalInfo; // Dynamic fields

  Contact({
    this.id,
    required this.name,
    required this.phone1,
    required this.phone2,
    required this.nickname,
    required this.organization,
    Map<String, String>? additionalInfo,
  }) : additionalInfo = additionalInfo ?? {};

  // Create a Contact object from a Map
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'] as String,
      phone1: map['phone1'] as String,
      phone2: map['phone2'] as String,
      nickname: map['nickname'] as String,
      organization: map['organization'] as String,
      additionalInfo: _decodeAdditionalInfo(map['additionalInfo']),
    );
  }

  // Convert a Contact object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone1': phone1,
      'phone2': phone2,
      'nickname': nickname,
      'organization': organization,
      'additionalInfo': jsonEncode(additionalInfo),
    };
  }

  // Helper method to decode additionalInfo safely
  static Map<String, String> _decodeAdditionalInfo(dynamic additionalInfo) {
    if (additionalInfo is String) {
      // Decode the JSON string
      final decodedMap = jsonDecode(additionalInfo) as Map<String, dynamic>;
      // Convert to Map<String, String>
      return decodedMap.map((key, value) => MapEntry(key, value.toString()));
    } else if (additionalInfo is Map<String, dynamic>) {
      // Convert to Map<String, String>
      return additionalInfo
          .map((key, value) => MapEntry(key, value.toString()));
    }
    return {}; // Return an empty map if additionalInfo is not a valid type
  }
}
