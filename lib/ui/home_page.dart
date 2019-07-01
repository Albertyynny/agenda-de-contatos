import '../helpers/contact_helper.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

  @override
  void initState() {
    super.initState();

    // Teste insert data on database
    // Contact c = Contact();
    // c.name = "Samuca";
    // c.email = "samuel@gmail.com";
    // c.phone = "sauhsuhasu";
    // c.img = "imgT";
    // helper.saveContact(c);

    // Teste get data of database
    helper.getAllContacts().then((list) {
      print(list);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
