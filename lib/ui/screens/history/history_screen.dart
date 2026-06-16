import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../providers/app_providers.dart';
import '../../../data/models/parking_session_model.dart';
import '../reservation/qr_code_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    final isDark = ref.watch(themeProvider);

    if (user == null) return const Center(child: Text('Please login'));

    final resAsync = ref.watch(sessionsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Parkir', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 20, color: isDark ? Colors.white : AppColors.textPrimary)),
        centerTitle: false,
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      ),
      body: resAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (reservations) {
          if (reservations.isEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.history_rounded, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('Belum ada riwayat parkir', style: GoogleFonts.inter(color: AppColors.textHint, fontSize: 14)),
              ]),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: reservations.length,
            itemBuilder: (_, i) {
              final res = reservations[i];
              final isActive = res.isActive;
              return GestureDetector(
                onTap: () {
                  if (isActive) Navigator.push(context, MaterialPageRoute(builder: (_) => QrCodeScreen(reservation: res)));
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isActive ? AppColors.primary : (isDark ? Colors.white10 : const Color(0xFFE8EDF2)), width: isActive ? 1.5 : 1),
                    boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: (isActive ? AppColors.primary : AppColors.textHint).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Icon(Icons.local_parking_rounded, size: 18, color: isActive ? AppColors.primary : AppColors.textHint),
                            ),
                            const SizedBox(width: 12),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Area ID: ${res.parkingId}', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: isDark ? Colors.white : AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              Text('Slot ${res.slotId}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textHint)),
                            ]),
                          ]),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: isActive ? AppColors.success.withOpacity(0.1) : Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text(isActive ? 'Aktif' : 'Selesai', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: isActive ? AppColors.success : AppColors.textHint)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFF0F2F5), height: 1),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _info(Icons.calendar_today_rounded, AppUtils.formatDate(res.checkInTime)),
                          const SizedBox(height: 4),
                          _info(Icons.access_time_rounded, '${AppUtils.formatTime(res.checkInTime)} - ${res.checkOutTime != null ? AppUtils.formatTime(res.checkOutTime!) : 'Sekarang'}'),
                          const Spacer(),
                          if (isActive)
                            Text('Tampilkan QR', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _info(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 14, color: AppColors.textHint),
      const SizedBox(width: 6),
      Text(text, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
    ]);
  }
}
