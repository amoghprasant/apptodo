import 'package:flutter/material.dart';
import 'package:sqliteproj/model/contacts_model.dart';

class ContactProfilePage extends StatelessWidget {
  final Contact contact;

  ContactProfilePage({required this.contact});

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
            SizedBox(height: 20),
            Text(
              'Additional Information',
              style: Theme.of(context).textTheme.titleLarge,
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
}
