import 'package:flutter/material.dart';
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

  // FUNGSI UNTUK MEMBUKA WHATSAPP ATAU BROWSER
  Future<void> _launchWhatsApp(BuildContext context) async {
    // 1. Bersihkan nomor telepon (ambil angka saja)
    String cleanNumber = nomorSatpam.replaceAll(RegExp(r'[^0-9]'), '');
    
    // 2. Ubah format 08 menjadi 62
    if (cleanNumber.startsWith('0')) {
      cleanNumber = '62${cleanNumber.substring(1)}';
    }

    // 3. Siapkan pesan otomatis
    String message = "DARURAT! Mohon bantuan keamanan di area $lokasiParkir.\n"
        "Kendaraan saya dengan Plat: $platNomor mengalami kendala.\n"
        "Mohon segera ditinjau. Terima kasih.";

    // 4. Link wa.me
    final Uri whatsappUri = Uri.parse(
      "https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}"
    );

    try {
      // Mencoba membuka aplikasi eksternal (WA / Browser)
      bool launched = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw 'Gagal membuka tautan';
      }
    } catch (e) {
      // Jika error (biasanya di emulator tanpa browser/WA), paksa buka lewat browser internal
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.platformDefault);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tidak dapat membuka WhatsApp atau Browser.")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Pusat Bantuan SOS", 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.redAccent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER EMERGENCY ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              color: Colors.redAccent,
              child: const Column(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white, size: 60),
                  SizedBox(height: 10),
                  Text("Bantuan Keamanan", 
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("Laporan Anda akan diteruskan ke WhatsApp Satpam", 
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- FOTO KENDARAAN ---
                  const Text("Bukti Foto Kendaraan Anda:", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: imagePath != null 
                        ? Image.file(File(imagePath!), fit: BoxFit.cover)
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                Text("Foto tidak tersedia", style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- DETAIL PETUGAS ---
                  const Text("Petugas Keamanan Terdekat:", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blueGrey,
                          child: Icon(Icons.person, color: Colors.white, size: 35),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(namaSatpam, 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                              Text("Pos Piket: $lokasiParkir", 
                                style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(nomorSatpam, 
                                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- TOMBOL UTAMA WHATSAPP ---
                  SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchWhatsApp(context),
                      icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 28),
                      label: const Text("KIRIM PESAN DARURAT (WA)", 
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366), // Hijau WA
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}