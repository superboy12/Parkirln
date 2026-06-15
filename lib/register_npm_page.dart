import 'package:flutter/material.dart';

class RegisterNpmPage extends StatelessWidget {
  const RegisterNpmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun Baru'), backgroundColor: const Color(0xFF005C97)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const Text('Lengkapi data diri sesuai KTM Anda untuk mendaftar.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            _buildInput('NPM (Nomor Pokok Mahasiswa)'),
            _buildInput('Nama Lengkap'),
            _buildInput('Fakultas / Jurusan'),
            _buildInput('Nomor WhatsApp'),
            _buildInput('Password', isPass: true),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005C97)),
                child: const Text('DAFTAR SEKARANG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, {bool isPass = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        obscureText: isPass,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}