import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/parking_area_model.dart';
import '../models/parking_session_model.dart';
import '../models/slot_model.dart';
import '../models/user_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // --------------------------------------------------------------------------
  // AUTHENTICATION
  // --------------------------------------------------------------------------
  
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  User? get currentUser => _client.auth.currentUser;

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String namaLengkap,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'nama_lengkap': namaLengkap}, // This will trigger handle_new_user SQL
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', uid)
          .maybeSingle();
      if (response == null) return null;
      
      // Parse to UserModel
      return UserModel(
        uid: response['id'],
        email: response['email'],
        nama: response['nama_lengkap'],
        noPlat: response['no_plat'] ?? '-',
        npm: '-', // Supabase doesn't have NPM yet
        jenisKendaraan: 'Motor', // Supabase default
      );
    } catch (e) {
      print('Error getUserProfile: $e');
      return null;
    }
  }

  // --------------------------------------------------------------------------
  // DATABASE - PARKING
  // --------------------------------------------------------------------------

  Future<List<ParkingAreaModel>> getParkingAreas() async {
    try {
      final response = await _client.from('parking_areas').select();
      return List<ParkingAreaModel>.from(response.map((e) => ParkingAreaModel(
        id: e['id'],
        namaArea: e['nama_area'],
        totalSlot: e['total_slot'],
        availableSlot: e['available_slot'],
        latitude: (e['latitude'] as num).toDouble(),
        longitude: (e['longitude'] as num).toDouble(),
        radiusGeofenceM: e['radius_geofence_m'],
      )));
    } catch (e) {
      print('Error getParkingAreas: $e');
      return [];
    }
  }

  Future<List<SlotModel>> getSlotsByArea(String parkingId) async {
    try {
      final response = await _client
          .from('slots')
          .select()
          .eq('parking_id', parkingId)
          .order('nomor_slot', ascending: true);
          
      return List<SlotModel>.from(response.map((e) => SlotModel(
        slotId: e['slot_id'],
        parkingId: e['parking_id'],
        nomorSlot: e['nomor_slot'],
        jenisKendaraan: e['jenis_kendaraan'],
        status: e['status'],
        latitude: (e['latitude'] as num).toDouble(),
        longitude: (e['longitude'] as num).toDouble(),
      )));
    } catch (e) {
      print('Error getSlotsByArea: $e');
      return [];
    }
  }

  // --------------------------------------------------------------------------
  // DATABASE - PARKING SESSIONS
  // --------------------------------------------------------------------------

  Future<ParkingSessionModel> createParkingSession({
    required String uid,
    required String parkingId,
    required String slotId,
    required String platNomor,
    required double checkInLat,
    required double checkInLng,
    required String fotoMasukUrl,
  }) async {
    final String sessionId = 'SES-${DateTime.now().millisecondsSinceEpoch}';

    // Transaction-like: insert session and update slot status
    await _client.from('parking_sessions').insert({
      'id': sessionId,
      'uid': uid,
      'parking_id': parkingId,
      'slot_id': slotId,
      'plat_nomor': platNomor,
      'check_in_lat': checkInLat,
      'check_in_lng': checkInLng,
      'foto_masuk_url': fotoMasukUrl,
      'status': 'Aktif',
    });

    await _client.from('slots').update({
      'status': 'Terisi'
    }).eq('slot_id', slotId);

    final areaData = await _client.from('parking_areas').select('available_slot').eq('id', parkingId).single();
    int currentAvail = areaData['available_slot'] as int;
    if (currentAvail > 0) {
      await _client.from('parking_areas').update({'available_slot': currentAvail - 1}).eq('id', parkingId);
    }

    return ParkingSessionModel(
      id: sessionId,
      uid: uid,
      parkingId: parkingId,
      slotId: slotId,
      platNomor: platNomor,
      checkInTime: DateTime.now(),
      checkInLat: checkInLat,
      checkInLng: checkInLng,
      fotoMasukUrl: fotoMasukUrl,
      status: 'Aktif',
    );
  }

  Future<List<ParkingSessionModel>> getUserSessions(String uid) async {
    try {
      final response = await _client
          .from('parking_sessions')
          .select()
          .eq('uid', uid)
          .order('created_at', ascending: false);
          
      return List<ParkingSessionModel>.from(response.map((e) => ParkingSessionModel(
        id: e['id'],
        uid: e['uid'],
        parkingId: e['parking_id'],
        slotId: e['slot_id'],
        platNomor: e['plat_nomor'],
        checkInTime: DateTime.parse(e['check_in_time']),
        checkOutTime: e['check_out_time'] != null ? DateTime.parse(e['check_out_time']) : null,
        checkInLat: (e['check_in_lat'] as num).toDouble(),
        checkInLng: (e['check_in_lng'] as num).toDouble(),
        fotoMasukUrl: e['foto_masuk_url'],
        fotoKeluarUrl: e['foto_keluar_url'],
        status: e['status'],
      )));
    } catch (e) {
      print('Error getUserSessions: $e');
      return [];
    }
  }

  Future<void> checkOutSession({
    required String sessionId, 
    required String slotId, 
    required String parkingId,
    required String fotoKeluarUrl,
  }) async {
    await _client.from('parking_sessions').update({
      'status': 'Selesai',
      'check_out_time': DateTime.now().toIso8601String(),
      'foto_keluar_url': fotoKeluarUrl,
    }).eq('id', sessionId);
    
    await _client.from('slots').update({'status': 'Tersedia'}).eq('slot_id', slotId);
    
    final areaData = await _client.from('parking_areas').select('available_slot').eq('id', parkingId).single();
    int currentAvail = areaData['available_slot'] as int;
    await _client.from('parking_areas').update({'available_slot': currentAvail + 1}).eq('id', parkingId);
  }

  Future<void> sendSosLog({
    required String uid,
    required String sessionId,
    required double lat,
    required double lng,
  }) async {
    await _client.from('sos_logs').insert({
      'uid': uid,
      'session_id': sessionId,
      'lat': lat,
      'lng': lng,
    });
  }
}
