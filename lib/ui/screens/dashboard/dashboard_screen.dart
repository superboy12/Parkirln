import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../../core/services/location_service.dart';
import '../../widgets/custom_glass_card.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final locationService = ref.read(locationServiceProvider);
    final pos = await locationService.getCurrentPosition();
    if (pos != null && mounted) {
      setState(() => _currentPosition = pos);
      _animateToPosition(pos);
    }

    _positionStream = locationService.getPositionStream().listen((pos) {
      if (mounted) {
        setState(() => _currentPosition = pos);
      }
    });
  }

  void _animateToPosition(Position pos) {
    _mapController.move(LatLng(pos.latitude, pos.longitude), 16.0);
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final areasAsync = ref.watch(parkingAreasProvider);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: CustomGlassCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_parking_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('SmartPark', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : AppColors.textPrimary)),
              ],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
              child: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          // MAP LAYER
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(-5.3645, 105.2435), // Unila default
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}', // Google Maps tile URL
                userAgentPackageName: 'com.example.smartpark_unila',
              ),
              MarkerLayer(
                markers: [
                  if (_currentPosition != null)
                    Marker(
                      point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 15,
                            height: 15,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.white, spreadRadius: 3)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ...areasAsync.maybeWhen(
                    data: (areas) => areas.map((area) {
                      return Marker(
                        point: LatLng(area.latitude, area.longitude),
                        width: 50,
                        height: 50,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: area.availableSlot > 0 ? AppColors.markerGreen : AppColors.markerRed,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.local_parking_rounded, color: Colors.white, size: 20),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    orElse: () => [],
                  ),
                ],
              ),
            ],
          ),

          // VEHICLE TYPE SELECTOR (Top Center)
          Positioned(
            top: MediaQuery.of(context).padding.top + AppBar().preferredSize.height + 16,
            left: 20,
            right: 20,
            child: Align(
              alignment: Alignment.topCenter,
              child: CustomGlassCard(
                borderRadius: 30,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: ['Motor', 'Mobil'].map((type) {
                      final isSelected = ref.watch(vehicleTypeProvider) == type;
                      return GestureDetector(
                        onTap: () => ref.read(vehicleTypeProvider.notifier).state = type,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Text(
                            type,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textPrimary),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),

          // FLOATING CARDS (Bottom)
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Recenter button
                FloatingActionButton(
                  heroTag: 'recenter',
                  backgroundColor: AppColors.primary,
                  onPressed: () {
                    if (_currentPosition != null) _animateToPosition(_currentPosition!);
                  },
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
                const SizedBox(height: 16),
                
                // Areas List Horizontal
                SizedBox(
                  height: 140,
                  child: areasAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(child: Text('Error: $e')),
                    data: (areas) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: areas.length,
                        itemBuilder: (context, index) {
                          final area = areas[index];
                          // Calculate distance if position available
                          String distText = 'Menghitung...';
                          if (_currentPosition != null) {
                            final dist = ref.read(locationServiceProvider).calculateDistance(
                              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                              LatLng(area.latitude, area.longitude)
                            );
                            distText = '${(dist / 1000).toStringAsFixed(1)} km';
                          }

                          return Container(
                            width: 280,
                            margin: const EdgeInsets.only(right: 16),
                            child: CustomGlassCard(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: Text(area.namaArea, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: area.availableSlot > 0 ? AppColors.markerGreen.withOpacity(0.2) : AppColors.markerRed.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                                          child: Text(area.availableSlot > 0 ? 'Tersedia' : 'Penuh', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: area.availableSlot > 0 ? AppColors.markerGreen : AppColors.markerRed)),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text('$distText dari lokasi Anda', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textHint)),
                                    const Spacer(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${area.availableSlot} / ${area.totalSlot} Slot', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primary)),
                                        ElevatedButton(
                                          onPressed: area.availableSlot > 0 ? () {
                                            // TODO: Start Navigation Macro
                                          } : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          ),
                                          child: Text('Navigasi', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12)),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
