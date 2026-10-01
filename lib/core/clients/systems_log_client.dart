import 'package:dio/dio.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:retrofit/retrofit.dart';

import '../models/clients/base_response.dart';
import '../models/clients/system_logs/system_log_item.dart';
import '../models/clients/system_logs/system_log_metric_item.dart';
import '../models/clients/system_logs/system_log_stats.dart';
import '../providers/network_providers.dart';

part 'systems_log_client.g.dart';

final systemsLogClientProvider = Provider<SystemsLogClient>((ref) {
  final dio = ref.watch(dioProvider);
  return SystemsLogClient(dio);
});

@RestApi(baseUrl: '/api/v1')
abstract class SystemsLogClient {
  factory SystemsLogClient(Dio dio, {String baseUrl}) = _SystemsLogClient;

  /// Retrieve system logs with optional filtering and pagination.
  @GET('/system/logs')
  Future<BaseApiResponse<PaginatedData<SystemLogItem>>> getSystemLogs({
    @Query('level') String? level,
    @Query('source') String? source,
    @Query('page') int? page,
    @Query('per_page') int? perPage,
  });

  /// Retrieve system log statistics grouped by log level.
  @GET('/system/logs/stats')
  Future<BaseApiResponse<SystemLogStats>> getLogStats();

  /// Retrieve system metrics summary grouped by source with pagination.
  @GET('/system/logs/metrics')
  Future<BaseApiResponse<PaginatedData<SystemLogMetricItem>>> getMetricsSummary({
    @Query('page') int? page,
    @Query('per_page') int? perPage,
  });
}
