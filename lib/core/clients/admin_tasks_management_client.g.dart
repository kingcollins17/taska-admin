// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_tasks_management_client.dart';

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter

class _AdminTasksManagementClient implements AdminTasksManagementClient {
  _AdminTasksManagementClient(this._dio, {this.baseUrl, this.errorLogger}) {
    baseUrl ??= '/api/v1';
  }

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<BaseApiResponse<PaginatedData<AdminTaskItem>>> listTasks({
    int? page,
    int? perPage,
    List<String>? status,
    String? categoryId,
    String? serviceId,
    String? search,
    num? latitude,
    num? longitude,
    num? radiusKm,
    String? sortBy,
    bool? sortDesc,
    String? regionId,
    String? scheduledStartAt,
    String? expiresAt,
    String? customerId,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'page': page,
      r'per_page': perPage,
      r'status': status,
      r'category_id': categoryId,
      r'service_id': serviceId,
      r'search': search,
      r'latitude': latitude,
      r'longitude': longitude,
      r'radius_km': radiusKm,
      r'sort_by': sortBy,
      r'sort_desc': sortDesc,
      r'region_id': regionId,
      r'scheduled_start_at': scheduledStartAt,
      r'expires_at': expiresAt,
      r'customer_id': customerId,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<BaseApiResponse<PaginatedData<AdminTaskItem>>>(
          Options(method: 'GET', headers: _headers, extra: _extra)
              .compose(
                _dio.options,
                '/tasks',
                queryParameters: queryParameters,
                data: _data,
              )
              .copyWith(
                baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
              ),
        );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late BaseApiResponse<PaginatedData<AdminTaskItem>> _value;
    try {
      _value = BaseApiResponse<PaginatedData<AdminTaskItem>>.fromJson(
        _result.data!,
        (json) => PaginatedData<AdminTaskItem>.fromJson(
          json as Map<String, dynamic>,
          (json) => AdminTaskItem.fromJson(json as Map<String, dynamic>),
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<BaseApiResponse<AdminTaskDetail>> getTaskDetail(String taskId) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<BaseApiResponse<AdminTaskDetail>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/tasks/${taskId}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late BaseApiResponse<AdminTaskDetail> _value;
    try {
      _value = BaseApiResponse<AdminTaskDetail>.fromJson(
        _result.data!,
        (json) => AdminTaskDetail.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}

// dart format on
