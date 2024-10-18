import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqliteproj/model/contacts_model.dart';
import 'package:sqliteproj/screen/contactProfilepage.dart';
import 'package:sqliteproj/screen/createcontact.dart';
import 'package:sqliteproj/database/repository.dart';
import 'package:sqliteproj/providers/theme.dart'; // Import the ThemeProvider

class ContactsHomePage extends StatefulWidget {
  final ContactEntityRepository contactRepository;

  ContactsHomePage({required this.contactRepository});

  @override
  _ContactsHomePageState createState() => _ContactsHomePageState();
}

class _ContactsHomePageState extends State<ContactsHomePage> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false; // State variable to track search mode

  @override
  void initState() {
    super.initState();
    _loadContacts();
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
      if (searchText.isEmpty) {
        _filteredContacts = List.from(_contacts);
      } else {
        _filteredContacts = _contacts.where((contact) {
          return contact.name.toLowerCase().contains(searchText) ||
              contact.nickname.toLowerCase().contains(searchText) ||
              contact.phone1.toLowerCase().contains(searchText) ||
              contact.phone2.toLowerCase().contains(searchText);
        }).toList();
      }
    });
  }

  Future<void> _loadContacts() async {
    List<Contact> contacts = await widget.contactRepository.getAll();
    contacts
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    setState(() {
      _contacts = contacts;
      _filteredContacts = List.from(_contacts);
    });
  }

  Future<void> _addContact(Contact newContact) async {
    int id = await widget.contactRepository.create(newContact);
    newContact.id = id;
    setState(() {
      _contacts.add(newContact);
      _filteredContacts = List.from(_contacts);
    });
  }

  Future<void> _deleteContact(int contactId) async {
    await widget.contactRepository.delete(contactId);
    _loadContacts(); // Refresh the contact list after deletion
  }

  Future<void> _refreshContactList() async {
    await _loadContacts(); // Reload contacts to refresh the list
  }

  void _startSearch() {
    setState(() {
      _isSearching = true; // Enable search mode
    });
  }

  void _cancelSearch() {
    setState(() {
      _isSearching = false; // Disable search mode
      _searchController.clear(); // Clear the search text
      _filteredContacts = List.from(_contacts); // Show all contacts again
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider =
        Provider.of<ThemeProvider>(context); // Access ThemeProvider

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
          final newContactMap = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateContactPage(
                contactRepository: widget.contactRepository,
              ),
            ),
          );

          if (newContactMap != null) {
            Contact newContact = Contact.fromMap(newContactMap);
            await _addContact(newContact);
          }
        },
        backgroundColor: Colors.blueAccent, // Floating action button color
        child: Icon(Icons.add),
      ),
    );
  }

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
