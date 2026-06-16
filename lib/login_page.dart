import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // --- HEADER BAGIAN ATAS ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(28, 40, 28, 48),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D1B2A),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A73E8),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(Icons.local_parking_rounded, color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 12),
                          Text('Parkirin', style: GoogleFonts.inter(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text('Selamat Datang', style: GoogleFonts.inter(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                      const SizedBox(height: 6),
                      Text('Masuk ke akun Anda untuk melanjutkan', style: GoogleFonts.inter(color: Colors.white54, fontSize: 14)),
                    ],
                  ),
                ),

                // --- FORM LOGIN ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // NPM
                        _buildLabel('NPM / Username'),
                        const SizedBox(height: 8),
                        _buildField(
                          controller: _userController,
                          hint: 'Masukkan NPM Anda',
                          icon: Icons.person_outline_rounded,
                          errorMsg: 'NPM tidak boleh kosong',
                        ),

                        const SizedBox(height: 20),

                        // Password
                        _buildLabel('Kata Sandi'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passController,
                          obscureText: _obscurePass,
                          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF0D1B2A)),
                          validator: (v) => (v == null || v.isEmpty) ? 'Kata sandi tidak boleh kosong' : null,
                          decoration: InputDecoration(
                            hintText: 'Masukkan kata sandi',
                            hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
                            prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF9EABBE), size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey[400], size: 20),
                              onPressed: () => setState(() => _obscurePass = !_obscurePass),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE8EDF2))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 1.5)),
                            errorStyle: GoogleFonts.inter(fontSize: 11, color: Colors.redAccent),
                          ),
                        ),

                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text('Lupa kata sandi?', style: GoogleFonts.inter(color: const Color(0xFF1A73E8), fontSize: 13, fontWeight: FontWeight.w600)),
                        ),

                        const SizedBox(height: 28),

                        // Tombol Login
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isLoading = true);
                                await Future.delayed(const Duration(milliseconds: 600));
                                if (context.mounted) {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage(
                                    username: _userController.text,
                                    fakultas: 'Fakultas Teknik',
                                    jurusan: 'Teknik Informatika',
                                  )));
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A73E8),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _isLoading
                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                : Text('Masuk', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Divider
                        Row(children: [
                          const Expanded(child: Divider(color: Color(0xFFE8EDF2), thickness: 1.5)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text('atau lanjutkan dengan', style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 12)),
                          ),
                          const Expanded(child: Divider(color: Color(0xFFE8EDF2), thickness: 1.5)),
                        ]),

                        const SizedBox(height: 20),

                        // Social Buttons
                        _buildSocialBtn(
                          icon: Icons.g_mobiledata_rounded,
                          label: 'Lanjutkan dengan Google',
                          bgColor: Colors.white,
                          fgColor: const Color(0xFF0D1B2A),
                          borderColor: const Color(0xFFE8EDF2),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoogleLoginPage())),
                        ),
                        const SizedBox(height: 12),
                        _buildSocialBtn(
                          icon: Icons.school_rounded,
                          label: 'Akun Student (V-Class)',
                          bgColor: const Color(0xFFFFF8E1),
                          fgColor: const Color(0xFFE65100),
                          borderColor: const Color(0xFFFFE082),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentLoginPage())),
                        ),

                        const SizedBox(height: 28),

                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterNpmPage())),
                            child: RichText(
                              text: TextSpan(
                                text: 'Belum terdaftar? ',
                                style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 14),
                                children: [
                                  TextSpan(
                                    text: 'Daftar via NPM',
                                    style: GoogleFonts.inter(color: const Color(0xFF1A73E8), fontWeight: FontWeight.w700, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF3D4A5C)));
  }

  Widget _buildField({required TextEditingController controller, required String hint, required IconData icon, required String errorMsg}) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF0D1B2A)),
      validator: (v) => (v == null || v.isEmpty) ? errorMsg : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF9EABBE), size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE8EDF2))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 1.5)),
        errorStyle: GoogleFonts.inter(fontSize: 11, color: Colors.redAccent),
      ),
    );
  }

  Widget _buildSocialBtn({required IconData icon, required String label, required Color bgColor, required Color fgColor, required Color borderColor, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: fgColor, size: 24),
        label: Text(label, style: GoogleFonts.inter(color: fgColor, fontWeight: FontWeight.w600, fontSize: 14)),
        style: OutlinedButton.styleFrom(
          backgroundColor: bgColor,
          side: BorderSide(color: borderColor, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
