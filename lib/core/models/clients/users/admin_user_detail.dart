import 'package:json_annotation/json_annotation.dart';

part 'admin_user_detail.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class AdminUserDetail {
  final String? id;
  final String? email;
  final String? phoneNumber;
  final String? type;
  final bool? isActive;
  final bool? emailVerified;
  final bool? phoneVerified;
  final String? createdAt;
  final String? updatedAt;
  final String? regionId;
  final Map<String, dynamic>? metaData;
  final UserStats? stats;
  final CustomerProfile? customerProfile;
  final ProviderProfile? providerProfile;
  final List<dynamic>? devices;
  final UserLocation? location;
  final PaymentAccount? paymentAccount;

  const AdminUserDetail({
    this.id,
    this.email,
    this.phoneNumber,
    this.type,
    this.isActive,
    this.emailVerified,
    this.phoneVerified,
    this.createdAt,
    this.updatedAt,
    this.regionId,
    this.metaData,
    this.stats,
    this.customerProfile,
    this.providerProfile,
    this.devices,
    this.location,
    this.paymentAccount,
  });

  factory AdminUserDetail.fromJson(Map<String, dynamic> json) =>
      _$AdminUserDetailFromJson(json);

  Map<String, dynamic> toJson() => _$AdminUserDetailToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UserStats {
  final String? id;
  final String? userId;
  final num? credibilityScore;
  final num? averageRatings;
  final int? totalRatings;
  final num? acceptanceRate30d;
  final num? completionRate30d;
  final int? currentTier;
  final int? totalTasksCompleted;
  final int? totalTasksPosted;
  final int? consecutiveDeclines;
  final int? cancellationCount;

  const UserStats({
    this.id,
    this.userId,
    this.credibilityScore,
    this.averageRatings,
    this.totalRatings,
    this.acceptanceRate30d,
    this.completionRate30d,
    this.currentTier,
    this.totalTasksCompleted,
    this.totalTasksPosted,
    this.consecutiveDeclines,
    this.cancellationCount,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);

  Map<String, dynamic> toJson() => _$UserStatsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CustomerProfile {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? addressLine;

  const CustomerProfile({
    this.id,
    this.firstName,
    this.lastName,
    this.addressLine,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) =>
      _$CustomerProfileFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerProfileToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ProviderProfile {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? selfieUrl;
  final String? gender;
  final String? kycStatus;
  final String? providerReference;
  final num? livenessScore;
  final String? verifiedAt;
  final String? addressLine;
  final bool? isOnline;
  final String? dutyStatus;
  final String? lastHeartbeatAt;
  final List<dynamic>? services;
  final List<dynamic>? kycDocuments;

  const ProviderProfile({
    this.id,
    this.firstName,
    this.lastName,
    this.selfieUrl,
    this.gender,
    this.kycStatus,
    this.providerReference,
    this.livenessScore,
    this.verifiedAt,
    this.addressLine,
    this.isOnline,
    this.dutyStatus,
    this.lastHeartbeatAt,
    this.services,
    this.kycDocuments,
  });

  factory ProviderProfile.fromJson(Map<String, dynamic> json) =>
      _$ProviderProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderProfileToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UserLocation {
  final String? id;
  final String? userId;
  final String? regionId;
  final String? addressLine;
  final num? latitude;
  final num? longitude;
  final String? createdAt;
  final String? updatedAt;

  const UserLocation({
    this.id,
    this.userId,
    this.regionId,
    this.addressLine,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) =>
      _$UserLocationFromJson(json);

  Map<String, dynamic> toJson() => _$UserLocationToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class PaymentAccount {
  final String? id;
  final String? userId;
  final String? provider;
  final String? externalAccountId;
  final String? accountName;
  final Map<String, dynamic>? accountMetadata;
  final bool? isActive;

  const PaymentAccount({
    this.id,
    this.userId,
    this.provider,
    this.externalAccountId,
    this.accountName,
    this.accountMetadata,
    this.isActive,
  });

  factory PaymentAccount.fromJson(Map<String, dynamic> json) =>
      _$PaymentAccountFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentAccountToJson(this);
}
