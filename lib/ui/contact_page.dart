import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../helpers/contact_helper.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;
  const ContactPage({super.key, this.contact});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameFocus = FocusNode();
  bool _userEdited = false;
  late Contact _editedContact;

  @override
  void initState() {
    super.initState();
    _editedContact = widget.contact?.copy() ?? Contact();
    _nameController.text = _editedContact.name ?? "";
    _emailController.text = _editedContact.email ?? "";
    _phoneController.text = _editedContact.phone ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (!didPop) {
          final shouldPop = await _requestPop();
          if (shouldPop && mounted && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(
            _editedContact.name ?? "Novo Contato",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _saveContact,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(
            Icons.save,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  backgroundImage: _editedContact.img != null
                      ? FileImage(File(_editedContact.img!))
                      : const AssetImage("assets/person.png") as ImageProvider,
                  child: _editedContact.img == null
                      ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(
                  labelText: "Nome",
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                onChanged: (text) => _updateContact(name: text),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                onChanged: (text) => _updateContact(email: text),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Telefone",
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                onChanged: (text) => _updateContact(phone: text),
                keyboardType: TextInputType.phone,
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null && mounted) {
        setState(() => _editedContact.img = pickedFile.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro ao selecionar imagem"),
          duration: Duration(seconds: 2),
        )
      );
    }
  }

  void _updateContact({String? name, String? email, String? phone}) {
    _userEdited = true;
    setState(() {
      _editedContact.name = name ?? _editedContact.name;
      _editedContact.email = email ?? _editedContact.email;
      _editedContact.phone = phone ?? _editedContact.phone;
    });
  }

  Future<bool> _requestPop() async {
    if (!_userEdited) return true;
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Descartar Alterações?"),
        content: const Text("Se sair, as alterações serão perdidas."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Sim"),
          ),
        ],
      ),
    ) ?? false;
  }

  void _saveContact() {
    if (_editedContact.name?.isEmpty ?? true) {
      FocusScope.of(context).requestFocus(_nameFocus);
      return;
    }
    if (mounted && context.mounted) Navigator.pop(context, _editedContact);
  }
}