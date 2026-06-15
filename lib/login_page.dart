import 'package:flutter/material.dart';
import 'home_page.dart';
import 'google_login_page.dart';
import 'student_login_page.dart';
import 'register_npm_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // GlobalKey untuk validasi form
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00B4DB), Color(0xFF005C97)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: _formKey, // Membungkus dengan Form untuk validasi
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  // --- LOGO & JUDUL ---
                  const Icon(Icons.local_parking_rounded, size: 80, color: Colors.white),
                  const Text('Parkirin', 
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text('Cek Dulu, Parkir Kemudian.', 
                    style: TextStyle(color: Colors.white70, letterSpacing: 1.2)),
                  
                  const SizedBox(height: 40),
                  
                  // --- KARTU INPUT LOGIN ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15), 
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.2))
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white, 
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                            ]
                          ),
                          child: Column(
                            children: [
                              const Text('MASUK PENGGUNA', 
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0083B0))),
                              const SizedBox(height: 25),
                              
                              // FIELD NPM DENGAN VALIDASI
                              _buildValidatableField(
                                label: 'NPM / USERNAME', 
                                controller: _userController, 
                                icon: Icons.person_outline,
                                errorMsg: 'NPM tidak boleh kosong',
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // FIELD PASSWORD DENGAN VALIDASI
                              _buildValidatableField(
                                label: 'KATA SANDI', 
                                controller: _passController, 
                                icon: Icons.lock_outline, 
                                isPass: true,
                                errorMsg: 'Kata sandi tidak boleh kosong',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // TOMBOL LOGIN UTAMA
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () {
                              // Validasi sebelum pindah halaman
                              if (_formKey.currentState!.validate()) {
                                String namaInput = _userController.text;
                                Navigator.pushReplacement(
                                  context, 
                                  MaterialPageRoute(builder: (context) => HomePage(
                                    username: namaInput,
                                    fakultas: "Fakultas Teknik",
                                    jurusan: "Teknik Informatika",
                                  ))
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00A896),
                              elevation: 5,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            child: const Text('MASUK SEKARANG', 
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  
                  // --- DIVIDER ---
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white30, thickness: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text("Atau masuk melalui", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ),
                      Expanded(child: Divider(color: Colors.white30, thickness: 1)),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // --- TOMBOL LOGIN ALTERNATIF ---
                  _buildSocialButton(
                    icon: Icons.g_mobiledata_rounded, 
                    label: "Lanjutkan dengan Google", 
                    color: Colors.white,
                    textColor: Colors.black87,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GoogleLoginPage()))
                  ),
                  const SizedBox(height: 12),
                  _buildSocialButton(
                    icon: Icons.school_rounded, 
                    label: "Akun Student (V-Class)", 
                    color: const Color(0xFFF39C12),
                    textColor: Colors.white,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentLoginPage()))
                  ),

                  const SizedBox(height: 35),

                  // --- FOOTER DAFTAR ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Belum terdaftar? ", style: TextStyle(color: Colors.white70)),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterNpmPage())),
                        child: const Text("Daftar via NPM", 
                          style: TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold, 
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white
                          )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET BARU: TextFormField dengan fungsi Validasi
  Widget _buildValidatableField({
    required String label, 
    required TextEditingController controller, 
    required IconData icon, 
    bool isPass = false,
    required String errorMsg
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFF0083B0)),
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0083B0))),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPass,
          style: const TextStyle(fontSize: 14),
          // LOGIKA MANDATORY (WAJIB ISI)
          validator: (value) {
            if (value == null || value.isEmpty) {
              return errorMsg;
            }
            return null;
          },
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0083B0), width: 1.5)),
            errorStyle: const TextStyle(fontSize: 10, color: Colors.redAccent),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon, 
    required String label, 
    required Color color, 
    required Color textColor,
    required VoidCallback onTap
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: textColor, size: 28),
        label: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}