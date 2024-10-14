import 'package:flutter/material.dart';

class CreateContactPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController phone1Controller = TextEditingController();
  final TextEditingController phone2Controller = TextEditingController();
  final TextEditingController organizationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: nicknameController,
              decoration: InputDecoration(labelText: 'Nickname'),
            ),
            TextField(
              controller: phone1Controller,
              decoration: InputDecoration(labelText: 'Phone Number 1'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: phone2Controller,
              decoration: InputDecoration(labelText: 'Phone Number 2'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: organizationController,
              decoration: InputDecoration(labelText: 'Organization'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Retrieve values from the text controllers
                String name = nameController.text.trim();
                String nickname = nicknameController.text.trim();
                String phone1 = phone1Controller.text.trim();
                String phone2 = phone2Controller.text.trim();
                String organization = organizationController.text.trim();

                // Ensure the name is not empty
                if (name.isNotEmpty) {
                  Navigator.pop(context, {
                    'name': name,
                    'nickname': nickname.isNotEmpty
                        ? nickname
                        : 'N/A', // Default value for nickname
                    'phone1': phone1.isNotEmpty
                        ? phone1
                        : 'N/A', // Default value for phone 1
                    'phone2': phone2.isNotEmpty
                        ? phone2
                        : 'N/A', // Default value for phone 2
                    'organization': organization.isNotEmpty
                        ? organization
                        : 'N/A', // Default value for organization
                  });
                } else {
                  // Show a warning if the name is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Name cannot be empty')),
                  );
                }
              },
              child: Text('Add Contact'),
            ),
          ],
        ),
      ),
    );
  }
}
