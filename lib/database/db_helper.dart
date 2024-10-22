import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:contacts_service/contacts_service.dart' as DeviceContact;
import 'package:sqliteproj/model/contacts_model.dart'; // Ensure this path is correct

class DBHelper {
  static Database? _db;

  // Default Contact
  static Contact get defaultContact => Contact(
        id: 0, // or some other default value
        name: '',
        phone1: '',
        phone2: '',
        nickname: '',
        organization: '',
        additionalInfo: {},
        identifier: 'default', // Add a default identifier
      );

  // Initialize the database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'my_database.db');
    return await openDatabase(
      path,
      version: 3, // Increment the version to handle schema updates
      onCreate: _createDatabase,
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 3) {
          // Add 'identifier' column for sync purposes
          await db.execute('ALTER TABLE contact ADD COLUMN identifier TEXT');
        }
      },
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create the contact table with identifier field
    await db.execute('''
      CREATE TABLE contact (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        identifier TEXT,  
        name TEXT,
        nickname TEXT,
        phone1 TEXT,
        phone2 TEXT,
        organization TEXT,
        additionalInfo TEXT
        identifier TEXT
      )
    ''');
  }

  // Open the database or create it if it doesn't exist
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  // Fetch all contacts from the local database
  Future<List<Contact>> getAllContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('contact');

    return List.generate(maps.length, (i) {
      return Contact(
        id: maps[i]['id'],
        identifier: maps[i]['identifier'] ?? 'default',
        name: maps[i]['name'],
        nickname: maps[i]['nickname'],
        phone1: maps[i]['phone1'],
        phone2: maps[i]['phone2'],
        organization: maps[i]['organization'],
        additionalInfo: jsonDecode(maps[i]['additionalInfo'] ?? '{}'),
      );
    });
  }

  // Insert a new contact into the database
  Future<void> insertContact(Contact contact) async {
    final db = await database;
    await db.insert(
      'contact',
      contact.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update a contact in the local database
  Future<void> updateContact(Contact contact) async {
    final db = await database;
    await db.update(
      'contact',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  // Delete a contact from the local database
  Future<void> deleteContact(int id) async {
    final db = await database;
    await db.delete(
      'contact',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all contacts (if needed)
  Future<void> deleteAllContacts() async {
    final db = await database;
    await db.delete('contact');
  }
}
