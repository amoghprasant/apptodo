import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqliteproj/database/repository.dart';
import 'package:sqliteproj/screen/contactsHomepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Open the database
  final database = await openDatabase(
    join(await getDatabasesPath(), 'contacts.db'),
    onCreate: (db, version) {
      // Create the contacts table
      return db.execute(
        'CREATE TABLE contact(id INTEGER PRIMARY KEY, name TEXT, nickname TEXT, phone1 TEXT, phone2 TEXT, organization TEXT)',
      );
    },
    version: 1,
  );

  final contactRepository = ContactEntityRepository(database: database);

  runApp(MyApp(contactRepository: contactRepository));
}

class MyApp extends StatelessWidget {
  final ContactEntityRepository contactRepository;

  MyApp({required this.contactRepository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ContactsHomePage(
          contactRepository: contactRepository), // Pass the repository instance
    );
  }
}
