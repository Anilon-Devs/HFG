import 'user.dart';

enum CampaignStatus {
  draft,
  pending,
  active,
  paused,
  completed,
  cancelled,
  rejected
}

enum CampaignCategory {
  medical,
  education,
  emergency,
  community,
  environment,
  sports,
  technology,
  arts,
  other
}

class Campaign {
  final String id;
  final String creatorId;
  final String title;
  final String description;
  final String shortDescription;
  final double goalAmount;
  final double currentAmount;
  final CampaignStatus status;
  final CampaignCategory category;
  final DateTime startDate;
  final DateTime endDate;
  final String? imageUrl;
  final List<String> additionalImages;
  final String? location;
  final int totalDonors;
  final int totalShares;
  final int totalLikes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? creator;
  final List<CampaignUpdate> updates;
  final List<Comment> comments;
  final String? rejectionReason;
  final bool isUrgent;
  final List<String> tags;

  Campaign({
    required this.id,
    required this.creatorId,
    required this.title,
    required this.description,
    required this.shortDescription,
    required this.goalAmount,
    required this.currentAmount,
    required this.status,
    required this.category,
    required this.startDate,
    required this.endDate,
    this.imageUrl,
    this.additionalImages = const [],
    this.location,
    required this.totalDonors,
    required this.totalShares,
    required this.totalLikes,
    required this.createdAt,
    required this.updatedAt,
    this.creator,
    this.updates = const [],
    this.comments = const [],
    this.rejectionReason,
    required this.isUrgent,
    this.tags = const [],
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'],
      creatorId: json['creator_id'],
      title: json['title'],
      description: json['description'],
      shortDescription: json['short_description'],
      goalAmount: json['goal_amount'].toDouble(),
      currentAmount: json['current_amount'].toDouble(),
      status: CampaignStatus.values.byName(json['status']),
      category: CampaignCategory.values.byName(json['category']),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      imageUrl: json['image_url'],
      additionalImages: List<String>.from(json['additional_images'] ?? []),
      location: json['location'],
      totalDonors: json['total_donors'] ?? 0,
      totalShares: json['total_shares'] ?? 0,
      totalLikes: json['total_likes'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      creator: json['creator'] != null ? User.fromJson(json['creator']) : null,
      updates: (json['updates'] as List<dynamic>?)
          ?.map((e) => CampaignUpdate.fromJson(e))
          .toList() ?? [],
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e))
          .toList() ?? [],
      rejectionReason: json['rejection_reason'],
      isUrgent: json['is_urgent'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': creatorId,
      'title': title,
      'description': description,
      'short_description': shortDescription,
      'goal_amount': goalAmount,
      'current_amount': currentAmount,
      'status': status.name,
      'category': category.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'image_url': imageUrl,
      'additional_images': additionalImages,
      'location': location,
      'total_donors': totalDonors,
      'total_shares': totalShares,
      'total_likes': totalLikes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'creator': creator?.toJson(),
      'updates': updates.map((e) => e.toJson()).toList(),
      'comments': comments.map((e) => e.toJson()).toList(),
      'rejection_reason': rejectionReason,
      'is_urgent': isUrgent,
      'tags': tags,
    };
  }

  double get progressPercentage {
    if (goalAmount == 0) return 0;
    return (currentAmount / goalAmount * 100).clamp(0, 100);
  }

  int get daysLeft {
    final now = DateTime.now();
    if (endDate.isBefore(now)) return 0;
    return endDate.difference(now).inDays;
  }

  bool get isActive => status == CampaignStatus.active;
  bool get isCompleted => status == CampaignStatus.completed;
  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get canDonate => isActive && !isExpired;
}

class CampaignUpdate {
  final String id;
  final String campaignId;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;

  CampaignUpdate({
    required this.id,
    required this.campaignId,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.createdAt,
  });

  factory CampaignUpdate.fromJson(Map<String, dynamic> json) {
    return CampaignUpdate(
      id: json['id'],
      campaignId: json['campaign_id'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaign_id': campaignId,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Comment {
  final String id;
  final String campaignId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final User? user;

  Comment({
    required this.id,
    required this.campaignId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      campaignId: json['campaign_id'],
      userId: json['user_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaign_id': campaignId,
      'user_id': userId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'user': user?.toJson(),
    };
  }
}
