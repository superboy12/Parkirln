import 'package:flutter/material.dart';
import 'login_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00B4DB), Color(0xFF005C97)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.electric_scooter, size: 60, color: Color(0xFF0083B0)),
            ),
            const SizedBox(height: 20),
            const Text('Parkirin', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
            const Text('Cek Dulu, Parkir Kemudian.', style: TextStyle(fontSize: 16, color: Colors.white)),
            const Spacer(flex: 2),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage())),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: const BorderSide(color: Colors.white54)),
              ),
              child: const Text('PARKIR SEKARANG!', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}