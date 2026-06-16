import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../../data/models/slot_model.dart';
import '../../../data/models/parking_area_model.dart';
import 'active_session_screen.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  final SlotModel slot;
  final ParkingAreaModel area;

  const CheckInScreen({super.key, required this.slot, required this.area});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  CameraController? _cameraController;
  XFile? _capturedImage;
  bool _isProcessing = false;
  final TextEditingController _platController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initCamera();
    
    // Auto-fill plat nomor if user has it
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = await ref.read(authProvider.future);
      if (user != null && user.noPlat != null && user.noPlat != '-') {
        _platController.text = user.noPlat!;
      }
    });
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    
    _cameraController = CameraController(cameras.first, ResolutionPreset.medium, enableAudio: false);
    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      final image = await _cameraController!.takePicture();
      setState(() => _capturedImage = image);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengambil foto: $e')));
    }
  }

  Future<void> _submitCheckIn() async {
    if (_platController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plat nomor wajib diisi!')));
      return;
    }
    if (_capturedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto kendaraan wajib dilampirkan!')));
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final user = await ref.read(authProvider.future);
      if (user == null) throw Exception('User not found');

      final pos = await Geolocator.getCurrentPosition();

      // 1. Upload photo to Supabase Storage
      final bytes = await _capturedImage!.readAsBytes();
      final ext = _capturedImage!.path.split('.').last;
      final fileName = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      
      await Supabase.instance.client.storage.from('parking_docs').uploadBinary(
        fileName, 
        bytes,
        fileOptions: FileOptions(contentType: 'image/$ext'),
      );
      
      final imageUrl = Supabase.instance.client.storage.from('parking_docs').getPublicUrl(fileName);

      // 2. Create Parking Session
      final session = await ref.read(supabaseServiceProvider).createParkingSession(
        uid: user.uid,
        parkingId: widget.area.id,
        slotId: widget.slot.slotId,
        platNomor: _platController.text.trim().toUpperCase(),
        checkInLat: pos.latitude,
        checkInLng: pos.longitude,
        fotoMasukUrl: imageUrl,
      );

      // Refresh providers
      ref.invalidate(parkingAreasProvider);
      ref.invalidate(sessionsProvider);

      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ActiveSessionScreen(session: session)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal Check-In: $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _platController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Check-In Parkir', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _isProcessing 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lokasi: ${widget.area.namaArea}', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 4),
              Text('Slot: ${widget.slot.nomorSlot} (${widget.slot.jenisKendaraan})', style: GoogleFonts.inter(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold)),
              
              const SizedBox(height: 24),
              Text('Plat Nomor Kendaraan', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _platController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Contoh: BE 1234 XY',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 24),
              Text('Bukti Foto Kendaraan', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),

              if (_capturedImage != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(_capturedImage!.path), height: 200, width: double.infinity, fit: BoxFit.cover),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _capturedImage = null),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Foto Ulang'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                )
              ] else if (_cameraController != null && _cameraController!.value.isInitialized) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: _cameraController!.value.aspectRatio,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _takePicture,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Ambil Foto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )
              ] else ...[
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                )
              ],

              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _capturedImage != null ? _submitCheckIn : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: Text('KONFIRMASI CHECK-IN', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
              )
            ],
          ),
        ),
    );
  }
}
