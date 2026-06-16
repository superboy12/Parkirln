import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class RoutePage extends StatefulWidget {
  final String destinationName;
  final String jarak;
  final double destLat;
  final double destLng;
  final double userLat;
  final double userLng;

  const RoutePage({
    super.key,
    required this.destinationName,
    required this.jarak,
    required this.destLat,
    required this.destLng,
    this.userLat = -5.3656,
    this.userLng = 105.2440,
  });

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  LatLng get _userLatLng => LatLng(widget.userLat, widget.userLng);
  LatLng get _destLatLng => LatLng(widget.destLat, widget.destLng);
  LatLng get _centerLatLng => LatLng(
    (widget.userLat + widget.destLat) / 2,
    (widget.userLng + widget.destLng) / 2,
  );

  Future<void> _openNavigation() async {
    final Uri geoUri = Uri.parse('geo:${widget.destLat},${widget.destLng}?q=${widget.destLat},${widget.destLng}(${Uri.encodeComponent(widget.destinationName)})');
    final Uri mapsUri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${widget.destLat},${widget.destLng}&travelmode=walking');

    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri);
    } else {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ===== PETA OPENSTREETMAP =====
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _centerLatLng,
              initialZoom: 16.0,
              maxZoom: 19,
              minZoom: 10,
            ),
            children: [
              // Tile Layer (OpenStreetMap)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.parkirin_app',
                maxZoom: 19,
              ),

              // Polyline rute (garis biru dari user ke tujuan)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [_userLatLng, _destLatLng],
                    strokeWidth: 5.0,
                    color: const Color(0xFF1A73E8),
                  ),
                ],
              ),

              // Marker Layer
              MarkerLayer(
                markers: [
                  // Marker Posisi User (biru)
                  Marker(
                    point: _userLatLng,
                    width: 50,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A73E8),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [BoxShadow(color: const Color(0xFF1A73E8).withOpacity(0.4), blurRadius: 10, spreadRadius: 3)],
                      ),
                      child: const Icon(Icons.navigation_rounded, color: Colors.white, size: 22),
                    ),
                  ),

                  // Marker Tujuan (merah)
                  Marker(
                    point: _destLatLng,
                    width: 120,
                    height: 70,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: Text(widget.destinationName, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF0D1B2A)), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        const Icon(Icons.location_on, color: Color(0xFFE53935), size: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ===== HEADER BAR =====
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Tombol Back
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0D1B2A), size: 17),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Search bar style
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Row(children: [
                        const Icon(Icons.search_rounded, color: Color(0xFF1A73E8), size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Rute ke ${widget.destinationName}', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF3D4A5C), fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Zoom to fit
                  GestureDetector(
                    onTap: () {
                      _mapController.move(_centerLatLng, 16.0);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: const Icon(Icons.my_location_rounded, color: Color(0xFF1A73E8), size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== BOTTOM CARD =====
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, -4))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      // Icon destinasi
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFF1A73E8).withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.local_parking_rounded, color: Color(0xFF1A73E8), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.destinationName, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16, color: const Color(0xFF0D1B2A))),
                            const SizedBox(height: 3),
                            Row(children: [
                              const Icon(Icons.near_me_rounded, size: 13, color: Color(0xFF9EABBE)),
                              const SizedBox(width: 4),
                              Text(widget.jarak, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500])),
                              const SizedBox(width: 12),
                              const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF9EABBE)),
                              const SizedBox(width: 4),
                              Text('~8 menit jalan kaki', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500])),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  const Divider(color: Color(0xFFF0F2F5), height: 1),
                  const SizedBox(height: 18),

                  // Info row
                  Row(children: [
                    _infoChip(icon: Icons.route_rounded, label: widget.jarak, color: const Color(0xFF1A73E8)),
                    const SizedBox(width: 10),
                    _infoChip(icon: Icons.directions_walk_rounded, label: '~8 menit', color: Colors.green),
                    const SizedBox(width: 10),
                    _infoChip(icon: Icons.wb_sunny_rounded, label: '28°C', color: Colors.orange),
                  ]),

                  const SizedBox(height: 18),

                  // Tombol Navigasi
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _openNavigation,
                      icon: const Icon(Icons.navigation_rounded, color: Colors.white, size: 20),
                      label: Text('Mulai Navigasi', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A73E8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip({required IconData icon, required String label, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
