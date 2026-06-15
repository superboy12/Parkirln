import 'package:flutter/material.dart';
import 'camera_page.dart'; 

class ChooseSpacePage extends StatefulWidget {
  final String parkingName;
  final String jenisKendaraan;

  const ChooseSpacePage({super.key, required this.parkingName, required this.jenisKendaraan});

  @override
  State<ChooseSpacePage> createState() => _ChooseSpacePageState();
}

class _ChooseSpacePageState extends State<ChooseSpacePage> {
  int selectedSide = 0; 
  int? selectedIndex; 
  final TextEditingController _platController = TextEditingController();

  // Data simulasi plat yang sudah parkir
  Map<int, String> platTerisi = {
    0: "BE 2021 AB",
    1: "B 1234 XYZ",
    3: "D 9999 GA",
  };

  List<int> slotsKiri = [1, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1];
  List<int> slotsKanan = [0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];

  @override
  void dispose() {
    _platController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), 
          onPressed: () => Navigator.pop(context)
        ),
        title: Text(widget.parkingName, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSideTab('Parkiran Kiri', 0),
                const SizedBox(width: 15),
                _buildSideTab('Parkiran Kanan', 1),
              ],
            ),
            const SizedBox(height: 20),
            
            // AREA GRID PARKIR
            SizedBox(
              height: 350,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildGrid(selectedSide == 0 ? slotsKiri : slotsKanan),
              ),
            ),

            // INPUT PLAT NOMOR
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Masukkan Plat Nomor Kendaraan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _platController,
                    textCapitalization: TextCapitalization.characters, // Otomatis Huruf Kapital
                    decoration: InputDecoration(
                      hintText: "Contoh: BE 1234 XX",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onChanged: (v) => setState(() {}),
                  ),
                ],
              ),
            ),

            // TOMBOL KONFIRMASI (NYAMBUNG KE KAMERA & KIRIM DATA LENGKAP)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: ElevatedButton(
                onPressed: (selectedIndex != null && _platController.text.isNotEmpty)
                  ? () async {
                      // 1. PINDAH KE HALAMAN KAMERA DULU
                      // Kita menunggu hasil dari CameraPage (true/false atau path foto)
                      final cameraResult = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CameraPage(platNomor: _platController.text),
                        ),
                      );

                      // 2. JIKA PROSES AMBIL FOTO SUKSES
                      if (cameraResult != null) {
                        if (mounted) {
                          // KITA KIRIM DATA DALAM BENTUK MAP KE HOME_PAGE
                          // Pastikan camera_page.dart mengirimkan Path Foto saat Navigator.pop
                          Navigator.pop(context, {
                            'plat': _platController.text,
                            'imagePath': cameraResult.toString(), // Mengirim path foto untuk SOS
                          });
                        }
                      }
                    }
                  : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B8EFF),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('KONFIRMASI PARKIR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSideTab(String title, int index) {
    bool isSelected = selectedSide == index;
    return GestureDetector(
      onTap: () => setState(() { selectedSide = index; selectedIndex = null; }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B8EFF) : Colors.grey[100], 
          borderRadius: BorderRadius.circular(12)
        ),
        child: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildGrid(List<int> slots) {
    return GridView.builder(
      itemCount: slots.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        int status = slots[index];
        bool isThisSelected = selectedIndex == index;
        
        return GestureDetector(
          onTap: () { if (status == 0) setState(() => selectedIndex = index); },
          child: Container(
            decoration: BoxDecoration(
              color: isThisSelected ? const Color(0xFFAEC4FF) : (status == 1 ? Colors.white : const Color(0xFFE8EFFF)),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isThisSelected ? const Color(0xFF6B8EFF) : Colors.grey[200]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.jenisKendaraan == 'Mobil' ? Icons.directions_car : Icons.pedal_bike, 
                     color: status == 1 ? Colors.black26 : (isThisSelected ? const Color(0xFF6B8EFF) : Colors.black12)),
                if (status == 1 && platTerisi.containsKey(index))
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(platTerisi[index]!, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ),
                if (isThisSelected) const Icon(Icons.check_circle, size: 15, color: Color(0xFF6B8EFF)),
              ],
            ),
          ),
        );
      },
    );
  }
}