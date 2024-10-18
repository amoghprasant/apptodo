import 'package:flutter/material.dart';
import 'package:sqliteproj/model/contacts_model.dart';
import 'package:sqliteproj/database/repository.dart';
import 'package:sqliteproj/screen/createcontact.dart';

class ContactProfilePage extends StatelessWidget {
  final Contact contact;
  final ContactEntityRepository contactRepository;

  const ContactProfilePage(
      {Key? key, required this.contact, required this.contactRepository})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contact.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildContactInfoTile(
              icon: Icons.person,
              label: 'Name',
              value: contact.name,
            ),
            _buildContactInfoTile(
              icon: Icons.alternate_email,
              label: 'Nickname',
              value: contact.nickname.isNotEmpty ? contact.nickname : 'N/A',
            ),
            _buildContactInfoTile(
              icon: Icons.phone,
              label: 'Phone Number 1',
              value: contact.phone1.isNotEmpty ? contact.phone1 : 'N/A',
            ),
            _buildContactInfoTile(
              icon: Icons.phone_android,
              label: 'Phone Number 2',
              value: contact.phone2.isNotEmpty ? contact.phone2 : 'N/A',
            ),
            _buildContactInfoTile(
              icon: Icons.business,
              label: 'Organization',
              value: contact.organization.isNotEmpty
                  ? contact.organization
                  : 'N/A',
            ),
            SizedBox(height: 20),
            Text(
              'Additional Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Set text color to black
                  ),
            ),
            ...contact.additionalInfo?.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    subtitle: Text(entry.value),
                  );
                }).toList() ??
                [],
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoCard(
      {required IconData icon, required String label, required String value}) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }

  IconData _getIconForKey(String key) {
    // Map keys to specific icons
    switch (key.toLowerCase()) {
      case 'email':
        return Icons.email;
      case 'address':
        return Icons.location_on;
      case 'birthday':
        return Icons.cake;
      case 'notes':
        return Icons.notes;
      default:
        return Icons.info; // Default icon for unspecified keys
    }
  }
}
