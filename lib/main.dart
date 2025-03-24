// Flutter import
import 'package:flutter/material.dart';

// Local Page Imports
import 'package:kar_color/pages/home.dart';

// Main App Call
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'karCOLOR',
      debugShowCheckedModeBanner: false,

      // Theme data
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xffF2F0EF),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),

      // Routing of different pages
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
      },
    );
  }
}