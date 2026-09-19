import 'package:dio/dio.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:taska_admin/core/providers/network_providers.dart';

import '../models/clients/base_response.dart';
import '../models/clients/dashboard/admin_dashboard_overview.dart';
import '../models/clients/dashboard/admin_guarantor_stats.dart';
import '../models/clients/dashboard/admin_interview_stats.dart';
import '../models/clients/dashboard/admin_kyc_stats.dart';
import '../models/clients/dashboard/admin_user_stats.dart';
import '../models/clients/users/admin_platform_user_item.dart';
import '../models/clients/users/admin_user_detail.dart';
import '../models/clients/users/admin_user_status_update_body.dart';
import '../models/clients/vetting/admin_approve_vetting_body.dart';
import '../models/clients/vetting/admin_guarantor_item.dart';
import '../models/clients/vetting/admin_interview_item.dart';
import '../models/clients/vetting/admin_kyc_document_item.dart';
import '../models/clients/vetting/admin_reject_vetting_body.dart';
import '../models/clients/vetting/admin_schedule_interview_body.dart';
import '../models/clients/vetting/admin_update_interview_status_body.dart';

part 'admin_user_client.g.dart';

final adminUserClientProvider = Provider<AdminUserClient>((ref) {
  final dio = ref.watch(dioProvider);
  return AdminUserClient(dio);
});

@RestApi(baseUrl: '/api/v1')
abstract class AdminUserClient {
  factory AdminUserClient(Dio dio, {String baseUrl}) = _AdminUserClient;

  @GET('/admin/dashboard/overview')
  Future<BaseApiResponse<AdminDashboardOverview>> getDashboardOverview();

  @GET('/admin/dashboard/user-stats')
  Future<BaseApiResponse<AdminUserStats>> getUserStats();

  @GET('/admin/dashboard/kyc-stats')
  Future<BaseApiResponse<AdminKycStats>> getKycStats();

  @GET('/admin/dashboard/guarantor-stats')
  Future<BaseApiResponse<AdminGuarantorStats>> getGuarantorStats();

  @GET('/admin/dashboard/interview-stats')
  Future<BaseApiResponse<AdminInterviewStats>> getInterviewStats();

  @GET('/users/admin')
  Future<BaseApiResponse<PaginatedData<AdminPlatformUserItem>>> getUsers({
    @Query('email') String? email,
    @Query('phone_number') String? phoneNumber,
    @Query('name') String? name,
    @Query('role') String? role,
    @Query('is_active') bool? isActive,
    @Query('region_id') String? regionId,
    @Query('page') int? page,
    @Query('per_page') int? perPage,
  });

  @GET('/users/admin/{user_id}')
  Future<BaseApiResponse<AdminUserDetail>> getUserDetail(
    @Path('user_id') String userId,
  );

  @POST('/users/admin/{user_id}/activate')
  Future<BaseApiResponse<dynamic>> activateUser(
    @Path('user_id') String userId,
    @Body() AdminUserStatusUpdateBody body,
  );

  @POST('/users/admin/{user_id}/deactivate')
  Future<BaseApiResponse<dynamic>> deactivateUser(
    @Path('user_id') String userId,
    @Body() AdminUserStatusUpdateBody body,
  );

  @GET('/vetting/admin/kyc-documents')
  Future<BaseApiResponse<PaginatedData<AdminKycDocumentItem>>> getKycDocuments({
    @Query('user_id') String? userId,
    @Query('document_id') String? documentId,
    @Query('provider_profile_id') String? providerProfileId,
    @Query('id_type') String? idType,
    @Query('id_number') String? idNumber,
    @Query('status') String? status,
    @Query('attempt_number') int? attemptNumber,
    @Query('search') String? search,
    @Query('submitted_from') String? submittedFrom,
    @Query('submitted_to') String? submittedTo,
    @Query('reviewed_from') String? reviewedFrom,
    @Query('reviewed_to') String? reviewedTo,
    @Query('created_from') String? createdFrom,
    @Query('created_to') String? createdTo,
    @Query('page') int? page,
    @Query('per_page') int? perPage,
    @Query('sort_by') String? sortBy,
    @Query('order') String? order,
  });

  @GET('/vetting/admin/guarantors')
  Future<BaseApiResponse<PaginatedData<AdminGuarantorItem>>> getGuarantors({
    @Query('provider_id') String? providerId,
    @Query('guarantor_id') String? guarantorId,
    @Query('status') String? status,
    @Query('guarantor_name') String? guarantorName,
    @Query('guarantor_phone') String? guarantorPhone,
    @Query('relationship') String? relationship,
    @Query('search') String? search,
    @Query('created_from') String? createdFrom,
    @Query('created_to') String? createdTo,
    @Query('verified_from') String? verifiedFrom,
    @Query('verified_to') String? verifiedTo,
    @Query('page') int? page,
    @Query('per_page') int? perPage,
    @Query('sort_by') String? sortBy,
    @Query('order') String? order,
  });

  @GET('/vetting/admin/interviews')
  Future<BaseApiResponse<PaginatedData<AdminInterviewItem>>> getInterviews({
    @Query('user_id') String? userId,
    @Query('admin_id') String? adminId,
    @Query('status') String? status,
    @Query('meeting_link') String? meetingLink,
    @Query('notes') String? notes,
    @Query('search') String? search,
    @Query('scheduled_from') String? scheduledFrom,
    @Query('scheduled_to') String? scheduledTo,
    @Query('passed_from') String? passedFrom,
    @Query('passed_to') String? passedTo,
    @Query('created_from') String? createdFrom,
    @Query('created_to') String? createdTo,
    @Query('page') int? page,
    @Query('per_page') int? perPage,
    @Query('sort_by') String? sortBy,
    @Query('order') String? order,
  });

  @POST('/vetting/admin/guarantors/{guarantor_id}/approve')
  Future<BaseApiResponse<dynamic>> approveGuarantor(
    @Path('guarantor_id') String guarantorId,
    @Body() AdminApproveVettingBody body,
  );

  @POST('/vetting/admin/guarantors/{guarantor_id}/reject')
  Future<BaseApiResponse<dynamic>> rejectGuarantor(
    @Path('guarantor_id') String guarantorId,
    @Body() AdminRejectVettingBody body,
  );

  @POST('/vetting/admin/kyc/{user_id}/approve')
  Future<BaseApiResponse<dynamic>> approveKyc(
    @Path('user_id') String userId,
    @Body() AdminApproveVettingBody body,
  );

  @POST('/vetting/admin/kyc/{user_id}/reject')
  Future<BaseApiResponse<dynamic>> rejectKyc(
    @Path('user_id') String userId,
    @Body() AdminRejectVettingBody body,
  );

  @POST('/vetting/admin/interviews/schedule')
  Future<BaseApiResponse<dynamic>> scheduleInterview(
    @Body() AdminScheduleInterviewBody body,
  );

  @PUT('/vetting/admin/interviews/{interview_id}/status')
  Future<BaseApiResponse<dynamic>> updateInterviewStatus(
    @Path('interview_id') String interviewId,
    @Body() AdminUpdateInterviewStatusBody body,
  );
}