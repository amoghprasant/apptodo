import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqliteproj/model/contacts_model.dart';
import 'package:sqliteproj/screen/contactProfilepage.dart'; // Adjust the import path if necessary
import 'package:sqliteproj/screen/createcontact.dart';
import 'package:sqliteproj/database/repository.dart';
import 'package:sqliteproj/providers/theme.dart';
import 'package:contacts_service/contacts_service.dart'
    as DeviceContact; // Import for syncing contacts
import 'dart:convert';

class ContactsHomePage extends StatefulWidget {
  final ContactEntityRepository contactRepository;

  // Constructor with required contactRepository parameter
  ContactsHomePage({required this.contactRepository});

  @override
  _ContactsHomePageState createState() => _ContactsHomePageState();
}

class _ContactsHomePageState extends State<ContactsHomePage> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

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
    await _syncContacts(); // Synchronize contacts before loading
    List<Contact> contacts = await widget.contactRepository.getAll();
    contacts
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    setState(() {
      _contacts = contacts;
      _filteredContacts = List.from(_contacts);
    });
  }

  Future<void> _syncContacts() async {
    List<DeviceContact.Contact> deviceContacts =
        await DeviceContact.ContactsService.getContacts();
    print('Device Contacts: ${deviceContacts.length}'); // Debug log

    // Get local contacts from the database
    List<Contact> localContacts = await widget.contactRepository.getAll();

    // Sync from address book to local DB
    for (var deviceContact in deviceContacts) {
      var localContact = localContacts.firstWhere(
        (contact) => contact.identifier == deviceContact.identifier,
        orElse: () => Contact(
          identifier: '',
          name: deviceContact.displayName ?? '',
          phone1: deviceContact.phones?.isNotEmpty == true
              ? deviceContact.phones!.first.value!
              : '',
          additionalInfo: {},
          phone2: '',
          organization: deviceContact.company ?? '', nickname: '',
          // nickname: deviceContact.nickname ?? '',
        ),
      );

      if (localContact.identifier!.isEmpty) {
        await widget.contactRepository
            .create(Contact.fromDeviceContact(deviceContact));
      }
    }

    // Sync from local DB to address book
    for (var localContact in localContacts) {
      var deviceContact = deviceContacts.firstWhere(
        (contact) => contact.identifier == localContact.identifier,
        orElse: () => DeviceContact.Contact(),
      );

      if (deviceContact.identifier == null ||
          deviceContact.identifier!.isEmpty) {
        await DeviceContact.ContactsService.addContact(
            localContact.toDeviceContact());
      }
    }
  }

  Future<void> _addContact(Contact newContact) async {
    if (_contacts.any(
        (c) => c.phone1 == newContact.phone1 || c.name == newContact.name)) {
      return; // Do not add the contact if it already exists
    }
    int id = await widget.contactRepository.create(newContact);
    newContact.id = id;
    await _loadContacts(); // Reload contacts
  }

  Future<void> _deleteContact(int contactId) async {
    await widget.contactRepository.delete(contactId);
    _loadContacts(); // Refresh the contact list after deletion
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
    final themeProvider = Provider.of<ThemeProvider>(context);

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
                style:
                    TextStyle(color: const Color.fromARGB(255, 243, 242, 242)),
              )
            : Text('Contacts'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.wb_sunny
                  : Icons.nightlight_round,
            ),
            onPressed: () {
              themeProvider.toggleTheme(
                  themeProvider.themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark);
            },
          ),
          _isSearching
              ? IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: _cancelSearch,
                )
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _startSearch,
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
                  contactRepository: widget.contactRepository),
            ),
          );

          if (newContactMap != null) {
            Contact newContact = Contact.fromMap(newContactMap);
            await _addContact(newContact);
          }
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildContactCard(Contact contact) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContactProfilePage(
                contact: contact,
                contactRepository:
                    widget.contactRepository), // Navigate to Profile Page
          ),
        );
      },
      child: Card(
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
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              // Confirm deletion before deleting
              final confirmDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Delete Contact'),
                  content:
                      Text('Are you sure you want to delete this contact?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirmDelete == true) {
                await _deleteContact(contact.id!);
              }
            },
          ),
        ),
      ),
    );
  }
}
