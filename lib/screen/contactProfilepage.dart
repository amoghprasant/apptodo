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
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildContactInfoCard(
              icon: Icons.person,
              label: 'Name',
              value: contact.name,
            ),
            SizedBox(height: 10),
            _buildContactInfoCard(
              icon: Icons.alternate_email,
              label: 'Nickname',
              value: contact.nickname.isNotEmpty ? contact.nickname : 'N/A',
            ),
            SizedBox(height: 10),
            _buildContactInfoCard(
              icon: Icons.phone,
              label: 'Phone Number 1',
              value: contact.phone1.isNotEmpty ? contact.phone1 : 'N/A',
            ),
            SizedBox(height: 10),
            _buildContactInfoCard(
              icon: Icons.phone_android,
              label: 'Phone Number 2',
              value: contact.phone2.isNotEmpty ? contact.phone2 : 'N/A',
            ),
            SizedBox(height: 10),
            _buildContactInfoCard(
              icon: Icons.business,
              label: 'Organization',
              value: contact.organization.isNotEmpty
                  ? contact.organization
                  : 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a styled card for displaying contact information
  Widget _buildContactInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.blueAccent),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
