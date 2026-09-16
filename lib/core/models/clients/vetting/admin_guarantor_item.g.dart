// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_guarantor_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminGuarantorItem _$AdminGuarantorItemFromJson(Map<String, dynamic> json) =>
    AdminGuarantorItem(
      id: json['id'] as String?,
      providerId: json['provider_id'] as String?,
      guarantorName: json['guarantor_name'] as String?,
      guarantorPhone: json['guarantor_phone'] as String?,
      relationship: json['relationship'] as String?,
      status: json['status'] as String?,
      metaData: json['meta_data'] as Map<String, dynamic>?,
      verifiedAt: json['verified_at'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$AdminGuarantorItemToJson(AdminGuarantorItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'provider_id': instance.providerId,
      'guarantor_name': instance.guarantorName,
      'guarantor_phone': instance.guarantorPhone,
      'relationship': instance.relationship,
      'status': instance.status,
      'meta_data': instance.metaData,
      'verified_at': instance.verifiedAt,
      'created_at': instance.createdAt,
    };
