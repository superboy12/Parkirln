class ParkingSessionModel {
  final String id;
  final String uid;
  final String parkingId;
  final String slotId;
  final String platNomor;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final double checkInLat;
  final double checkInLng;
  final String fotoMasukUrl;
  final String? fotoKeluarUrl;
  final String status; // 'Aktif', 'Selesai'

  const ParkingSessionModel({
    required this.id,
    required this.uid,
    required this.parkingId,
    required this.slotId,
    required this.platNomor,
    required this.checkInTime,
    this.checkOutTime,
    required this.checkInLat,
    required this.checkInLng,
    required this.fotoMasukUrl,
    this.fotoKeluarUrl,
    required this.status,
  });

  bool get isActive => status == 'Aktif';

  Duration get duration => (checkOutTime ?? DateTime.now()).difference(checkInTime);

  factory ParkingSessionModel.fromMap(Map<String, dynamic> map) => ParkingSessionModel(
    id: map['id'] ?? '',
    uid: map['uid'] ?? '',
    parkingId: map['parking_id'] ?? '',
    slotId: map['slot_id'] ?? '',
    platNomor: map['plat_nomor'] ?? '',
    checkInTime: DateTime.tryParse(map['check_in_time'] ?? '') ?? DateTime.now(),
    checkOutTime: map['check_out_time'] != null ? DateTime.tryParse(map['check_out_time']) : null,
    checkInLat: (map['check_in_lat'] ?? 0).toDouble(),
    checkInLng: (map['check_in_lng'] ?? 0).toDouble(),
    fotoMasukUrl: map['foto_masuk_url'] ?? '',
    fotoKeluarUrl: map['foto_keluar_url'],
    status: map['status'] ?? 'Aktif',
  );
}
