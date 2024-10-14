import 'package:sqflite/sqflite.dart';
import 'package:sqliteproj/model/todo_model.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart'; // Add this import for fuzzy search

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
