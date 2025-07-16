import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import '../models/campaign.dart';

class CampaignProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  bool _isLoading = false;
  String? _error;
  List<Campaign> _campaigns = [];
  Campaign? _selectedCampaign;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Campaign> get campaigns => _campaigns;
  Campaign? get selectedCampaign => _selectedCampaign;

  Future<bool> createCampaign({
    required String title,
    required String description,
    required String shortDescription,
    required double goalAmount,
    required CampaignCategory category,
    required DateTime endDate,
    required String creatorId,
    String? location,
    PlatformFile? imageFile,
    List<PlatformFile>? additionalImages,
    bool isUrgent = false,
    List<String> tags = const [],
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      String? mainImageUrl;
      List<String> additionalImageUrls = [];

      // Upload main image
      if (imageFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
        final filePath = 'campaign_images/$fileName';
        
        await _supabase.storage
            .from('campaigns')
            .uploadBinary(filePath, imageFile.bytes!);

        mainImageUrl = _supabase.storage
            .from('campaigns')
            .getPublicUrl(filePath);
      }

      // Upload additional images
      if (additionalImages != null && additionalImages.isNotEmpty) {
        for (var image in additionalImages) {
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
          final filePath = 'campaign_images/$fileName';
          
          await _supabase.storage
              .from('campaigns')
              .uploadBinary(filePath, image.bytes!);

          final publicUrl = _supabase.storage
              .from('campaigns')
              .getPublicUrl(filePath);

          additionalImageUrls.add(publicUrl);
        }
      }

      // Create campaign
      final campaignData = {
        'creator_id': creatorId,
        'title': title,
        'description': description,
        'short_description': shortDescription,
        'goal_amount': goalAmount,
        'current_amount': 0.0,
        'status': CampaignStatus.pending.name,
        'category': category.name,
        'start_date': DateTime.now().toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'image_url': mainImageUrl,
        'additional_images': additionalImageUrls,
        'location': location,
        'total_donors': 0,
        'total_shares': 0,
        'total_likes': 0,
        'is_urgent': isUrgent,
        'tags': tags,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('campaigns').insert(campaignData);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Campaign creation failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<List<Campaign>> fetchCampaigns({
    CampaignStatus? status,
    CampaignCategory? category,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      var query = _supabase
          .from('campaigns')
          .select('*, creator:users(*)');

      if (status != null) {
        query = query.eq('status', status.name);
      }

      if (category != null) {
        query = query.eq('category', category.name);
      }

      if (search != null && search.isNotEmpty) {
        query = query.or('title.ilike.%$search%,description.ilike.%$search%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      _campaigns = (response as List)
          .map((campaign) => Campaign.fromJson(campaign))
          .toList();

      _isLoading = false;
      notifyListeners();
      return _campaigns;
    } catch (e) {
      _error = 'Failed to fetch campaigns: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  Future<Campaign?> fetchCampaignById(String campaignId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase
          .from('campaigns')
          .select('*, creator:users(*), updates:campaign_updates(*), comments:campaign_comments(*, user:users(*))')
          .eq('id', campaignId)
          .single();

      _selectedCampaign = Campaign.fromJson(response);
      _isLoading = false;
      notifyListeners();
      return _selectedCampaign;
    } catch (e) {
      _error = 'Failed to fetch campaign: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateCampaignStatus({
    required String campaignId,
    required CampaignStatus status,
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
          .from('campaigns')
          .update(updates)
          .eq('id', campaignId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update campaign status: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addCampaignUpdate({
    required String campaignId,
    required String title,
    required String content,
    PlatformFile? imageFile,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      String? imageUrl;

      // Upload image if provided
      if (imageFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
        final filePath = 'campaign_updates/$fileName';
        
        await _supabase.storage
            .from('campaigns')
            .uploadBinary(filePath, imageFile.bytes!);

        imageUrl = _supabase.storage
            .from('campaigns')
            .getPublicUrl(filePath);
      }

      // Create update
      await _supabase.from('campaign_updates').insert({
        'campaign_id': campaignId,
        'title': title,
        'content': content,
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add campaign update: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addComment({
    required String campaignId,
    required String userId,
    required String content,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabase.from('campaign_comments').insert({
        'campaign_id': campaignId,
        'user_id': userId,
        'content': content,
        'created_at': DateTime.now().toIso8601String(),
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add comment: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> likeCampaign({
    required String campaignId,
    required String userId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check if user already liked
      final existingLike = await _supabase
          .from('campaign_likes')
          .select('id')
          .eq('campaign_id', campaignId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingLike != null) {
        // Remove like
        await _supabase
            .from('campaign_likes')
            .delete()
            .eq('campaign_id', campaignId)
            .eq('user_id', userId);
      } else {
        // Add like
        await _supabase.from('campaign_likes').insert({
          'campaign_id': campaignId,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Update campaign likes count
      final likesCount = await _supabase
          .from('campaign_likes')
          .select('id')
          .eq('campaign_id', campaignId)
          .count();

      await _supabase
          .from('campaigns')
          .update({'total_likes': likesCount})
          .eq('id', campaignId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to like campaign: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> shareCampaign({
    required String campaignId,
  }) async {
    try {
      // Increment share count
      await _supabase.rpc('increment_campaign_shares', params: {
        'campaign_id': campaignId,
      });

      return true;
    } catch (e) {
      _error = 'Failed to share campaign: ${e.toString()}';
      return false;
    }
  }

  Future<List<Campaign>> searchCampaigns({
    required String query,
    CampaignCategory? category,
    int limit = 20,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      var searchQuery = _supabase
          .from('campaigns')
          .select('*, creator:users(*)')
          .or('title.ilike.%$query%,description.ilike.%$query%,short_description.ilike.%$query%');

      if (category != null) {
        searchQuery = searchQuery.eq('category', category.name);
      }

      final response = await searchQuery
          .eq('status', CampaignStatus.active.name)
          .order('created_at', ascending: false)
          .limit(limit);

      final searchResults = (response as List)
          .map((campaign) => Campaign.fromJson(campaign))
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

  Future<List<Campaign>> fetchUserCampaigns({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase
          .from('campaigns')
          .select('*, creator:users(*)')
          .eq('creator_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final userCampaigns = (response as List)
          .map((campaign) => Campaign.fromJson(campaign))
          .toList();

      _isLoading = false;
      notifyListeners();
      return userCampaigns;
    } catch (e) {
      _error = 'Failed to fetch user campaigns: ${e.toString()}';
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
