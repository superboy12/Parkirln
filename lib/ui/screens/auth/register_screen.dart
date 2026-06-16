import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../dashboard/dashboard_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl    = TextEditingController();
  final _npmCtrl     = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _platCtrl    = TextEditingController();
  String _jenisKendaraan = 'Motor';
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _namaCtrl.dispose(); _npmCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _platCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final err = await ref.read(authProvider.notifier).register(
      nama: _namaCtrl.text.trim(), npm: _npmCtrl.text.trim(),
      email: _emailCtrl.text.trim(), password: _passCtrl.text,
      noPlat: _platCtrl.text.trim().toUpperCase(), jenisKendaraan: _jenisKendaraan,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating));
    } else {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const DashboardScreen()), (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.32,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text('Buat Akun', style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  ]),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 54),
                    child: Text('Isi data untuk mendaftar SmartPark', style: GoogleFonts.inter(color: Colors.white60, fontSize: 12)),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 10))],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _field(_namaCtrl, 'Nama Lengkap', Icons.person_outline_rounded, validator: (v) => (v == null || v.isEmpty) ? 'Nama tidak boleh kosong' : null),
                          const SizedBox(height: 14),
                          _field(_npmCtrl, 'NPM', Icons.badge_outlined, keyType: TextInputType.number, validator: (v) => (v == null || v.length < 10) ? 'NPM minimal 10 digit' : null),
                          const SizedBox(height: 14),
                          _field(_emailCtrl, 'Email (@student.unila.ac.id)', Icons.email_outlined, keyType: TextInputType.emailAddress, validator: (v) => (v == null || !v.contains('@')) ? 'Email tidak valid' : null),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            style: GoogleFonts.inter(fontSize: 14),
                            validator: (v) => (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
                            decoration: _inputDec('Kata Sandi', Icons.lock_outline_rounded, suffix: IconButton(icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: AppColors.textHint), onPressed: () => setState(() => _obscure = !_obscure))),
                          ),
                          const SizedBox(height: 14),
                          _field(_platCtrl, 'Plat Nomor Kendaraan', Icons.credit_card_rounded, textCapitalization: TextCapitalization.characters, validator: (v) => (v == null || v.isEmpty) ? 'Plat tidak boleh kosong' : null),
                          const SizedBox(height: 14),
                          Text('Jenis Kendaraan', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          const SizedBox(height: 8),
                          Row(children: ['Motor', 'Mobil'].map((j) {
                            final active = _jenisKendaraan == j;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: j == 'Motor' ? 8 : 0),
                                child: GestureDetector(
                                  onTap: () => setState(() => _jenisKendaraan = j),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: active ? AppColors.primary : const Color(0xFFF8FAFF),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: active ? AppColors.primary : const Color(0xFFE8EDF2)),
                                    ),
                                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      Icon(j == 'Motor' ? Icons.two_wheeler_rounded : Icons.directions_car_rounded, size: 18, color: active ? Colors.white : AppColors.textHint),
                                      const SizedBox(width: 7),
                                      Text(j, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.textHint)),
                                    ]),
                                  ),
                                ),
                              ),
                            );
                          }).toList()),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _register,
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                              child: _loading
                                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                  : Text('Daftar Sekarang', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: RichText(text: TextSpan(
                              text: 'Sudah punya akun? ',
                              style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                              children: [TextSpan(text: 'Masuk', style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13))],
                            )),
                          )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDec(String hint, IconData icon, {Widget? suffix}) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.inter(color: AppColors.textHint, fontSize: 14),
    prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
    suffixIcon: suffix,
    filled: true, fillColor: const Color(0xFFF8FAFF),
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE8EDF2))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE8EDF2))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.error)),
  );

  Widget _field(TextEditingController ctrl, String hint, IconData icon, {TextInputType? keyType, TextCapitalization textCapitalization = TextCapitalization.none, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl, keyboardType: keyType,
      textCapitalization: textCapitalization,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
      validator: validator,
      decoration: _inputDec(hint, icon),
    );
  }
}
