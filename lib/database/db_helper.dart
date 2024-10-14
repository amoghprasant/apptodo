import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper dbHelper = DBHelper._secretDBConstructor();
  static Database? _database;

  DBHelper._secretDBConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'my_database.db');
    return await openDatabase(
      path,
      version: 2, // Increment the version number
      onCreate: _createDatabase,
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < newVersion) {
          // Create the todo table if it doesn't exist
          await db.execute('''
            CREATE TABLE IF NOT EXISTS todo (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              description TEXT
            )
          ''');

          // Create the contact table if it doesn't exist
          await db.execute('''
            CREATE TABLE IF NOT EXISTS contact (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              nickname TEXT,
              phone1 TEXT,
              phone2 TEXT,
              organization TEXT
            )
          ''');
        }
      },
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create the todo table
    await db.execute('''
      CREATE TABLE todo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT
      )
    ''');

    // Create the contact table
    await db.execute('''
      CREATE TABLE contact (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        nickname TEXT,
        phone1 TEXT,
        phone2 TEXT,
        organization TEXT
      )
    ''');
  }
}
