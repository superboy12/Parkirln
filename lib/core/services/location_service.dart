import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/parking_area_model.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final locationStreamProvider = StreamProvider<Position>((ref) {
  final service = ref.watch(locationServiceProvider);
  return service.getPositionStream();
});

class LocationService {
  LocationService();

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<Position?> getCurrentPosition() async {
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) return null;
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2, // Update every 2 meters
      ),
    );
  }

  double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude, point1.longitude,
      point2.latitude, point2.longitude,
    );
  }

  bool isInsideGeofence(Position userPos, ParkingAreaModel area) {
    double distance = calculateDistance(
      LatLng(userPos.latitude, userPos.longitude),
      LatLng(area.latitude, area.longitude),
    );
    return distance <= area.radiusGeofenceM;
  }

  bool isNearSlot(Position userPos, LatLng slotPos) {
    double distance = calculateDistance(
      LatLng(userPos.latitude, userPos.longitude),
      slotPos,
    );
    return distance <= 5.0; // 5 meters threshold for check-in
  }
}
