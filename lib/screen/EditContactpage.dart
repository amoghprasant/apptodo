import 'package:flutter/material.dart';
import 'package:sqliteproj/model/contacts_model.dart';
import 'package:sqliteproj/database/repository.dart';

class EditContactPage extends StatefulWidget {
  final Contact contact;
  final ContactEntityRepository contactRepository;

  EditContactPage({required this.contact, required this.contactRepository});

  @override
  _EditContactPageState createState() => _EditContactPageState();
}

class _EditContactPageState extends State<EditContactPage> {
  late TextEditingController nameController;
  late TextEditingController phone1Controller;
  late TextEditingController phone2Controller;
  late TextEditingController nicknameController;
  late TextEditingController organizationController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.contact.name);
    phone1Controller = TextEditingController(text: widget.contact.phone1);
    phone2Controller = TextEditingController(text: widget.contact.phone2);
    nicknameController = TextEditingController(text: widget.contact.nickname);
    organizationController =
        TextEditingController(text: widget.contact.organization);
  }

  @override
  void dispose() {
    nameController.dispose();
    phone1Controller.dispose();
    phone2Controller.dispose();
    nicknameController.dispose();
    organizationController.dispose();
    super.dispose();
  }

  void _saveContact() async {
    final updatedContact = Contact(
      id: widget.contact.id,
      name: nameController.text,
      phone1: phone1Controller.text,
      phone2: phone2Controller.text,
      nickname: nicknameController.text,
      organization: organizationController.text,
      additionalInfo: widget.contact.additionalInfo,
    );

    await widget.contactRepository.update(updatedContact);
    Navigator.pop(context, updatedContact);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Contact'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveContact,
          ),
        ],
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
              controller: phone1Controller,
              decoration: InputDecoration(labelText: 'Phone Number 1'),
            ),
            TextField(
              controller: phone2Controller,
              decoration: InputDecoration(labelText: 'Phone Number 2'),
            ),
            TextField(
              controller: nicknameController,
              decoration: InputDecoration(labelText: 'Nickname'),
            ),
            TextField(
              controller: organizationController,
              decoration: InputDecoration(labelText: 'Organization'),
            ),
          ],
        ),
      ),
    );
  }
}
