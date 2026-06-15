import 'package:flutter/material.dart';
import 'landing_page.dart';

void main() {
  runApp(const ParkirinApp());
}

class ParkirinApp extends StatelessWidget {
  const ParkirinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parkirin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF00B4DB),
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const LandingPage(),
    );
  }
}