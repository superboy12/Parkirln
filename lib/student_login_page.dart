import 'package:flutter/material.dart';
import 'home_page.dart';

class StudentLoginPage extends StatelessWidget {
  const StudentLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SSO Akun Student'), backgroundColor: const Color(0xFF00A896)),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Icon(Icons.school, size: 80, color: Color(0xFF00A896))),
            const SizedBox(height: 30),
            const Text('Email Student', style: TextStyle(fontWeight: FontWeight.bold)),
            const TextField(decoration: InputDecoration(hintText: '@students.unila.ac.id')),
            const SizedBox(height: 20),
            const Text('Password', style: TextStyle(fontWeight: FontWeight.bold)),
            const TextField(obscureText: true, decoration: InputDecoration(hintText: 'Masukkan password SSO')),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context, 
                    MaterialPageRoute(builder: (context) => const HomePage(username: "Daniel (Student)")),
                    (route) => false
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A896)),
                child: const Text('LOGIN STUDENT', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}