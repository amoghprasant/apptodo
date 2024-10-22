import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqliteproj/model/contacts_model.dart';
import 'package:sqliteproj/screen/contactProfilepage.dart';
import 'package:sqliteproj/screen/createcontact.dart';
import 'package:sqliteproj/database/repository.dart';
import 'package:sqliteproj/providers/theme.dart'; // Import the ThemeProvider
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

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
      _filteredContacts =
          List.from(_contacts); // Ensure _filteredContacts is also updated
    });
  }

  Future<void> _addContact(Contact newContact) async {
    // Check if contact already exists (based on a unique identifier)
    if (_contacts.any(
        (c) => c.phone1 == newContact.phone1 || c.name == newContact.name)) {
      // You can show a message here if you want to notify the user about duplicates
      return; // Do not add the contact if it already exists
    }

    int id = await widget.contactRepository.create(newContact);
    newContact.id = id;

    // Reload contacts to avoid duplication
    await _loadContacts(); // Reload contacts to avoid duplicates
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
              // Toggle the theme
              themeProvider.toggleTheme(
                  themeProvider.themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark);
            },
          ),
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
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildContactCard(Contact contact) {
    return Dismissible(
      key: ValueKey(contact.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight, // Align to the right for left swipe
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart, // Allow left swipe for deletion
      confirmDismiss: (direction) async {
        // Show a confirmation dialog before deleting
        final confirmDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Contact'),
            content: Text('Are you sure you want to delete this contact?'),
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
          await _deleteContact(contact.id!); // Delete the contact if confirmed
          return true;
        }
        return false;
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
          onTap: () async {
            // Show dialog to select phone number for calling
            _showPhoneNumberDialog(contact);
          },
        ),
      ),
    );
  }

  // Method to show a dialog with phone numbers for the selected contact
  void _showPhoneNumberDialog(Contact contact) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Phone Number'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (contact.phone1.isNotEmpty)
                ListTile(
                  title: Text(contact.phone1),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the dialog
                    _confirmAndCall(contact.phone1); // Initiate the call
                  },
                ),
              if (contact.phone2.isNotEmpty)
                ListTile(
                  title: Text(contact.phone2),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the dialog
                    _confirmAndCall(contact.phone2); // Initiate the call
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // Method to confirm and initiate a call
  Future<void> _confirmAndCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunch(launchUri.toString())) {
      await launch(launchUri.toString());
    } else {
      // Handle the error if the device cannot make a call
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch the dialer.')),
      );
    }
  }
}
