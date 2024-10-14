import 'package:flutter/material.dart';
import 'package:sqliteproj/model/contacts_model.dart';
import 'package:sqliteproj/screen/createcontact.dart';
import 'package:sqliteproj/database/repository.dart'; // Import repository

class ContactsHomePage extends StatefulWidget {
  final ContactEntityRepository contactRepository;

  ContactsHomePage({required this.contactRepository});

  @override
  _ContactsHomePageState createState() => _ContactsHomePageState();
}

class _ContactsHomePageState extends State<ContactsHomePage> {
  List<Contact> _contacts = []; // List to hold contact details
  List<Contact> _filteredContacts = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts(); // Load contacts from the database
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterContacts);
    _searchController.dispose();
    super.dispose();
  }

  void _filterContacts() {
    String searchText = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = _contacts
          .where((contact) => contact.name.toLowerCase().contains(searchText))
          .toList();
    });
  }

  Future<void> _loadContacts() async {
    // Fetch contacts from the database
    List<Contact> contacts = await widget.contactRepository.getAll();
    setState(() {
      _contacts = contacts;
      _filteredContacts = _contacts;
    });
  }

  Future<void> _addContact(Contact newContact) async {
    // Save the new contact to the database
    int id = await widget.contactRepository.create(newContact);
    newContact.id = id; // Update the contact's ID with the generated ID

    setState(() {
      _contacts.add(newContact);
      _filteredContacts = _contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Contacts',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredContacts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_filteredContacts[index].name),
                  leading: CircleAvatar(
                    child: Text(_filteredContacts[index]
                        .nickname[0]), // Display first letter of nickname
                  ),
                  onTap: () {
                    // Handle contact tap (e.g., navigate to a contact detail page)
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to the CreateContactPage
          final newContactMap = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateContactPage(),
            ),
          );

          // Check if new contact is not null and add it to the list
          if (newContactMap != null) {
            Contact newContact = Contact.fromMap(newContactMap);
            await _addContact(newContact);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
