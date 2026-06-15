import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPage extends StatefulWidget {
  final String platNomor;
  const CameraPage({super.key, required this.platNomor});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  bool isReady = false;
  bool isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  // Fungsi untuk menyalakan kamera asli device
  Future<void> _setupCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        // Mencari kamera belakang, jika tidak ada pakai yang tersedia (webcam)
        CameraDescription selectedCamera = cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => cameras!.first,
        );

        controller = CameraController(
          selectedCamera,
          ResolutionPreset.high,
        );

        await controller!.initialize();
        if (!mounted) return;
        setState(() {
          isReady = true;
        });
      }
    } catch (e) {
      print("Error kamera: $e");
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady || controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // --- VIEWINDER KAMERA ASLI ---
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: controller!.value.aspectRatio,
              child: CameraPreview(controller!),
            ),
          ),

          // OVERLAY BINGKAI FOTO
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white54, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.center_focus_strong, color: Colors.white54, size: 40),
            ),
          ),

          // UI TEXT & BUTTONS
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                        child: Text("FOTO UNIT: ${widget.platNomor}", 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const Icon(Icons.flash_off, color: Colors.white),
                    ],
                  ),
                ),
                
                // TOMBOL JEPRET
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Column(
                    children: [
                      if (isTakingPicture)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      GestureDetector(
                        onTap: () async {
                          if (isTakingPicture) return;
                          setState(() => isTakingPicture = true);
                          
                          try {
                            // 1. Ambil foto asli
                            final XFile photo = await controller!.takePicture();
                            
                            // 2. Kirim path file foto kembali ke halaman sebelumnya (ChooseSpacePage)
                            if (mounted) Navigator.pop(context, photo.path);
                          } catch (e) {
                            setState(() => isTakingPicture = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Gagal mengambil gambar: $e"))
                            );
                          }
                        },
                        child: Container(
                          width: 85,
                          height: 85,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 5),
                          ),
                          child: Center(
                            child: Container(
                              width: 65,
                              height: 65,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text("AMBIL FOTO BUKTI PARKIR", 
                        style: TextStyle(color: Colors.white, fontSize: 10, letterSpacing: 1)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}