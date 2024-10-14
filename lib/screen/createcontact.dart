import 'package:flutter/material.dart';

class CreateContactPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();

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
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: nicknameController,
              decoration: InputDecoration(labelText: 'Nickname'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Create a contact object or pass the data back
                String name = nameController.text.trim();
                String phone = phoneController.text.trim();
                String nickname = nicknameController.text.trim();

                if (name.isNotEmpty) {
                  Navigator.pop(context, {
                    'name': name,
                    'phone': phone,
                    'nickname': nickname,
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
