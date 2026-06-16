class ParkingAreaModel {
  final String id;
  final String namaArea;
  final double latitude;
  final double longitude;
  final int radiusGeofenceM;
  final int totalSlot;
  final int availableSlot;

  const ParkingAreaModel({
    required this.id,
    required this.namaArea,
    required this.latitude,
    required this.longitude,
    required this.radiusGeofenceM,
    required this.totalSlot,
    required this.availableSlot,
  });

  int get occupiedSlot => totalSlot - availableSlot;
  double get occupancyRate => totalSlot > 0 ? occupiedSlot / totalSlot : 0;

  factory ParkingAreaModel.fromMap(Map<String, dynamic> map, String id) => ParkingAreaModel(
    id: id,
    namaArea: map['nama_area'] ?? '',
    latitude: (map['latitude'] ?? 0).toDouble(),
    longitude: (map['longitude'] ?? 0).toDouble(),
    radiusGeofenceM: map['radius_geofence_m'] ?? 50,
    totalSlot: map['total_slot'] ?? 0,
    availableSlot: map['available_slot'] ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'nama_area': namaArea,
    'latitude': latitude,
    'longitude': longitude,
    'radius_geofence_m': radiusGeofenceM,
    'total_slot': totalSlot,
    'available_slot': availableSlot,
  };

  ParkingAreaModel copyWith({int? availableSlot}) => ParkingAreaModel(
    id: id, namaArea: namaArea, latitude: latitude, longitude: longitude,
    radiusGeofenceM: radiusGeofenceM, totalSlot: totalSlot,
    availableSlot: availableSlot ?? this.availableSlot,
  );
}
