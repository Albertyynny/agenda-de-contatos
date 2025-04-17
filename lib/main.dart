import 'package:flutter/material.dart';
import 'ui/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda de Contatos',
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.light(
          primary: Colors.lightBlue[300]!,
          secondary: Colors.lightBlue[200]!,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.lightBlue,
          secondary: Colors.lightBlueAccent,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: HomePage(
        toggleTheme: _toggleTheme,
        isDarkTheme: _themeMode == ThemeMode.dark,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}