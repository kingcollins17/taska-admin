import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../clients/admin_tasks_management_client.dart';
import '../models/clients/base_response.dart';
import '../models/clients/tasks/admin_task_detail.dart';
import '../models/clients/tasks/admin_task_item.dart';

class ListTasksParams {
  final int? page;
  final int? perPage;
  final List<String>? status;
  final String? categoryId;
  final String? serviceId;
  final String? search;
  final num? latitude;
  final num? longitude;
  final num? radiusKm;
  final String? sortBy;
  final bool? sortDesc;
  final String? regionId;
  final String? scheduledStartAt;
  final String? expiresAt;
  final String? customerId;

  const ListTasksParams({
    this.page,
    this.perPage,
    this.status,
    this.categoryId,
    this.serviceId,
    this.search,
    this.latitude,
    this.longitude,
    this.radiusKm,
    this.sortBy,
    this.sortDesc,
    this.regionId,
    this.scheduledStartAt,
    this.expiresAt,
    this.customerId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListTasksParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          perPage == other.perPage &&
          _listEquals(status, other.status) &&
          categoryId == other.categoryId &&
          serviceId == other.serviceId &&
          search == other.search &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          radiusKm == other.radiusKm &&
          sortBy == other.sortBy &&
          sortDesc == other.sortDesc &&
          regionId == other.regionId &&
          scheduledStartAt == other.scheduledStartAt &&
          expiresAt == other.expiresAt &&
          customerId == other.customerId;

  static bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        page,
        perPage,
        Object.hashAll(status ?? []),
        categoryId,
        serviceId,
        search,
        latitude,
        longitude,
        radiusKm,
        sortBy,
        sortDesc,
        regionId,
        scheduledStartAt,
        expiresAt,
        customerId,
      );
}

final listTasksProvider =
    FutureProvider.family<PaginatedData<AdminTaskItem>?, ListTasksParams>(
  (ref, params) async {
    final client = ref.watch(adminTasksManagementClientProvider);
    final response = await client.listTasks(
      page: params.page ?? 1,
      perPage: params.perPage ?? 20,
      status: params.status,
      categoryId: params.categoryId,
      serviceId: params.serviceId,
      search: params.search,
      latitude: params.latitude,
      longitude: params.longitude,
      radiusKm: params.radiusKm,
      sortBy: params.sortBy,
      sortDesc: params.sortDesc,
      regionId: params.regionId,
      scheduledStartAt: params.scheduledStartAt,
      expiresAt: params.expiresAt,
      customerId: params.customerId,
    );
    return response.data;
  },
);

final adminTaskDetailProvider =
    FutureProvider.family<AdminTaskDetail?, String>(
  (ref, taskId) async {
    final client = ref.watch(adminTasksManagementClientProvider);
    final response = await client.getTaskDetail(taskId);
    return response.data;
  },
);

class AdminTaskStats {
  final int total;
  final int completed;
  final int open;
  final int cancelled;

  const AdminTaskStats({
    required this.total,
    required this.completed,
    required this.open,
    required this.cancelled,
  });
}

final adminTaskStatsProvider = FutureProvider<AdminTaskStats?>((ref) async {
  final client = ref.watch(adminTasksManagementClientProvider);
  try {
    final results = await Future.wait([
      client.listTasks(perPage: 1),
      client.listTasks(perPage: 1, status: ['COMPLETED']),
      client.listTasks(perPage: 1, status: ['CANCELLED']),
      client.listTasks(perPage: 1, status: ['POSTED', 'ASSIGNED', 'IN_PROGRESS', 'PENDING', 'DRAFT']),
    ]);

    final total = results[0].data?.total ?? 0;
    final completed = results[1].data?.total ?? 0;
    final cancelled = results[2].data?.total ?? 0;
    final open = results[3].data?.total ?? (total - completed - cancelled);

    return AdminTaskStats(
      total: total,
      completed: completed,
      open: open,
      cancelled: cancelled,
    );
  } catch (e) {
    return const AdminTaskStats(
      total: 0,
      completed: 0,
      open: 0,
      cancelled: 0,
    );
  }
});
