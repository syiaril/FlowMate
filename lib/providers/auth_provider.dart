import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;

  User? _user;
  ProfileModel? _profile;
  bool _isLoading = true;

  User? get user => _user;
  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;

  bool get isAuthenticated => _user != null;
  bool get isAdmin => _profile?.role == 'admin';

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    // Listen to auth state changes
    _authService.authStateChanges.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.initialSession) {
        _user = session?.user;
        await _fetchProfile();
      } else if (event == AuthChangeEvent.signedOut) {
        _user = null;
        _profile = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _fetchProfile() async {
    if (_user == null) return;
    _profile = await _authService.getCurrentProfile();
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    await _fetchProfile();
  }

  Future<void> login(String email, String password) async {
    await _authService.login(email: email, password: password);
  }

  Future<void> register(String email, String password, String name, String role) async {
    // Don't touch _isLoading here — register_screen manages its own loading state
    await _authService.register(email: email, password: password, name: name, role: role);
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
