import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ContactHelper {
  static final ContactHelper instance = ContactHelper._internal();
  static Database? _db;

  ContactHelper._internal();

  Future<Database> get db async => _db ??= await _initDb();

  Future<Database> _initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contacts.db");

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) => db.execute(
        "CREATE TABLE contactTable("
        "idColumn INTEGER PRIMARY KEY, "
        "nameColumn TEXT, "
        "emailColumn TEXT, "
        "phoneColumn TEXT, "
        "imgColumn TEXT)"
      ),
    );
  }

  Future<Contact> saveContact(Contact contact) async {
    final db = await instance.db;
    contact.id = await db.insert('contactTable', contact.toMap());
    return contact;
  }

  Future<int> updateContact(Contact contact) async {
    final db = await instance.db;
    return db.update(
      'contactTable',
      contact.toMap(),
      where: 'idColumn = ?',
      whereArgs: [contact.id],
    );
  }

  Future<int> deleteContact(int? id) async {
    final db = await instance.db;
    return db.delete(
      'contactTable',
      where: 'idColumn = ?',
      whereArgs: [id],
    );
  }

  Future<List<Contact>> getAllContacts() async {
    final db = await instance.db;
    final list = await db.query('contactTable');
    return list.map((map) => Contact.fromMap(map)).toList();
  }
}

class Contact {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? img;

  Contact();

  Contact copy() => Contact()
    ..id = id
    ..name = name
    ..email = email
    ..phone = phone
    ..img = img;

  Contact.fromMap(Map map) {
    id = map['idColumn'];
    name = map['nameColumn'];
    email = map['emailColumn'];
    phone = map['phoneColumn'];
    img = map['imgColumn'];
  }

  Map<String, dynamic> toMap() => {
    'nameColumn': name,
    'emailColumn': email,
    'phoneColumn': phone,
    'imgColumn': img,
    if (id != null) 'idColumn': id,
  };
}