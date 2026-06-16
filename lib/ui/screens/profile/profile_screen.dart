import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    final isDark = ref.watch(themeProvider);

    if (user == null) return const Center(child: Text('Please login'));

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER PROFILE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [BoxShadow(color: AppColors.primaryDark.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))],
                      gradient: const LinearGradient(colors: [AppColors.accent, AppColors.accentDark]),
                    ),
                    child: Center(child: Text(user.nama.isNotEmpty ? user.nama[0].toUpperCase() : 'U', style: GoogleFonts.inter(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800))),
                  ),
                  const SizedBox(height: 16),
                  Text(user.nama, style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(user.email, style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                    child: Text('NPM: ${user.npm}', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Data Kendaraan', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE8EDF2)),
                      boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                          child: Icon(user.jenisKendaraan == 'Motor' ? Icons.two_wheeler_rounded : Icons.directions_car_rounded, color: AppColors.primary, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Plat Nomor', style: GoogleFonts.inter(color: AppColors.textHint, fontSize: 12)),
                            Text(user.noPlat, style: GoogleFonts.inter(color: isDark ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: 1.5)),
                            Text('Jenis: ${user.jenisKendaraan}', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                          ]),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.edit_rounded, color: AppColors.textSecondary, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  Text('Pengaturan', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textPrimary)),
                  const SizedBox(height: 16),

                  _settingsItem(context, Icons.person_outline_rounded, 'Edit Profil', isDark),
                  _settingsItem(context, Icons.notifications_none_rounded, 'Notifikasi', isDark),
                  _settingsItem(context, isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, isDark ? 'Mode Terang' : 'Mode Gelap', isDark, trailing: Switch(
                    value: isDark,
                    activeColor: AppColors.primaryLight,
                    onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
                  )),
                  _settingsItem(context, Icons.help_outline_rounded, 'Pusat Bantuan', isDark),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(authProvider.notifier).logout();
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Keluar Akun', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(child: Text('SmartPark Unila v1.0.0', style: GoogleFonts.inter(color: AppColors.textHint, fontSize: 12))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsItem(BuildContext context, IconData icon, String label, bool isDark, {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE8EDF2)),
      ),
      child: Material(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.textSecondary, size: 20),
          ),
          title: Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textPrimary)),
          trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
          onTap: () {},
        ),
      ),
    );
  }
}
