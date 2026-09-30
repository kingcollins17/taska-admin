// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_cancel_task_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminCancelTaskRequest _$AdminCancelTaskRequestFromJson(
  Map<String, dynamic> json,
) => AdminCancelTaskRequest(
  cancellationReason: json['cancellation_reason'] as String?,
  cancellationPin: json['cancellation_pin'] as String?,
);

Map<String, dynamic> _$AdminCancelTaskRequestToJson(
  AdminCancelTaskRequest instance,
) => <String, dynamic>{
  'cancellation_reason': instance.cancellationReason,
  'cancellation_pin': instance.cancellationPin,
};
