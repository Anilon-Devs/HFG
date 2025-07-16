import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import '../models/user.dart' as app_models;

class UserController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Reactive variables
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxList<app_models.User> _users = <app_models.User>[].obs;
  final RxList<String> _uploadedDocuments = <String>[].obs;

  // Getters
  bool get isLoading => _isLoading.value;
  String? get error => _error.value.isEmpty ? null : _error.value;
  List<app_models.User> get users => _users;
  List<String> get uploadedDocuments => _uploadedDocuments;

  // Reactive getters
  RxBool get isLoadingRx => _isLoading;
  RxString get errorRx => _error;
  RxList<app_models.User> get usersRx => _users;
  RxList<String> get uploadedDocumentsRx => _uploadedDocuments;

  Future<bool> submitVerificationDocuments({
    required String userId,
    String? passportNumber,
    String? nidNumber,
    String? licenseNumber,
    String? taxNumber,
    String? registrationNumber,
    List<PlatformFile>? documents,
    String? notes,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      List<String> documentUrls = [];

      // Upload documents if provided
      if (documents != null && documents.isNotEmpty) {
        for (var document in documents) {
          final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}_${document.name}';
          final filePath = 'verification_documents/$fileName';
          
          await _supabase.storage
              .from('documents')
              .uploadBinary(filePath, document.bytes!);

          final publicUrl = _supabase.storage
              .from('documents')
              .getPublicUrl(filePath);

          documentUrls.add(publicUrl);
        }
      }

      // Save verification data to database
      await _supabase.from('verification_submissions').insert({
        'user_id': userId,
        'passport_number': passportNumber,
        'nid_number': nidNumber,
        'license_number': licenseNumber,
        'tax_number': taxNumber,
        'registration_number': registrationNumber,
        'document_urls': documentUrls,
        'notes': notes,
        'status': 'pending',
        'submitted_at': DateTime.now().toIso8601String(),
      });

      _uploadedDocuments.addAll(documentUrls);
      return true;
    } catch (e) {
      _error.value = 'Failed to submit verification documents: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> uploadProfileImage({
    required String userId,
    required PlatformFile imageFile,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final fileName = '${userId}_profile_${DateTime.now().millisecondsSinceEpoch}.${imageFile.extension}';
      final filePath = 'profile_images/$fileName';
      
      await _supabase.storage
          .from('avatars')
          .uploadBinary(filePath, imageFile.bytes!);

      final publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);

      // Update user profile with new image URL
      await _supabase
          .from('users')
          .update({
            'profile_image_url': publicUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      return true;
    } catch (e) {
      _error.value = 'Failed to upload profile image: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<List<app_models.User>> getAllUsers() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _supabase
          .from('users')
          .select()
          .order('created_at', ascending: false);

      _users.value = response
          .map<app_models.User>((json) => app_models.User.fromJson(json))
          .toList();

      return _users;
    } catch (e) {
      _error.value = 'Failed to fetch users: ${e.toString()}';
      return [];
    } finally {
      _isLoading.value = false;
    }
  }

  Future<List<app_models.User>> getUsersByType(String userType) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _supabase
          .from('users')
          .select()
          .eq('user_type', userType)
          .order('created_at', ascending: false);

      final filteredUsers = response
          .map<app_models.User>((json) => app_models.User.fromJson(json))
          .toList();

      return filteredUsers;
    } catch (e) {
      _error.value = 'Failed to fetch users by type: ${e.toString()}';
      return [];
    } finally {
      _isLoading.value = false;
    }
  }

  Future<List<app_models.User>> getPendingVerifications() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _supabase
          .from('users')
          .select()
          .eq('is_verified', false)
          .order('created_at', ascending: false);

      final pendingUsers = response
          .map<app_models.User>((json) => app_models.User.fromJson(json))
          .toList();

      return pendingUsers;
    } catch (e) {
      _error.value = 'Failed to fetch pending verifications: ${e.toString()}';
      return [];
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateUserVerificationStatus({
    required String userId,
    required bool isVerified,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      await _supabase
          .from('users')
          .update({
            'is_verified': isVerified,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      // Update local user list
      final userIndex = _users.indexWhere((user) => user.id == userId);
      if (userIndex != -1) {
        // Reload the updated user from database
        final updatedUser = await getUserById(userId);
        if (updatedUser != null) {
          _users[userIndex] = updatedUser;
        }
      }

      return true;
    } catch (e) {
      _error.value = 'Failed to update verification status: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      await _supabase
          .from('users')
          .delete()
          .eq('id', userId);

      // Remove user from local list
      _users.removeWhere((user) => user.id == userId);

      return true;
    } catch (e) {
      _error.value = 'Failed to delete user: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<app_models.User?> getUserById(String userId) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return app_models.User.fromJson(response);
    } catch (e) {
      _error.value = 'Failed to fetch user: ${e.toString()}';
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> getVerificationDocuments(String userId) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _supabase
          .from('verification_submissions')
          .select()
          .eq('user_id', userId)
          .order('submitted_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _error.value = 'Failed to fetch verification documents: ${e.toString()}';
      return [];
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateUserProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
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
          .eq('id', userId);

      // Update local user list
      final userIndex = _users.indexWhere((user) => user.id == userId);
      if (userIndex != -1) {
        // Reload the updated user from database
        final updatedUser = await getUserById(userId);
        if (updatedUser != null) {
          _users[userIndex] = updatedUser;
        }
      }

      return true;
    } catch (e) {
      _error.value = 'Failed to update user profile: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  void clearError() {
    _error.value = '';
  }
}
