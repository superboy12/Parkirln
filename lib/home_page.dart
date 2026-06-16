import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:math';
import 'choose_space_page.dart';
import 'route_page.dart';
import 'sos_page.dart';

// Koordinat pusat kampus (Universitas Lampung)
const double _campusLat = -5.3656;
const double _campusLng = 105.2440;

// Jarak fallback per parkiran (digunakan jika GPS tidak akurat / emulator)
const Map<String, String> _jarakFallback = {
  'Teknik Elektro': '1.2 km',
  'Teknik Sipil': '450 m',
  'Teknik Geodesi': '800 m',
  'Teknik Mesin': '600 m',
};

// Data parkiran dengan koordinat GPS nyata
final List<Map<String, dynamic>> _semuaParkiran = [
  {
    'nama': 'Teknik Elektro',
    'jenis': 'Mobil',
    'lokasi': 'Gedung H',
    'sisa': 4,
    'total': 50,
    'img': 'https://images.unsplash.com/photo-1590674899484-d5640e854abe?w=400',
    'lat': -5.3640,
    'lng': 105.2460,
  },
  {
    'nama': 'Teknik Sipil',
    'jenis': 'Motor',
    'lokasi': 'Gedung A',
    'sisa': 45,
    'total': 100,
    'img': 'https://images.unsplash.com/photo-1621993202323-f438eec934ff?w=400',
    'lat': -5.3670,
    'lng': 105.2430,
  },
  {
    'nama': 'Teknik Geodesi',
    'jenis': 'Motor',
    'lokasi': 'Samping Lab',
    'sisa': 12,
    'total': 60,
    'img': 'https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?w=400',
    'lat': -5.3660,
    'lng': 105.2450,
  },
  {
    'nama': 'Teknik Mesin',
    'jenis': 'Mobil',
    'lokasi': 'Gedung C',
    'sisa': 18,
    'total': 40,
    'img': 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=400',
    'lat': -5.3650,
    'lng': 105.2420,
  },
];

class HomePage extends StatefulWidget {
  final String username;
  final String fakultas;
  final String jurusan;

  const HomePage({
    super.key,
    this.username = 'Daniel',
    this.fakultas = 'Fakultas Teknik',
    this.jurusan = 'Teknik Informatika',
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  int selectedCategoryIndex = 0;

  bool isParking = false;
  String? platUser;
  String? lokasiParkir;
  String? currentImagePath;

  Timer? _timer;
  int _secondsElapsed = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  // GPS State
  Position? _userPosition;
  String _locationLabel = 'Mencari lokasi...';
  bool _locationLoading = true;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  // --- LOKASI GPS ---
  Future<void> _initLocation() async {
    final status = await Permission.location.request();
    if (!status.isGranted) {
      setState(() {
        _locationLabel = 'Izin lokasi ditolak';
        _locationLoading = false;
      });
      return;
    }
    try {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _userPosition = pos;
        _locationLabel = 'Kampus Utama, Bandar Lampung';
        _locationLoading = false;
      });
    } catch (_) {
      setState(() {
        _locationLabel = 'Bandar Lampung';
        _locationLoading = false;
      });
    }
  }

  String _getJarak(Map<String, dynamic> parkiran) {
    if (_userPosition == null) return _jarakFallback[parkiran['nama']] ?? '— km';
    // Cek apakah posisi user terlalu jauh dari kampus (emulator GPS tidak akurat)
    final double distFromCampus = Geolocator.distanceBetween(
      _userPosition!.latitude, _userPosition!.longitude, _campusLat, _campusLng,
    );
    // Jika lebih dari 50km dari kampus → pakai jarak fallback (emulator)
    if (distFromCampus > 50000) return _jarakFallback[parkiran['nama']] ?? '— km';
    
    final double distM = Geolocator.distanceBetween(
      _userPosition!.latitude, _userPosition!.longitude,
      parkiran['lat'] as double, parkiran['lng'] as double,
    );
    if (distM < 1000) return '${distM.round()} m';
    return '${(distM / 1000).toStringAsFixed(1)} km';
  }

  // --- TIMER ---
  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Pagi';
    if (h < 15) return 'Siang';
    if (h < 18) return 'Sore';
    return 'Malam';
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsElapsed = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _secondsElapsed++));
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _secondsElapsed = 0;
      isParking = false;
      platUser = null;
      lokasiParkir = null;
      currentImagePath = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Parkir Selesai. Hati-hati di jalan!', style: GoogleFonts.inter()),
        backgroundColor: const Color(0xFF1A73E8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _formatDuration(int s) {
    int h = s ~/ 3600, m = (s % 3600) ~/ 60, sec = s % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // --- KEAMANAN ---
  void _cekPosisi() {
    final msg = isParking ? '📍 Kendaraan aman di $lokasiParkir' : 'Anda belum memarkirkan kendaraan.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: GoogleFonts.inter()), backgroundColor: const Color(0xFF0D1B2A), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    );
  }

  void _laporKeamanan() {
    if (!isParking) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silakan parkir terlebih dahulu.', style: GoogleFonts.inter()), backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      );
      return;
    }
    String nama = 'Pak Budi', nomor = '0812-3456-7890';
    if (lokasiParkir == 'Teknik Elektro') { nama = 'Pak Slamet (Elektro)'; nomor = '0811-7777-8888'; }
    else if (lokasiParkir == 'Teknik Sipil') { nama = 'Pak Agus (Sipil)'; nomor = '0852-6666-5555'; }
    else if (lokasiParkir == 'Teknik Geodesi') { nama = 'Pak Rahmat (Geodesi)'; nomor = '0821-9999-0000'; }

    Navigator.push(context, MaterialPageRoute(builder: (_) => SosPage(
      namaSatpam: nama, nomorSatpam: nomor,
      lokasiParkir: lokasiParkir ?? 'Area Kampus',
      platNomor: platUser ?? '-', imagePath: currentImagePath,
    )));
  }

  void _showActionMenu(Map<String, dynamic> item) {
    final String title = item['nama'];
    final String jenis = item['jenis'];
    final int sisa = item['sisa'];
    final String jarak = _getJarak(item);
    final String imageUrl = item['img'];
    final double lat = item['lat'];
    final double lng = item['lng'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Row(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.network(imageUrl, width: 64, height: 64, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 64, height: 64, color: Colors.grey[100], child: const Icon(Icons.local_parking, color: Colors.grey)))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0D1B2A))),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on, size: 13, color: Color(0xFF1A73E8)),
                    const SizedBox(width: 3),
                    Text(jarak, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[500])),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: sisa <= 5 ? Colors.red[50] : Colors.green[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('$sisa Slot Tersedia', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: sisa <= 5 ? Colors.red[600] : Colors.green[600])),
                    ),
                  ]),
                ])),
              ],
            ),

            const SizedBox(height: 16),
            _SlotIndicator(sisa: sisa, total: item['total']),
            const SizedBox(height: 24),

            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => RoutePage(
                      destinationName: title,
                      jarak: jarak,
                      destLat: lat,
                      destLng: lng,
                      userLat: _userPosition?.latitude ?? _campusLat,
                      userLng: _userPosition?.longitude ?? _campusLng,
                    )));
                  },
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: Text('Lihat Rute', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1A73E8),
                    side: const BorderSide(color: Color(0xFF1A73E8)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    if (sisa == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Maaf, parkiran penuh!', style: GoogleFonts.inter()), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
                      return;
                    }
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => ChooseSpacePage(parkingName: title, jenisKendaraan: jenis)));
                    if (result != null && result is Map<String, dynamic>) {
                      setState(() {
                        isParking = true;
                        platUser = result['plat'];
                        currentImagePath = result['imagePath'];
                        lokasiParkir = title;
                      });
                      _startTimer();
                    }
                  },
                  icon: const Icon(Icons.local_parking, size: 18, color: Colors.white),
                  label: Text('Pesan Slot', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String kategori = selectedCategoryIndex == 0 ? 'Mobil' : 'Motor';
    final List<Map<String, dynamic>> filtered = _semuaParkiran
        .where((p) => p['jenis'] == kategori && p['nama'].toString().toLowerCase().contains(_searchText))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // ===== HEADER =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 52, left: 24, right: 24, bottom: 28),
            decoration: const BoxDecoration(
              color: Color(0xFF0D1B2A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          widget.username.isNotEmpty ? widget.username[0].toUpperCase() : 'U',
                          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.username, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                          Text(widget.jurusan, style: GoogleFonts.inter(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    // Notif
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                Text('Selamat ${_getGreeting()},', style: GoogleFonts.inter(color: Colors.white54, fontSize: 14)),
                Text('Cari Parkir Sekarang 🚗', style: GoogleFonts.inter(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.3)),

                const SizedBox(height: 14),

                // Lokasi Chip
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF1A73E8), size: 14),
                    const SizedBox(width: 5),
                    _locationLoading
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2))
                        : Text(_locationLabel, style: GoogleFonts.inter(color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== QUICK ACTIONS =====
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(child: _buildQuickAction(icon: Icons.my_location_rounded, label: 'Posisi', sublabel: 'Kendaraan Saya', color: const Color(0xFF1A73E8), onTap: _cekPosisi)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildQuickAction(icon: Icons.emergency_rounded, label: 'SOS', sublabel: 'Lapor Keamanan', color: const Color(0xFFE53935), onTap: _laporKeamanan)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== SEARCH =====
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchText = v.toLowerCase()),
                      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF0D1B2A)),
                      decoration: InputDecoration(
                        hintText: 'Cari lokasi parkir...',
                        hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF9EABBE), size: 20),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE8EDF2))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1A73E8))),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== STATUS PARKIR AKTIF =====
                  if (isParking)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)]),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: const Color(0xFF1A73E8).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.timer_rounded, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_formatDuration(_secondsElapsed), style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: 2)),
                                  Text('Plat: ${platUser?.toUpperCase() ?? "-"} • $lokasiParkir', style: GoogleFonts.inter(color: Colors.white60, fontSize: 11)),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _stopTimer,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                              child: Text('Selesai', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.red)),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // ===== KATEGORI =====
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _buildCategoryChip(icon: Icons.directions_car_rounded, label: 'Mobil', index: 0),
                        const SizedBox(width: 10),
                        _buildCategoryChip(icon: Icons.two_wheeler_rounded, label: 'Motor', index: 1),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== JUDUL DAFTAR =====
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Parkiran $kategori', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: const Color(0xFF0D1B2A))),
                        Text('${filtered.length} tersedia', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500])),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ===== DAFTAR PARKIRAN =====
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _buildParkingCard(filtered[i]),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[100]!, width: 1.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          selectedItemColor: const Color(0xFF1A73E8),
          unselectedItemColor: Colors.grey[400],
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({required IconData icon, required String label, required String sublabel, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8EDF2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: const Color(0xFF0D1B2A))),
                Text(sublabel, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[400])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip({required IconData icon, required String label, required int index}) {
    final bool active = selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedCategoryIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1A73E8) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? const Color(0xFF1A73E8) : const Color(0xFFE8EDF2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: active ? Colors.white : Colors.grey[400]),
            const SizedBox(width: 7),
            Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: active ? Colors.white : Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _buildParkingCard(Map<String, dynamic> item) {
    final bool isAlmostFull = item['sisa'] <= 5;
    final String jarak = _getJarak(item);
    return GestureDetector(
      onTap: () => _showActionMenu(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8EDF2)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item['img'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: Colors.grey[100], child: const Icon(Icons.local_parking, color: Colors.grey)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['nama'], style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: const Color(0xFF0D1B2A))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF9EABBE)),
                      const SizedBox(width: 3),
                      Text(item['lokasi'], style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12)),
                      const SizedBox(width: 10),
                      const Icon(Icons.near_me_outlined, size: 12, color: Color(0xFF9EABBE)),
                      const SizedBox(width: 3),
                      Text(jarak, style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: isAlmostFull ? Colors.red[50] : Colors.green[50],
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text('${item['sisa']} Slot', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: isAlmostFull ? Colors.red[600] : Colors.green[600])),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (item['total'] - item['sisa']) / item['total'],
                            backgroundColor: Colors.grey[100],
                            color: isAlmostFull ? Colors.red[400] : const Color(0xFF1A73E8),
                            minHeight: 5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF9EABBE)),
          ],
        ),
      ),
    );
  }
}

// Widget Indikator slot
class _SlotIndicator extends StatelessWidget {
  final int sisa;
  final int total;
  const _SlotIndicator({required this.sisa, required this.total});

  @override
  Widget build(BuildContext context) {
    final double pct = (total - sisa) / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Kapasitas Terisi', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500])),
            Text('${total - sisa}/$total', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF0D1B2A))),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.grey[100],
            color: pct > 0.8 ? Colors.red[400] : const Color(0xFF1A73E8),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
