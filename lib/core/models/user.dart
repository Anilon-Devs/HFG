enum UserType { individual, organization }

enum UserStatus { 
  pending, 
  verified, 
  rejected, 
  suspended 
}

class User {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? organizationName;
  final UserType userType;
  final UserStatus status;
  final String? phoneNumber;
  final String? address;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserVerificationData? verificationData;

  User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.organizationName,
    required this.userType,
    required this.status,
    this.phoneNumber,
    this.address,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.verificationData,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      organizationName: json['organization_name'],
      userType: UserType.values.byName(json['user_type']),
      status: UserStatus.values.byName(json['status']),
      phoneNumber: json['phone_number'],
      address: json['address'],
      profileImageUrl: json['profile_image_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      verificationData: json['verification_data'] != null
          ? UserVerificationData.fromJson(json['verification_data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'organization_name': organizationName,
      'user_type': userType.name,
      'status': status.name,
      'phone_number': phoneNumber,
      'address': address,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'verification_data': verificationData?.toJson(),
    };
  }

  String get displayName {
    if (userType == UserType.organization) {
      return organizationName ?? 'Unknown Organization';
    }
    return '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }
}

class UserVerificationData {
  final String? passportNumber;
  final String? nidNumber;
  final String? licenseNumber;
  final String? taxNumber;
  final String? registrationNumber;
  final List<String> documentUrls;
  final String? notes;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? rejectionReason;

  UserVerificationData({
    this.passportNumber,
    this.nidNumber,
    this.licenseNumber,
    this.taxNumber,
    this.registrationNumber,
    this.documentUrls = const [],
    this.notes,
    this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
  });

  factory UserVerificationData.fromJson(Map<String, dynamic> json) {
    return UserVerificationData(
      passportNumber: json['passport_number'],
      nidNumber: json['nid_number'],
      licenseNumber: json['license_number'],
      taxNumber: json['tax_number'],
      registrationNumber: json['registration_number'],
      documentUrls: List<String>.from(json['document_urls'] ?? []),
      notes: json['notes'],
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'])
          : null,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'])
          : null,
      reviewedBy: json['reviewed_by'],
      rejectionReason: json['rejection_reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'passport_number': passportNumber,
      'nid_number': nidNumber,
      'license_number': licenseNumber,
      'tax_number': taxNumber,
      'registration_number': registrationNumber,
      'document_urls': documentUrls,
      'notes': notes,
      'submitted_at': submittedAt?.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'reviewed_by': reviewedBy,
      'rejection_reason': rejectionReason,
    };
  }
}
