import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_models;

class AuthProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  app_models.User? _currentUser;
  bool _isLoading = false;
  String? _error;

  app_models.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _supabase.auth.onAuthStateChange.listen((data) {
      _handleAuthStateChange(data);
    });

    // Check if user is already signed in
    final session = _supabase.auth.currentSession;
    if (session != null) {
      _loadUserProfile(session.user.id);
    } else {
      // No session, so we're not loading and not authenticated
      _isLoading = false;
      _currentUser = null;
      notifyListeners();
    }
  }

  void _handleAuthStateChange(AuthState data) {
    if (data.event == AuthChangeEvent.signedIn) {
      _loadUserProfile(data.session?.user.id);
    } else if (data.event == AuthChangeEvent.signedOut) {
      _currentUser = null;
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile(String? userId) async {
    if (userId == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase
          .from('users')
          .select('*')
          .eq('id', userId)
          .single();

      _currentUser = app_models.User.fromJson(response);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load user profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required app_models.UserType userType,
    String? organizationName,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user != null) {
        // Create user profile
        await _supabase.from('users').insert({
          'id': authResponse.user!.id,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'organization_name': organizationName,
          'user_type': userType.name,
          'status': app_models.UserStatus.pending.name,
          'phone_number': phoneNumber,
          'address': address,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Sign up failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return response.user != null;
    } catch (e) {
      _error = 'Sign in failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabase.auth.signOut();
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Sign out failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword({required String email}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabase.auth.resetPasswordForEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Password reset failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Password update failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? organizationName,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (firstName != null) updates['first_name'] = firstName;
      if (lastName != null) updates['last_name'] = lastName;
      if (organizationName != null) updates['organization_name'] = organizationName;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (address != null) updates['address'] = address;
      if (profileImageUrl != null) updates['profile_image_url'] = profileImageUrl;

      await _supabase
          .from('users')
          .update(updates)
          .eq('id', _currentUser!.id);

      // Reload user profile
      await _loadUserProfile(_currentUser!.id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Profile update failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
