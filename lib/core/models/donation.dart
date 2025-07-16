import 'user.dart';
import 'campaign.dart';

enum DonationStatus {
  pending,
  completed,
  failed,
  refunded,
  cancelled
}

enum PaymentMethod {
  creditCard,
  debitCard,
  paypal,
  stripe,
  bankTransfer
}

class Donation {
  final String id;
  final String campaignId;
  final String donorId;
  final double amount;
  final double platformFee;
  final double netAmount;
  final DonationStatus status;
  final PaymentMethod paymentMethod;
  final String? paymentIntentId;
  final String? transactionId;
  final String? message;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Campaign? campaign;
  final User? donor;

  Donation({
    required this.id,
    required this.campaignId,
    required this.donorId,
    required this.amount,
    required this.platformFee,
    required this.netAmount,
    required this.status,
    required this.paymentMethod,
    this.paymentIntentId,
    this.transactionId,
    this.message,
    required this.isAnonymous,
    required this.createdAt,
    this.completedAt,
    this.campaign,
    this.donor,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'],
      campaignId: json['campaign_id'],
      donorId: json['donor_id'],
      amount: json['amount'].toDouble(),
      platformFee: json['platform_fee'].toDouble(),
      netAmount: json['net_amount'].toDouble(),
      status: DonationStatus.values.byName(json['status']),
      paymentMethod: PaymentMethod.values.byName(json['payment_method']),
      paymentIntentId: json['payment_intent_id'],
      transactionId: json['transaction_id'],
      message: json['message'],
      isAnonymous: json['is_anonymous'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      campaign: json['campaign'] != null
          ? Campaign.fromJson(json['campaign'])
          : null,
      donor: json['donor'] != null ? User.fromJson(json['donor']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaign_id': campaignId,
      'donor_id': donorId,
      'amount': amount,
      'platform_fee': platformFee,
      'net_amount': netAmount,
      'status': status.name,
      'payment_method': paymentMethod.name,
      'payment_intent_id': paymentIntentId,
      'transaction_id': transactionId,
      'message': message,
      'is_anonymous': isAnonymous,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'campaign': campaign?.toJson(),
      'donor': donor?.toJson(),
    };
  }

  bool get isCompleted => status == DonationStatus.completed;
  bool get isPending => status == DonationStatus.pending;
  bool get isFailed => status == DonationStatus.failed;
  bool get isRefunded => status == DonationStatus.refunded;
}

class DonationSummary {
  final double totalAmount;
  final double totalPlatformFee;
  final double totalNetAmount;
  final int totalDonations;
  final int totalDonors;
  final Map<String, double> donationsByMonth;
  final Map<String, int> donationsByMethod;

  DonationSummary({
    required this.totalAmount,
    required this.totalPlatformFee,
    required this.totalNetAmount,
    required this.totalDonations,
    required this.totalDonors,
    required this.donationsByMonth,
    required this.donationsByMethod,
  });

  factory DonationSummary.fromJson(Map<String, dynamic> json) {
    return DonationSummary(
      totalAmount: json['total_amount'].toDouble(),
      totalPlatformFee: json['total_platform_fee'].toDouble(),
      totalNetAmount: json['total_net_amount'].toDouble(),
      totalDonations: json['total_donations'],
      totalDonors: json['total_donors'],
      donationsByMonth: Map<String, double>.from(json['donations_by_month'] ?? {}),
      donationsByMethod: Map<String, int>.from(json['donations_by_method'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_amount': totalAmount,
      'total_platform_fee': totalPlatformFee,
      'total_net_amount': totalNetAmount,
      'total_donations': totalDonations,
      'total_donors': totalDonors,
      'donations_by_month': donationsByMonth,
      'donations_by_method': donationsByMethod,
    };
  }
}
