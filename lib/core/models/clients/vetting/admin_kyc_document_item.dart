import 'package:json_annotation/json_annotation.dart';

part 'admin_kyc_document_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminKycDocumentItem {
  final String? id;
  final String? userId;
  final String? providerProfileId;
  final String? idType;
  final String? idNumber;
  final String? idDocUrl;
  final String? status;
  final String? rejectionReason;
  final int? attemptNumber;
  final Map<String, dynamic>? metaData;
  final String? submittedAt;
  final String? reviewedAt;
  final String? createdAt;
  final String? updatedAt;

  const AdminKycDocumentItem({
    this.id,
    this.userId,
    this.providerProfileId,
    this.idType,
    this.idNumber,
    this.idDocUrl,
    this.status,
    this.rejectionReason,
    this.attemptNumber,
    this.metaData,
    this.submittedAt,
    this.reviewedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminKycDocumentItem.fromJson(Map<String, dynamic> json) =>
      _$AdminKycDocumentItemFromJson(json);

  Map<String, dynamic> toJson() => _$AdminKycDocumentItemToJson(this);
}
