import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqliteproj/database/repository.dart';
import 'package:sqliteproj/providers/theme.dart';
import 'package:sqliteproj/screen/contactsHomepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Open the database
  final Database database = await initializeDatabase();
  final contactRepository = ContactEntityRepository(database: database);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider()..initialize(),
      child: MyApp(contactRepository: contactRepository),
    ),
  );
}

// Function to initialize the database
Future<Database> initializeDatabase() async {
  String path = join(await getDatabasesPath(), 'your_database_name.db');

  return await openDatabase(
    path,
    version: 2, // Increment the version number
    onCreate: (db, version) {
      return db.execute(
        '''
        CREATE TABLE contact(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          phone1 TEXT,
          phone2 TEXT,
          nickname TEXT,
          organization TEXT,
          additionalInfo TEXT
        )
        ''',
      );
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute('ALTER TABLE contact ADD COLUMN additionalInfo TEXT');
      }
    },
  );
}

class MyApp extends StatelessWidget {
  final ContactEntityRepository contactRepository;

  MyApp({required this.contactRepository});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Contacts App',
      theme: themeProvider.themeMode == ThemeMode.dark
          ? themeProvider.darkTheme
          : themeProvider.lightTheme,
      home: ContactsHomePage(
          contactRepository: contactRepository), // Pass the repository instance
    );
  }
}
