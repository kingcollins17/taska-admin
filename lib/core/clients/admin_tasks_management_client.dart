import 'package:dio/dio.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:taska_admin/core/providers/network_providers.dart';

import '../models/clients/base_response.dart';
import '../models/clients/tasks/admin_cancel_task_request.dart';
import '../models/clients/tasks/admin_dispatch_attempt.dart';
import '../models/clients/tasks/admin_dispatch_session.dart';
import '../models/clients/tasks/admin_task_detail.dart';
import '../models/clients/tasks/admin_task_item.dart';
import '../models/clients/tasks/trigger_admin_redispatch_request.dart';

part 'admin_tasks_management_client.g.dart';

final adminTasksManagementClientProvider = Provider<AdminTasksManagementClient>((ref) {
  final dio = ref.watch(dioProvider);
  return AdminTasksManagementClient(dio);
});

@RestApi(baseUrl: '/api/v1')
abstract class AdminTasksManagementClient {
  factory AdminTasksManagementClient(Dio dio, {String baseUrl}) = _AdminTasksManagementClient;

  /// Retrieve a list of tasks matching the filters and coordinates.
  @GET('/tasks')
  Future<BaseApiResponse<PaginatedData<AdminTaskItem>>> listTasks({
    @Query('page') int? page,
    @Query('per_page') int? perPage,
    @Query('status') List<String>? status,
    @Query('category_id') String? categoryId,
    @Query('service_id') String? serviceId,
    @Query('search') String? search,
    @Query('task_id') String? taskId,
    @Query('id') String? id,
    @Query('name') String? name,
    @Query('title') String? title,
    @Query('latitude') num? latitude,
    @Query('longitude') num? longitude,
    @Query('radius_km') num? radiusKm,
    @Query('sort_by') String? sortBy,
    @Query('sort_desc') bool? sortDesc,
    @Query('region_id') String? regionId,
    @Query('scheduled_start_at') String? scheduledStartAt,
    @Query('expires_at') String? expiresAt,
    @Query('customer_id') String? customerId,
  });

  /// Retrieve details for a single task by ID.
  @GET('/tasks/{task_id}')
  Future<BaseApiResponse<AdminTaskDetail>> getTaskDetail(
    @Path('task_id') String taskId,
  );

  /// List dispatch sessions with optional query parameter filtering.
  @GET('/admin/tasks/dispatch-sessions')
  Future<BaseApiResponse<PaginatedData<AdminDispatchSession>>> listDispatchSessions({
    @Query('task_id') String? taskId,
    @Query('trigger') String? trigger,
    @Query('status') String? status,
    @Query('page') int? page,
    @Query('per_page') int? perPage,
  });

  /// List dispatch attempts for a task or dispatch session with query filtering and provider details.
  @GET('/admin/tasks/dispatch-attempts')
  Future<BaseApiResponse<PaginatedData<AdminDispatchAttempt>>> listDispatchAttempts({
    @Query('task_id') String? taskId,
    @Query('dispatch_session_id') String? dispatchSessionId,
    @Query('provider_id') String? providerId,
    @Query('status') String? status,
    @Query('page') int? page,
    @Query('per_page') int? perPage,
  });

  /// Trigger admin-initiated redispatch for a task.
  @POST('/admin/tasks/{task_id}/redispatch')
  Future<BaseApiResponse<dynamic>> triggerAdminRedispatch(
    @Path('task_id') String taskId,
    @Body() TriggerAdminRedispatchRequest request,
  );

  /// Cancel a task by an administrator.
  @POST('/admin/tasks/{task_id}/cancel')
  Future<BaseApiResponse<dynamic>> adminCancelTask(
    @Path('task_id') String taskId,
    @Body() AdminCancelTaskRequest request,
  );
}
