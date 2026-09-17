import 'package:dio/dio.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:taska_admin/core/providers/network_providers.dart';

import '../models/clients/admin_management/admin_audit_log_item.dart';
import '../models/clients/admin_management/admin_invitation_item.dart';
import '../models/clients/admin_management/change_admin_role_request.dart';
import '../models/clients/admin_management/invite_admin_request.dart';
import '../models/clients/auth/admin_user.dart';
import '../models/clients/base_response.dart';

part 'admin_management_client.g.dart';

final adminManagementClientProvider = Provider<AdminManagementClient>((ref) {
  final dio = ref.watch(dioProvider);
  return AdminManagementClient(dio);
});

@RestApi(baseUrl: '/api/v1')
abstract class AdminManagementClient {
  factory AdminManagementClient(Dio dio, {String baseUrl}) = _AdminManagementClient;

  /// Invite a new administrator account.
  @POST('/admin/users/invite')
  Future<BaseApiResponse<dynamic>> inviteAdmin(
    @Body() InviteAdminRequest request,
  );

  /// List admin invitations with pagination.
  @GET('/admin/users/invitations')
  Future<BaseApiResponse<PaginatedData<AdminInvitationItem>>> listInvitations({
    @Query('email') String? email,
    @Query('status') String? status,
    @Query('page') int? page,
    @Query('per_page') int? perPage,
  });

  /// Resend an admin invitation by issuing a new token.
  @POST('/admin/users/invitations/{invitation_id}/resend')
  Future<BaseApiResponse<dynamic>> resendInvitation(
    @Path('invitation_id') String invitationId,
  );

  /// Revoke an active admin invitation.
  @POST('/admin/users/invitations/{invitation_id}/revoke')
  Future<BaseApiResponse<dynamic>> revokeInvitation(
    @Path('invitation_id') String invitationId,
  );

  /// List administrators with filtering by email, fullname, role, active status, region_id, and hierarchy permissions.
  @GET('/admin/users')
  Future<BaseApiResponse<PaginatedData<AdminUser>>> listAdmins({
    @Query('email') String? email,
    @Query('fullname') String? fullname,
    @Query('role') String? role,
    @Query('is_active') bool? isActive,
    @Query('region_id') String? regionId,
    @Query('page') int? page,
    @Query('per_page') int? perPage,
  });

  /// Fetch administrator detail by ID.
  @GET('/admin/users/{admin_id}')
  Future<BaseApiResponse<AdminUser>> getAdminDetail(
    @Path('admin_id') String adminId,
  );

  /// Promote or demote an administrator's role.
  @PATCH('/admin/users/{admin_id}/role')
  Future<BaseApiResponse<dynamic>> changeAdminRole(
    @Path('admin_id') String adminId,
    @Body() ChangeAdminRoleRequest request,
  );

  /// Deactivate an administrator account.
  @POST('/admin/users/{admin_id}/deactivate')
  Future<BaseApiResponse<dynamic>> deactivateAdmin(
    @Path('admin_id') String adminId,
  );

  /// Reactivate a deactivated administrator account.
  @POST('/admin/users/{admin_id}/reactivate')
  Future<BaseApiResponse<dynamic>> reactivateAdmin(
    @Path('admin_id') String adminId,
  );

  /// Query immutable admin audit logs with pagination.
  @GET('/admin/audit/logs')
  Future<BaseApiResponse<PaginatedData<AdminAuditLogItem>>> listAuditLogs({
    @Query('admin_id') String? adminId,
    @Query('resource_type') String? resourceType,
    @Query('resource_id') String? resourceId,
    @Query('action') String? action,
    @Query('page') int? page,
    @Query('per_page') int? perPage,
  });
}
