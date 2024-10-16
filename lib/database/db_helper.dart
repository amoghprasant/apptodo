import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> _initDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'my_database.db');
  return await openDatabase(
    path,
    version: 2,
    onCreate: _createDatabase,
    onUpgrade: (Database db, int oldVersion, int newVersion) async {
      if (oldVersion < newVersion) {
        // Create the contact table if it doesn't exist
        await db.execute('''
          CREATE TABLE IF NOT EXISTS contact (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            nickname TEXT,
            phone1 TEXT,
            phone2 TEXT,
            organization TEXT,
            additionalInfo TEXT
          )
        ''');
      }
    },
  );
}

Future<void> _createDatabase(Database db, int version) async {
  // Create the contact table
  await db.execute('''
    CREATE TABLE contact (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      nickname TEXT,
      phone1 TEXT,
      phone2 TEXT,
      organization TEXT,
      additionalInfo TEXT
    )
  ''');
}
