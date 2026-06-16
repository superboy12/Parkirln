import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../data/models/parking_area_model.dart';
import '../data/models/slot_model.dart';
import '../data/models/parking_session_model.dart';
import '../data/services/supabase_service.dart';

// Single instance of SupabaseService
final supabaseServiceProvider = Provider((ref) => SupabaseService());

// ===== AUTH PROVIDER =====
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>(
  (ref) => AuthNotifier(ref.read(supabaseServiceProvider)),
);

// ===== VEHICLE TYPE PROVIDER =====
final vehicleTypeProvider = StateProvider<String>((ref) => 'Motor');

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final SupabaseService _supabaseService;

  AuthNotifier(this._supabaseService) : super(const AsyncValue.loading()) {
    _initAuthListener();
  }

  void _initAuthListener() {
    _supabaseService.authStateChanges.listen((event) async {
      final user = event.session?.user;
      if (user == null) {
        state = const AsyncValue.data(null);
      } else {
        // Fetch user profile from public.users
        final profile = await _supabaseService.getUserProfile(user.id);
        state = AsyncValue.data(profile);
      }
    });
  }

  Future<String?> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _supabaseService.signIn(email: email, password: password);
      return null;
    } catch (e) {
      state = const AsyncValue.data(null);
      return e.toString();
    }
  }

  Future<String?> register({required String nama, required String npm, required String email, required String password, required String noPlat, required String jenisKendaraan}) async {
    state = const AsyncValue.loading();
    try {
      await _supabaseService.signUp(email: email, password: password, namaLengkap: nama);
      return null;
    } catch (e) {
      state = const AsyncValue.data(null);
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _supabaseService.signOut();
  }
}

// ===== PARKING PROVIDER =====
final parkingAreasProvider = FutureProvider<List<ParkingAreaModel>>((ref) async {
  return ref.watch(supabaseServiceProvider).getParkingAreas();
});

final slotsProvider = FutureProvider.family<List<SlotModel>, String>((ref, parkingId) async {
  return ref.watch(supabaseServiceProvider).getSlotsByArea(parkingId);
});

// Since MockDataService handled stats, we can generate it locally for now based on area data
final statsProvider = FutureProvider<Map<String, int>>((ref) async {
  final areas = await ref.watch(parkingAreasProvider.future);
  int total = areas.fold(0, (sum, item) => sum + item.totalSlot);
  int available = areas.fold(0, (sum, item) => sum + item.availableSlot);
  return {
    'total': total,
    'occupied': total - available,
    'available': available,
    'active': 0, // dynamic
  };
});

// ===== PARKING SESSIONS PROVIDER =====
final sessionsProvider = FutureProvider.family<List<ParkingSessionModel>, String>((ref, uid) async {
  return ref.watch(supabaseServiceProvider).getUserSessions(uid);
});

// ===== THEME PROVIDER =====
final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false);
  void toggle() => state = !state;
}
