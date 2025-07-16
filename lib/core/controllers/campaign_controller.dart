import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import '../models/campaign.dart';
import '../models/donation.dart';

class CampaignController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Reactive variables
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxList<Campaign> _campaigns = <Campaign>[].obs;
  final RxList<Donation> _donations = <Donation>[].obs;
  final RxList<Campaign> _userCampaigns = <Campaign>[].obs;

  // Getters
  bool get isLoading => _isLoading.value;
  String? get error => _error.value.isEmpty ? null : _error.value;
  List<Campaign> get campaigns => _campaigns;
  List<Donation> get donations => _donations;
  List<Campaign> get userCampaigns => _userCampaigns;

  // Reactive getters
  RxBool get isLoadingRx => _isLoading;
  RxString get errorRx => _error;
  RxList<Campaign> get campaignsRx => _campaigns;
  RxList<Donation> get donationsRx => _donations;
  RxList<Campaign> get userCampaignsRx => _userCampaigns;

  @override
  void onInit() {
    super.onInit();
    loadCampaigns();
  }

  Future<void> loadCampaigns() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _supabase
          .from('campaigns')
          .select('''
            *,
            user:creator_id (
              id,
              email,
              first_name,
              last_name,
              organization_name,
              user_type,
              profile_image_url
            )
          ''')
          .eq('status', 'active')
          .order('created_at', ascending: false);

      _campaigns.value = response
          .map<Campaign>((json) => Campaign.fromJson(json))
          .toList();
    } catch (e) {
      _error.value = 'Failed to load campaigns: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadUserCampaigns(String userId) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _supabase
          .from('campaigns')
          .select('''
            *,
            user:creator_id (
              id,
              email,
              first_name,
              last_name,
              organization_name,
              user_type,
              profile_image_url
            )
          ''')
          .eq('creator_id', userId)
          .order('created_at', ascending: false);

      _userCampaigns.value = response
          .map<Campaign>((json) => Campaign.fromJson(json))
          .toList();
    } catch (e) {
      _error.value = 'Failed to load user campaigns: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> createCampaign({
    required String creatorId,
    required String title,
    required String description,
    required double goalAmount,
    required String category,
    required DateTime endDate,
    List<PlatformFile>? images,
    List<PlatformFile>? documents,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      List<String> imageUrls = [];
      List<String> documentUrls = [];

      // Upload images
      if (images != null && images.isNotEmpty) {
        for (var image in images) {
          final fileName = '${creatorId}_${DateTime.now().millisecondsSinceEpoch}_${image.name}';
          final filePath = 'campaign_images/$fileName';
          
          await _supabase.storage
              .from('campaigns')
              .uploadBinary(filePath, image.bytes!);

          final publicUrl = _supabase.storage
              .from('campaigns')
              .getPublicUrl(filePath);

          imageUrls.add(publicUrl);
        }
      }

      // Upload documents
      if (documents != null && documents.isNotEmpty) {
        for (var document in documents) {
          final fileName = '${creatorId}_${DateTime.now().millisecondsSinceEpoch}_${document.name}';
          final filePath = 'campaign_documents/$fileName';
          
          await _supabase.storage
              .from('campaigns')
              .uploadBinary(filePath, document.bytes!);

          final publicUrl = _supabase.storage
              .from('campaigns')
              .getPublicUrl(filePath);

          documentUrls.add(publicUrl);
        }
      }

      // Create campaign record
      final campaignData = {
        'creator_id': creatorId,
        'title': title,
        'description': description,
        'goal_amount': goalAmount,
        'current_amount': 0.0,
        'category': category,
        'status': 'active',
        'end_date': endDate.toIso8601String(),
        'image_urls': imageUrls,
        'document_urls': documentUrls,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('campaigns')
          .insert(campaignData)
          .select()
          .single();

      final newCampaign = Campaign.fromJson(response);
      _campaigns.insert(0, newCampaign);
      _userCampaigns.insert(0, newCampaign);

      return true;
    } catch (e) {
      _error.value = 'Failed to create campaign: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateCampaign({
    required String campaignId,
    String? title,
    String? description,
    double? goalAmount,
    String? category,
    DateTime? endDate,
    List<PlatformFile>? newImages,
    List<String>? removeImageUrls,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (goalAmount != null) updates['goal_amount'] = goalAmount;
      if (category != null) updates['category'] = category;
      if (endDate != null) updates['end_date'] = endDate.toIso8601String();

      // Handle image updates
      if (newImages != null && newImages.isNotEmpty) {
        List<String> newImageUrls = [];
        
        for (var image in newImages) {
          final fileName = 'campaign_${campaignId}_${DateTime.now().millisecondsSinceEpoch}_${image.name}';
          final filePath = 'campaign_images/$fileName';
          
          await _supabase.storage
              .from('campaigns')
              .uploadBinary(filePath, image.bytes!);

          final publicUrl = _supabase.storage
              .from('campaigns')
              .getPublicUrl(filePath);

          newImageUrls.add(publicUrl);
        }

        // Get current image URLs
        final currentCampaign = await _supabase
            .from('campaigns')
            .select('image_urls')
            .eq('id', campaignId)
            .single();

        List<String> currentImageUrls = List<String>.from(currentCampaign['image_urls'] ?? []);
        
        // Remove specified images
        if (removeImageUrls != null) {
          currentImageUrls.removeWhere((url) => removeImageUrls.contains(url));
        }
        
        // Add new images
        currentImageUrls.addAll(newImageUrls);
        updates['image_urls'] = currentImageUrls;
      }

      await _supabase
          .from('campaigns')
          .update(updates)
          .eq('id', campaignId);

      // Update local campaigns list
      await loadCampaigns();
      
      return true;
    } catch (e) {
      _error.value = 'Failed to update campaign: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> deleteCampaign(String campaignId) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      await _supabase
          .from('campaigns')
          .delete()
          .eq('id', campaignId);

      _campaigns.removeWhere((campaign) => campaign.id == campaignId);
      _userCampaigns.removeWhere((campaign) => campaign.id == campaignId);

      return true;
    } catch (e) {
      _error.value = 'Failed to delete campaign: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateCampaignStatus({
    required String campaignId,
    required String status,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      await _supabase
          .from('campaigns')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', campaignId);

      // Update local campaigns list
      final campaignIndex = _campaigns.indexWhere((campaign) => campaign.id == campaignId);
      if (campaignIndex != -1) {
        // Reload the updated campaign
        await loadCampaigns();
      }

      return true;
    } catch (e) {
      _error.value = 'Failed to update campaign status: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<Campaign?> getCampaignById(String campaignId) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _supabase
          .from('campaigns')
          .select('''
            *,
            user:creator_id (
              id,
              email,
              first_name,
              last_name,
              organization_name,
              user_type,
              profile_image_url
            )
          ''')
          .eq('id', campaignId)
          .single();

      return Campaign.fromJson(response);
    } catch (e) {
      _error.value = 'Failed to fetch campaign: ${e.toString()}';
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<List<Campaign>> getCampaignsByCategory(String category) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _supabase
          .from('campaigns')
          .select('''
            *,
            user:creator_id (
              id,
              email,
              first_name,
              last_name,
              organization_name,
              user_type,
              profile_image_url
            )
          ''')
          .eq('category', category)
          .eq('status', 'active')
          .order('created_at', ascending: false);

      return response
          .map<Campaign>((json) => Campaign.fromJson(json))
          .toList();
    } catch (e) {
      _error.value = 'Failed to fetch campaigns by category: ${e.toString()}';
      return [];
    } finally {
      _isLoading.value = false;
    }
  }

  Future<List<Campaign>> searchCampaigns(String query) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _supabase
          .from('campaigns')
          .select('''
            *,
            user:creator_id (
              id,
              email,
              first_name,
              last_name,
              organization_name,
              user_type,
              profile_image_url
            )
          ''')
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .eq('status', 'active')
          .order('created_at', ascending: false);

      return response
          .map<Campaign>((json) => Campaign.fromJson(json))
          .toList();
    } catch (e) {
      _error.value = 'Failed to search campaigns: ${e.toString()}';
      return [];
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> makeDonation({
    required String campaignId,
    required String donorId,
    required double amount,
    String? message,
    bool isAnonymous = false,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      // Create donation record
      final donationData = {
        'campaign_id': campaignId,
        'donor_id': donorId,
        'amount': amount,
        'message': message,
        'is_anonymous': isAnonymous,
        'status': 'completed',
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('donations')
          .insert(donationData);

      // Update campaign's current amount
      await _supabase.rpc('update_campaign_amount', params: {
        'campaign_id': campaignId,
        'donation_amount': amount,
      });

      // Refresh campaigns to reflect updated amount
      await loadCampaigns();

      return true;
    } catch (e) {
      _error.value = 'Failed to make donation: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<List<Donation>> getCampaignDonations(String campaignId) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _supabase
          .from('donations')
          .select('''
            *,
            donor:donor_id (
              id,
              email,
              first_name,
              last_name,
              organization_name,
              user_type,
              profile_image_url
            )
          ''')
          .eq('campaign_id', campaignId)
          .order('created_at', ascending: false);

      return response
          .map<Donation>((json) => Donation.fromJson(json))
          .toList();
    } catch (e) {
      _error.value = 'Failed to fetch campaign donations: ${e.toString()}';
      return [];
    } finally {
      _isLoading.value = false;
    }
  }

  Future<List<Donation>> getUserDonations(String userId) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _supabase
          .from('donations')
          .select('''
            *,
            campaign:campaign_id (
              id,
              title,
              description,
              goal_amount,
              current_amount,
              status,
              image_urls
            )
          ''')
          .eq('donor_id', userId)
          .order('created_at', ascending: false);

      _donations.value = response
          .map<Donation>((json) => Donation.fromJson(json))
          .toList();

      return _donations;
    } catch (e) {
      _error.value = 'Failed to fetch user donations: ${e.toString()}';
      return [];
    } finally {
      _isLoading.value = false;
    }
  }

  void clearError() {
    _error.value = '';
  }
}
