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
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              // Confirm deletion
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
                await contactRepository.delete(contact.id!);
                Navigator.of(context)
                    .pop(true); // Indicate that a contact was deleted
              }
            },
          ),
        ],
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
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ...contact.additionalInfo.entries.map((entry) {
              return _buildContactInfoTile(
                icon: Icons.info,
                label: entry.key,
                value: entry.value,
              );
            }).toList(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Navigate to CreateContactPage for editing
                final updatedContactMap = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateContactPage(
                      contactRepository: contactRepository,
                      existingContact: contact, // Pass the existing contact
                    ),
                  ),
                );

                if (updatedContactMap != null) {
                  Navigator.of(context)
                      .pop(updatedContactMap); // Return the updated contact
                }
              },
              child: Text('Edit Contact'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
      tileColor: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
