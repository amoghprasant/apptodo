import 'package:flutter/material.dart';
import 'package:sqliteproj/model/contacts_model.dart';
import 'package:sqliteproj/database/repository.dart';

class CreateContactPage extends StatelessWidget {
  final ContactEntityRepository contactRepository;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController phone1Controller = TextEditingController();
  final TextEditingController phone2Controller = TextEditingController();
  final TextEditingController organizationController = TextEditingController();

  CreateContactPage({required this.contactRepository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Contact'),
        centerTitle: true,
        backgroundColor: Colors.blue, // Custom app bar color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          color: Colors.grey[100], // Light background color for the card
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildTextField(
                  controller: nameController,
                  labelText: 'Name',
                  icon: Icons.person,
                ),
                SizedBox(height: 10),
                _buildTextField(
                  controller: nicknameController,
                  labelText: 'Nickname',
                  icon: Icons.alternate_email,
                ),
                SizedBox(height: 10),
                _buildTextField(
                  controller: phone1Controller,
                  labelText: 'Phone Number 1',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 10),
                _buildTextField(
                  controller: phone2Controller,
                  labelText: 'Phone Number 2',
                  icon: Icons.phone_android,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 10),
                _buildTextField(
                  controller: organizationController,
                  labelText: 'Organization',
                  icon: Icons.business,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor:
                        const Color.fromARGB(255, 9, 20, 225), // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 12.0),
                  ),
                  onPressed: () async {
                    // Retrieve values from the text controllers
                    String name = nameController.text.trim();
                    String nickname = nicknameController.text.trim();
                    String phone1 = phone1Controller.text.trim();
                    String phone2 = phone2Controller.text.trim();
                    String organization = organizationController.text.trim();

                    // Ensure the name is not empty
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Name cannot be empty')),
                      );
                      return;
                    }

                    // Check if phone number already exists
                    bool isPhone1Exists =
                        await contactRepository.isPhoneNumberExists(phone1);
                    bool isPhone2Exists = phone2.isNotEmpty
                        ? await contactRepository.isPhoneNumberExists(phone2)
                        : false;

                    if (isPhone1Exists || isPhone2Exists) {
                      // Show a warning dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Duplicate Phone Number'),
                          content: Text(
                              'The phone number is already saved as a contact. Do you want to continue?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(); // Dismiss the dialog
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(); // Dismiss the dialog
                                // Proceed to add the contact
                                _addContact(context, name, nickname, phone1,
                                    phone2, organization);
                              },
                              child: Text('Continue'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Add the contact directly if no duplicate found
                      _addContact(context, name, nickname, phone1, phone2,
                          organization);
                    }
                  },
                  child: Text(
                    'Add Contact',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build a styled text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.blue), // Focused border color
        ),
        prefixIcon: Icon(icon, color: Colors.blue),
      ),
      keyboardType: keyboardType,
    );
  }

  void _addContact(BuildContext context, String name, String nickname,
      String phone1, String phone2, String organization) {
    Navigator.pop(context, {
      'name': name,
      'nickname': nickname.isNotEmpty ? nickname : 'N/A',
      'phone1': phone1.isNotEmpty ? phone1 : 'N/A',
      'phone2': phone2.isNotEmpty ? phone2 : 'N/A',
      'organization': organization.isNotEmpty ? organization : 'N/A',
    });
  }
}
