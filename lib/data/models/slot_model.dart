class SlotModel {
  final String slotId;
  final String parkingId;
  final String nomorSlot;
  final String jenisKendaraan;
  final String status; // 'Tersedia', 'Terisi'
  final double latitude;
  final double longitude;

  const SlotModel({
    required this.slotId,
    required this.parkingId,
    required this.nomorSlot,
    required this.jenisKendaraan,
    required this.status,
    required this.latitude,
    required this.longitude,
  });

  bool get isAvailable => status == 'Tersedia';

  factory SlotModel.fromMap(Map<String, dynamic> map) => SlotModel(
    slotId: map['slot_id'] ?? '',
    parkingId: map['parking_id'] ?? '',
    nomorSlot: map['nomor_slot'] ?? '',
    jenisKendaraan: map['jenis_kendaraan'] ?? 'Mobil',
    status: map['status'] ?? 'Tersedia',
    latitude: (map['latitude'] ?? 0).toDouble(),
    longitude: (map['longitude'] ?? 0).toDouble(),
  );
}
