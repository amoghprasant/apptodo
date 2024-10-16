import 'package:flutter/material.dart';
import 'package:sqliteproj/model/contacts_model.dart';
import 'package:sqliteproj/database/repository.dart';

class CreateContactPage extends StatefulWidget {
  final ContactEntityRepository contactRepository;

  CreateContactPage({required this.contactRepository});

  @override
  _CreateContactPageState createState() => _CreateContactPageState();
}

class _CreateContactPageState extends State<CreateContactPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _nicknameController = TextEditingController();
  TextEditingController _phone1Controller = TextEditingController();
  TextEditingController _phone2Controller = TextEditingController();
  TextEditingController _organizationController = TextEditingController();

  List<Map<String, TextEditingController>> _additionalFields = [];

  void _addAdditionalField() {
    setState(() {
      _additionalFields.add({
        'key': TextEditingController(),
        'value': TextEditingController(),
      });
    });
  }

  Future<void> _saveContact() async {
    if (_formKey.currentState!.validate()) {
      Map<String, String> additionalInfo = {};
      for (var field in _additionalFields) {
        String key = field['key']!.text;
        String value = field['value']!.text;
        if (key.isNotEmpty && value.isNotEmpty) {
          additionalInfo[key] = value;
        }
      }

      Contact newContact = Contact(
        name: _nameController.text,
        nickname: _nicknameController.text,
        phone1: _phone1Controller.text,
        phone2: _phone2Controller.text,
        organization: _organizationController.text,
        additionalInfo: additionalInfo,
      );

      await widget.contactRepository.create(newContact);
      Navigator.pop(context, newContact.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Contact'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Name',
                validator: (value) => value!.isEmpty ? 'Enter name' : null,
              ),
              _buildTextField(
                controller: _nicknameController,
                label: 'Nickname',
              ),
              _buildTextField(
                controller: _phone1Controller,
                label: 'Phone Number 1',
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? 'Enter phone number' : null,
              ),
              _buildTextField(
                controller: _phone2Controller,
                label: 'Phone Number 2',
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                controller: _organizationController,
                label: 'Organization',
              ),
              SizedBox(height: 20),
              Text(
                'Additional Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
              ..._additionalFields.map((field) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: field['key']!,
                        label: 'Field Name',
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(
                        controller: field['value']!,
                        label: 'Field Value',
                      ),
                    ),
                  ],
                );
              }).toList(),
              TextButton.icon(
                onPressed: _addAdditionalField,
                icon: Icon(Icons.add, color: Colors.blueAccent),
                label: Text(
                  'Add More Fields',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveContact,
                child: Text(
                  'Save Contact',
                  style: TextStyle(color: Colors.black), // Black text color
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create styled text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.blueAccent, width: 1.5),
          ),
          contentPadding:
              EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        ),
        validator: validator,
        keyboardType: keyboardType,
      ),
    );
  }
}
