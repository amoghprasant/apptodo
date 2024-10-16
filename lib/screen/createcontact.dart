import 'package:flutter/material.dart';
import 'package:sqliteproj/model/contacts_model.dart';
import 'package:sqliteproj/database/repository.dart';

class CreateContactPage extends StatefulWidget {
  final ContactEntityRepository contactRepository;
  final Contact? existingContact; // Nullable existing contact

  CreateContactPage({
    required this.contactRepository,
    this.existingContact,
  });

  @override
  _CreateContactPageState createState() => _CreateContactPageState();
}

class _CreateContactPageState extends State<CreateContactPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _nicknameController;
  late TextEditingController _phone1Controller;
  late TextEditingController _phone2Controller;
  late TextEditingController _organizationController;

  List<Map<String, TextEditingController>> _additionalFields = [];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing contact data if available
    _nameController = TextEditingController(text: widget.existingContact?.name);
    _nicknameController =
        TextEditingController(text: widget.existingContact?.nickname);
    _phone1Controller =
        TextEditingController(text: widget.existingContact?.phone1);
    _phone2Controller =
        TextEditingController(text: widget.existingContact?.phone2);
    _organizationController =
        TextEditingController(text: widget.existingContact?.organization);

    // Load additional fields if the existing contact has them
    if (widget.existingContact != null) {
      widget.existingContact!.additionalInfo.forEach((key, value) {
        _additionalFields.add({
          'key': TextEditingController(text: key),
          'value': TextEditingController(text: value),
        });
      });
    }
  }

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

      Contact contact = Contact(
        id: widget
            .existingContact?.id, // Keep the ID if editing an existing contact
        name: _nameController.text,
        nickname: _nicknameController.text,
        phone1: _phone1Controller.text,
        phone2: _phone2Controller.text,
        organization: _organizationController.text,
        additionalInfo: additionalInfo,
      );

      if (widget.existingContact == null) {
        await widget.contactRepository.create(contact); // Create new contact
      } else {
        await widget.contactRepository
            .update(contact); // Update existing contact
      }

      Navigator.pop(context, contact.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.existingContact == null ? 'Create Contact' : 'Edit Contact'),
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
                child: Text(widget.existingContact == null
                    ? 'Save Contact'
                    : 'Update Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
