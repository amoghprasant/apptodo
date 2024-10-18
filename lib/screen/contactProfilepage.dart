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
              context: context,
            ),
            _buildContactInfoTile(
              icon: Icons.alternate_email,
              label: 'Nickname',
              value: contact.nickname.isNotEmpty ? contact.nickname : 'N/A',
              context: context,
            ),
            _buildContactInfoTile(
              icon: Icons.phone,
              label: 'Phone Number 1',
              value: contact.phone1.isNotEmpty ? contact.phone1 : 'N/A',
              context: context,
            ),
            _buildContactInfoTile(
              icon: Icons.phone_android,
              label: 'Phone Number 2',
              value: contact.phone2.isNotEmpty ? contact.phone2 : 'N/A',
              context: context,
            ),
            _buildContactInfoTile(
              icon: Icons.business,
              label: 'Organization',
              value: contact.organization.isNotEmpty
                  ? contact.organization
                  : 'N/A',
              context: context,
            ),
            SizedBox(height: 20),
            Text(
              'Additional Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ...contact.additionalInfo.entries.map((entry) {
              return _buildContactInfoTile(
                icon: _getIconForKey(entry.key),
                label: entry.key,
                value: entry.value,
                context: context,
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
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue),
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
    required BuildContext context,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
      tileColor: isDarkMode
          ? Colors.grey[800] // Darker background for dark mode
          : Colors.grey[200], // Lighter background for light mode
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      visualDensity: VisualDensity.adaptivePlatformDensity,
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
