import 'package:flutter/material.dart';
import 'package:sqliteproj/model/contacts_model.dart'; // Ensure you import the Contact model

class ContactProfilePage extends StatelessWidget {
  final Contact contact; // Change to accept a Contact object

  ContactProfilePage({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contact.name), // Use contact.name directly
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${contact.name}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Nickname: ${contact.nickname}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Phone Number 1: ${contact.phone1 ?? 'N/A'}', // Assuming phone1 can be null
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Phone Number 2: ${contact.phone2 ?? 'N/A'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Organization: ${contact.organization ?? 'N/A'}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
