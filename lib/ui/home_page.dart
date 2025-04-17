import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import './contact_page.dart';
import '../helpers/contact_helper.dart';

enum OrderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  final Function(bool) toggleTheme;
  final bool isDarkTheme;
  
  const HomePage({
    super.key,
    required this.toggleTheme,
    required this.isDarkTheme,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ContactHelper helper = ContactHelper.instance;
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  void _getAllContacts() async {
    final list = await helper.getAllContacts();
    if (mounted) setState(() => contacts = list);
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        contacts.sort((a, b) => a.name!.compareTo(b.name!));
        break;
      case OrderOptions.orderza:
        contacts.sort((a, b) => b.name!.compareTo(a.name!));
        break;
    }
    setState(() {});
  }

  void _showContactPage({Contact? contact}) async {
  final recContact = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ContactPage(contact: contact),
    ),
  );

    
    if (recContact != null && mounted) {
      contact != null 
          ? await helper.updateContact(recContact)
          : await helper.saveContact(recContact);
      _getAllContacts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Contatos"),
            const SizedBox(width: 10),
            IconButton(
              icon: Icon(
                widget.isDarkTheme ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
              ),
              onPressed: () => widget.toggleTheme(!widget.isDarkTheme),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        actions: [
          PopupMenuButton<OrderOptions>(
            onSelected: _orderList,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: OrderOptions.orderaz,
                child: Text("Ordenar de A-Z"),
              ),
              const PopupMenuItem(
                value: OrderOptions.orderza,
                child: Text("Ordenar de Z-A"),
              )
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactPage(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: contacts.length,
        itemBuilder: (context, index) => _contactCard(context, index),
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => _showOptions(context, index),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: contacts[index].img != null
                        ? FileImage(File(contacts[index].img!))
                        : const AssetImage("assets/person.png") as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contacts[index].name ?? "",
                      style: const TextStyle(
                          fontSize: 22.0, 
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      contacts[index].email ?? "",
                      style: const TextStyle(fontSize: 18.0),
                    ),
                    Text(
                      contacts[index].phone ?? "",
                      style: const TextStyle(fontSize: 18.0),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text("Ligar",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 20.0)),
            onTap: () {
              launchUrl(Uri.parse("tel:${contacts[index].phone}"));
              if (mounted) Navigator.pop(context);
            },
          ),
          if (contacts[index].email?.isNotEmpty ?? false)
            ListTile(
              title: Text("Enviar E-mail",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 20.0)),
              onTap: () {
                final email = Uri.encodeComponent(contacts[index].email!);
                final subject = Uri.encodeComponent("Contato via App");
                final uri = Uri.parse("mailto:$email?subject=$subject");
                launchUrl(uri);
                if (mounted) Navigator.pop(context);
              },
            ),
          ListTile(
            title: Text("Editar",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 20.0)),
            onTap: () {
              if (mounted) Navigator.pop(context);
              _showContactPage(contact: contacts[index]);
            },
          ),
          ListTile(
            title: Text("Excluir",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 20.0)),
            onTap: () {
              helper.deleteContact(contacts[index].id);
              if (mounted) {
                setState(() => contacts.removeAt(index));
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}