// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_reject_vetting_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminRejectVettingBody _$AdminRejectVettingBodyFromJson(
  Map<String, dynamic> json,
) => AdminRejectVettingBody(
  reason: json['reason'] as String,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$AdminRejectVettingBodyToJson(
  AdminRejectVettingBody instance,
) => <String, dynamic>{'reason': instance.reason, 'notes': instance.notes};
