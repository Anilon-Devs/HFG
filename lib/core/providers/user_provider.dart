import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import '../models/user.dart' as app_models;

class UserProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  bool _isLoading = false;
  String? _error;
  List<app_models.User> _users = [];
  List<String> _uploadedDocuments = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<app_models.User> get users => _users;
  List<String> get uploadedDocuments => _uploadedDocuments;

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
      _isLoading = true;
      _error = null;
      notifyListeners();

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

      // Create verification data
      final verificationData = app_models.UserVerificationData(
        passportNumber: passportNumber,
        nidNumber: nidNumber,
        licenseNumber: licenseNumber,
        taxNumber: taxNumber,
        registrationNumber: registrationNumber,
        documentUrls: documentUrls,
        notes: notes,
        submittedAt: DateTime.now(),
      );

      // Update user with verification data
      await _supabase
          .from('users')
          .update({
            'verification_data': verificationData.toJson(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      _uploadedDocuments = documentUrls;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Document submission failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadProfileImage({
    required String userId,
    required PlatformFile imageFile,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final fileName = '${userId}_profile_${DateTime.now().millisecondsSinceEpoch}.${imageFile.extension}';
      final filePath = 'profile_images/$fileName';

      await _supabase.storage
          .from('avatars')
          .uploadBinary(filePath, imageFile.bytes!);

      final publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);

      // Update user profile with image URL
      await _supabase
          .from('users')
          .update({
            'profile_image_url': publicUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Profile image upload failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<List<app_models.User>> fetchUsers({
    app_models.UserType? userType,
    app_models.UserStatus? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      var query = _supabase
          .from('users')
          .select('*');

      if (userType != null) {
        query = query.eq('user_type', userType.name);
      }

      if (status != null) {
        query = query.eq('status', status.name);
      }

      final response = await query.range(offset, offset + limit - 1);
      _users = (response as List)
          .map((user) => app_models.User.fromJson(user))
          .toList();

      _isLoading = false;
      notifyListeners();
      return _users;
    } catch (e) {
      _error = 'Failed to fetch users: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  Future<app_models.User?> fetchUserById(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase
          .from('users')
          .select('*')
          .eq('id', userId)
          .single();

      final user = app_models.User.fromJson(response);
      _isLoading = false;
      notifyListeners();
      return user;
    } catch (e) {
      _error = 'Failed to fetch user: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateUserStatus({
    required String userId,
    required app_models.UserStatus status,
    String? rejectionReason,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updates = {
        'status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (rejectionReason != null) {
        updates['rejection_reason'] = rejectionReason;
      }

      await _supabase
          .from('users')
          .update(updates)
          .eq('id', userId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update user status: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<List<app_models.User>> searchUsers({
    required String query,
    app_models.UserType? userType,
    int limit = 20,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      var searchQuery = _supabase
          .from('users')
          .select('*')
          .or('first_name.ilike.%$query%,last_name.ilike.%$query%,organization_name.ilike.%$query%,email.ilike.%$query%');

      if (userType != null) {
        searchQuery = searchQuery.eq('user_type', userType.name);
      }

      final response = await searchQuery.limit(limit);
      final searchResults = (response as List)
          .map((user) => app_models.User.fromJson(user))
          .toList();

      _isLoading = false;
      notifyListeners();
      return searchResults;
    } catch (e) {
      _error = 'Search failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
