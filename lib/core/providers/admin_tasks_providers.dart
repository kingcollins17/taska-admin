import 'package:dio/dio.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../clients/admin_tasks_management_client.dart';
import '../models/clients/base_response.dart';
import '../models/clients/tasks/admin_cancel_task_request.dart';
import '../models/clients/tasks/admin_dispatch_attempt.dart';
import '../models/clients/tasks/admin_dispatch_session.dart';
import '../models/clients/tasks/admin_task_detail.dart';
import '../models/clients/tasks/admin_task_item.dart';
import '../models/clients/tasks/trigger_admin_redispatch_request.dart';
import '../utils/error_handler.dart';

class ListTasksParams {
  final int? page;
  final int? perPage;
  final List<String>? status;
  final String? categoryId;
  final String? serviceId;
  final String? search;
  final String? taskId;
  final String? name;
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
    this.taskId,
    this.name,
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
          taskId == other.taskId &&
          name == other.name &&
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
        taskId,
        name,
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

    String? taskId = params.taskId;
    String? name = params.name;
    String? categoryId = params.categoryId;
    String? serviceId = params.serviceId;
    String? search = params.search;

    if (search != null && search.trim().isNotEmpty) {
      final rawQuery = search.trim();
      final lower = rawQuery.toLowerCase();
      if (lower.startsWith('id:')) {
        taskId = rawQuery.substring(3).trim();
        search = null;
      } else if (lower.startsWith('name:')) {
        name = rawQuery.substring(5).trim();
        search = null;
      } else if (lower.startsWith('service:') || lower.startsWith('service_id:')) {
        final colonIdx = rawQuery.indexOf(':');
        serviceId = rawQuery.substring(colonIdx + 1).trim();
        search = null;
      } else if (lower.startsWith('category:') || lower.startsWith('category_id:')) {
        final colonIdx = rawQuery.indexOf(':');
        categoryId = rawQuery.substring(colonIdx + 1).trim();
        search = null;
      } else {
        search = rawQuery;
      }
    }

    final response = await client.listTasks(
      page: params.page ?? 1,
      perPage: params.perPage ?? 20,
      status: params.status,
      categoryId: (categoryId != null && categoryId.isNotEmpty) ? categoryId : null,
      serviceId: (serviceId != null && serviceId.isNotEmpty) ? serviceId : null,
      search: search,
      taskId: (taskId != null && taskId.isNotEmpty) ? taskId : null,
      id: (taskId != null && taskId.isNotEmpty) ? taskId : null,
      name: (name != null && name.isNotEmpty) ? name : null,
      title: (name != null && name.isNotEmpty) ? name : null,
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

class ListDispatchSessionsParams {
  final String? taskId;
  final String? trigger;
  final String? status;
  final int? page;
  final int? perPage;

  const ListDispatchSessionsParams({
    this.taskId,
    this.trigger,
    this.status,
    this.page,
    this.perPage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListDispatchSessionsParams &&
          runtimeType == other.runtimeType &&
          taskId == other.taskId &&
          trigger == other.trigger &&
          status == other.status &&
          page == other.page &&
          perPage == other.perPage;

  @override
  int get hashCode => Object.hash(taskId, trigger, status, page, perPage);
}

final listDispatchSessionsProvider = FutureProvider.family<
    PaginatedData<AdminDispatchSession>?, ListDispatchSessionsParams>(
  (ref, params) async {
    final client = ref.watch(adminTasksManagementClientProvider);
    final response = await client.listDispatchSessions(
      taskId: params.taskId,
      trigger: params.trigger,
      status: params.status,
      page: params.page ?? 1,
      perPage: params.perPage ?? 20,
    );
    return response.data;
  },
);

class ListDispatchAttemptsParams {
  final String? taskId;
  final String? dispatchSessionId;
  final String? providerId;
  final String? status;
  final int? page;
  final int? perPage;

  const ListDispatchAttemptsParams({
    this.taskId,
    this.dispatchSessionId,
    this.providerId,
    this.status,
    this.page,
    this.perPage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListDispatchAttemptsParams &&
          runtimeType == other.runtimeType &&
          taskId == other.taskId &&
          dispatchSessionId == other.dispatchSessionId &&
          providerId == other.providerId &&
          status == other.status &&
          page == other.page &&
          perPage == other.perPage;

  @override
  int get hashCode => Object.hash(
        taskId,
        dispatchSessionId,
        providerId,
        status,
        page,
        perPage,
      );
}

final listDispatchAttemptsProvider = FutureProvider.family<
    PaginatedData<AdminDispatchAttempt>?, ListDispatchAttemptsParams>(
  (ref, params) async {
    final client = ref.watch(adminTasksManagementClientProvider);
    final response = await client.listDispatchAttempts(
      taskId: params.taskId,
      dispatchSessionId: params.dispatchSessionId,
      providerId: params.providerId,
      status: params.status,
      page: params.page ?? 1,
      perPage: params.perPage ?? 20,
    );
    return response.data;
  },
);

// ─────────────────────────────────────────────────────────────
// Admin Tasks Notifier
// ─────────────────────────────────────────────────────────────

final adminTasksProvider =
    AsyncNotifierProvider<AdminTasksNotifier, void>(AdminTasksNotifier.new);

class AdminTasksNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Trigger admin-initiated redispatch for a task.
  Future<void> triggerAdminRedispatch(
    String taskId,
    TriggerAdminRedispatchRequest request, {
    void Function(String message)? onSuccess,
    void Function(String message)? onError,
  }) async {
    try {
      final client = ref.read(adminTasksManagementClientProvider);
      final response = await client.triggerAdminRedispatch(taskId, request);

      final successMsg = response.message ??
          response.detail ??
          'Redispatch triggered successfully';
      onSuccess?.call(successMsg);
    } catch (e, stackTrace) {
      ErrorHandler.handle(e, stackTrace);
      final errorMsg = _extractErrorMessage(e);
      onError?.call(errorMsg);
    }
  }

  /// Cancel a task by an administrator.
  Future<void> adminCancelTask(
    String taskId,
    AdminCancelTaskRequest request, {
    void Function(String message)? onSuccess,
    void Function(String message)? onError,
  }) async {
    try {
      final client = ref.read(adminTasksManagementClientProvider);
      final response = await client.adminCancelTask(taskId, request);

      final successMsg =
          response.message ?? response.detail ?? 'Task cancelled successfully';
      onSuccess?.call(successMsg);
    } catch (e, stackTrace) {
      ErrorHandler.handle(e, stackTrace);
      final errorMsg = _extractErrorMessage(e);
      onError?.call(errorMsg);
    }
  }

  String _extractErrorMessage(dynamic e) {
    if (e is DioException && e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ??
            data['detail'] as String? ??
            e.message ??
            'An unexpected error occurred';
      }
    }
    return e.toString();
  }
}

