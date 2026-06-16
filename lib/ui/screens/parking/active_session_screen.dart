import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../providers/app_providers.dart';
import '../../../data/models/parking_session_model.dart';
import 'check_out_screen.dart';

class ActiveSessionScreen extends ConsumerStatefulWidget {
  final ParkingSessionModel session;

  const ActiveSessionScreen({super.key, required this.session});

  @override
  ConsumerState<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends ConsumerState<ActiveSessionScreen> {
  Timer? _timer;
  Duration _duration = Duration.zero;
  bool _sosLoading = false;

  @override
  void initState() {
    super.initState();
    _updateDuration();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateDuration());
  }

  void _updateDuration() {
    setState(() {
      _duration = DateTime.now().difference(widget.session.checkInTime);
    });
  }

  Future<void> _sendSos() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kirim Sinyal SOS?'),
        content: const Text('Gunakan hanya dalam keadaan darurat (kehilangan, kecelakaan, dll). Lokasi Anda akan dikirim ke sistem keamanan kampus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Kirim SOS'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _sosLoading = true);
    try {
      final pos = await Geolocator.getCurrentPosition();
      await ref.read(supabaseServiceProvider).sendSosLog(
        uid: widget.session.uid,
        sessionId: widget.session.id,
        lat: pos.latitude,
        lng: pos.longitude,
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sinyal SOS berhasil dikirim! Petugas akan segera datang.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengirim SOS: $e')));
    } finally {
      if (mounted) setState(() => _sosLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = [
      _duration.inHours.toString().padLeft(2, '0'),
      _duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
      _duration.inSeconds.remainder(60).toString().padLeft(2, '0')
    ].join(':');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Sesi Parkir Aktif', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        automaticallyImplyLeading: false, // User can't go back casually
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // TIMER CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  Text('Durasi Parkir', style: GoogleFonts.inter(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(formattedTime, style: GoogleFonts.inter(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold, tabularFigures: true)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // INFO CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow('Area Parkir', widget.session.parkingId), // Should fetch actual name ideally
                  const Divider(height: 24),
                  _infoRow('Slot', widget.session.slotId),
                  const Divider(height: 24),
                  _infoRow('Plat Nomor', widget.session.platNomor),
                  const Divider(height: 24),
                  _infoRow('Waktu Masuk', AppUtils.formatTime(widget.session.checkInTime)),
                ],
              ),
            ),

            const SizedBox(height: 24),
            // FOTO MASUK
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                widget.session.fotoMasukUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(height: 180, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
              ),
            ),

            const SizedBox(height: 40),

            // ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sosLoading ? null : _sendSos,
                    icon: _sosLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.warning_amber_rounded),
                    label: const Text('SOS Darurat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => CheckOutScreen(session: widget.session)));
                    },
                    icon: const Icon(Icons.exit_to_app_rounded),
                    label: const Text('Check-Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(color: AppColors.textHint, fontSize: 14)),
        Text(value, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
