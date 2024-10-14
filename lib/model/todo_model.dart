import 'package:sqliteproj/database/repository.dart';

class Todo extends BaseEntity {
  @override
  int? id; // Make id field available

  String name;
  String description;

  Todo({
    this.id,
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
    );
  }
}
