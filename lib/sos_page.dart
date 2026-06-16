import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class SosPage extends StatelessWidget {
  final String namaSatpam;
  final String nomorSatpam;
  final String lokasiParkir;
  final String platNomor;
  final String? imagePath;

  const SosPage({
    super.key,
    required this.namaSatpam,
    required this.nomorSatpam,
    required this.lokasiParkir,
    required this.platNomor,
    this.imagePath,
  });

  Future<void> _launchWhatsApp(BuildContext context) async {
    String clean = nomorSatpam.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.startsWith('0')) clean = '62${clean.substring(1)}';
    final msg = 'DARURAT! Mohon bantuan keamanan di area $lokasiParkir.\n'
        'Kendaraan saya dengan Plat: $platNomor mengalami kendala.\n'
        'Mohon segera ditinjau. Terima kasih.';
    final uri = Uri.parse('https://wa.me/$clean?text=${Uri.encodeComponent(msg)}');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka WhatsApp.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // ===== HEADER EMERGENCY =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 52, left: 20, right: 20, bottom: 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8B0000), Color(0xFFE53935)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                // Back + title
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text('Pusat Bantuan', style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    // Pulse SOS Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Row(children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text('LIVE', style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Emergency icon + label
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 44),
                ),
                const SizedBox(height: 12),
                Text('Bantuan Segera', style: GoogleFonts.inter(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Laporan diteruskan langsung ke satpam terdekat', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 16),
                // Info chips
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _headerChip(Icons.location_on_rounded, lokasiParkir),
                  const SizedBox(width: 10),
                  _headerChip(Icons.credit_card_rounded, platNomor),
                ]),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  // ===== FOTO KENDARAAN =====
                  Text('Bukti Foto Kendaraan', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF0D1B2A))),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: imagePath != null
                          ? Image.file(File(imagePath!), fit: BoxFit.cover)
                          : Container(
                              color: Colors.white,
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Icon(Icons.image_not_supported_rounded, size: 48, color: Colors.grey[300]),
                                const SizedBox(height: 8),
                                Text('Foto tidak tersedia', style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 13)),
                              ]),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ===== PETUGAS TERDEKAT =====
                  Text('Petugas Terdekat', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF0D1B2A))),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE8EDF2)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56, height: 56,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)]),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.security_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(namaSatpam, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 15, color: const Color(0xFF0D1B2A))),
                              const SizedBox(height: 3),
                              Text('Pos: $lokasiParkir', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500])),
                              const SizedBox(height: 6),
                              Row(children: [
                                const Icon(Icons.phone_rounded, size: 13, color: Color(0xFF1A73E8)),
                                const SizedBox(width: 4),
                                Text(nomorSatpam, style: GoogleFonts.inter(color: const Color(0xFF1A73E8), fontWeight: FontWeight.w700, fontSize: 13)),
                              ]),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(children: [
                            Container(width: 7, height: 7, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                            const SizedBox(width: 5),
                            Text('Online', style: GoogleFonts.inter(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w700)),
                          ]),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ===== STATUS DETAIL =====
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE8EDF2)),
                    ),
                    child: Column(
                      children: [
                        _detailRow(Icons.local_parking_rounded, 'Lokasi Parkir', lokasiParkir),
                        const Divider(color: Color(0xFFF0F2F5), height: 20),
                        _detailRow(Icons.credit_card_rounded, 'Plat Nomor', platNomor),
                        const Divider(color: Color(0xFFF0F2F5), height: 20),
                        _detailRow(Icons.access_time_rounded, 'Waktu Laporan', '${TimeOfDay.now().format(context)} WIB'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ===== TOMBOL WA =====
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchWhatsApp(context),
                      icon: const Icon(Icons.chat_rounded, color: Colors.white, size: 22),
                      label: Text('Kirim Pesan ke Satpam (WA)', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: Text('Kembali ke Beranda', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3D4A5C),
                        side: const BorderSide(color: Color(0xFFE8EDF2), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white70, size: 13),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 16, color: const Color(0xFF1A73E8)),
      ),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500])),
        Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0D1B2A))),
      ]),
    ]);
  }
}
