import 'package:flutter/material.dart';
import 'package:sqliteproj/model/contacts_model.dart';

import 'package:sqliteproj/screen/contactProfilepage.dart';
import 'package:sqliteproj/screen/createcontact.dart';
import 'package:sqliteproj/database/repository.dart';

class ContactsHomePage extends StatefulWidget {
  final ContactEntityRepository contactRepository;

  ContactsHomePage({required this.contactRepository});

  @override
  _ContactsHomePageState createState() => _ContactsHomePageState();
}

class _ContactsHomePageState extends State<ContactsHomePage> {
  List<Contact> _contacts = []; // List to hold contact details
  List<Contact> _filteredContacts = []; // List to hold filtered contact details
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
      // Filter contacts based on the search text
      if (searchText.isEmpty) {
        _filteredContacts =
            List.from(_contacts); // Show all contacts if search is empty
      } else {
        _filteredContacts = _contacts.where((contact) {
          // Check if the search text matches the name, nickname, phone1, or phone2
          return contact.name.toLowerCase().contains(searchText) ||
              contact.nickname.toLowerCase().contains(searchText) ||
              contact.phone1.toLowerCase().contains(searchText) ||
              contact.phone2.toLowerCase().contains(searchText);
        }).toList();
      }
    });
  }

  Future<void> _loadContacts() async {
    // Fetch contacts from the database
    List<Contact> contacts = await widget.contactRepository.getAll();
    setState(() {
      _contacts = contacts;
      _filteredContacts = List.from(_contacts); // Initialize filtered contacts
    });
  }

  Future<void> _addContact(Contact newContact) async {
    // Save the new contact to the database
    int id = await widget.contactRepository.create(newContact);
    newContact.id = id; // Update the contact's ID with the generated ID

    setState(() {
      _contacts.add(newContact);
      _filteredContacts = List.from(_contacts); // Update filtered contacts
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Contacts',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _filteredContacts.isNotEmpty
                ? ListView.builder(
                    itemCount: _filteredContacts.length,
                    itemBuilder: (context, index) {
                      return _buildContactCard(_filteredContacts[index]);
                    },
                  )
                : Center(
                    child: Text(
                      'No contacts found.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to the CreateContactPage and pass the contactRepository
          final newContactMap = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateContactPage(
                contactRepository: widget.contactRepository,
              ),
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

  // Helper method to build a styled card for each contact
  Widget _buildContactCard(Contact contact) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Text(
            contact.nickname.isNotEmpty
                ? contact.nickname[0].toUpperCase()
                : '?',
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          contact.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(contact.phone1),
        onTap: () {
          // Navigate to the ContactProfilePage with the selected contact
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContactProfilePage(
                contact: contact,
              ),
            ),
          );
        },
      ),
    );
  }
}
//instead of map