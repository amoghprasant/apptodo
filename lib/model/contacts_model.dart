import 'package:sqliteproj/database/repository.dart';

class Contact extends BaseEntity {
  @override
  int? id; // Make id field available

  String name;
  String phone1;
  String phone2;
  String nickname;
  String organization;

  Contact({
    this.id,
    required this.name,
    required this.phone1,
    required this.phone2,
    required this.nickname,
    required this.organization,
  });

  // Convert a Contact object to a Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone1': phone1,
      'phone2': phone2,
      'nickname': nickname,
      'organization': organization,
    };
  }

  // Create a Contact object from a Map
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone1: map['phone1'] as String,
      phone2: map['phone2'] as String,
      nickname: map['nickname'] as String,
      organization: map['organization'] as String,
    );
  }
}
