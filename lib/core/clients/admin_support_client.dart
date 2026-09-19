import 'package:dio/dio.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:taska_admin/core/providers/network_providers.dart';

import '../models/clients/base_response.dart';
import '../models/clients/support/admin_add_support_internal_note_body.dart';
import '../models/clients/support/admin_assign_support_case_body.dart';
import '../models/clients/support/admin_resolve_support_case_body.dart';
import '../models/clients/support/admin_send_support_message_body.dart';
import '../models/clients/support/admin_support_case_detail.dart';
import '../models/clients/support/admin_support_case_item.dart';
import '../models/clients/support/admin_support_message_item.dart';
import '../models/clients/support/admin_support_timeline_item.dart';
import '../models/clients/support/admin_update_support_case_body.dart';

part 'admin_support_client.g.dart';

final adminSupportClientProvider = Provider<AdminSupportClient>((ref) {
  final dio = ref.watch(dioProvider);
  return AdminSupportClient(dio);
});

@RestApi(baseUrl: '/api/v1')
abstract class AdminSupportClient {
  factory AdminSupportClient(Dio dio, {String baseUrl}) = _AdminSupportClient;

  @GET('/admin/support/cases')
  Future<BaseApiResponse<PaginatedData<AdminSupportCaseItem>>> listCases({
    @Query('page') int? page,
    @Query('per_page') int? perPage,
    @Query('status') List<String>? status,
    @Query('priority') String? priority,
    @Query('type') String? type,
    @Query('assigned_agent_id') String? assignedAgentId,
    @Query('customer_id') String? customerId,
    @Query('provider_id') String? providerId,
    @Query('task_id') String? taskId,
    @Query('search') String? search,
  });

  @GET('/admin/support/cases/my-cases')
  Future<BaseApiResponse<PaginatedData<AdminSupportCaseItem>>> listAssignedCases({
    @Query('page') int? page,
    @Query('per_page') int? perPage,
    @Query('status') List<String>? status,
    @Query('priority') String? priority,
    @Query('type') String? type,
    @Query('search') String? search,
  });

  @GET('/admin/support/cases/{case_id}')
  Future<BaseApiResponse<AdminSupportCaseDetail>> getCase(
    @Path('case_id') String caseId,
  );

  @PATCH('/admin/support/cases/{case_id}')
  Future<BaseApiResponse<dynamic>> updateCase(
    @Path('case_id') String caseId,
    @Body() AdminUpdateSupportCaseBody body,
  );

  @GET('/admin/support/cases/{case_id}/messages')
  Future<BaseApiResponse<PaginatedData<AdminSupportMessageItem>>> getMessages(
    @Path('case_id') String caseId, {
    @Query('page') int? page,
    @Query('per_page') int? perPage,
  });

  @POST('/admin/support/cases/{case_id}/messages')
  Future<BaseApiResponse<dynamic>> sendMessage(
    @Path('case_id') String caseId,
    @Body() AdminSendSupportMessageBody body,
  );

  @GET('/admin/support/cases/{case_id}/timeline')
  Future<BaseApiResponse<PaginatedData<AdminSupportTimelineItem>>> getTimeline(
    @Path('case_id') String caseId, {
    @Query('page') int? page,
    @Query('per_page') int? perPage,
  });

  @POST('/admin/support/cases/{case_id}/claim')
  Future<BaseApiResponse<dynamic>> claimCase(
    @Path('case_id') String caseId,
  );

  @POST('/admin/support/cases/{case_id}/assign')
  Future<BaseApiResponse<dynamic>> assignCase(
    @Path('case_id') String caseId,
    @Body() AdminAssignSupportCaseBody body,
  );

  @POST('/admin/support/cases/{case_id}/attachments')
  @MultiPart()
  Future<BaseApiResponse<dynamic>> uploadAttachment(
    @Path('case_id') String caseId,
    @Part() MultipartFile file,
  );

  @POST('/admin/support/cases/{case_id}/notes')
  Future<BaseApiResponse<dynamic>> addInternalNote(
    @Path('case_id') String caseId,
    @Body() AdminAddSupportInternalNoteBody body,
  );

  @POST('/admin/support/cases/{case_id}/resolve')
  Future<BaseApiResponse<dynamic>> resolveCase(
    @Path('case_id') String caseId,
    @Body() AdminResolveSupportCaseBody body,
  );

  @POST('/admin/support/cases/{case_id}/escalate')
  Future<BaseApiResponse<dynamic>> escalateCase(
    @Path('case_id') String caseId,
  );
}
