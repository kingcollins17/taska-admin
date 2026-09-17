import 'package:dio/dio.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../clients/admin_management_client.dart';
import '../models/clients/admin_management/admin_audit_log_item.dart';
import '../models/clients/admin_management/admin_invitation_item.dart';
import '../models/clients/admin_management/change_admin_role_request.dart';
import '../models/clients/admin_management/invite_admin_request.dart';
import '../models/clients/auth/admin_user.dart';
import '../models/clients/base_response.dart';
import '../utils/error_handler.dart';

class ListAdminsParams {
  final String? email;
  final String? fullname;
  final String? role;
  final bool? isActive;
  final String? regionId;
  final int? page;
  final int? perPage;

  const ListAdminsParams({
    this.email,
    this.fullname,
    this.role,
    this.isActive,
    this.regionId,
    this.page,
    this.perPage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListAdminsParams &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          fullname == other.fullname &&
          role == other.role &&
          isActive == other.isActive &&
          regionId == other.regionId &&
          page == other.page &&
          perPage == other.perPage;

  @override
  int get hashCode => Object.hash(
        email,
        fullname,
        role,
        isActive,
        regionId,
        page,
        perPage,
      );
}

class ListInvitationsParams {
  final String? email;
  final String? status;
  final int? page;
  final int? perPage;

  const ListInvitationsParams({
    this.email,
    this.status,
    this.page,
    this.perPage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListInvitationsParams &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          status == other.status &&
          page == other.page &&
          perPage == other.perPage;

  @override
  int get hashCode => Object.hash(email, status, page, perPage);
}

final listAdminsProvider =
    FutureProvider.family<PaginatedData<AdminUser>?, ListAdminsParams>(
  (ref, params) async {
    final client = ref.watch(adminManagementClientProvider);
    final response = await client.listAdmins(
      email: params.email,
      fullname: params.fullname,
      role: params.role,
      isActive: params.isActive,
      regionId: params.regionId,
      page: params.page ?? 1,
      perPage: params.perPage ?? 20,
    );
    return response.data;
  },
);

final adminManagementDetailProvider =
    FutureProvider.family<AdminUser?, String>(
  (ref, adminId) async {
    final client = ref.watch(adminManagementClientProvider);
    final response = await client.getAdminDetail(adminId);
    return response.data;
  },
);

final listInvitationsProvider =
    FutureProvider.family<PaginatedData<AdminInvitationItem>?, ListInvitationsParams>(
  (ref, params) async {
    final client = ref.watch(adminManagementClientProvider);
    final response = await client.listInvitations(
      email: params.email,
      status: params.status,
      page: params.page ?? 1,
      perPage: params.perPage ?? 20,
    );
    return response.data;
  },
);

class ListAuditLogsParams {
  final String? adminId;
  final String? resourceType;
  final String? resourceId;
  final String? action;
  final int? page;
  final int? perPage;

  const ListAuditLogsParams({
    this.adminId,
    this.resourceType,
    this.resourceId,
    this.action,
    this.page,
    this.perPage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListAuditLogsParams &&
          runtimeType == other.runtimeType &&
          adminId == other.adminId &&
          resourceType == other.resourceType &&
          resourceId == other.resourceId &&
          action == other.action &&
          page == other.page &&
          perPage == other.perPage;

  @override
  int get hashCode => Object.hash(
        adminId,
        resourceType,
        resourceId,
        action,
        page,
        perPage,
      );
}

final listAuditLogsProvider =
    FutureProvider.family<PaginatedData<AdminAuditLogItem>?, ListAuditLogsParams>(
  (ref, params) async {
    final client = ref.watch(adminManagementClientProvider);
    final response = await client.listAuditLogs(
      adminId: params.adminId,
      resourceType: params.resourceType,
      resourceId: params.resourceId,
      action: params.action,
      page: params.page ?? 1,
      perPage: params.perPage ?? 20,
    );
    return response.data;
  },
);

// ─────────────────────────────────────────────────────────────
// Admin Management Notifier
// ─────────────────────────────────────────────────────────────

final adminManagementProvider =
    AsyncNotifierProvider<AdminManagementNotifier, void>(AdminManagementNotifier.new);

class AdminManagementNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Invite a new administrator.
  Future<void> inviteAdmin(
    InviteAdminRequest request, {
    void Function(String message)? onSuccess,
    void Function(String message)? onError,
  }) async {
    try {
      final client = ref.read(adminManagementClientProvider);
      final response = await client.inviteAdmin(request);

      final successMsg = response.message ?? response.detail ?? 'Invitation sent successfully';
      onSuccess?.call(successMsg);
    } catch (e, stackTrace) {
      ErrorHandler.handle(e, stackTrace);
      final errorMsg = _extractErrorMessage(e);
      onError?.call(errorMsg);
    }
  }

  /// Resend an admin invitation.
  Future<void> resendInvitation(
    String invitationId, {
    void Function(String message)? onSuccess,
    void Function(String message)? onError,
  }) async {
    try {
      final client = ref.read(adminManagementClientProvider);
      final response = await client.resendInvitation(invitationId);

      final successMsg = response.message ?? response.detail ?? 'Invitation resent successfully';
      onSuccess?.call(successMsg);
    } catch (e, stackTrace) {
      ErrorHandler.handle(e, stackTrace);
      final errorMsg = _extractErrorMessage(e);
      onError?.call(errorMsg);
    }
  }

  /// Revoke an active admin invitation.
  Future<void> revokeInvitation(
    String invitationId, {
    void Function(String message)? onSuccess,
    void Function(String message)? onError,
  }) async {
    try {
      final client = ref.read(adminManagementClientProvider);
      final response = await client.revokeInvitation(invitationId);

      final successMsg = response.message ?? response.detail ?? 'Invitation revoked successfully';
      onSuccess?.call(successMsg);
    } catch (e, stackTrace) {
      ErrorHandler.handle(e, stackTrace);
      final errorMsg = _extractErrorMessage(e);
      onError?.call(errorMsg);
    }
  }

  /// Change an administrator's role.
  Future<void> changeAdminRole(
    String adminId,
    ChangeAdminRoleRequest request, {
    void Function(String message)? onSuccess,
    void Function(String message)? onError,
  }) async {
    try {
      final client = ref.read(adminManagementClientProvider);
      final response = await client.changeAdminRole(adminId, request);

      final successMsg = response.message ?? response.detail ?? 'Admin role updated successfully';
      onSuccess?.call(successMsg);
    } catch (e, stackTrace) {
      ErrorHandler.handle(e, stackTrace);
      final errorMsg = _extractErrorMessage(e);
      onError?.call(errorMsg);
    }
  }

  /// Deactivate an administrator account.
  Future<void> deactivateAdmin(
    String adminId, {
    void Function(String message)? onSuccess,
    void Function(String message)? onError,
  }) async {
    try {
      final client = ref.read(adminManagementClientProvider);
      final response = await client.deactivateAdmin(adminId);

      final successMsg = response.message ?? response.detail ?? 'Admin deactivated successfully';
      onSuccess?.call(successMsg);
    } catch (e, stackTrace) {
      ErrorHandler.handle(e, stackTrace);
      final errorMsg = _extractErrorMessage(e);
      onError?.call(errorMsg);
    }
  }

  /// Reactivate a deactivated administrator account.
  Future<void> reactivateAdmin(
    String adminId, {
    void Function(String message)? onSuccess,
    void Function(String message)? onError,
  }) async {
    try {
      final client = ref.read(adminManagementClientProvider);
      final response = await client.reactivateAdmin(adminId);

      final successMsg = response.message ?? response.detail ?? 'Admin reactivated successfully';
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
