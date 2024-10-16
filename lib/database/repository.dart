import 'dart:convert'; // Import for JSON encoding and decoding
import 'package:sqflite/sqflite.dart';
import 'package:sqliteproj/model/contacts_model.dart';
import 'package:sqliteproj/model/todo_model.dart';

// Abstract Repository Interface
abstract class Repository<T extends BaseEntity, K> {
  /// Get all
  Future<List<T>> getAll();

  /// Get one record
  Future<T?> getById(K id);

  /// Create a record
  Future<K> create(T entity);

  /// Update a record
  Future<K> update(T entity);

  /// Delete a record
  Future<bool> delete(K id);
}

// Base entity class
abstract class BaseEntity {
  int? get id; // Getter for id
}

// Abstract Entity Repository Implementation
abstract class EntityRepository<K extends BaseEntity>
    implements Repository<K, int> {
  final Database database;

  EntityRepository({required this.database});

  /// Get Name of table
  String get tableName;

  /// Convert to Map
  Map<String, dynamic> toMap(K entity);

  /// Deserialization
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
      whereArgs: [entity.id], // Now this will work since entity has an id
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

  /// Method for searching Contacts by keyword (name, phone, or additionalInfo)
  Future<List<Contact>> quickSearchWithFallback(String keyword) async {
    // Search in specified fields first
    final queryFields =
        _searchableFields.map((field) => '$field LIKE ?').toList();
    final whereArgs = List.filled(_searchableFields.length, '%$keyword%');
    final query = queryFields.join(' OR ');

    // Perform the initial query to get matching records from specified fields
    final List<Map<String, dynamic>> records = await database.query(
      tableName,
      where: query,
      whereArgs: whereArgs,
    );

    // Convert the initial query results into a list of Contacts
    List<Contact> contacts = records.map((record) => fromMap(record)).toList();

    // If no results are found, search in additionalInfo
    if (contacts.isEmpty) {
      final List<Map<String, dynamic>> allRecords =
          await database.query(tableName);
      contacts = allRecords
          .map((record) {
            final contact = fromMap(record);

            // Check if the keyword exists in the additionalInfo map values
            final additionalInfo = contact.additionalInfo;
            final isKeywordInAdditionalInfo = additionalInfo.values.any(
              (value) => value.toLowerCase().contains(keyword.toLowerCase()),
            );

            // Return the contact if the keyword is found in additionalInfo
            return isKeywordInAdditionalInfo ? contact : null;
          })
          .whereType<Contact>()
          .toList(); // Filter out nulls
    }

    return contacts;
  }

  final Set<String> _searchableFields = {'name', 'phone1', 'phone2'};
}

// Todo Entity Repository Implementation
class TodoEntityRepository extends EntityRepository<Todo> {
  TodoEntityRepository({required super.database});

  @override
  Todo fromMap(Map<String, dynamic> map) => Todo.fromMap(map);

  @override
  String get tableName => 'todo';

  @override
  Map<String, dynamic> toMap(Todo entity) => entity.toMap();

  /// Method for searching Todos by keyword (name or description)
  Future<List<Todo>> quickSearch(String keyword) async {
    final query = "name LIKE ? OR description LIKE ?";
    final List<Map<String, dynamic>> records = await database
        .query(tableName, where: query, whereArgs: ['$keyword%', '%$keyword%']);
    final List<Todo> todos = records.map((record) => fromMap(record)).toList();
    return todos;
  }
}
