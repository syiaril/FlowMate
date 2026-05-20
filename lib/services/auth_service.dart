import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

class AuthService {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Returns the current authenticated user (if any)
  User? get currentUser => _supabase.auth.currentUser;

  /// Stream of authentication state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Register a new user with email, password, name, and role
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': role,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Login with email and password
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out the current user
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch the profile of the current user
  Future<ProfileModel?> getCurrentProfile() async {
    if (currentUser == null) return null;
    
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();
      return ProfileModel.fromJson(data);
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }
}
