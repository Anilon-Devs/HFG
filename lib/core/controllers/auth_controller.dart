import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_models;

class AuthController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Reactive variables
  final Rx<app_models.User?> _currentUser = Rx<app_models.User?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  // Getters
  app_models.User? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value.isEmpty ? null : _error.value;
  bool get isAuthenticated => _currentUser.value != null;

  // Reactive getters
  Rx<app_models.User?> get currentUserRx => _currentUser;
  RxBool get isLoadingRx => _isLoading;
  RxString get errorRx => _error;

  @override
  void onInit() {
    super.onInit();
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
      _isLoading.value = false;
      _currentUser.value = null;
    }
  }

  void _handleAuthStateChange(AuthState data) {
    print('Auth state changed: ${data.event}, user: ${data.session?.user.email}');
    if (data.event == AuthChangeEvent.signedIn) {
      _loadUserProfile(data.session?.user.id);
    } else if (data.event == AuthChangeEvent.signedOut) {
      _currentUser.value = null;
    }
  }

  Future<void> _loadUserProfile(String? userId) async {
    if (userId == null) return;

    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      _currentUser.value = app_models.User.fromJson(response);
    } catch (e) {
      _error.value = 'Failed to load user profile: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserProfile(response.user!.id);
        return true;
      }
      return false;
    } on AuthException catch (e) {
      _error.value = e.message;
      return false;
    } catch (e) {
      _error.value = 'An unexpected error occurred: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String userType,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone_number': phoneNumber,
          'user_type': userType,
        },
      );

      if (response.user != null) {
        // Create user profile in the database
        await _createUserProfile(
          userId: response.user!.id,
          email: email,
          fullName: fullName,
          phoneNumber: phoneNumber,
          userType: userType,
        );
        
        // Only load user profile if the user is already confirmed
        // If email confirmation is required, the user won't be authenticated yet
        if (response.session != null) {
          await _loadUserProfile(response.user!.id);
        }
        
        return true;
      }
      return false;
    } on AuthException catch (e) {
      _error.value = e.message;
      return false;
    } catch (e) {
      _error.value = 'An unexpected error occurred: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    required String phoneNumber,
    required String userType,
  }) async {
    await _supabase.from('users').insert({
      'id': userId,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'user_type': userType,
      'is_verified': false,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<bool> signOut() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      await _supabase.auth.signOut();
      _currentUser.value = null;
      return true;
    } catch (e) {
      _error.value = 'Failed to sign out: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> resetPassword({required String email}) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } on AuthException catch (e) {
      _error.value = e.message;
      return false;
    } catch (e) {
      _error.value = 'An unexpected error occurred: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    if (_currentUser.value == null) return false;

    try {
      _isLoading.value = true;
      _error.value = '';

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updates['full_name'] = fullName;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (profileImageUrl != null) updates['profile_image_url'] = profileImageUrl;

      await _supabase
          .from('users')
          .update(updates)
          .eq('id', _currentUser.value!.id);

      // Reload user profile to reflect changes
      await _loadUserProfile(_currentUser.value!.id);
      return true;
    } catch (e) {
      _error.value = 'Failed to update profile: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateVerificationStatus({required bool isVerified}) async {
    if (_currentUser.value == null) return false;

    try {
      _isLoading.value = true;
      _error.value = '';

      await _supabase
          .from('users')
          .update({
            'is_verified': isVerified,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', _currentUser.value!.id);

      // Reload user profile to reflect changes
      await _loadUserProfile(_currentUser.value!.id);
      return true;
    } catch (e) {
      _error.value = 'Failed to update verification status: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  void clearError() {
    _error.value = '';
  }
}
