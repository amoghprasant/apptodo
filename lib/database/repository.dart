import 'package:sqflite/sqflite.dart';

import 'package:sqliteproj/model/contacts_model.dart';
import 'package:sqliteproj/model/todo_model.dart'; // Add this import for fuzzy search

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
    List<Todo> filteredTodos = todos;

    // // Filter based on fuzzy matching
    // final filteredTodos = todos.where((todo) {
    //   final nameScore = ratio(todo.name.toLowerCase(), keyword.toLowerCase());
    //   final descriptionScore =
    //       ratio(todo.description.toLowerCase(), keyword.toLowerCase());
    //   // Consider as a match if either score is above a certain threshold (e.g., 70)
    //   return nameScore > 70 || descriptionScore > 70;
    // }).toList();

    return filteredTodos;
  }
}

// Contact Entity Repository Implementation
class ContactEntityRepository extends EntityRepository<Contact> {
  ContactEntityRepository({required super.database});

  @override
  Contact fromMap(Map<String, dynamic> map) => Contact.fromMap(map);

  @override
  String get tableName => 'contact';

  @override
  Map<String, dynamic> toMap(Contact entity) => entity.toMap();
  Future<bool> isPhoneNumberExists(String phoneNumber) async {
    final List<Map<String, dynamic>> records = await database.query(
      tableName,
      where: 'phone1 = ? OR phone2 = ?',
      whereArgs: [phoneNumber, phoneNumber],
    );
    return records.isNotEmpty;
  }

  /// Method for searching Contacts by keyword (name, nickname, or organization)
  Future<List<Contact>> quickSearch(String keyword) async {
    final query =
        "name LIKE ? OR nickname LIKE ? OR organization LIKE ?OR phone1 LIKE ? OR phone2 LIKE ?";
    final List<Map<String, dynamic>> records = await database.query(
      tableName,
      where: query,
      whereArgs: [
        '$keyword%',
        '$keyword%',
        '$keyword%' '$keyword%',
        '$keyword%'
      ],
    );
    final List<Contact> contacts =
        records.map((record) => fromMap(record)).toList();
    List<Contact> filteredContacts = contacts;

    // // Filter based on fuzzy matching
    // final filteredContacts = contacts.where((contact) {
    //   final nameScore = ratio(contact.name.toLowerCase(), keyword.toLowerCase());
    //   final nicknameScore = ratio(contact.nickname.toLowerCase(), keyword.toLowerCase());
    //   final organizationScore = ratio(contact.organization.toLowerCase(), keyword.toLowerCase());
    //   // Consider as a match if any score is above a certain threshold (e.g., 70)
    //   return nameScore > 70 || nicknameScore > 70 || organizationScore > 70;
    // }).toList();

    return filteredContacts;
  }
}
