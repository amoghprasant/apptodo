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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                controller: _nicknameController,
                decoration: InputDecoration(labelText: 'Nickname'),
              ),
              TextFormField(
                controller: _phone1Controller,
                decoration: InputDecoration(labelText: 'Phone Number 1'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? 'Enter phone number' : null,
              ),
              TextFormField(
                controller: _phone2Controller,
                decoration: InputDecoration(labelText: 'Phone Number 2'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _organizationController,
                decoration: InputDecoration(labelText: 'Organization'),
              ),
              SizedBox(height: 20),
              Text('Additional Information'),
              ..._additionalFields.map((field) {
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: field['key'],
                        decoration: InputDecoration(labelText: 'Field Name'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: field['value'],
                        decoration: InputDecoration(labelText: 'Field Value'),
                      ),
                    ),
                  ],
                );
              }).toList(),
              TextButton(
                onPressed: _addAdditionalField,
                child: Text('Add More Fields'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveContact,
                child: Text('Save Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
