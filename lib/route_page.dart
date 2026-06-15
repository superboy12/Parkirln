import 'package:flutter/material.dart';

class RoutePage extends StatelessWidget {
  final String destinationName;
  final String jarak;

  const RoutePage({
    super.key, 
    required this.destinationName, 
    required this.jarak
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- SIMULASI PETA (BACKGROUND) ---
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFE5E3DF), // Warna dasar Google Maps
            child: Stack(
              children: [
                // Gambar denah kampus (Bisa diganti image map beneran nanti)
                Center(
                  child: Icon(Icons.map_outlined, size: 500, color: Colors.white.withOpacity(0.5)),
                ),
                
                // JALUR NAVIGASI (Simulasi Garis Biru Maps)
                Positioned(
                  top: 250,
                  left: 100,
                  child: CustomPaint(
                    size: const Size(200, 300),
                    painter: RoutePainter(),
                  ),
                ),

                // ICON LOKASI ANDA (Pulse Effect)
                const Positioned(
                  top: 500,
                  left: 100,
                  child: _CurrentLocationIcon(),
                ),

                // ICON TUJUAN (Pin Merah)
                Positioned(
                  top: 230,
                  left: 280,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                        ),
                        child: Text(destinationName, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- HEADER SEARCH BAR (LOOKS LIKE MAPS) ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.blue),
                          const SizedBox(width: 10),
                          Text('Rute ke $destinationName', style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- KARTU DETAIL RUTE (BOTTOM CARD) ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('8 Menit', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                          Text('Jarak tercepat saat ini', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      Text(jarak, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const Divider(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.navigation, color: Colors.white),
                          label: const Text('MULAI SEKARANG', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- PAINTER UNTUK GARIS RUTE ---
class RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.8)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height); // Start posisi User
    path.lineTo(50, size.height - 100);
    path.lineTo(150, size.height - 150);
    path.lineTo(200, 0); // End posisi Tujuan

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- WIDGET IKON LOKASI BERDENYUT ---
class _CurrentLocationIcon extends StatefulWidget {
  const _CurrentLocationIcon();

  @override
  State<_CurrentLocationIcon> createState() => _CurrentLocationIconState();
}

class _CurrentLocationIconState extends State<_CurrentLocationIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 40 * _controller.value,
              height: 40 * _controller.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(1 - _controller.value),
              ),
            ),
            const Icon(Icons.circle, color: Colors.white, size: 18),
            const Icon(Icons.circle, color: Colors.blue, size: 14),
          ],
        );
      },
    );
  }
}