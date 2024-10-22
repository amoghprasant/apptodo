import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:contacts_service/contacts_service.dart' as DeviceContact;
import 'package:sqliteproj/model/contacts_model.dart'; // Ensure this path is correct
import 'package:sqliteproj/model/todo_model.dart'; // Ensure this path is correct

// Abstract Repository Interface
abstract class Repository<T extends BaseEntity, K> {
  Future<List<T>> getAll();
  Future<T?> getById(K id);
  Future<K> create(T entity);
  Future<K> update(T entity);
  Future<bool> delete(K id);

  syncContacts() {}
}

// Abstract Entity Repository Implementation
abstract class EntityRepository<K extends BaseEntity>
    implements Repository<K, int> {
  final Database database;

  EntityRepository({required this.database});

  String get tableName;
  Map<String, dynamic> toMap(K entity);
  K fromMap(Map<String, dynamic> map);

  @override
  Future<int> create(K entity) async =>
      await database.insert(tableName, toMap(entity));

  @override
  Future<bool> delete(int id) async {
    final int count =
        await database.delete(tableName, where: 'id = ?', whereArgs: [id]);
    return count > 0;
  }

  @override
  Future<List<K>> getAll() async {
    final List<Map<String, dynamic>> records = await database.query(tableName);
    return records.map((record) => fromMap(record)).toList();
  }

  @override
  Future<K?> getById(int id) async {
    final List<Map<String, dynamic>> records =
        await database.query(tableName, where: 'id = ?', whereArgs: [id]);
    return records.isNotEmpty ? fromMap(records.first) : null;
  }

  @override
  Future<int> update(K entity) async {
    return await database.update(
      tableName,
      toMap(entity),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }
}

// Contact Entity Repository Implementation
class ContactEntityRepository extends EntityRepository<Contact> {
  ContactEntityRepository({required super.database});

  @override
  Contact fromMap(Map<String, dynamic> map) {
    // Parse the dynamic fields from the 'additionalInfo' column
    Map<String, String> additionalInfo = {};
    if (map['additionalInfo'] != null) {
      final decodedInfo = jsonDecode(map['additionalInfo']);
      if (decodedInfo is Map<String, dynamic>) {
        additionalInfo =
            decodedInfo.map((key, value) => MapEntry(key, value.toString()));
      }
    }
    return Contact.fromMap(map)..additionalInfo = additionalInfo;
  }

  @override
  String get tableName => 'contact';

  @override
  Map<String, dynamic> toMap(Contact entity) {
    // Convert the dynamic fields to a JSON string
    final additionalInfoJson = jsonEncode(entity.additionalInfo);
    final baseMap = entity.toMap();
    baseMap['additionalInfo'] = additionalInfoJson;
    return baseMap;
  }

  Future<bool> isPhoneNumberExists(String phoneNumber) async {
    final List<Map<String, dynamic>> records = await database.query(
      tableName,
      where: 'phone1 = ? OR phone2 = ?',
      whereArgs: [phoneNumber, phoneNumber],
    );
    return records.isNotEmpty;
  }

  @override
  Future<int> create(Contact entity) async {
    bool exists = await isPhoneNumberExists(entity.phone1);
    if (exists) {
      return -1; // Indicate that the contact already exists
    }
    return await database.insert(tableName, toMap(entity));
  }

  // Method for two-way sync
  Future<void> syncContacts() async {
    List<DeviceContact.Contact> deviceContacts =
        await DeviceContact.ContactsService.getContacts();
    List<Contact> localContacts = await getAll();

    // Sync from address book to local DB
    for (var deviceContact in deviceContacts) {
      var localContact = localContacts.firstWhere(
        (contact) => contact.identifier == deviceContact.identifier,
        orElse: () => Contact(
            identifier: '',
            name: '',
            phone1: '',
            additionalInfo: {},
            phone2: '',
            organization: '',
            nickname: ''),
      );

      if (localContact.identifier!.isEmpty) {
        await create(Contact.fromDeviceContact(deviceContact));
      }
    }

    // Sync from local DB to address book
    for (var localContact in localContacts) {
      var deviceContact = deviceContacts.firstWhere(
        (contact) => contact.identifier == localContact.identifier,
        orElse: () => DeviceContact.Contact(),
      );

      if (deviceContact.identifier == null ||
          deviceContact.identifier!.isEmpty) {
        await DeviceContact.ContactsService.addContact(
            localContact.toDeviceContact());
      }
    }
  }

  // Method for searching Contacts by keyword (name, phone, or additionalInfo)
  Future<List<Contact>> quickSearchWithFallback(String keyword) async {
    final queryFields =
        _searchableFields.map((field) => '$field LIKE ?').toList();
    final whereArgs = List.filled(_searchableFields.length, '%$keyword%');
    final query = queryFields.join(' OR ');

    final List<Map<String, dynamic>> records = await database.query(
      tableName,
      where: query,
      whereArgs: whereArgs,
    );

    List<Contact> contacts = records.map((record) => fromMap(record)).toList();

    if (contacts.isEmpty) {
      final List<Map<String, dynamic>> allRecords =
          await database.query(tableName);
      contacts = allRecords
          .map((record) {
            final contact = fromMap(record);
            final additionalInfo = contact.additionalInfo;
            final isKeywordInAdditionalInfo = additionalInfo.values.any(
              (value) => value.toLowerCase().contains(keyword.toLowerCase()),
            );
            return isKeywordInAdditionalInfo ? contact : null;
          })
          .where((contact) => contact != null) // Filter out null values
          .cast<Contact>() // Cast to List<Contact>
          .toList();
    }

    return contacts;
  }

  final Set<String> _searchableFields = {'name', 'phone1', 'phone2'};
}


// // Todo Entity Repository Implementation
// class TodoEntityRepository extends EntityRepository<Todo> {
//   TodoEntityRepository({required super.database});

//   @override
//   Todo fromMap(Map<String, dynamic> map) => Todo.fromMap(map);

//   @override
//   String get tableName => 'todo';

//   @override
//   Map<String, dynamic> toMap(Todo entity) => entity.toMap();
// }
