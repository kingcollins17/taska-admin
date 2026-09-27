// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_payments_client.dart';

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter

class _AdminPaymentsClient implements AdminPaymentsClient {
  _AdminPaymentsClient(this._dio, {this.baseUrl, this.errorLogger}) {
    baseUrl ??= '/api/v1';
  }

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<BaseApiResponse<PaginatedData<AdminTransactionItem>>>
  listTransactions({
    String? id,
    String? userId,
    String? taskId,
    String? transactionType,
    String? status,
    String? reference,
    int? page,
    int? perPage,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'id': id,
      r'user_id': userId,
      r'task_id': taskId,
      r'transaction_type': transactionType,
      r'status': status,
      r'reference': reference,
      r'page': page,
      r'per_page': perPage,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<BaseApiResponse<PaginatedData<AdminTransactionItem>>>(
          Options(method: 'GET', headers: _headers, extra: _extra)
              .compose(
                _dio.options,
                '/admin/payments/transactions',
                queryParameters: queryParameters,
                data: _data,
              )
              .copyWith(
                baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
              ),
        );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late BaseApiResponse<PaginatedData<AdminTransactionItem>> _value;
    try {
      _value = BaseApiResponse<PaginatedData<AdminTransactionItem>>.fromJson(
        _result.data!,
        (json) => PaginatedData<AdminTransactionItem>.fromJson(
          json as Map<String, dynamic>,
          (json) => AdminTransactionItem.fromJson(json as Map<String, dynamic>),
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<BaseApiResponse<PaginatedData<AdminPayoutItem>>> listPayouts({
    String? id,
    String? providerId,
    String? customerId,
    String? taskId,
    String? status,
    String? reference,
    int? page,
    int? perPage,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'id': id,
      r'provider_id': providerId,
      r'customer_id': customerId,
      r'task_id': taskId,
      r'status': status,
      r'reference': reference,
      r'page': page,
      r'per_page': perPage,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<BaseApiResponse<PaginatedData<AdminPayoutItem>>>(
          Options(method: 'GET', headers: _headers, extra: _extra)
              .compose(
                _dio.options,
                '/admin/payments/payouts',
                queryParameters: queryParameters,
                data: _data,
              )
              .copyWith(
                baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
              ),
        );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late BaseApiResponse<PaginatedData<AdminPayoutItem>> _value;
    try {
      _value = BaseApiResponse<PaginatedData<AdminPayoutItem>>.fromJson(
        _result.data!,
        (json) => PaginatedData<AdminPayoutItem>.fromJson(
          json as Map<String, dynamic>,
          (json) => AdminPayoutItem.fromJson(json as Map<String, dynamic>),
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<BaseApiResponse<dynamic>> transferPayout(String payoutId) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<BaseApiResponse<dynamic>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/admin/payments/payouts/${payoutId}/transfer',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late BaseApiResponse<dynamic> _value;
    try {
      _value = BaseApiResponse<dynamic>.fromJson(
        _result.data!,
        (json) => json as dynamic,
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
