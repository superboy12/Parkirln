import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../../data/models/parking_session_model.dart';
import '../dashboard/dashboard_screen.dart';

class CheckOutScreen extends ConsumerStatefulWidget {
  final ParkingSessionModel session;

  const CheckOutScreen({super.key, required this.session});

  @override
  ConsumerState<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends ConsumerState<CheckOutScreen> {
  CameraController? _cameraController;
  XFile? _capturedImage;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
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

  Future<void> _submitCheckOut() async {
    if (_capturedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto kendaraan wajib dilampirkan sebelum keluar!')));
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 1. Upload photo to Supabase Storage
      final bytes = await _capturedImage!.readAsBytes();
      final ext = _capturedImage!.path.split('.').last;
      final fileName = '${widget.session.uid}_checkout_${DateTime.now().millisecondsSinceEpoch}.$ext';
      
      await Supabase.instance.client.storage.from('parking_docs').uploadBinary(
        fileName, 
        bytes,
        fileOptions: FileOptions(contentType: 'image/$ext'),
      );
      
      final imageUrl = Supabase.instance.client.storage.from('parking_docs').getPublicUrl(fileName);

      // 2. Finalize Session
      await ref.read(supabaseServiceProvider).checkOutSession(
        sessionId: widget.session.id,
        slotId: widget.session.slotId,
        parkingId: widget.session.parkingId,
        fotoKeluarUrl: imageUrl,
      );

      // Refresh providers
      ref.invalidate(parkingAreasProvider);
      ref.invalidate(sessionsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil Check-Out! Terima kasih.')));
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const DashboardScreen()), (_) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal Check-Out: $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Konfirmasi Keluar (Check-Out)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
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
              Text('Silakan ambil foto kendaraan Anda sebelum meninggalkan slot parkir.', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textHint)),
              
              const SizedBox(height: 24),
              Text('Bukti Foto Akhir Kendaraan', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),

              if (_capturedImage != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(_capturedImage!.path), height: 300, width: double.infinity, fit: BoxFit.cover),
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
                  label: const Text('Ambil Foto Keluar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )
              ] else ...[
                Container(
                  height: 300,
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
                onPressed: _capturedImage != null ? _submitCheckOut : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: Text('AKHIRI SESI PARKIR', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
              )
            ],
          ),
        ),
    );
  }
}
