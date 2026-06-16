import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'camera_page.dart';

class ChooseSpacePage extends StatefulWidget {
  final String parkingName;
  final String jenisKendaraan;

  const ChooseSpacePage({super.key, required this.parkingName, required this.jenisKendaraan});

  @override
  State<ChooseSpacePage> createState() => _ChooseSpacePageState();
}

class _ChooseSpacePageState extends State<ChooseSpacePage> with SingleTickerProviderStateMixin {
  int selectedSide = 0;
  int? selectedIndex;
  final TextEditingController _platController = TextEditingController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  Map<int, String> platTerisi = {
    0: 'BE 2021 AB',
    1: 'B 1234 XY',
    3: 'D 9999 GA',
    7: 'BG 4567 Z',
  };

  // 0 = kosong, 1 = terisi
  List<int> slotsKiri  = [1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0];
  List<int> slotsKanan = [0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _platController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  List<int> get _activeSlots => selectedSide == 0 ? slotsKiri : slotsKanan;

  int get _availableCount => _activeSlots.where((s) => s == 0).length;

  Color _slotColor(int status, bool isSelected) {
    if (status == 1) return const Color(0xFFF0F2F5); // terisi
    if (isSelected) return const Color(0xFF1A73E8);   // dipilih
    return const Color(0xFFEAF2FF);                   // kosong
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // ===== HEADER =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 52, left: 20, right: 20, bottom: 24),
            decoration: const BoxDecoration(
              color: Color(0xFF0D1B2A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pilih Slot Parkir', style: GoogleFonts.inter(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500)),
                        Text(widget.parkingName, style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Stats row
                Row(
                  children: [
                    _buildHeaderStat(Icons.check_circle_rounded, '$_availableCount Kosong', Colors.greenAccent),
                    const SizedBox(width: 16),
                    _buildHeaderStat(Icons.block_rounded, '${_activeSlots.where((s) => s == 1).length} Terisi', Colors.redAccent),
                    const SizedBox(width: 16),
                    _buildHeaderStat(
                      widget.jenisKendaraan == 'Mobil' ? Icons.directions_car_rounded : Icons.two_wheeler_rounded,
                      widget.jenisKendaraan,
                      Colors.lightBlueAccent,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ===== CONTENT =====
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SIDE TABS
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE8EDF2)),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _buildSideTab('Parkiran Kiri', 0)),
                        Expanded(child: _buildSideTab('Parkiran Kanan', 1)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // LEGEND
                  Row(
                    children: [
                      _buildLegend(const Color(0xFFEAF2FF), const Color(0xFF1A73E8), 'Tersedia'),
                      const SizedBox(width: 16),
                      _buildLegend(const Color(0xFF1A73E8), const Color(0xFF1A73E8), 'Dipilih', textColor: Colors.white),
                      const SizedBox(width: 16),
                      _buildLegend(const Color(0xFFF0F2F5), Colors.grey, 'Terisi'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // PARKING GRID AREA
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE8EDF2)),
                    ),
                    child: Column(
                      children: [
                        // Road indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F2F5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(children: [
                                const Icon(Icons.arrow_upward_rounded, size: 12, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text('Jalan Utama', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_downward_rounded, size: 12, color: Colors.grey),
                              ]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _activeSlots.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.78,
                          ),
                          itemBuilder: (_, i) => _buildSlot(i, _activeSlots[i]),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PLAT INPUT
                  Text('Plat Nomor Kendaraan', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF3D4A5C))),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _platController,
                    textCapitalization: TextCapitalization.characters,
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF0D1B2A), letterSpacing: 2),
                    decoration: InputDecoration(
                      hintText: 'Contoh: BE 1234 XX',
                      hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14, letterSpacing: 0, fontWeight: FontWeight.w400),
                      prefixIcon: const Icon(Icons.credit_card_rounded, color: Color(0xFF9EABBE), size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE8EDF2))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 1.5)),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 12),

                  // Info selected slot
                  if (selectedIndex != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1A73E8).withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.local_parking_rounded, color: Color(0xFF1A73E8), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Slot ${selectedSide == 0 ? "Kiri" : "Kanan"}-${selectedIndex! + 1} dipilih',
                          style: GoogleFonts.inter(color: const Color(0xFF1A73E8), fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ]),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ===== BOTTOM BUTTON =====
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[100]!, width: 1.5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Checklist validasi
                if (selectedIndex == null || _platController.text.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        _buildCheck('Pilih slot parkir', selectedIndex != null),
                        const SizedBox(width: 20),
                        _buildCheck('Isi plat nomor', _platController.text.isNotEmpty),
                      ],
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: (selectedIndex != null && _platController.text.isNotEmpty)
                        ? () async {
                            final result = await Navigator.push(context,
                              MaterialPageRoute(builder: (_) => CameraPage(platNomor: _platController.text)));
                            if (result != null && mounted) {
                              Navigator.pop(context, {
                                'plat': _platController.text,
                                'imagePath': result.toString(),
                              });
                            }
                          }
                        : null,
                    icon: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                    label: Text('Lanjut & Ambil Foto', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A73E8),
                      disabledBackgroundColor: const Color(0xFFBDD3F8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(IconData icon, String label, Color color) {
    return Row(children: [
      Icon(icon, color: color, size: 14),
      const SizedBox(width: 5),
      Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _buildSideTab(String title, int index) {
    final bool active = selectedSide == index;
    return GestureDetector(
      onTap: () => setState(() { selectedSide = index; selectedIndex = null; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1A73E8) : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Center(
          child: Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: active ? Colors.white : Colors.grey[400])),
        ),
      ),
    );
  }

  Widget _buildLegend(Color bg, Color border, String label, {Color textColor = const Color(0xFF3D4A5C)}) {
    return Row(children: [
      Container(
        width: 14, height: 14,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4), border: Border.all(color: border, width: 1.5)),
      ),
      const SizedBox(width: 5),
      Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500])),
    ]);
  }

  Widget _buildSlot(int index, int status) {
    final bool isSelected = selectedIndex == index;
    final bool isEmpty = status == 0;
    final Color bg = _slotColor(status, isSelected);
    final bool isMotor = widget.jenisKendaraan != 'Mobil';

    return GestureDetector(
      onTap: isEmpty ? () => setState(() => selectedIndex = index) : null,
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF1A73E8) : (isEmpty ? const Color(0xFFBDD3F8) : const Color(0xFFE8EDF2)),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF1A73E8).withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))] : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Nomor slot
              Text(
                'P${index + 1}',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white70 : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 4),
              // Icon kendaraan
              Icon(
                isMotor ? Icons.two_wheeler_rounded : Icons.directions_car_rounded,
                size: 22,
                color: isSelected ? Colors.white : (isEmpty ? const Color(0xFF1A73E8) : Colors.grey[300]),
              ),
              const SizedBox(height: 4),
              // Status / Plat
              if (!isEmpty && platTerisi.containsKey(index))
                Text(
                  platTerisi[index]!,
                  style: GoogleFonts.inter(fontSize: 7, fontWeight: FontWeight.w700, color: Colors.grey[400]),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              else if (isSelected)
                const Icon(Icons.check_circle_rounded, size: 13, color: Colors.white)
              else if (isEmpty)
                Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(color: Color(0xFF1A73E8), shape: BoxShape.circle),
                )
              else
                const Icon(Icons.lock_rounded, size: 11, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheck(String label, bool done) {
    return Row(children: [
      Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
        size: 16, color: done ? Colors.green : Colors.grey[300]),
      const SizedBox(width: 5),
      Text(label, style: GoogleFonts.inter(fontSize: 12, color: done ? Colors.green : Colors.grey[400], fontWeight: FontWeight.w600)),
    ]);
  }
}
