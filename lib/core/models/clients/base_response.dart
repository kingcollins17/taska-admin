import 'package:json_annotation/json_annotation.dart';

part 'base_response.g.dart';

@JsonSerializable(genericArgumentFactories: true, explicitToJson: true, fieldRename: FieldRename.snake)
class BaseApiResponse<T> {
  final String? detail;
  final String? message;
  final T? data;
  final int? statusCode;

  const BaseApiResponse({
    this.detail,
    this.message,
    this.data,
    this.statusCode,
  });

  factory BaseApiResponse.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$BaseApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$BaseApiResponseToJson(this, toJsonT);
}

@JsonSerializable(genericArgumentFactories: true, explicitToJson: true, fieldRename: FieldRename.snake)
class PaginatedData<T> {
  final List<T>? items;
  final int? page;
  final int? perPage;

  const PaginatedData({
    this.items,
    this.page,
    this.perPage,
  });

  factory PaginatedData.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$PaginatedDataFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PaginatedDataToJson(this, toJsonT);
}