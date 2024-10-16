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
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search Contacts',
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.black),
              )
            : Text('Contacts'),
        centerTitle: true,
        actions: [
          _isSearching
              ? IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: _cancelSearch, // Cancel search
                )
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _startSearch, // Start search
                ),
        ],
      ),
      body: Column(
        children: [
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
        onTap: () async {
          // Navigate to the ContactProfilePage with the selected contact
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContactProfilePage(
                contact: contact,
                contactRepository: widget.contactRepository,
              ),
            ),
          );

          if (result == true) {
            await _refreshContactList(); // Refresh the contact list if deleted
          } else if (result != null) {
            // If the contact was edited, update the contact in the list
            setState(() {
              int index = _contacts.indexWhere((c) => c.id == result['id']);
              if (index != -1) {
                _contacts[index] = Contact.fromMap(result);
                _filteredContacts = List.from(_contacts);
              }
            });
          }
        },
      ),
    );
  }
}
