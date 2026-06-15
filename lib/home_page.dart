import 'package:flutter/material.dart';
import 'dart:async';
import 'choose_space_page.dart';
import 'route_page.dart';
import 'sos_page.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String fakultas;
  final String jurusan;

  const HomePage({
    super.key, 
    this.username = "Daniel",
    this.fakultas = "Fakultas Teknik",
    this.jurusan = "Teknik Informatika",
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int selectedCategoryIndex = 0; // 0: Mobil, 1: Motor
  
  // State Parkir Aktif
  bool isParking = false; 
  String? platUser; 
  String? lokasiParkir;
  String? currentImagePath; // Variabel krusial untuk menyimpan path foto hasil kamera

  // State Timer
  Timer? _timer;
  int _secondsElapsed = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  // DATA MASTER PARKIRAN KAMPUS
  final List<Map<String, dynamic>> semuaParkiran = [
    {
      'nama': 'Teknik Elektro', 'jenis': 'Mobil', 'lokasi': 'Gedung H', 'sisa': 4, 'total': 50,
      'img': 'https://images.unsplash.com/photo-1590674899484-d5640e854abe?w=400',
      'jarak': '1.2 km'
    },
    {
      'nama': 'Teknik Sipil', 'jenis': 'Motor', 'lokasi': 'Gedung A', 'sisa': 45, 'total': 100,
      'img': 'https://images.unsplash.com/photo-1621993202323-f438eec934ff?w=400',
      'jarak': '450 m'
    },
    {
      'nama': 'Teknik Geodesi', 'jenis': 'Motor', 'lokasi': 'Samping Lab', 'sisa': 12, 'total': 60,
      'img': 'https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?w=400',
      'jarak': '800 m'
    },
  ];

  // --- FUNGSI LOGIKA WAKTU ---

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  void _startTimer() {
    _timer?.cancel(); 
    _secondsElapsed = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsElapsed++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _secondsElapsed = 0;
      isParking = false;
      platUser = null;
      lokasiParkir = null;
      currentImagePath = null; // Menghapus path foto saat parkir selesai
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Parkir Selesai. Hati-hati di jalan!'), backgroundColor: Colors.blue),
    );
  }

  String _formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    _searchController.dispose();
    super.dispose();
  }

  // --- FITUR KEAMANAN & SOS ---

  void _cekPosisi() {
    if (isParking) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('📍 Kendaraan Anda aman di $lokasiParkir'), backgroundColor: Colors.blueGrey));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anda belum memarkirkan kendaraan.'), backgroundColor: Colors.grey));
    }
  }

  // FUNGSI SOS (LAPOR): Membuka SosPage dengan Data Dinamis & Foto Kamera
  void _laporKeamanan() {
    if (!isParking) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan parkir terlebih dahulu untuk fitur SOS.'), backgroundColor: Colors.orange)
      );
      return;
    }

    String namaSatpam = "Pak Budi"; 
    String nomorSatpam = "0812-3456-7890";

    // Filter Satpam berdasarkan Lokasi Parkir Daniel
    if (lokasiParkir == "Teknik Elektro") {
      namaSatpam = "Pak Slamet (Elektro)";
      nomorSatpam = "0811-7777-8888";
    } else if (lokasiParkir == "Teknik Sipil") {
      namaSatpam = "Pak Agus (Sipil)";
      nomorSatpam = "0852-6666-5555";
    } else if (lokasiParkir == "Teknik Geodesi") {
      namaSatpam = "Pak Rahmat (Geodesi)";
      nomorSatpam = "0821-9999-0000";
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SosPage(
          namaSatpam: namaSatpam,
          nomorSatpam: nomorSatpam,
          lokasiParkir: lokasiParkir ?? "Area Kampus",
          platNomor: platUser ?? "-",
          imagePath: currentImagePath, // MENGIRIM FOTO ASLI HASIL KAMERA KE SOS_PAGE
        ),
      ),
    );
  }

  void _showCCTV() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.videocam, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(child: Text('Live CCTV: $lokasiParkir', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network('https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?w=500', height: 150, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Plat: ${platUser?.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const Row(
                  children: [
                    Icon(Icons.shield, color: Colors.green, size: 16),
                    SizedBox(width: 5),
                    Text('Aman', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  void _showActionMenu(String title, String jenis, int sisa, String jarak, String imageUrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Row(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover)),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Jarak: $jarak dari Gerbang Utama', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RoutePage(destinationName: title, jarak: jarak)));
                    },
                    icon: const Icon(Icons.map, color: Color(0xFF0083B0)),
                    label: const Text('Lihat Rute', style: TextStyle(color: Color(0xFF0083B0))),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), side: const BorderSide(color: Color(0xFF0083B0)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context); 
                      if(sisa == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maaf, Parkiran Penuh!')));
                        return;
                      }
                      
                      // PINDAH KE CHOOSE SPACE -> CAMERA PAGE
                      final result = await Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => ChooseSpacePage(parkingName: title, jenisKendaraan: jenis))
                      );

                      // FOKUS: Menangkap Map data (Plat & Path Foto)
                      if (result != null && result is Map<String, dynamic>) {
                        setState(() { 
                          isParking = true; 
                          platUser = result['plat']; 
                          currentImagePath = result['imagePath']; // Menyimpan lokasi file foto asli
                          lokasiParkir = title; 
                        });
                        _startTimer(); 
                      }
                    },
                    icon: const Icon(Icons.local_parking, color: Colors.white),
                    label: const Text('Pesan Slot', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0083B0), padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String kategoriAktif = selectedCategoryIndex == 0 ? "Mobil" : "Motor";
    List<Map<String, dynamic>> parkiranTersaring = semuaParkiran.where((p) => p['jenis'] == kategoriAktif && p['nama'].toString().toLowerCase().contains(_searchText)).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // --- HEADER GRADIENT ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 35), 
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF00B4DB), Color(0xFF00A896)]),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_circle, color: Colors.white, size: 45),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("${widget.jurusan} • ${widget.fakultas}", 
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.w500)),
                          ],
                        )
                      ],
                    ),
                    const Icon(Icons.notifications_none, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 25),
                Text('${_getGreeting()},', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                const Text('Aman parkir\ndi kampus hari ini.', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.2)),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text('Bandar Lampung, 28°C', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 25), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- KEAMANAN & SOS ---
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickAction(Icons.location_on, 'Posisi', 'Cari Kendaraan', _cekPosisi),
                        Container(width: 1, height: 40, color: Colors.grey[200]), 
                        _buildQuickAction(Icons.sos, 'Lapor', 'Keamanan', _laporKeamanan, iconColor: Colors.orange),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 25),

                  // --- SEARCH BAR ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: TextField(
                      onChanged: (v) => setState(() => _searchText = v.toLowerCase()),
                      decoration: InputDecoration(hintText: 'Cari Lokasi Fakultas...', prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- STATUS PARKIR REALTIME ---
                  if (isParking) 
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.green[300]!)),
                      child: Row(children: [
                        const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.timer, color: Colors.white)),
                        const SizedBox(width: 15),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Durasi: ${_formatDuration(_secondsElapsed)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)), Text('Plat: ${platUser?.toUpperCase()}', style: const TextStyle(fontSize: 12))])),
                        IconButton(onPressed: _showCCTV, icon: const Icon(Icons.videocam, color: Colors.blue)),
                        ElevatedButton(onPressed: _stopTimer, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), child: const Text('Selesai'))
                      ]),
                    ),

                  const SizedBox(height: 10),

                  // --- FILTER KATEGORI ---
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildCategoryItem(Icons.directions_car, 'Mobil', 0), const SizedBox(width: 30), _buildCategoryItem(Icons.pedal_bike, 'Motor', 1)]),
                  
                  const SizedBox(height: 30),

                  // --- DAFTAR PARKIRAN ---
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 25), child: Text('Daftar Parkiran $kategoriAktif', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 15),
                  ListView.builder(
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    itemCount: parkiranTersaring.length,
                    itemBuilder: (context, index) {
                      var item = parkiranTersaring[index];
                      return _buildParkingItem(item['nama'], item['lokasi'], item['img'], kategoriAktif, item['sisa'], item['total'], item['jarak']);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF0083B0),
        items: const [BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Beranda'), BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil')],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String title, String subtitle, VoidCallback onTap, {Color? iconColor}) {
    return InkWell(onTap: onTap, child: Column(children: [Icon(icon, color: iconColor ?? const Color(0xFF00A896), size: 30), const SizedBox(height: 5), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey))]));
  }

  Widget _buildCategoryItem(IconData icon, String label, int index) {
    bool isActive = selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedCategoryIndex = index),
      child: Column(children: [Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: isActive ? const Color(0xFF00A896) : Colors.white, borderRadius: BorderRadius.circular(18), border: isActive ? null : Border.all(color: Colors.grey[200]!)), child: Icon(icon, color: isActive ? Colors.white : Colors.grey[400], size: 30)), const SizedBox(height: 8), Text(label, style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? Colors.black : Colors.grey))]),
    );
  }

  Widget _buildParkingItem(String title, String subtitle, String imageUrl, String jenis, int sisa, int total, String jarak) {
    bool isAlmostFull = sisa <= 5;
    Color statusColor = isAlmostFull ? Colors.red : Colors.green;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 25, right: 25),
      child: InkWell(
        onTap: () => _showActionMenu(title, jenis, sisa, jarak, imageUrl),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[100]!)),
          child: Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(imageUrl, width: 85, height: 85, fit: BoxFit.cover)),
            const SizedBox(width: 15),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(jarak, style: const TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(height: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text('Tersedia $sisa Slot', style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)))]))
          ]),
        ),
      ),
    );
  }
}