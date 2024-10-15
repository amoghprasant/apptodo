import 'package:flutter/material.dart';
import 'package:sqliteproj/database/repository.dart';
import 'package:sqliteproj/model/contacts_model.dart';

class EditContactPage extends StatefulWidget {
  final Contact contact;
  final ContactEntityRepository repository;

  EditContactPage({required this.contact, required this.repository});

  @override
  _EditContactPageState createState() => _EditContactPageState();
}

class _EditContactPageState extends State<EditContactPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _nicknameController;
  late TextEditingController _phone1Controller;
  late TextEditingController _phone2Controller;
  late TextEditingController _organizationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact.name);
    _nicknameController = TextEditingController(text: widget.contact.nickname);
    _phone1Controller = TextEditingController(text: widget.contact.phone1);
    _phone2Controller = TextEditingController(text: widget.contact.phone2);
    _organizationController =
        TextEditingController(text: widget.contact.organization);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _organizationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Contact")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the contact name";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nicknameController,
                decoration: InputDecoration(labelText: "Nickname"),
              ),
              TextFormField(
                controller: _phone1Controller,
                decoration: InputDecoration(labelText: "Phone Number 1"),
              ),
              TextFormField(
                controller: _phone2Controller,
                decoration: InputDecoration(labelText: "Phone Number 2"),
              ),
              TextFormField(
                controller: _organizationController,
                decoration: InputDecoration(labelText: "Organization"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    Contact updatedContact = Contact(
                      id: widget.contact.id,
                      name: _nameController.text,
                      nickname: _nicknameController.text,
                      phone1: _phone1Controller.text,
                      phone2: _phone2Controller.text,
                      organization: _organizationController.text,
                    );

                    // Update contact in the database
                    await widget.repository.update(updatedContact);

                    // Return the updated contact to the previous screen
                    Navigator.pop(context, updatedContact);
                  }
                },
                child: Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
