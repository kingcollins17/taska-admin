// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'systems_log_client.dart';

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter

class _SystemsLogClient implements SystemsLogClient {
  _SystemsLogClient(this._dio, {this.baseUrl, this.errorLogger}) {
    baseUrl ??= '/api/v1';
  }

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<BaseApiResponse<PaginatedData<SystemLogItem>>> getSystemLogs({
    String? level,
    String? source,
    int? page,
    int? perPage,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'level': level,
      r'source': source,
      r'page': page,
      r'per_page': perPage,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<BaseApiResponse<PaginatedData<SystemLogItem>>>(
          Options(method: 'GET', headers: _headers, extra: _extra)
              .compose(
                _dio.options,
                '/system/logs',
                queryParameters: queryParameters,
                data: _data,
              )
              .copyWith(
                baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
              ),
        );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late BaseApiResponse<PaginatedData<SystemLogItem>> _value;
    try {
      _value = BaseApiResponse<PaginatedData<SystemLogItem>>.fromJson(
        _result.data!,
        (json) => PaginatedData<SystemLogItem>.fromJson(
          json as Map<String, dynamic>,
          (json) => SystemLogItem.fromJson(json as Map<String, dynamic>),
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<BaseApiResponse<SystemLogStats>> getLogStats() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<BaseApiResponse<SystemLogStats>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/system/logs/stats',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late BaseApiResponse<SystemLogStats> _value;
    try {
      _value = BaseApiResponse<SystemLogStats>.fromJson(
        _result.data!,
        (json) => SystemLogStats.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<BaseApiResponse<PaginatedData<SystemLogMetricItem>>>
  getMetricsSummary({int? page, int? perPage}) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'page': page,
      r'per_page': perPage,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<BaseApiResponse<PaginatedData<SystemLogMetricItem>>>(
          Options(method: 'GET', headers: _headers, extra: _extra)
              .compose(
                _dio.options,
                '/system/logs/metrics',
                queryParameters: queryParameters,
                data: _data,
              )
              .copyWith(
                baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
              ),
        );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late BaseApiResponse<PaginatedData<SystemLogMetricItem>> _value;
    try {
      _value = BaseApiResponse<PaginatedData<SystemLogMetricItem>>.fromJson(
        _result.data!,
        (json) => PaginatedData<SystemLogMetricItem>.fromJson(
          json as Map<String, dynamic>,
          (json) => SystemLogMetricItem.fromJson(json as Map<String, dynamic>),
        ),
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
