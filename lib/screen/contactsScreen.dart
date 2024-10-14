import 'package:flutter/material.dart';
import 'package:sqliteproj/screen/createcontact.dart';
// Import the CreateContactPage

class ContactsHomePage extends StatefulWidget {
  @override
  _ContactsHomePageState createState() => _ContactsHomePageState();
}

class _ContactsHomePageState extends State<ContactsHomePage> {
  List<Map<String, String>> _contacts = []; // List to hold contact details
  List<Map<String, String>> _filteredContacts = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredContacts = _contacts;
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
          .where(
              (contact) => contact['name']!.toLowerCase().contains(searchText))
          .toList();
    });
  }

  void _addContact(Map<String, String> newContact) {
    setState(() {
      _contacts.add(newContact);
      _filteredContacts =
          _contacts; // Update filtered list to include the new contact
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
                  title: Text(_filteredContacts[index]['name']!),
                  leading: CircleAvatar(
                    child: Text(_filteredContacts[index]
                        ['nickname']![0]), // Display first letter of nickname
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
          final newContact = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateContactPage(),
            ),
          );

          // Check if new contact is not null and add it to the list
          if (newContact != null) {
            _addContact(newContact);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
