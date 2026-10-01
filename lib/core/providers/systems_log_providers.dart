import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../clients/systems_log_client.dart';
import '../models/clients/base_response.dart';
import '../models/clients/system_logs/system_log_item.dart';
import '../models/clients/system_logs/system_log_metric_item.dart';
import '../models/clients/system_logs/system_log_stats.dart';

class GetSystemLogsParams {
  final String? level;
  final String? source;
  final int? page;
  final int? perPage;

  const GetSystemLogsParams({
    this.level,
    this.source,
    this.page,
    this.perPage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetSystemLogsParams &&
          runtimeType == other.runtimeType &&
          level == other.level &&
          source == other.source &&
          page == other.page &&
          perPage == other.perPage;

  @override
  int get hashCode => Object.hash(level, source, page, perPage);
}

class GetMetricsSummaryParams {
  final int? page;
  final int? perPage;

  const GetMetricsSummaryParams({
    this.page,
    this.perPage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetMetricsSummaryParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          perPage == other.perPage;

  @override
  int get hashCode => Object.hash(page, perPage);
}

/// Provider to fetch system logs with optional filtering and pagination.
final getSystemLogsProvider =
    FutureProvider.family<PaginatedData<SystemLogItem>?, GetSystemLogsParams>(
  (ref, params) async {
    final client = ref.watch(systemsLogClientProvider);
    final response = await client.getSystemLogs(
      level: params.level,
      source: params.source,
      page: params.page ?? 1,
      perPage: params.perPage ?? 100,
    );
    return response.data;
  },
);

/// Provider to fetch system log statistics grouped by log level.
final getLogStatsProvider = FutureProvider<SystemLogStats?>((ref) async {
  final client = ref.watch(systemsLogClientProvider);
  final response = await client.getLogStats();
  return response.data;
});

/// Provider to fetch system metrics summary grouped by source with pagination.
final getMetricsSummaryProvider =
    FutureProvider.family<PaginatedData<SystemLogMetricItem>?, GetMetricsSummaryParams>(
  (ref, params) async {
    final client = ref.watch(systemsLogClientProvider);
    final response = await client.getMetricsSummary(
      page: params.page ?? 1,
      perPage: params.perPage ?? 100,
    );
    return response.data;
  },
);
